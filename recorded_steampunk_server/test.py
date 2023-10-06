import sqlite3

with sqlite3.connect('database.db') as con:
    cur = con.cursor()

    res = cur.execute('SELECT COUNT(*) FROM test_record').fetchall()

    print(type(res))
    print(res)
