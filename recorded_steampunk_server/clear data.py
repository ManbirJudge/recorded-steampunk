import sqlite3

con = sqlite3.connect('database.db')
cur = con.cursor()

table_name = 'test_record'

sure = input(f'Are you sure you want to delete the \'{table_name}\' table? (y/n) ') == 'y'

if sure:
    print(f'\nDeleting the \'{table_name}\' table.')
    cur.execute('DROP TABLE IF EXISTS test_record')
    print(f'\'{table_name}\' table deleted successfully.')
else:
    print(f'\nNot deleting the \'{table_name}\' table.')
