import logging
import os
import re
import subprocess

logging.basicConfig()
logger = logging.getLogger('android')

# not using enum because need to install pip that will make docker image size bigger
TYPE_ARMEABI = 'armeabi'
TYPE_X86 = 'x86'
TYPE_X86_64 = 'x86_64'

API_LEVEL_ANDROID_5 = 21


def get_available_sdk_packages():
    """
    Get list of available sdk packages.

    :return: List of available packages.
    :rtype: bytearray
    """
    logger.info('List of Android SDK: ')
    output_str = subprocess.check_output('android list sdk'.split())
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
            pos = p  # Get the last item that match with keyword
    return pos


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
            logger.info('Package in position: {pos}'.format(pos=item_pos))
            item = packages[item_pos]
            logger.info('Item: {item}'.format(item=item))

            item_info = item.split('-')
            api_version = re.search('%s(.*)%s' % ('API', ','), item_info[1]).group(1).strip()
            logger.info('API level: {api}'.format(api=api_version))
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
    logger.info('SDK package installation command: {install}'.format(install=cmd))
    titel = 'SDK package installation process'
    subprocess.check_call('xterm -T "{titel}" -n "{titel}" -e \"{cmd}\"'.format(
        titel=titel, cmd=cmd), shell=True)


def create_avd(android_path, device, avd_name, api_level):
    """
    Create android virtual device.

    :param android_path: location where android SDK is installed
    :type android_path: str
    :param device: name of device
    :type device: str
    :param avd_name: desire name
    :type avd_name: str
    :param api_level: api level
    :type api_level: str
    """
    # Create android emulator
    cmd = 'echo no | android create avd -f -n {name} -t android-{api}'.format(name=avd_name, api=api_level)
    if device != 'emulator':
        # Link emulator skins
        from src import ROOT
        skin_rsc_path = os.path.join(ROOT, 'devices', 'skins')
        logger.info('Skin ressource path: {rsc}'.format(rsc=skin_rsc_path))

        skin_dst_path = os.path.join(android_path, 'platforms', 'android-{api}'.format(api=api_level), 'skins')
        logger.info('Skin destination path: {dst}'.format(dst=skin_dst_path))

        for s in os.listdir(skin_rsc_path):
            os.symlink(os.path.join(skin_rsc_path, s), os.path.join(skin_dst_path, s))

        # Hardware and its skin
        device_name_bash = device.replace(' ', '\ ')
        skin_name = device.replace(' ', '_').lower()
        logger.info('device name in bash: {db}, skin name: {skin}'.format(db=device_name_bash, skin=skin_name))

        # For custom hardware profile
        profile_dst_path = os.path.join(ROOT, '.android', 'devices.xml')
        if 'samsung' in device.lower():
            # profile file name = skin name
            profile_src_path = os.path.join(ROOT, 'devices', 'profiles', '{profile}.xml'.format(profile=skin_name))
            logger.info('Hardware profile resource path: {rsc}'.format(rsc=profile_src_path))
            logger.info('Hardware profile destination path: {dst}'.format(dst=profile_dst_path))
            os.symlink(profile_src_path, profile_dst_path)

        # append command
        cmd += ' -d {device} -s {skin}'.format(device=device_name_bash, skin=skin_name)

    logger.info('AVD creation command: {cmd}'.format(cmd=cmd))
    titel = 'AVD creation process'
    subprocess.check_call('xterm -T "{titel}" -n "{titel}" -e \"{cmd}\"'.format(
        titel=titel, cmd=cmd), shell=True)
