import os

ROOT = '/root'
WORKDIR = os.path.dirname(__file__)
CHROME_DRIVER = os.path.join(ROOT, 'chromedriver')
CONFIG_FILE = os.path.join(WORKDIR, 'nodeconfig.json')
LOGGING_FILE = os.path.join(WORKDIR, 'logging.conf')
