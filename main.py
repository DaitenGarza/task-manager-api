from datetime import date

from fastapi import FastAPI, HTTPException, Depends, Query
from sqlalchemy.orm import Session

from database import Base, engine, get_db
from models import Task
from schemas import TaskCreate, TaskUpdate, TaskResponse

# Create database tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Task Manager API",
    description="A REST API for managing tasks — with filtering, search, and due dates. Built with FastAPI + SQLite.",
    version="1.0.0",
)

# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.get("/")
def root():
    return {"message": "Welcome to the Task Manager API! Visit /docs for interactive documentation."}


@app.get("/tasks", response_model=list[TaskResponse])
def get_tasks(
    completed: bool | None = Query(None, description="Filter by completion status"),
    search: str | None = Query(None, description="Search title and description"),
    due_before: date | None = Query(None, description="Tasks due on or before this date"),
    due_after: date | None = Query(None, description="Tasks due on or after this date"),
    db: Session = Depends(get_db),
):
    """Return all tasks. Supports filtering by status, searching, and due-date ranges."""
    query = db.query(Task)

    if completed is not None:
        query = query.filter(Task.completed == completed)

    if search:
        pattern = f"%{search}%"
        query = query.filter(Task.title.ilike(pattern) | Task.description.ilike(pattern))

    if due_before:
        query = query.filter(Task.due_date <= due_before)

    if due_after:
        query = query.filter(Task.due_date >= due_after)

    return query.order_by(Task.created_at.desc()).all()


@app.get("/tasks/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    """Return a single task by its ID."""
    task = db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@app.post("/tasks", response_model=TaskResponse, status_code=201)
def create_task(data: TaskCreate, db: Session = Depends(get_db)):
    """Create a new task."""
    task = Task(**data.model_dump())
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@app.put("/tasks/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, data: TaskCreate, db: Session = Depends(get_db)):
    """Replace an existing task entirely."""
    task = db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    for key, value in data.model_dump().items():
        setattr(task, key, value)
    db.commit()
    db.refresh(task)
    return task


@app.patch("/tasks/{task_id}", response_model=TaskResponse)
def patch_task(task_id: int, data: TaskUpdate, db: Session = Depends(get_db)):
    """Partially update a task — only send the fields you want to change."""
    task = db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(task, key, value)
    db.commit()
    db.refresh(task)
    return task


@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    """Delete a task."""
    task = db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(task)
    db.commit()
    return {"detail": "Task deleted"}
