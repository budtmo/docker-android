import logging
import os
import re
import subprocess

logging.basicConfig()
logger = logging.getLogger('android_appium')


def run():
    """
    Run Android emulator and Appium server.

    """
    android_version = os.getenv('ANDROID_VERSION', '4.2.2')
    create_android_emulator(android_version)

    emulator_name = 'emulator_{version}'.format(version=android_version)

    logger.info('android emulator name: {name} '.format(name=emulator_name))
    # TODO: check android emulator is ready to use
    cmd_run = 'emulator -avd {name} -no-audio -no-window & appium'.format(name=emulator_name)
    subprocess.check_call(cmd_run, shell=True)


def get_available_sdk_packages():
    """
    Get list of available sdk packages.

    :return: List of available packages.
    :rtype: bytearray
    """
    logger.info('List of Android SDK: ')
    cmd = ['android', 'list', 'sdk']

    output_str = subprocess.check_output(cmd)
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


def create_android_emulator(android_version):
    """
    Create android emulator based on given android version.

    It include installation of sdk package and its armeabi v7a.
    To see list of available targets: android list targets
    To see list to avd: android list avd

    :param android_version: android version
    :type android_version: str
    """
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

            # Install SDK package
            logger.info('Installing SDK package...')
            cmd_sdk = 'echo y | android update sdk --no-ui --filter {number}'.format(number=package_number)
            subprocess.check_call(cmd_sdk, shell=True)
            logger.info('Installation completed')

            # Install armeabi v7a
            logger.info('Installing its armeabi...')
            cmd_arm = 'echo y | android update sdk --no-ui -a --filter sys-img-armeabi-v7a-android-{api}'.format(
                api=api_version)
            subprocess.check_call(cmd_arm, shell=True)
            logger.info('Installation completed')

            # Create android emulator
            logger.info('Creating android emulator...')
            cmd_emu = 'echo no | android create avd -f -n emulator_{version} -t android-{api} --abi armeabi-v7a'.format(
                version=android_version, api=api_version)
            subprocess.check_call(cmd_emu, shell=True)
            logger.info('Android emulator is created')
        else:
            raise RuntimeError('Packages is empty!')

    except IndexError as i_err:
        logger.error(i_err)


if __name__ == '__main__':
    logger.setLevel(logging.INFO)
    run()
