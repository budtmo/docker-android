import logging
import logging.config

from src import LOGGING_FILE


def init():
    """Init log."""
    logging.config.fileConfig(LOGGING_FILE)
