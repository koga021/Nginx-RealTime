# Nginx-RealTime

Real-time visitor counter using **Nginx**, **Lua**, and **Redis**.  
This project demonstrates a simple SSE (Server-Sent Events) setup with multiple Nginx instances connected to a shared Redis cache.

---

## Features

- Real-time visitor counter.
- SSE endpoint (`/events`) to push live updates to clients.
- Automatic caching with `lua_shared_dict`.
- Multiple Nginx instances can share the same counter via Redis Pub/Sub.
- Minimal Docker setup with OpenResty and Redis.

---

## Prerequisites

- Docker
- Docker Compose
- `make` (optional, for convenience commands)

---

## Running

Build and run the containers:

```bash
make build
make run
```
--- 

## Testing
Access the route and click in button.
* http://localhost:8081/
* http://localhost:8082/

Execute to increment:
```
curl http://localhost:8080/visit
```