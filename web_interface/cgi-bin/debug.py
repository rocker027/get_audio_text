#!/usr/bin/env python3

import sys
import os

print("Content-Type: text/html; charset=utf-8")
print()
print("<html><body>")
print("<h1>CGI Debug Information</h1>")
print(f"<p><strong>Python Version:</strong> {sys.version}</p>")
print(f"<p><strong>Python Executable:</strong> {sys.executable}</p>")
print(f"<p><strong>Current Working Directory:</strong> {os.getcwd()}</p>")
print(f"<p><strong>Script Path:</strong> {__file__}</p>")
print("<h2>Environment Variables:</h2>")
print("<ul>")
for key, value in os.environ.items():
    if key in ['REQUEST_METHOD', 'SERVER_SOFTWARE', 'CONTENT_TYPE', 'QUERY_STRING', 'PATH', 'PYTHONPATH']:
        print(f"<li><strong>{key}:</strong> {value}</li>")
print("</ul>")
print("</body></html>")