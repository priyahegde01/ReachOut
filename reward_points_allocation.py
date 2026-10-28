async def handle_mark_request_as_complete(websocket, message):
    """
    WebSocket handler for marking a help request as 'COMPLETED'.
    
    This function performs the following steps:
    1. Extracts the target request ID from the incoming WebSocket message.
    2. Authenticates the client using the active WebSocket connection.
    3. Locates the request record in the shared data store.
    4. Enforces security checks (must be in 'ACCEPTED' state and called by the original requester).
    5. Updates task lifecycle attributes (status and completed_at timestamp).
    6. Allocates a standardized 10 reward points to the assigned helper (accepted_by user).
    7. Returns an appropriate WebSocket confirmation or error response dictionary containing "data": {}.
    """
    
    # -------------------------------------------------------------------------
    # Step 1: Extract request payload data
    # -------------------------------------------------------------------------
    # Extract the nested 'data' dictionary from the incoming WebSocket message.
    data = message["data"]
    # Retrieve the 'request_id' associated with the request being acted upon.
    request_id = data.get("request_id")

    # -------------------------------------------------------------------------
    # Step 2: User Authentication & Authorization Check
    # -------------------------------------------------------------------------
    # Ensure the client is logged in by retrieving their assigned UUID from connected_users.
    # If the client is unauthenticated, require_user raises a PermissionError exception.
    user_id = require_user(websocket)
    
    # -------------------------------------------------------------------------
    # Step 3: Search for the target request in the global data store
    # -------------------------------------------------------------------------
    # Iterate through all help requests stored in data_store.requests.
    for request in requests:
        # Match the incoming request_id against records stored in the data store.
        if request["request_id"] == request_id:
            
            # -----------------------------------------------------------------
            # Step 4: Validate request state and requester ownership
            # -----------------------------------------------------------------
            # A request can only be completed if:
            #   a) Its status is currently 'ACCEPTED' (someone accepted the request).
            #   b) The user initiating completion is the original creator (request['user_id']).
            if request["status"] == "ACCEPTED" and request["user_id"] == user_id:
                
                # -------------------------------------------------------------
                # Step 5: Update request lifecycle attributes
                # -------------------------------------------------------------
                # Transition the task lifecycle state to 'COMPLETED' in data_store.
                request["status"] = "COMPLETED"
                
                # Record the exact UTC completion timestamp in ISO 8601 format.
                request["completed_at"] = (datetime.now(timezone.utc)).isoformat()
                
                # -------------------------------------------------------------
                # Step 6: Standardized Reward Point Allocation (10 Points)
                # -------------------------------------------------------------
                # Retrieve the service provider's UUID from the request's 'accepted_by' attribute.
                provider_id = request.get("accepted_by")
                
                if provider_id:
                    # Locate the helper's user profile in data_store.users.
                    for user in users:
                        if user["user_id"] == provider_id:
                            # Award the standardized 10 reward points to the helper.
                            user["reward_points"] = user.get("reward_points", 0) + 10
                            
                            # Append the request ID to the provider's completed_requests history list.
                            if "completed_requests" in user and isinstance(user["completed_requests"], list):
                                if request_id not in user["completed_requests"]:
                                    user["completed_requests"].append(request_id)
                            
                            # Exit loop once the provider's record is successfully updated
                            break
                
                # -------------------------------------------------------------
                # Step 7a: Return Success Response
                # -------------------------------------------------------------
                # Return success payload confirming completion state update containing "data": {}
                return {
                    "type": "request_completed",
                    "message": "Request marked as completed successfully",
                    "data": {}
                }
            else:
                # -------------------------------------------------------------
                # Step 7b: Return Authorization / State Error
                # -------------------------------------------------------------
                # Triggered if request is not 'ACCEPTED' or caller is not the creator.
                return {
                    "type": "error",
                    "message": f"Request {request_id} cannot be marked as completed by user {user_id}.",
                    "data": {}
                }
                
    # -------------------------------------------------------------------------
    # Step 7c: Return Request Not Found Error
    # -------------------------------------------------------------------------
    # Triggered if request_id does not exist in data_store.requests.
    return {
        "type": "error",
        "message": f"Request {request_id} not found.",
        "data": {}
    }