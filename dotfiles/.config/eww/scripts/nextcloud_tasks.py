#!/usr/bin/env python3

import argparse
import json
import os

import caldav
from dotenv import load_dotenv

# ----------------------------
# Arguments
# ----------------------------

parser = argparse.ArgumentParser(description="Afficher les tâches CalDAV")

parser.add_argument(
    "--cours",
    action="store_true",
    help="Afficher uniquement les tâches des calendriers de cours",
)

args = parser.parse_args()

# ----------------------------
# Configuration
# ----------------------------

load_dotenv()

SERVER = os.environ["CALDAV_SERVER"]
USERNAME = os.environ["CALDAV_USERNAME"]
PASSWORD = os.environ["CALDAV_PASSWORD"]

# ----------------------------
# Connexion CalDAV
# ----------------------------

client = caldav.DAVClient(
    url=f"{SERVER}/remote.php/dav",
    username=USERNAME,
    password=PASSWORD,
)

principal = client.principal()
calendars = principal.calendars()

tasks = []

#print(f"Found {len(calendars)} calendars")
#print(f"Calendars: {[calendar.get_display_name() for calendar in calendars]}")

# ----------------------------
# Récupération des tâches
# ----------------------------

for calendar in calendars:
    calendar_name = calendar.get_display_name()
    is_course_calendar = "cours" in calendar_name.lower()

    # --cours -> uniquement les calendriers de cours
    # sans --cours -> tous les calendriers sauf ceux de cours
    if args.cours:
        if not is_course_calendar:
            continue
    else:
        if is_course_calendar:
            continue

    for event in calendar.todos():
        todo = event.vobject_instance.vtodo

        summary = str(todo.summary.value)
        completed = hasattr(todo, "completed")

        due = None
        if hasattr(todo, "due"):
            due = str(todo.due.value)

        tasks.append(
            {
                "title": summary,
                "done": completed,
                "due": due,
            }
        )

# ----------------------------
# Tri des tâches
# ----------------------------

tasks.sort(key=lambda task: (task["due"] is None, task["due"]))

print(json.dumps(tasks[:10], indent=2, ensure_ascii=False))
