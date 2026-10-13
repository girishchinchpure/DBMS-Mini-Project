from flask import Flask
from dotenv import load_dotenv

from .routes import main


def create_app():
    load_dotenv()
    app = Flask(__name__)
    app.config['SECRET_KEY'] = __import__('os').getenv('FLASK_SECRET_KEY', 'dev-secret-key')
    app.register_blueprint(main)
    return app
