import sqlite3 as sql
from datetime import datetime

from flask import Flask, request

# NOTE: date is stored as milliseconds
DATE_FMT = '%d-%m-%Y'

app = Flask(__name__)

with sql.connect('database.db') as con:
    cur = con.cursor()

    cur.execute('CREATE TABLE IF NOT EXISTS test_record (id INTEGER primary key autoincrement, date INTEGER, '
                'title STRING, subject STRING, topic STRING, total_marks REAL, marks_obtained REAL)')
    con.commit()


@app.route('/')
def index():
    return '<p>Hello, World!</p>'


@app.get('/test-record/<page_no>')
def get_test_record(page_no: str):
    page_no = int(page_no)

    if request.data.decode('utf-8') == '':
        data = {}
    else:
        data = dict(request.json)

    if data.get('tests-per-page') is None:
        tests_per_page = 20
    else:
        tests_per_page = int(data['test-per-page'])

    if data.get('str-dates') is None:
        str_dates = False
    else:
        str_dates = bool(data['str-dates'])

    print(tests_per_page)
    print(str_dates)

    with sql.connect('database.db') as con:
        cur = con.cursor()

        num_tests = cur.execute('SELECT COUNT(*) FROM test_record').fetchone()[0]
        num_pages = num_tests // tests_per_page + (num_tests % tests_per_page > 0)

        result = cur.execute(
            f'SELECT date, title, subject, topic, total_marks, marks_obtained, id FROM test_record LIMIT'
            f' {tests_per_page} OFFSET {page_no * tests_per_page}'
        )

        tests = [{
            'id': int(row[6]),
            'date': datetime.fromtimestamp(int(row[0])).strftime(DATE_FMT) if str_dates else row[0],
            'title': row[1],
            'subject': row[2],
            'topic': row[3],
            'total-marks': float(row[4]),
            'marks-obtained': float(row[5]),
        } for row in result]

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

        cur.execute('DELETE FROM test_record')
        cur.executemany(
            'INSERT INTO test_record (date, title, subject, topic, total_marks, marks_obtained) VALUES(?, ?, ?, '
            '?, ?, ?)',
            new_tests_data
        )
        con.commit()

        return {
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
    app.run(
        '0.0.0.0',
        5000
    )
