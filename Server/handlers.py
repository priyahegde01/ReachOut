# Contains all the functions that handle the different calls/messages that are communicated via the WebSocket.

from datetime import datetime, timedelta, timezone
from uuid import uuid4
import data_store
from data_store import *

requestLifetime = timedelta(seconds=5)


def require_user(websocket):
    user_id = connected_users.get(websocket)
    if user_id is None:
        raise PermissionError(
            "Register or log in before performing this action.")
    return user_id


def handle_verify_user(websocket, message):
    data = message["data"]
    input_user_id = data.get("user_id")

    for user in users:
        if user["user_id"] == input_user_id:
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


def handle_register_user(websocket, message):
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

    return {
        "type": "user_registered",
        "message": "User registered successfully",
        "data": {"user_id": new_user["user_id"]}
    }


def handle_create_request(websocket, message):
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


def handle_list_requests(websocket, message):
    return {
        "type": "list_requests",
        "data": {"requests": requests}
    }


def handle_accept_request(websocket, message):
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


def handle_mark_request_as_complete(websocket, message):
    request_id = message["request_id"]
    user_id = require_user(websocket)

    for request in requests:
        if request["request_id"] == request_id:
            if request["status"] == "ACCEPTED" and request["user_id"] == user_id:
                request["status"] = "COMPLETED"
                request["completed_at"] = (
                    datetime.now(timezone.utc)).isoformat()

                for user in users:
                    if user["user_id"] == user_id:
                        user["completed_requests"].append(request_id)
                        user["reward_points"] += 5
                        break

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

    return {
        "type": "error",
        "message": f"Request {request_id} not found.",
        "data": {}
    }


def handle_cancel_request(websocket, message):
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


def handle_user_details(websocket, message):
    """Handles the 'user_details' WebSocket action.
    Retrieves and returns details for a specified user (or the currently authenticated 
    user), including their total accumulated reward points and request history."""

    # 1. Ensure the requesting client is authenticated
    authenticated_user_id = require_user(websocket)

    # 2. Extract target user_id from top-level payload or 'data' map, defaulting to the authenticated caller if not explicitly provided
    data = message.get("data", {})
    target_user_id = message.get("user_id")
    if target_user_id is None and isinstance(data, dict):
        target_user_id = data.get("user_id")

    if not target_user_id:
        target_user_id = authenticated_user_id

    # 3. Search for the user record in data_store.users
    for user in users:
        if user["user_id"] == target_user_id:
            return {

                "type": "user_details",
                "message": "User details retrieved successfully",
                "data": {

                    "user_id": user["user_id"],
                    "reward_points": user.get("reward_points", 0),
                    "raised_requests": user.get("raised_requests", []),
                    "accepted_requests": user.get("accepted_requests", []),
                    "completed_requests": user.get("completed_requests", [])
                }
            }

    # 4. Return error response if the target user ID does not exist
    return {

        "type": "error",
        "message": f"User {target_user_id} not found."
    }
