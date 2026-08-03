#!/usr/bin/env python3

import caldav
import json
from datetime import datetime

import os
from dotenv import load_dotenv

load_dotenv()

SERVER = os.environ["CALDAV_SERVER"]
USERNAME = os.environ["CALDAV_USERNAME"]
PASSWORD = os.environ["CALDAV_PASSWORD"]


client = caldav.DAVClient(
    url=SERVER + "/remote.php/dav", username=USERNAME, password=PASSWORD
)

principal = client.principal()

calendars = principal.calendars()

tasks = []

for calendar in calendars:
    for event in calendar.todos():
        todo = event.vobject_instance.vtodo

        summary = str(todo.summary.value)

        completed = hasattr(todo, "completed")

        due = None
        if hasattr(todo, "due"):
            due = str(todo.due.value)

        tasks.append({"title": summary, "done": completed, "due": due})


print(json.dumps(tasks[:10], indent=2))
