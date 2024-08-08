# This is a simple example web app that is meant to illustrate the basics.
from flask import Flask, redirect, g, request, jsonify
import sqlite3
import requests
import json

DATABASE = 'todolist.db'

app = Flask(__name__)
app.config.from_object(__name__)

#Front End: show_list()
@app.route("/api/items")
def get_items():
    db = get_db()
    cur = db.execute('SELECT what_to_do, due_date, status FROM entries')
    entries = cur.fetchall()
    tdlist = [dict(what_to_do=row[0], due_date=row[1], status=row[2]) 
              for row in entries]
    return jsonify(tdlist)

# Maybe Put
@app.route('/api/add/', methods=['POST'])
def add_entry():
   data = json.loads(request.data)
   db = get_db()
   db.execute('insert into entries (what_to_do, due_date) values (?, ?)',
               [data['what_to_do'], data['due_date']])
   db.commit()
   return jsonify({'result': 'success'})

@app.route("/api/mark/<item>",methods=['PUT'])
def mark_as_done(item):
   db = get_db()
   db.execute("UPDATE entries SET status='done' WHERE what_to_do='"+item+"'")
   db.commit()
   return get_items()

@app.route("/api/delete/<item>", methods=['DELETE'])
def delete_entry(item):
   db = get_db()
   db.execute("DELETE FROM entries WHERE what_to_do='"+item+"'")
   db.commit()
   return jsonify({'result': 'success'})

def get_db():
   """Opens a new database connection if there is none yet for the
   current application context.
   """
   if not hasattr(g, 'sqlite_db'):
      g.sqlite_db = sqlite3.connect(app.config['DATABASE'])
   return g.sqlite_db


@app.teardown_appcontext
def close_db(error):
   """Closes the database again at the end of the request."""
   if hasattr(g, 'sqlite_db'):
      g.sqlite_db.close()


if __name__ == "__main__":
   #changed to 80 when running from cloud 
   app.run("0.0.0.0", port=5001)

