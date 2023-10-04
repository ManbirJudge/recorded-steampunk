import sqlite3 as sql

test_ids = [1]

with sql.connect('database.db') as con:
    cur = con.cursor()

    cur.execute(f'DELETE FROM test_record WHERE id IN ({", ".join([str(test_id) for test_id in test_ids])})')
