# Nginx-RealTime
Nginx Real time with LUA and Redis

# Running
* make build
* make run

# Test
Access the address 
```
http://localhost:8080/events
```
Now send requests to ```http://localhost:8080/visit``` this request will start a transmission of data to each open conection on ```http://localhost:8080/events```