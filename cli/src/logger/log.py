import logging.config

from logger import LOGGING_FILE


def init():
    logging.config.fileConfig(LOGGING_FILE)
