# Contains all the functions that handle the different calls/messages that are communicated via the WebSocket.

from datetime import datetime, timedelta, timezone
from uuid import uuid4
import data_store
from data_store import *

requestLifetime = timedelta(minutes=5)


def require_user(websocket):
    user_id = connected_users.get(websocket)
    if user_id is None:
        raise PermissionError(
            "Register or log in before performing this action.")
    return user_id


async def handle_verify_user(websocket, message):
    data = message["data"]
    input_user_id = data.get("user_id")

    for user in users:
        if user["user_id"] == input_user_id:
            connected_users[websocket] = input_user_id
            await send_user_points(websocket, "")
            return {
                "type": "Valid ID",
                "message": "User verified successfully",
                "data": {"user_id": input_user_id}
            }

    return {
        "type": "Invalid ID",
        "message": f"User {input_user_id} not found.",
        "data": {}
    }


async def handle_register_user(websocket, message):
    existing_ids = {user["user_id"] for user in users}
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

    await send_user_points(websocket, "")

    return {
        "type": "user_registered",
        "message": "User registered successfully",
        "data": {"user_id": new_user["user_id"]}
    }


async def handle_create_request(websocket, message):
    data = message["data"]
    request_id = data_store.next_request_id
    data_store.next_request_id += 1
    user_id = require_user(websocket)

    new_request = {
        "request_id": request_id,
        "user_id": user_id,
        "title": data.get("title"),
        "description": data.get("description"),
        "title": data.get("title"),
        "location": data.get("location"),
        "status": "UNACCEPTED",
        "created_at": (datetime.now(timezone.utc)).isoformat(),
        "expires_at": (datetime.now(timezone.utc) + requestLifetime).isoformat(),
        "accepted_by": None,
        "completed_at": None
    }

    requests.append(new_request)

    return {
        "type": "request_created",
        "message": "Request created successfully",
        "data": {"request_id": new_request["request_id"]}
    }


async def handle_list_requests(websocket, message):
    return {
        "type": "list_requests",
        "data": {"requests": requests}
    }


async def handle_accept_request(websocket, message):
    request_id = message["request_id"]
    user_id = require_user(websocket)

    for request in requests:
        if request["request_id"] == request_id:
            if request["status"] == "UNACCEPTED":
                request["status"] = "ACCEPTED"
                request["accepted_by"] = user_id
                return {
                    "type": "request_accepted",
                    "message": "Request accepted successfully",
                    "data": {"requests": requests}
                }
            else:
                return {
                    "type": "error",
                    "message": f"Request {request_id} is not available for acceptance.",
                    "data": {}
                }

    return {
        "type": "error",
        "message": f"Request {request_id} not found.",
        "data": {}
    }


def _removeRequestWithID(requestID: str):
    for i, request in enumerate(data_store.requests):
        if (request["request_id"] == requestID):
            data_store.requests.pop(i)


def _getRequestFromID(requestID: str):
    for request in data_store.requests:
        if (request["request_id"] == requestID):
            return request
    return None


async def handle_mark_request_as_complete(websocket, message):
    request_id = message["request_id"]
    request = _getRequestFromID(request_id)
    if (request == None):
        return {
            "type": "error",
            "message": f"Request {request_id} not found.",
            "data": {}
        }

    user_id = require_user(websocket)
    if request["status"] == "ACCEPTED" and request["user_id"] == user_id:
        acceptingUserID = request["accepted_by"]
        acceptingUserIDSocket = next(
            (k for k, v in connected_users.items() if v == acceptingUserID), None)

        for user in users:
            if user["user_id"] == acceptingUserID:
                _removeRequestWithID(request_id)
                user["reward_points"] += 5
                await send_user_points(acceptingUserIDSocket, "")
                return {
                    "type": "request_completed",
                            "message": "Request marked as completed successfully",
                            "data": {"requests": requests}
                }
    else:
        return {
            "type": "error",
            "message": f"Request {request_id} cannot be marked as completed by user {user_id}.",
            "data": {}
        }


async def handle_cancel_request(websocket, message):
    """Handles the 'cancel_request' WebSocket action.
    According to project requirements, when a service provider who accepted a 
    request (or the requester who created it) cancels the action, the request 
    status reverts from 'ACCEPTED' back to 'UNACCEPTED' and 'accepted_by' is cleared 
    so it can be picked up again on the Request Board."""

    # 1. Verify that the current user is authenticated/connected
    user_id = require_user(websocket)

    request_id = message["request_id"]

    # 3. Locate the target request in the in-memory data store
    for index, request in enumerate(requests):
        if request["request_id"] == request_id:
            # Check eligibility: Request must be currently 'ACCEPTED', and the action
            # must be initiated by either the provider who accepted it or the creator.
            is_provider = request.get("accepted_by") == user_id
            is_creator = request.get("user_id") == user_id

            if (is_creator):
                requests.pop(index)
                return {
                    "type": "request_cancelled",
                    "message": "Request removed",
                    "request_id": request_id
                }
            elif (is_provider):
                request["status"] = "UNACCEPTED"
                request["accepted_by"] = None
                return {
                    "type": "request_cancelled",
                    "message": "Request unaccepted",
                    "request_id": request_id,
                    "data": {"requests": requests}
                }
            else:
                # User is either not authorized or request is not in a cancellable state
                return {
                    "type": "error",
                    "message": f"Request {request_id} cannot be cancelled by user {user_id}.",
                    "data": {}
                }

    # 4. If no matching request ID was found in storage
    return {

        "type": "error",
        "message": f"Request {request_id} not found."
    }


async def send_user_points(websocket, _):
    """Sends a points update to the user attributed to the websocket.
    """

    user_id = require_user(websocket)

    for user in users:
        if user["user_id"] == user_id:
            toSend = {
                "type": "user_details",
                "message": "User details retrieved successfully",
                "data": {
                    "reward_points": user["reward_points"],
                }
            }
            await websocket.send_json(toSend)
            return


async def handle_send_user_points(websocket, _):
    """Handles the 'user_details' WebSocket action.
    Retrieves and returns details for a specified user (their points)."""

    user_id = require_user(websocket)

    for user in users:
        if user["user_id"] == user_id:
            return {
                "type": "user_details",
                "message": "User details retrieved successfully",
                "data": {
                    "reward_points": user["reward_points"],
                }
            }

    return {
        "type": "error",
        "message": f"User not found."
    }
