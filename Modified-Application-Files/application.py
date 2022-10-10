#!/usr/bin/env python3
"""
Url shortener flask app
"""

import json
import os.path
from flask import Flask, render_template, request, redirect, url_for, flash, abort, session, jsonify
from werkzeug.utils import secure_filename


application = app = Flask(__name__)
app.secret_key = 'h432hi5ohi3h5i5hi3o2hi'

#def create_app():
#    """
#    Not the same scope, probably won't work as intended and isn't used?
#    I commented it because the linter is complaining and failing the build.
#    """
#    application = app = Flask(__name__)

@app.route('/')
def home():
    """
    Home page route
    """
    return render_template('home.html', codes=session.keys())

@app.route('/your-url', methods=['GET','POST'])
def your_url():
    """
    shorten a page route
    """
    if request.method == 'POST':
        urls = {}

        if os.path.exists('urls.json'):
            with open('urls.json', 'r', encoding='utf8') as urls_file:
                urls = json.load(urls_file)

        if request.form['code'] in urls.keys():
            flash('That short name has already been taken. Please select another name.')
            return redirect(url_for('home'))

        if 'url' in request.form.keys():
            urls[request.form['code']] = {'url':request.form['url']}
        else:
            #I think this is the uploaded file data but I'm not certain
            file_data = request.files['file']
            full_name = request.form['code'] + secure_filename(file_data.filename)
            #I think I can shorten this path and make it relative
            file_data.save('static/user_files/' + full_name)
            urls[request.form['code']] = {'file':full_name}

        with open('urls.json','w', encoding='utf8') as url_file:
            json.dump(urls, url_file)
            session[request.form['code']] = True
        return render_template('your_url.html', code=request.form['code'])
    return redirect(url_for('home'))

@app.route('/<string:code>')
def redirect_to_url(code):
    """
    redirect page route
    """
    if os.path.exists('urls.json'):
        with open('urls.json', encoding='utf8') as urls_file:
            urls = json.load(urls_file)
            if code in urls.keys():
                if 'url' in urls[code].keys():
                    return redirect(urls[code]['url'])
                return redirect(url_for('static', filename='user_files/' + urls[code]['file']))
    return abort(404)

@app.errorhandler(404)
def page_not_found(_error):
    """
    404 page route
    Added the underscore to silence the unused var error
    """
    return render_template('page_not_found.html'), 404

@app.route('/api')
def session_api():
    """
    api page route
    """
    return jsonify(list(session.keys()))

def greet(person):
    """
    greet function for testing
    """
    return f"Hi {person}"
