import logging
import logging.config

from src import LOGGING_FILE


def init():
    logging.config.fileConfig(LOGGING_FILE)
