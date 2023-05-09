import logging.config

from src.logger import LOGGING_FILE


def init():
    logging.config.fileConfig(LOGGING_FILE)
