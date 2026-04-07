# Task Manager API

A RESTful API for managing tasks, built with **FastAPI** and **SQLite**.

## Features

- Full CRUD (Create, Read, Update, Delete) for tasks
- Due dates with date-range filtering
- Text search across titles and descriptions
- Filter tasks by completion status
- Partial updates via PATCH
- Auto-generated interactive API docs (Swagger UI)
- SQLite database with SQLAlchemy ORM

## Tech Stack

- **Python 3.12+**
- **FastAPI** — modern async web framework
- **SQLAlchemy 2.0** — ORM and database toolkit
- **Pydantic v2** — data validation
- **Uvicorn** — ASGI server
- **SQLite** — lightweight database

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/task-manager-api.git
cd task-manager-api

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn main:app --reload
```

Open **http://localhost:8000/docs** for the interactive API playground.

## API Endpoints

| Method   | Endpoint          | Description                          |
|----------|-------------------|--------------------------------------|
| `GET`    | `/`               | Welcome message                      |
| `GET`    | `/tasks`          | List all tasks (with optional filters) |
| `GET`    | `/tasks/{id}`     | Get a single task                    |
| `POST`   | `/tasks`          | Create a new task                    |
| `PUT`    | `/tasks/{id}`     | Replace a task entirely              |
| `PATCH`  | `/tasks/{id}`     | Partially update a task              |
| `DELETE` | `/tasks/{id}`     | Delete a task                        |

### Query Parameters for `GET /tasks`

| Parameter    | Type   | Description                              |
|--------------|--------|------------------------------------------|
| `completed`  | bool   | Filter by completion status              |
| `search`     | string | Search title and description             |
| `due_before` | date   | Tasks due on or before this date         |
| `due_after`  | date   | Tasks due on or after this date          |

### Example Requests

```bash
# Create a task with a due date
curl -X POST http://localhost:8000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Study for exam", "description": "Chapters 5-8", "due_date": "2026-04-15"}'

# Get only incomplete tasks
curl http://localhost:8000/tasks?completed=false

# Search for tasks containing "exam"
curl http://localhost:8000/tasks?search=exam

# Mark a task as completed
curl -X PATCH http://localhost:8000/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

## Project Structure

```
task-manager-api/
├── main.py           # API routes and app config
├── models.py         # SQLAlchemy database models
├── schemas.py        # Pydantic request/response schemas
├── database.py       # Database connection setup
├── requirements.txt  # Python dependencies
├── render.yaml       # Render deployment config
└── README.md
```

## Deploy to Render

1. Push this repo to GitHub
2. Go to [render.com](https://render.com) and create a **New Web Service**
3. Connect your GitHub repo
4. Render will auto-detect the `render.yaml` config
5. Click **Deploy**

## License

MIT
