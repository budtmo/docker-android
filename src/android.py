import logging
import os
import re
import subprocess

logging.basicConfig()
logger = logging.getLogger('android')


def get_api_level(android_version):
    """
    Get api level of android version.

    :param android_version: android version
    :type android_version: str
    :return: api version
    :rtype: str
    """
    api_version = None

    try:
        packages = get_available_sdk_packages()

        if packages:
            item_pos = get_item_position(android_version, packages)
            logger.info('package in position: {pos}'.format(pos=item_pos))
            item = packages[item_pos]

            item_info = item.split('-')
            api_version = re.search('%s(.*)%s' % ('API', ','), item_info[1]).group(1).strip()
            logger.info(
                'API level: {api}'.format(api=api_version))
        else:
            raise RuntimeError('List of packages is empty!')

    except IndexError as i_err:
        logger.error(i_err)

    return api_version


def install_package(android_path, emulator_file, api_level, sys_img):
    """
    Install sdk package.

    :param android_path: location where android SDK is installed
    :type android_path: str
    :param emulator_file: emulator file that need to be link
    :type emulator_file: str
    :param api_level: api level
    :type api_level: str
    :param sys_img: system image of emulator
    :type sys_img: str
    """
    # Link emulator shortcut
    emu_file = os.path.join(android_path, 'tools', emulator_file)
    emu_target = os.path.join(android_path, 'tools', 'emulator')
    os.symlink(emu_file, emu_target)

    # Install package based on given android version
    cmd = 'echo y | android update sdk --no-ui -a -t android-{api},sys-img-{sys_img}-android-{api}'.format(
        api=api_level, sys_img=sys_img)
    logger.info('Android installation command : {install}'.format(install=cmd))
    subprocess.check_call('xterm -e \"{cmd}\"'.format(cmd=cmd), shell=True)


def create_avd(android_path, avd_name, api_level):
    """
    Create android virtual device.

    :param android_path: location where android SDK is installed
    :type android_path: str
    :param avd_name: desire name
    :type avd_name: str
    :param api_level: api level
    :type api_level: str
    """
    # Link emulator skins
    skins_rsc = os.path.join(android_path, 'skins')
    skins_dst = os.path.join(android_path, 'platforms', 'android-{api}'.format(api=api_level), 'skins')
    for skin_file in os.listdir(skins_rsc):
        os.symlink(os.path.join(skins_rsc, skin_file), os.path.join(skins_dst, skin_file))

    # Create android emulator
    cmd = 'echo no | android create avd -f -n {name} -t android-{api}'.format(name=avd_name, api=api_level)
    logger.info('Emulator creation command : {cmd}'.format(cmd=cmd))
    subprocess.check_call('xterm -e \"{cmd}\"'.format(cmd=cmd), shell=True)


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
