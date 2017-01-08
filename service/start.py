import logging
import os
import re
import subprocess

logging.basicConfig()
logger = logging.getLogger('android_appium')


def run():
    """
    Start noVNC, installation of needed android SDK packages and Appium server.

    """
    android_version = os.getenv('ANDROID_VERSION', '4.2.2')
    os.environ['emulator_name'] = 'emulator_{version}'.format(version=android_version)

    # Start Xvfb
    subprocess.check_call('Xvfb ${DISPLAY} -screen ${SCREEN} ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} & '
                          'sleep ${TIMEOUT}', shell=True)

    # Start noVNC, installation of packages and appium
    vnc_cmd = 'openbox-session & x11vnc -display ${DISPLAY} -nopw -ncache 10 -forever & ' \
              './noVNC/utils/launch.sh --vnc localhost:${LOCAL_PORT} --listen ${TARGET_PORT}'
    android_cmd = get_android_bash_commands(android_version)
    if android_cmd:
        cmd = '({vnc}) & (xterm -T "Android-Appium" -n "Android-Appium" -e \"{android} && ' \
              '/bin/echo $emulator_name && appium\")'.format(vnc=vnc_cmd, android=android_cmd)
    else:
        logger.warning('There is no android packages installed!')
        cmd = '({vnc}) & (xterm -e \"appium\")'.format(vnc=vnc_cmd)
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

    :return: Item position.
    :rtype: int
    """
    pos = 0
    for p, v in enumerate(items):
        if keyword in v:
            pos = p
            break  # Get the first item that match with keyword
    return pos


def get_android_bash_commands(android_version):
    """
    Get bash commands to install given android version and to create android emulator.

    To see list of available targets: android list targets
    To see list to avd: android list avd

    :param android_version: android version
    :type android_version: str
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

            # Command to install armeabi v7a
            commands.append('echo y | android update sdk --no-ui -a --filter sys-img-armeabi-v7a-android-{api}'.format(
                api=api_version))

            # Command to create android emulator
            commands.append(
                'echo no | android create avd -f -n emulator_{version} -t android-{api} --abi armeabi-v7a'.format(
                    version=android_version, api=api_version))

            # Join all commands in one str for xterm
            bash_command = ' && '.join(commands)
        else:
            raise RuntimeError('Packages is empty!')

    except IndexError as i_err:
        logger.error(i_err)

    return bash_command


if __name__ == '__main__':
    logger.setLevel(logging.INFO)
    run()
