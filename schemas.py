from datetime import datetime, date
from pydantic import BaseModel


class TaskCreate(BaseModel):
    title: str
    description: str = ""
    completed: bool = False
    due_date: date | None = None


class TaskUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    completed: bool | None = None
    due_date: date | None = None


class TaskResponse(BaseModel):
    id: int
    title: str
    description: str
    completed: bool
    due_date: date | None
    created_at: datetime

    model_config = {"from_attributes": True}
