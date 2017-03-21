import os

ROOT = '/root'
ANDROID_PATH = os.getenv('ANDROID_HOME', '/root')
WORKDIR = os.path.dirname(__file__)
CONFIG_FILE = os.path.join(WORKDIR, 'nodeconfig.json')
LOGGING_FILE = os.path.join(WORKDIR, 'logging.conf')
