from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from handlers import handle_register_user, handle_create_request, handle_list_requests, handle_accept_request, handle_mark_request_as_complete, handle_cancel_request, handle_user_details, handle_verify_user
from data_store import connected_users
app = FastAPI(title="ReachOut API")

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
               "verify_user": handle_verify_user, # Do we need this? 
            }.get(message_type)

            if handler is None:
                await websocket.send_json({
                    "type": "error", 
                    "message": f"Unsupported message type: {message_type}"
                    })
                continue
            try:    
                result = await handler(websocket, message)
            except PermissionError as exc:
                await websocket.send_json({
                    "type": "error",
                    "message": str(exc),
                })
                continue

            await websocket.send_json(result)
    except WebSocketDisconnect:
        pass
    except Exception as e:
        await websocket.close()
        print(f"WebSocket connection closed: {e}")
    finally:
        connected_users.pop(websocket, None)