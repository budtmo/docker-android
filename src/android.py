import logging
import os
import subprocess

from src import ANDROID_PATH

logger = logging.getLogger('android')

EMULATOR = 'emulator'
TYPE_ARMEABI = 'armeabi'
TYPE_X86 = 'x86'
TYPE_X86_64 = 'x86_64'

API_LEVELS = {
    '2.1': 7,
    '2.2': 8,
    '2.3.1': 9,
    '2.3.3': 1,
    '3.0': 11,
    '3.1': 12,
    '3.2': 13,
    '4.0': 14,
    '4.0.3': 15,
    '4.1.2': 16,
    '4.2.2': 17,
    '4.3.1': 18,
    '4.4.2': 19,
    '4.4W.2': 20,
    '5.0.1': 21,
    '5.1.1': 22,
    '6.0': 23,
    '7.0': 24,
    '7.1.1': 25
}


def get_api_level(android_version):
    """
    Get api level of android version.

    :param android_version: android version
    :type android_version: str
    :return: api level
    :rtype: int
    """
    api_level = None

    try:
        for key in sorted(API_LEVELS):
            if android_version in key:
                api_level = API_LEVELS.get(key)
    except TypeError as t_err:
        logger.error(t_err)

    return api_level


def install_package(emulator_file, api_level, sys_img):
    """
    Install sdk package.

    :param emulator_file: emulator file that need to be link
    :type emulator_file: str
    :param api_level: api level
    :type api_level: str
    :param sys_img: system image of emulator
    :type sys_img: str
    """
    # Link emulator shortcut
    emu_file = os.path.join(ANDROID_PATH, 'tools', emulator_file)
    emu_target = os.path.join(ANDROID_PATH, 'tools', 'emulator')
    os.symlink(emu_file, emu_target)

    # Install package based on given android version
    cmd = 'echo y | android update sdk --no-ui -a -t android-{api},sys-img-{sys_img}-android-{api}'.format(
        api=api_level, sys_img=sys_img)
    logger.info('SDK package installation command: {install}'.format(install=cmd))
    titel = 'SDK package installation process'
    subprocess.check_call('xterm -T "{titel}" -n "{titel}" -e \"{cmd}\"'.format(titel=titel, cmd=cmd), shell=True)


def create_avd(device, avd_name, api_level):
    """
    Create android virtual device.

    :param device: name of device
    :type device: str
    :param avd_name: desire name
    :type avd_name: str
    :param api_level: api level
    :type api_level: str
    """
    # Create android emulator
    cmd = 'echo no | android create avd -f -n {name} -t android-{api}'.format(name=avd_name, api=api_level)
    if device != EMULATOR:
        # Link emulator skins
        from src import ROOT
        skin_rsc_path = os.path.join(ROOT, 'devices', 'skins')
        logger.info('Skin ressource path: {rsc}'.format(rsc=skin_rsc_path))

        skin_dst_path = os.path.join(ANDROID_PATH, 'platforms', 'android-{api}'.format(api=api_level), 'skins')
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
    subprocess.check_call('xterm -T "{titel}" -n "{titel}" -e \"{cmd}\"'.format(titel=titel, cmd=cmd), shell=True)
