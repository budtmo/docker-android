import logging
import os

from src import android, appium, log

logger = logging.getLogger('service')


def start():
    """
    Installation of needed sdk package, creation of android emulator and execution of appium server.

    """
    # Device name
    device = os.getenv('DEVICE', 'Nexus 5')

    # Android version
    android_version = os.getenv('ANDROID_VERSION', '5.0')
    logger.info('Android version: {version}'.format(version=android_version))

    # Emulator type
    emu_type = os.getenv('EMULATOR_TYPE', android.TYPE_ARMEABI).lower()
    emu_type = android.TYPE_ARMEABI if emu_type not in [android.TYPE_ARMEABI, android.TYPE_X86] else emu_type
    logger.info('Emulator type: {type}'.format(type=emu_type))
    emu_file = 'emulator64-x86' if emu_type == android.TYPE_X86 else 'emulator64-arm'
    logger.info('Emulator file: {file}'.format(file=emu_file))

    # Selenium grid connection
    connect_to_grid = str_to_bool(str(os.getenv('CONNECT_TO_GRID', False)))
    logger.info('Connect to selenium grid? {input}'.format(input=connect_to_grid))

    # Install android sdk package
    api_level = android.get_api_level(android_version)
    # Bug: cannot use skin for system image x86 with android version < 5.0
    if emu_type == android.TYPE_X86:
        if int(api_level) < android.get_api_level('5.0'):
            sys_img = android.TYPE_X86
            device = android.EMULATOR
        else:
            sys_img = android.TYPE_X86_64
    else:
        sys_img = '{type}-v7a'.format(type=android.TYPE_ARMEABI)
    logger.info('System image: {sys_img}'.format(sys_img=sys_img))
    android.install_package(emu_file, api_level, sys_img)

    # Create android virtual device
    logger.info('Device: {device}'.format(device=device))
    avd_name = '{device}_{version}'.format(device=device.replace(' ', '_').lower(), version=android_version)
    logger.info('AVD name: {avd}'.format(avd=avd_name))
    android.create_avd(device, avd_name, api_level)

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
