import logging
import os
import re
import subprocess

import appium

from service import CONFIG_FILE

logging.basicConfig()
logger = logging.getLogger('main')

# not using enum because need to install pip that will make docker image size bigger
TYPE_ARMEABI = 'armeabi'
TYPE_X86 = 'x86'


def run():
    """
    Start noVNC, installation of needed android SDK packages and Appium server.

    """
    # Get android version package
    android_version = os.getenv('ANDROID_VERSION', '4.2.2')
    emulator_name = 'emulator_{version}'.format(version=android_version)
    os.environ['EMULATOR_NAME'] = emulator_name

    # Get emulator type
    types = [TYPE_ARMEABI, TYPE_X86]
    emulator_type = os.getenv('EMULATOR_TYPE', TYPE_ARMEABI).lower()
    emulator_type = TYPE_ARMEABI if emulator_type not in types else emulator_type

    # Link emulator shortcut
    subprocess.check_call('ln -s $ANDROID_HOME/tools/{shortcut_file} $ANDROID_HOME/tools/emulator'.format(
        shortcut_file='emulator64-x86' if emulator_type == TYPE_X86 else 'emulator64-arm'), shell=True)

    # Option to connect with selenium server
    connect_to_grid = str_to_bool(str(os.getenv('CONNECT_TO_GRID', False)))
    logger.info('Connect with selenium grid? {input}'.format(input=connect_to_grid))
    appium_cmd = 'appium'
    if connect_to_grid:
        try:
            appium_host = os.getenv('APPIUM_HOST', '127.0.0.1')
            appium_port = int(os.getenv('APPIUM_PORT', 4723))
            selenium_host = os.getenv('SELENIUM_HOST', '172.17.0.1')
            selenium_port = int(os.getenv('SELENIUM_PORT', 4444))
            appium.create_node_config(CONFIG_FILE, emulator_name, android_version,
                                      appium_host, appium_port, selenium_host, selenium_port)
            appium_cmd += ' --nodeconfig {file}'.format(file=CONFIG_FILE)
        except ValueError as v_err:
            logger.error(v_err)

    # Start installation of android packages, emulator creation and appium in a terminal
    android_cmd = get_android_bash_commands(android_version, emulator_type)
    if android_cmd:
        cmd = 'xterm -T "Android-Appium" -n "Android-Appium" -e \"{android} && ' \
              '/bin/echo $EMULATOR_NAME && {appium}\"'.format(android=android_cmd, appium=appium_cmd)
    else:
        logger.warning('There is no android packages installed!')
        cmd = 'xterm -e \"{appium}\"'.format(appium=appium_cmd)
    subprocess.check_call(cmd, shell=True)


def get_available_sdk_packages():
    """
    Get list of available sdk packages.

    :return: List of available packages.
    :rtype: bytearray
    """
    cmd = ['android', 'list', 'sdk']
    output_str = subprocess.check_output(cmd)
    logger.info('List of Android SDK: ')
    logger.info(output_str)
    return [output.strip() for output in output_str.split('\n')] if output_str else None


def get_item_position(keyword, items):
    """
    Get position of item in array by given keyword.

    :return: item position
    :rtype: int
    """
    pos = 0
    for p, v in enumerate(items):
        if keyword in v:
            pos = p
            break  # Get the first item that match with keyword
    return pos


def get_android_bash_commands(android_version, emulator_type):
    """
    Get bash commands to install given android version and to create android emulator based on given type.

    To see list of available targets: android list targets
    To see list to avd: android list avd

    :param android_version: android version
    :type android_version: str
    :param emulator_type: emulator type
    :type emulator_type: str
    :return: bash commands
    :rtype: bytearray
    """
    bash_command = None

    try:
        packages = get_available_sdk_packages()

        if packages:
            item_pos = get_item_position(android_version, packages)
            logger.info('item position: {pos}'.format(pos=item_pos))
            item = packages[item_pos]

            item_info = item.split('-')
            package_number = item_info[0]
            api_version = re.search('%s(.*)%s' % ('API', ','), item_info[1]).group(1).strip()
            logger.info(
                'Package number: {number}, API version: {version}'.format(number=package_number, version=api_version))

            commands = []

            # Command to install SDK package
            commands.append('echo y | android update sdk --no-ui --filter {number}'.format(number=package_number))

            # Command to install system image and create android emulator
            sys_img = 'x86' if emulator_type == TYPE_X86 else 'armeabi-v7a'
            commands.append('echo y | android update sdk --no-ui -a --filter sys-img-{sys_img}-android-{api}'.format(
                sys_img=sys_img, api=api_version))
            commands.append(
                'echo no | android create avd -f -n emulator_{version} -t android-{api} --abi {sys_img}'.format(
                    version=android_version, api=api_version, sys_img=sys_img))

            # Join all commands in one str for xterm
            bash_command = ' && '.join(commands)
        else:
            raise RuntimeError('Packages is empty!')

    except IndexError as i_err:
        logger.error(i_err)

    return bash_command


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
    logger.setLevel(logging.INFO)
    run()
