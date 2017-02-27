import logging
import os

from src import android, appium, log

logger = logging.getLogger('service')

# not using enum because need to install pip that will make docker image size bigger
TYPE_ARMEABI = 'armeabi'
TYPE_X86 = 'x86'


def start():
    """
    Installation of needed sdk package, creation of android emulator and execution of appium server.

    """
    # Get all needed environment variables
    android_path = os.getenv('ANDROID_HOME', '/root')
    logger.info('Android path: {path}'.format(path=android_path))
    emulator_type = os.getenv('EMULATOR_TYPE', TYPE_ARMEABI).lower()
    logger.info('Emulator type: {type}'.format(type=emulator_type))
    android_version = os.getenv('ANDROID_VERSION', '4.2.2')
    logger.info('Android version: {version}'.format(version=android_version))
    connect_to_grid = str_to_bool(str(os.getenv('CONNECT_TO_GRID', False)))
    logger.info('Connect to selenium grid? {input}'.format(input=connect_to_grid))

    # Install needed sdk packages
    emulator_type = TYPE_ARMEABI if emulator_type not in [TYPE_ARMEABI, TYPE_X86] else emulator_type
    emulator_file = 'emulator64-x86' if emulator_type == TYPE_X86 else 'emulator64-arm'
    logger.info('Emulator file: {file}'.format(file=emulator_file))
    api_level = android.get_api_level(android_version)
    sys_img = 'x86' if emulator_type == TYPE_X86 else 'armeabi-v7a'
    logger.info('System image: {sys_img}'.format(sys_img=sys_img))
    android.install_package(android_path, emulator_file, api_level, sys_img)

    # Create android virtual device
    avd_name = 'emulator_{version}'.format(version=android_version)
    logger.info('AVD name: {avd}'.format(avd=avd_name))
    android.create_avd(android_path, avd_name, api_level)

    # Run appium server
    appium.run(connect_to_grid, avd_name, android_version)


def str_to_bool(str):
    """
    Convert string to boolean.

    :param str: given string
    :type str: str
    :return: converted string
    :rtype: bool
    """
    return str.lower() in ('yes', 'true', 't', '1')

if __name__ == '__main__':
    log.init()
    start()
