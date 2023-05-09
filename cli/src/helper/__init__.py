import logging
import os

logger = logging.getLogger("helper")


def convert_str_to_bool(given_str: str) -> bool:
    """
    Convert String to Boolean value

    :param given_str: given string
    :return: converted string in Boolean
    """
    if given_str:
        if type(given_str) is str:
            return given_str.lower() in ("yes", "true", "t", "1")
        else:
            raise AttributeError
    else:
        logger.info(f"'{given_str}' is empty!")
        return False


def get_env_value_or_raise(env_key: str) -> str:
    """
    Get value of necessary environment variable.

    :param env_key: given environment variable
    :return: env_value in String
    """
    try:
        env_value = os.getenv(env_key)
        if not env_value:
            raise RuntimeError(f"'{env_key}' is missing.")
        elif env_value.isspace():
            raise RuntimeError(f"'{env_key}' contains only white space.")
        return env_value
    except TypeError as t_err:
        logger.error(t_err)


def symlink_force(source: str, target: str) -> None:
    """
    Create Symbolic link

    :param source: source file
    :param target: target file
    :return: None
    """
    try:
        os.symlink(source, target)
    except FileNotFoundError as ffe_err:
        logger.error(ffe_err)
    except FileExistsError:
        os.remove(target)
        os.symlink(source, target)
