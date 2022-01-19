
import json
#import logging

# system imports
import os
import secrets

# web imports
from flask import Flask
from flask_executor import Executor
from flask_executor.futures import Future
from flask_shell2http import Shell2HTTP

# Globals
app = Flask(__name__)
#app.config["SECRET_KEY"] = secrets.token_hex(16)
executor = Executor(app)
#shell2http = Shell2HTTP(app, executor)
shell2http = Shell2HTTP(app, executor, base_url_prefix="/commands/")


# Functions


def intercept_result(context, future: Future) -> None:
    """
    Floss doesn't output result to standard output but to a file,
    using this callback function,
    we intercept the future object and update it's result attribute
    by reading the final analysis result from the saved result file
    before it is ready to be consumed.
    """
    # 1. get current result object
    res = future.result()
    # 2. dir from which we will read final analysis result
    f_loc = context.get("read_result_from", None)
    if not f_loc:
        res["error"] += ", No specified file to read result from"
        if res.get("returncode", -1) == 0:
            res["returncode"] = -1
    else:
        try:
            with open(f"/tmp/{f_loc}.json", "r") as fp:
                try:
                    res["report"] = json.load(fp)
                except json.JSONDecodeError:
                    res["report"] = fp.read()
        except FileNotFoundError:
            res["error"] += ", Output File Not Found."

    # 4. set final result after modifications
    future._result = res

    # 5. file can be removed now
    os.remove(f_loc)




def my_callback_fn(context, future):
  # optional user-defined callback function
  """Print 'Hello, world!' as the response body."""
  print(context, future.result())


shell2http.register_command(endpoint="wkhtmltopdf", command_name="/bin/wkhtmltopdf", callback_fn=my_callback_fn, decorators=[])
shell2http.register_command(endpoint="hello", command_name="echo", callback_fn=my_callback_fn, decorators=[])
