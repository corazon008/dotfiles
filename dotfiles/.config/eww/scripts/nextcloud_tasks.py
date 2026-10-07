#!/usr/bin/env python3

import argparse
import json
import os
from datetime import date, datetime, timezone

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
# Helpers
# ----------------------------

PRIORITY_RANK = {"high": 0, "med": 1, "low": 2, "none": 3}


def parse_due(value):
    """Convert a vobject date/datetime/string to an aware datetime, or None."""
    if value is None:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    if isinstance(value, date):
        return datetime(value.year, value.month, value.day, tzinfo=timezone.utc)

    raw = str(value)
    for fmt in (
        "%Y%m%dT%H%M%SZ",
        "%Y%m%dT%H%M%S",
        "%Y%m%d",
        "%Y-%m-%d %H:%M:%S%z",
        "%Y-%m-%d",
    ):
        try:
            parsed = datetime.strptime(raw, fmt)
            return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)
        except ValueError:
            continue
    return None


def priority_label(todo):
    """Map VTODO PRIORITY (RFC 5545: 1-4 high, 5 medium, 6-9 low) to a label."""
    if not hasattr(todo, "priority"):
        return "none"
    try:
        value = int(str(todo.priority.value))
    except (TypeError, ValueError):
        return "none"

    if 1 <= value <= 4:
        return "high"
    if value == 5:
        return "med"
    if 6 <= value <= 9:
        return "low"
    return "none"


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

# ----------------------------
# Récupération des tâches
# ----------------------------

now = datetime.now(timezone.utc)

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
        due_dt = None
        if hasattr(todo, "due"):
            due = str(todo.due.value)
            due_dt = parse_due(todo.due.value)

        priority = priority_label(todo)
        overdue = bool(due_dt and not completed and due_dt < now)

        # Fallback on due-date urgency when no explicit priority is set.
        if priority == "none" and due_dt and not completed:
            if overdue:
                priority = "high"
            elif (due_dt - now).total_seconds() <= 48 * 3600:
                priority = "med"

        tasks.append(
            {
                "title": summary,
                "done": completed,
                "due": due,
                "priority": priority,
                "overdue": overdue,
            }
        )

# ----------------------------
# Tri des tâches
# ----------------------------

tasks.sort(
    key=lambda task: (
        task["done"],
        PRIORITY_RANK[task["priority"]],
        task["due"] is None,
        task["due"] or "",
    )
)

print(json.dumps(tasks[:10], indent=2, ensure_ascii=False))
