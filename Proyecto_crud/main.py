from typing import Optional, List

from fastapi import FastAPI, HTTPException, status
from sqlmodel import SQLModel, Field, create_engine, Session, select

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(..., index=True)
    password: str
    email: Optional[str] = None
    is_active: bool = True

class UserCreate(SQLModel):
    username: str
    password: str
    email: Optional[str] = None
    is_active: Optional[bool] = True


class UserRead(SQLModel):
    id: int
    username: str
    email: Optional[str] = None
    is_active: bool


class UserUpdate(SQLModel):
    username: Optional[str] = None
    email: Optional[str] = None
    is_active: Optional[bool] = None


class LoginIn(SQLModel):
    username: str
    password: str


sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

engine = create_engine(sqlite_url, echo=False)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


app = FastAPI(title="API CRUD Usuarios - Laboratorio")


@app.on_event("startup")
def on_startup():
    create_db_and_tables()


@app.get("/")
def read_root():
    return {"message": "¡FastAPI con SQLite funcionando!"}



@app.post("/users", response_model=UserRead, status_code=status.HTTP_201_CREATED)
def create_user(user_in: UserCreate):
    """
    Crea usuario. Valida que username sea unico.
    Devuelve UserRead (sin password).
    """
    with Session(engine) as session:

        existing = session.exec(select(User).where(User.username == user_in.username)).first()
        if existing:
            raise HTTPException(status_code=400, detail="El username ya existe")

        user = User(
            username=user_in.username,
            password=user_in.password,
            email=user_in.email,
            is_active=bool(user_in.is_active)
        )
        session.add(user)
        session.commit()
        session.refresh(user)
        return UserRead.from_orm(user)


@app.get("/users", response_model=List[UserRead])
def get_users():
    with Session(engine) as session:
        users = session.exec(select(User)).all()
        return [UserRead.from_orm(u) for u in users]


@app.get("/users/{user_id}", response_model=UserRead)
def get_user(user_id: int):
    with Session(engine) as session:
        user = session.get(User, user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
        return UserRead.from_orm(user)


@app.put("/users/{user_id}", response_model=UserRead)
def update_user(user_id: int, user_up: UserUpdate):
    """
    Actualiza username/email/is_active. NO actualiza password (por requisito).
    Si se quiere cambiar password, se implementaría un endpoint separado.
    """
    with Session(engine) as session:
        user = session.get(User, user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")

        if user_up.username and user_up.username != user.username:
            existing = session.exec(select(User).where(User.username == user_up.username)).first()
            if existing:
                raise HTTPException(status_code=400, detail="El username nuevo ya existe")
            user.username = user_up.username

        if user_up.email is not None:
            user.email = user_up.email

        if user_up.is_active is not None:
            user.is_active = bool(user_up.is_active)

        session.add(user)
        session.commit()
        session.refresh(user)
        return UserRead.from_orm(user)


@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    with Session(engine) as session:
        user = session.get(User, user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
        session.delete(user)
        session.commit()
        return {"ok": True}


@app.post("/login")
def login(data: LoginIn):
    """
    Autentica por username y password en texto (práctica educativa).
    Devuelve resp: login exitoso / login fallido
    """
    with Session(engine) as s:
        user = s.exec(select(User).where(User.username == data.username)).first()
        if user and user.password == data.password:
            return {"resp": "login exitoso"}
        return {"resp": "login fallido"}
