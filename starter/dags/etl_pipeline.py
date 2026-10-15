"""CSAI 380 Week 3 ETL DAG: GCS + Redis -> transform -> MySQL.

Transform and load are provided; the extract phase is yours (3.4 Part Two).
"""
from __future__ import annotations

import csv
import io
import json
from datetime import datetime

from airflow.decorators import dag, task

GCS_BUCKET = "<project-id>-<your-username>-raw-data"
COUNTRY_CSV_OBJECT = "country-codes.csv"
REDIS_CONN_HOST = "redis.<your-namespace>.svc.cluster.local"
MYSQL_CONN_ID = "csai380_mysql"  # define in Airflow Connections


@dag(
    dag_id="csai380_etl_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,  # trigger manually from the UI
    catchup=False,
    tags=["csai380", "week3"],
)
def etl_pipeline():
    @task
    def extract() -> dict:
        """Extract phase.

        TODO(student): implement this task so it returns
          {"country_rows": [...], "signup_events": [...]}

        1. Read COUNTRY_CSV_OBJECT from GCS_BUCKET
           (hint: google.cloud.storage.Client; parse with csv.DictReader).
        2. Read user signup events (JSON values) from Redis at REDIS_CONN_HOST
           (hint: redis.Redis(host=...); keys match "signup:*").
        """
        raise NotImplementedError("TODO(student): implement the extract phase")

    @task
    def transform(extracted: dict) -> list[dict]:
        """Join signups to country metadata by phone country code."""
        by_dial_code = {}
        for row in extracted["country_rows"]:
            dial = (row.get("Dial") or "").strip()
            if dial:
                by_dial_code[dial] = row

        results = []
        for event in extracted["signup_events"]:
            dial = str(event.get("country_dial_code", "")).strip()
            country = by_dial_code.get(dial, {})
            results.append(
                {
                    "user_id": event.get("user_id"),
                    "iso_alpha3": country.get("ISO3166-1-Alpha-3"),
                    "country_name": country.get("official_name_en"),
                    # TODO(student): add capital city, continent, currency name,
                    # and internet TLD (3.4 Part Three)
                }
            )
        return results

    @task
    def load(rows: list[dict]) -> int:
        """Load transformed rows into MySQL."""
        from airflow.providers.mysql.hooks.mysql import MySqlHook

        hook = MySqlHook(mysql_conn_id=MYSQL_CONN_ID)
        hook.run(
            """
            CREATE TABLE IF NOT EXISTS signup_locations (
                user_id VARCHAR(64) PRIMARY KEY,
                iso_alpha3 CHAR(3),
                country_name VARCHAR(128)
            )
            """
        )
        for row in rows:
            hook.run(
                """
                REPLACE INTO signup_locations (user_id, iso_alpha3, country_name)
                VALUES (%s, %s, %s)
                """,
                parameters=(row["user_id"], row["iso_alpha3"], row["country_name"]),
            )
        return len(rows)

    load(transform(extract()))


etl_pipeline()
