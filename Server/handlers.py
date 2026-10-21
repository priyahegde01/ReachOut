# Contains all the functions that handle the different calls/messages that are communicated via the WebSocket.

from datetime import datetime, timedelta, timezone
from uuid import uuid4
import data_store
from data_store import users, requests, connected_users

def require_user(websocket):
    user_id = connected_users.get(websocket)
    if user_id is None:
        raise PermissionError("Register or log in before performing this action.")
    return user_id

async def handle_register_user(websocket, message):
    existing_ids =  {user["user_id"] for user in users}
    user_id = str(uuid4())
    while user_id in existing_ids:
        user_id = str(uuid4())

    new_user = {
        "user_id": user_id,
        "reward_points": 0,
        "raised_requests": [],
        "accepted_requests": [],
        "completed_requests": []
    }

    users.append(new_user)
    connected_users[websocket] = user_id

    return {
        "type": "user_registered",
        "message": "User registered successfully",
        "user_id":  new_user["user_id"]
    }

async def handle_create_request(websocket, message):
    data = message["data"]
    request_id = data_store.next_request_id
    data_store.next_request_id += 1
    user_id = require_user(websocket)

    new_request = {
        "request_id": request_id,
        "user_id": user_id,
        "description": data.get("description"),
        "location": data.get("location"),
        "status": "UNACCEPTED",
        "created_at": (datetime.now(timezone.utc)).isoformat(),
        "expires_at": (datetime.now(timezone.utc) + timedelta(minutes=5)).isoformat(),
        "accepted_by": None,
        "completed_at": None
    }

    requests.append(new_request)

    return {
        "type": "request_created",
        "message": "Request created successfully",
        "request_id": new_request["request_id"]
    }


async def handle_list_requests(websocket, message):
    require_user(websocket)
    return {
        "type": "list_requests",
        "requests": requests
    }

async def handle_accept_request(websocket, message):
    data = message["data"]
    request_id = data.get("request_id")
    user_id = require_user(websocket)

    for request in requests:
        if request["request_id"] == request_id:
            if request["status"] == "UNACCEPTED":
                request["status"] = "ACCEPTED"
                request["accepted_by"] = user_id
                return {
                    "type": "request_accepted",
                    "message": "Request accepted successfully",
                    "request_id": request_id
                }
            else:
                return {
                    "type": "error",
                    "message": f"Request {request_id} is not available for acceptance."
                }

    return {
        "type": "error",
        "message": f"Request {request_id} not found."
    }

async def handle_mark_request_as_complete(websocket, message):
    data = message["data"]
    request_id = data.get("request_id")
    user_id = require_user(websocket)

    for request in requests:
        if request["request_id"] == request_id:
            if request["status"] == "ACCEPTED" and request["user_id"] == user_id:
                request["status"] = "COMPLETED"
                request["completed_at"] = (datetime.now(timezone.utc)).isoformat()
                return {
                    "type": "request_completed",
                    "message": "Request marked as completed successfully",
                    "request_id": request_id
                }
            else:
                return {
                    "type": "error",
                    "message": f"Request {request_id} cannot be marked as completed by user {user_id}."
                }

    return {
        "type": "error",
        "message": f"Request {request_id} not found."
    }

async def handle_verify_user(websocket, message):
    data = message["data"]
    input_user_id = data.get("user_id")

    for user in users:
        if user["user_id"] == input_user_id:
            connected_users[websocket] = user["user_id"]
            return {
                "type": "user_verified",
                "message": "User verified successfully",
                "user_id": input_user_id
            }
        

    return {
        "type": "error",
        "message": f"User {input_user_id} not found."
    }


# Add cancel_request and user_details handlers here as needed
async def handle_cancel_request(websocket, message):
    pass

async def handle_user_details(websocket, message):
    pass