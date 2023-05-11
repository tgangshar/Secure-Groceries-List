# This is a simple example web app that is meant to illustrate the basics.
from flask import Flask, render_template, redirect, g, request, url_for
import sqlite3
import requests
import json
import os

DATABASE = 'todolist.db'

app = Flask(__name__)
app.config.from_object(__name__)

#Dockerfile evn
API_URL = "http://"+os.environ['TODO_API_IP']+":5001"
#'http://10.216.0.231:5001'

@app.route("/")
def show_list():
    resp = requests.get(API_URL+"/api/items")
    resp = resp.json()
    print(API_URL)
    return render_template('index.html', todolist=resp)

#Check m
@app.route("/add",methods=['POST'])
def add_entry():
    data = {
        'what_to_do': request.form['what_to_do'],
        'due_date': request.form['due_date']
    }
    headers = {'Content-Type': 'application/json'}
    response = requests.post(API_URL+'/api/add', data=json.dumps(data), headers=headers)
    return redirect(url_for('show_list'))
#Done
@app.route("/mark/<item>")
def mark_as_done(item):
    rsp = requests.put(API_URL+"/api/mark/%s" % item)
    return redirect(url_for('show_list'))

#Done
@app.route("/delete/<item>")
def delete_entry(item):
    rsp = requests.delete(API_URL+"/api/delete/%s" % item)
    return redirect(url_for('show_list'))

if __name__ == "__main__":
    #changed to 80 when running from cloud 
    app.run("0.0.0.0", port=80)
