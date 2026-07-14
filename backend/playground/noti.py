from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, messaging

# 1. Initialize the Firebase Admin SDK
# Replace 'serviceAccountKey.json' with the actual path to your downloaded key
if not firebase_admin._apps:
    cred = credentials.Certificate("playground/serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

app = FastAPI(title="FCM Notification Server")


# 2. Define the Pydantic model for the request payload
class NotificationModel(BaseModel):
    device_token: str
    title: str
    body: str
    data: dict | None = None  # Optional custom data payload


# 3. Create the endpoint
@app.post("/send-notification/")
async def send_push_notification(notification: NotificationModel):
    try:
        # Construct the FCM message
        message = messaging.Message(
            notification=messaging.Notification(
                title=notification.title,
                body=notification.body,
            ),
            data=notification.data if notification.data else {},
            token=notification.device_token,
        )

        # Send the message via Firebase
        response = messaging.send(message)

        return {
            "status": "success",
            "message": "Notification sent successfully",
            "message_id": response,
        }

    except Exception as e:
        print(f"Failed to send notification: {str(e)}")
        # If the token is invalid or Firebase has an issue, return a 500 error
        raise HTTPException(
            status_code=500, detail=f"Failed to send notification: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("noti:app", host="0.0.0.0", port=8000, reload=True)
