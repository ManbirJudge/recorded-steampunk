import json
import sqlite3 as sql
from datetime import datetime
from typing import List

from flask import Flask, request

DATE_FMT = '%d-%m-%Y'

app = Flask(__name__)

with sql.connect('database.db') as con:
    cur = con.cursor()

    cur.execute('CREATE TABLE IF NOT EXISTS test_record (id INTEGER primary key autoincrement, date INTEGER, '
                'title STRING, subject STRING, topic STRING, total_marks REAL, marks_obtained REAL)')
    con.commit()

SORT_ORDER = {
    0: 'ASC',
    1: 'DESC'
}


def create_sql_read_cmd(
        table: str,
        fields: List['str'],

        should_sort: bool = False,
        sort_by: str = 'date',
        sort_order: int = 1,

        should_filter: bool = False,
        filters: List[dict] | None = None,

        should_paginate: bool = False,
        tests_per_page: int = 20,
        page_no: int = None
) -> str:
    if filters is None:
        filters = list()

    cmd = f'SELECT {", ".join(fields)} from {table}'

    if should_filter:
        filter_cmd_str = ''

        for filter_ in filters:
            if filter_['type'] == 'comparison':
                filter_cmd_str += f'WHERE {filter_["col"]} = {filter_["val"]}'
            else:
                print(f'Unknown filter type: {filter_["type"]}')

    if should_sort:
        cmd = f'{cmd} ORDER BY {sort_by} {SORT_ORDER[sort_order]}'

    if should_paginate:
        cmd = f'{cmd} LIMIT {tests_per_page} OFFSET {page_no * tests_per_page}'

    return cmd


@app.route('/')
def index():
    return '<h1>This is an API only web application; so nothing here on the index page.</h1>'


@app.get('/test-record/<page_no>')
def get_test_record(page_no: str):
    page_no = int(page_no)

    tests_per_page = request.args.get('tests-per-page')
    str_dates = request.args.get('str-dates')
    sort_by = request.args.get('sort-by')
    sort_order = request.args.get('sort-order')
    filters = request.args.get('filters')

    if tests_per_page is None:
        tests_per_page = 20
    else:
        tests_per_page = int(tests_per_page)

    if str_dates is None:
        str_dates = False
    else:
        str_dates = str_dates == 'true'

    if sort_by is None:
        sort_by = 'date'
    else:
        sort_by = str(sort_by)

    if sort_order is None:
        sort_order = 1
    else:
        sort_order = int(sort_order)

    if filters is not None:
        filters = list(json.loads(str(filters)))

    with sql.connect('database.db') as con:
        cur = con.cursor()

        num_tests = cur.execute('SELECT COUNT(*) FROM test_record').fetchone()[0]
        num_pages = num_tests // tests_per_page + (num_tests % tests_per_page > 0)

        cmd = create_sql_read_cmd(
            table='test_record',
            fields=['date', 'title', 'subject', 'topic', 'total_marks', 'marks_obtained', 'id'],

            should_sort=True,
            sort_by=sort_by,
            sort_order=sort_order,

            should_filter=filters is None,
            filters=filters,

            should_paginate=True,
            tests_per_page=tests_per_page,
            page_no=page_no
        )

        print(cmd)

        res = cur.execute(cmd)

        tests = [{
            'id': int(row[6]),
            'date': datetime.fromtimestamp(int(row[0])).strftime(DATE_FMT) if str_dates else row[0],
            'title': row[1],
            'subject': row[2],
            'topic': row[3],
            'total-marks': float(row[4]),
            'marks-obtained': float(row[5]),
        } for row in res]

        return {
            'tests-per-page': tests_per_page,
            'num-pages': num_pages,
            'tests': tests,
            'num-tests': len(tests),
            'current-page': page_no
        }


@app.post('/test-record')
def update_test_record():
    data = request.json

    # print(json.dumps(data, indent=2))

    with sql.connect('database.db') as con:
        cur = con.cursor()

        if data['multiple']:
            try:
                new_tests_data = [(
                    int(datetime.strptime(test['date'], DATE_FMT).timestamp()),
                    test['title'],
                    test['subject'],
                    test['topic'],
                    float(test['total-marks']),
                    float(test['marks-obtained'])
                ) for test in data['tests']]

            except IndexError:
                return {
                    'error': 'Invalid data:\nNumber of parameters of each list are not equal.'
                }

            cur.executemany(
                'INSERT INTO test_record (date, title, subject, topic, total_marks, marks_obtained) VALUES(?, ?, ?, '
                '?, ?, ?)',
                new_tests_data
            )
            con.commit()

            return {
                'message': 'New tests added successfully.'
            }

        else:
            new_test_data = (
                data['test']['date'],
                data['test']['title'],
                data['test']['subject'],
                data['test']['topic'],
                float(data['test']['total-marks']),
                float(data['test']['marks-obtained'])
            )

            cur.execute(
                'INSERT INTO test_record (date, title, subject, topic, total_marks, marks_obtained) VALUES(?, ?, ?, '
                '?, ?, ?)',
                new_test_data
            )
            con.commit()

            return {
                'status': 0,
                'message': 'New test added successfully.',
                'index': int(cur.execute('SELECT COUNT(*) FROM test_record').fetchone()[0]) - 1,
                'test': {
                    'date': new_test_data[0],
                    'title': new_test_data[1],
                    'subject': new_test_data[2],
                    'topic': new_test_data[3],
                    'total-marks': new_test_data[4],
                    'marks-obtained': new_test_data[5]
                }
            }


@app.put('/test-record')
def replace_test_record():
    data = request.json

    with sql.connect('database.db') as con:
        cur = con.cursor()

        try:
            new_tests_data = [(
                int(test['date']),
                test['title'],
                test['subject'],
                test['topic'],
                float(test['total-marks']),
                float(test['marks-obtained'])
            ) for test in data['tests']]

        except IndexError:
            return {
                'error': 'Invalid data:\nNumber of parameters of each list are not equal.'
            }

        cur.execute('DELETE FROM test_record')
        cur.executemany(
            'INSERT INTO test_record (date, title, subject, topic, total_marks, marks_obtained) VALUES(?, ?, ?, '
            '?, ?, ?)',
            new_tests_data
        )
        con.commit()

        return {
            'status': 0,
            'message': 'Test record replaced successfully.'
        }


@app.delete('/test-record')
def delete_tests():
    data = request.json

    with sql.connect('database.db') as con:
        cur = con.cursor()

        cur.execute(
            f'DELETE FROM test_record WHERE id IN ({", ".join([str(test_id) for test_id in data["test-ids"]])})'
        )
        con.commit()

        return {
            'status': 0,
            'message': 'Tests deleted successfully.'
        }


@app.route('/greet/<name>')
def greet(name: str):
    return f'<p>Hello, {name}!</p>'


if __name__ == '__main__':
    app.run('0.0.0.0', 5000)
