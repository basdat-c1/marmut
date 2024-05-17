from django.db import connection
from collections import namedtuple

def map_cursor(cursor):
    desc = cursor.description
    nt_result = namedtuple("Result", [col[0] for col in desc])
    return [nt_result(*row) for row in cursor.fetchall()]

def query(query_str: str):
    result = []
    with connection.cursor() as cursor:
        cursor.execute("set search_path to marmut")
        try:
            cursor.execute(query_str)
            if query_str.strip().lower().startswith("select"):
                result = map_cursor(cursor)
            else:
                result = cursor.rowcount
        except Exception as e:
            result = e
        cursor.execute("set search_path to public")

    return result
