from flaskwebgui import FlaskUI
from main import app

# Created by ScillFury(scillfury@gmail.com)
FlaskUI(server='flask', app= app, fullscreen=True, port=3000,).run()
