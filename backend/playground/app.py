from typing import Annotated

from fastapi import FastAPI, Header

app = FastAPI()


@app.post("/echo")
async def echo(
    data: str,
    x_api_key: Annotated[str, Header()],
):
    return {
        "echo": data,
        "api_key": x_api_key,
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
