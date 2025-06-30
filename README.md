# Mini Betty Blocks Runtime

A mini runtime implementation for Betty Blocks

## ⚙️ Technologies Used

- Elixir
- Redis
- Docker
- React, Next.js
- Tailwind CSS

## 🚀 Running the Project

To build and run the whole project:

```bash
docker-compose up --build
```

Frontend: http://localhost:3000

Backend API: http://localhost:4001

## 🧱 Services Overview

### data-compiler

This service:

- Reads data from JSON files

- Compiles them into simplified schemas

- Stores compiled schemas in Redis (schema:{table})

### data-api

- Reads compiled schemas from Redis

- Fetches data from Postgres with support for filtering, sorting, pagination

- Accepts new records

## 🔌 Backend API Endpoints

`GET /schema/:table`

Returns the ordered column names for a table.

Example:

`{ "columns": ["id", "name", "email", "role"] }`

`GET /data/:table`

Returns filtered, sorted, and paginated rows from a table.

Query Params:

- filter[field]=value

- sort=column

- limit=5

- page=1

`/data/users?filter[name]=bob&sort=name&page=2&limit=5`

Example:

`{
  "rows": [ ... ],
  "total_count": 42
}`

`POST /data/:table`
Insert a new row into a table.

Body:
`{ "name": "Alice", "email": "alice@example.com", "role": "Admin" }`

## 🖥️ Frontend Features

- Dynamic table based on schema

- Filtering by name/email

- Column sorting

- Pagination with proper "Next"/"Prev" logic

- Modal form to create new records

- Fully styled with Tailwind (responsive layout)
