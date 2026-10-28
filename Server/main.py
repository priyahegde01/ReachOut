import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from data_store import requests, connected_users
from datetime import datetime, timezone
from handlers import *


async def global_expiry_cleaner():
    """Runs periodically in the background for the lifetime of the app."""
    try:
        while True:
            await asyncio.sleep(0.5)  # Run every 0.5 seconds
            await removeExpiredGlobally()
    except asyncio.CancelledError:
        pass


async def removeExpiredGlobally():
    """Checks and removes expired requests, then broadcasts to all users."""
    now = datetime.now(timezone.utc)
    active_requests = []
    changed = False

    for request in requests:
        expiryTime = datetime.fromisoformat(request["expires_at"])
        if expiryTime <= now:
            changed = True
        else:
            active_requests.append(request)

    if changed:
        requests[:] = active_requests
        # Broadcast to all currently connected users
        await broadcastRequestBoard()


async def broadcastRequestBoard():
    for connection in list(connected_users.keys()):
        try:
            await connection.send_json({
                "type": "list_requests",
                "data": {"requests": requests},
            })
        except Exception:
            # Handle dead/dropped connections gracefully
            pass


@asynccontextmanager
async def lifespan(app: FastAPI):
    # === STARTUP ===
    # Start the background task when the app boots up
    cleaner_task = asyncio.create_task(global_expiry_cleaner())
    yield
    # === SHUTDOWN ===
    # Cancel the background task and clean up when the app shuts down
    cleaner_task.cancel()
    try:
        await cleaner_task
    except asyncio.CancelledError:
        pass


# Register the lifespan handler in FastAPI
app = FastAPI(title="ReachOut API", lifespan=lifespan)


def isUpdate(operation: str):
    return operation in ["create_request", "accept_request", "mark_request_as_complete", "cancel_request"]


@app.websocket("/server")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            message = await websocket.receive_json()
            message_type = message.get("type")

            handler = {
                "register_user": handle_register_user,
                "create_request": handle_create_request,
                "list_requests": handle_list_requests,
                "accept_request": handle_accept_request,
                "mark_request_as_complete": handle_mark_request_as_complete,
                "cancel_request": handle_cancel_request,
                "user_details": handle_user_details,
                "verify_user": handle_verify_user,
            }.get(message_type)

            if handler is None:
                await websocket.send_json({
                    "type": "error",
                    "message": f"Unsupported message type: {message_type}"
                })
                continue
            try:
                result = handler(websocket, message)
            except PermissionError as exc:
                await websocket.send_json({
                    "type": "error",
                    "message": str(exc),
                })
                continue

            await websocket.send_json(result)
            if isUpdate(message_type):
                await broadcastRequestBoard()

    except WebSocketDisconnect:
        pass
    finally:
        connected_users.pop(websocket, None)
