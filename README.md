# Mini Betty Blocks Runtime

This is a technical assignment for the Full Stack Developer position at Betty Blocks.  
It simulates a minimal version of the Betty Blocks runtime.

## ⚙️ Technologies Used

- Elixir
- Redis
- Docker + Docker Compose

## 🚀 Running the Project

To build and run the backend with Redis:

```
docker-compose build
docker-compose up
```

You should see:

```
✅ Compiled and stored schema in Redis
```

The compiler stores a sample schema for the users table in Redis under the key:compiled_schema:users
