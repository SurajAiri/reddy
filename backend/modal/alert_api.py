import json
import os
from typing import Annotated

import modal
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, messaging
from enum import Enum

# 1. Initialize the FastAPI app
web_app = FastAPI(title="Open Alert API")


class AlertAction(Enum):
    NONE = "NONE"  # ONLY SENDS NOTIFICATION
    RING = "RING"  # SENDS NOTIFICATION AND RINGS & VIBRATES THE DEVICE
    FORCE_RING_START = "FORCE_RING_START"  # SENDS NOTIFICATION AND FORCES THE DEVICE TO RING & VIBRATE IMMEDIATELY UNTIL USER STOPS IT
    FORCE_RING_STOP = "FORCE_RING_STOP"  # SENDS NOTIFICATION AND STOPS ANY ONGOING RINGING & VIBRATION CAUSED BY THIS ALERT OR A PREVIOUS ALERT WITH THE SAME ID
    RING_STOP = "RING_STOP"  # SENDS NOTIFICATION AND STOPS ANY ONGOING RINGING & VIBRATION CAUSED BY THIS ALERT OR A PREVIOUS ALERT WITH THE SAME ID


# 2. Define your FastAPI routes
@web_app.get("/")
async def root():
    return {"message": "Hello from Open Alert API!", "status": "Healthy"}


class Alert(BaseModel):
    title: str
    message: str
    priority: int  # 1 (low) to 5 (high)
    fcm_token: str  # Add FCM token to the alert model
    payload: dict = {}  # Optional additional data to send with the notification
    action: AlertAction = AlertAction.NONE  # Default to NONE if not provided


def _android_priority(priority: int, action: AlertAction):
    if action != AlertAction.NONE:
        return "high"
    if priority >= 4:
        return "high"
    return "normal"


async def send_push_notification(alert: Alert, fcm_token: str):
    try:
        payload = alert.payload or {}
        payload["priority"] = str(alert.priority)
        payload["action"] = (
            alert.action.value
        )  # Convert Enum to string for JSON serialization
        # Construct the FCM message
        message = messaging.Message(
            notification=messaging.Notification(
                title=alert.title,
                body=alert.message,
            ),
            data=payload,
            token=fcm_token,  # Send to a specific device using its FCM token
            android=messaging.AndroidConfig(
                priority=_android_priority(alert.priority, alert.action),
                ttl=None,  # or e.g. datetime.timedelta(minutes=5) if you want it to expire instead of queuing
            ),
        )
        print(f"sending message: {message}")

        # Send the message via Firebase
        response = messaging.send(message)

        print(f"Notification sent successfully, message ID: {response}")
    except Exception as e:
        print(f"Failed to send notification: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Failed to send notification: {str(e)}"
        )


@web_app.post("/alert")
async def receive_alert(
    alert: Alert,
    x_api_key: Annotated[str, Header()],
):
    # validate the sender x-api-key header (for security)
    if x_api_key != os.getenv("WEBHOOK_API_SECRET"):
        raise HTTPException(status_code=401, detail="Unauthorized")

    try:
        firebase_secret = os.getenv("FIREBASE_SECRET")
        if not firebase_secret:
            print("FIREBASE_SECRET not set, skipping notification")
            return {"status": "Alert received but notification skipped"}
        firebase_credential = json.loads(firebase_secret)
        cred = credentials.Certificate(firebase_credential)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)

        res = await send_push_notification(alert, alert.fcm_token)
        print(res)

        # Use model_dump() instead of dict() for Pydantic V2
        return {
            "status": "Alert received",
        }
    except Exception as e:
        print(f"Failed to process alert: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Failed to process alert: {str(e)}"
        )


# 3. Initialize the Modal App
app = modal.App("open-alert-fastapi-app")

# 4. Define the container image with necessary dependencies
# Adding pydantic explicitly is good practice, though fastapi usually pulls it in.
image = modal.Image.debian_slim().pip_install("fastapi", "pydantic", "firebase-admin")


# 5. Mount the FastAPI app to Modal using @modal.asgi_app()
@app.function(
    image=image, timeout=2 * 60, secrets=[modal.Secret.from_name("open-alerts")]
)  # Set a timeout of 2 minutes for the function
@modal.asgi_app()
def fastapi_app():
    # This function returns the FastAPI instance to Modal's web server
    return web_app
