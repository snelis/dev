import asyncio
import json
import os
import socket
from datetime import datetime
from typing import Any

import databases
import orm
from fastapi import FastAPI
from starlette.responses import Response

db_host = os.environ.get('DATABASE_SERVICE_HOST')
db_name = os.environ.get('DATABASE_NAME')
db_username = os.environ.get('DATABASE_USERNAME')
db_password = os.environ.get('DATABASE_PASSWORD')

print(db_host)
print(db_name)
print(db_username)
print(db_password)

if db_host and db_name and db_username and db_password:
    DATABASE_URL = f"postgresql://{db_username}:{db_password}@database/{db_name}"
else:
    DATABASE_URL = "sqlite:////tmp/db.sqlite"

database = databases.Database(DATABASE_URL)

models = orm.ModelRegistry(database=database)


class Log(orm.Model):
    tablename = "log"
    registry = models
    fields = {
        "id": orm.Integer(primary_key=True),
        "hostname": orm.Text(max_length=100),
        "datetime": orm.DateTime(),
    }


app = FastAPI()
hostname = socket.gethostname()


@app.on_event("startup")
async def startup():
    await database.connect()
    await models.create_all()


class PrettyJSONResponse(Response):
    media_type = "application/json"

    def render(self, content: Any) -> bytes:
        return json.dumps(
            content,
            ensure_ascii=False,
            allow_nan=False,
            indent=2,
        ).encode("utf-8")


@app.get("/", response_class=PrettyJSONResponse)
async def root():
    return {k: v for k, v in sorted(os.environ.items())}


@app.get("/db", response_class=PrettyJSONResponse)
async def list_db():

    if not database.is_connected:
        await database.connect()

    output = []

    await Log.objects.create(hostname=hostname, datetime=datetime.now())
    logs = await Log.objects.limit(100).order_by('-id').all()
    for log in logs:
        output.append(f"{log.datetime}  {log.hostname}")

    return output
