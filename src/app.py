#!/usr/bin/env python3

import json
import logging
import os
import subprocess
import errno

from src import CONFIG_FILE, ROOT, CHROME_DRIVER
from src import log

log.init()
logger = logging.getLogger('app')

def symlink_force(target, link_name):
    try:
        os.symlink(target, link_name)
    except OSError as e:
        if e.errno == errno.EEXIST:
            os.remove(link_name)
            os.symlink(target, link_name)

def get_or_raise(env: str) -> str:
    """
    Check if needed environment variables are given.

    :param env: key
    :return: value
    """
    env_value = os.getenv(env)
    if not env_value:
        raise RuntimeError('The environment variable {0:s} is missing.'
                           'Please check docker image or Dockerfile!'.format(env))
    return env_value


def convert_str_to_bool(str: str) -> bool:
    """
    Convert string to boolean.

    :param str: given string
    :return: converted string
    """
    try:
        return str.lower() in ('yes', 'true', 't', '1')
    except AttributeError as err:
        logger.error(err)


ANDROID_HOME = get_or_raise('ANDROID_HOME')
ANDROID_VERSION = get_or_raise('ANDROID_VERSION')
API_LEVEL = get_or_raise('API_LEVEL')
PROCESSOR = get_or_raise('PROCESSOR')
SYS_IMG = get_or_raise('SYS_IMG')
IMG_TYPE = get_or_raise('IMG_TYPE')

logger.info('Android version: {version} \n'
            'API level: {level} \n'
            'Processor: {processor} \n'
            'System image: {img} \n'
            'Image type: {img_type}'.format(version=ANDROID_VERSION, level=API_LEVEL, processor=PROCESSOR,
                                            img=SYS_IMG, img_type=IMG_TYPE))


def prepare_avd(device: str, avd_name: str):
    """
    Create and run android virtual device.

    :param device: Device name
    :param avd_name: Name of android virtual device / emulator
    """
    cmd = 'echo no | android create avd -f -n {name} -t android-{api} -b {img_type}{sys_img}'.format(
        name=avd_name, api=API_LEVEL, img_type='google_apis/' if IMG_TYPE == 'google_apis' else '',
        sys_img=SYS_IMG)

    # Link emulator skins
    skin_rsc_path = os.path.join(ROOT, 'devices', 'skins')
    logger.info('Skin ressource path: {rsc}'.format(rsc=skin_rsc_path))
    skin_dst_path = os.path.join(ANDROID_HOME, 'platforms', 'android-{api}'.format(api=API_LEVEL), 'skins')
    logger.info('Skin destination path: {dst}'.format(dst=skin_dst_path))
    for s in os.listdir(skin_rsc_path):
        symlink_force(os.path.join(skin_rsc_path, s), os.path.join(skin_dst_path, s))

    # Hardware and its skin
    device_name_bash = device.replace(' ', '\ ')
    skin_name = device.replace(' ', '_').lower()
    logger.info('Device name in bash: {db}, Skin name: {skin}'.format(db=device_name_bash, skin=skin_name))

    # For custom hardware profile
    profile_dst_path = os.path.join(ROOT, '.android', 'devices.xml')
    if 'samsung' in device.lower():
        # profile file name = skin name
        profile_src_path = os.path.join(ROOT, 'devices', 'profiles', '{profile}.xml'.format(profile=skin_name))
        logger.info('Hardware profile resource path: {rsc}'.format(rsc=profile_src_path))
        logger.info('Hardware profile destination path: {dst}'.format(dst=profile_dst_path))
        symlink_force(profile_src_path, profile_dst_path)

    # Append command
    cmd += ' -d {device} -s {skin}'.format(device=device_name_bash, skin=skin_name)
    logger.info('AVD creation command: {cmd}'.format(cmd=cmd))
    subprocess.check_call(cmd, shell=True)


def appium_run(avd_name: str):
    """
    Run appium server.

    :param avd_name: Name of android virtual device / emulator
    """
    cmd = 'appium'

    default_web_browser = os.getenv('BROWSER')
    if default_web_browser == 'chrome':
        cmd += ' --chromedriver-executable {driver}'.format(driver=CHROME_DRIVER)

    grid_connect = convert_str_to_bool(str(os.getenv('CONNECT_TO_GRID', False)))
    logger.info('Connect to selenium grid? {connect}'.format(connect=grid_connect))
    if grid_connect:
        local_ip = os.popen('ifconfig eth0 | grep \'inet addr:\' | cut -d: -f2 | awk \'{ print $1}\'').read().strip()
        try:
            mobile_web_test = convert_str_to_bool(str(os.getenv('MOBILE_WEB_TEST', False)))
            appium_host = os.getenv('APPIUM_HOST', local_ip)
            appium_port = int(os.getenv('APPIUM_PORT', 4723))
            selenium_host = os.getenv('SELENIUM_HOST', '172.17.0.1')
            selenium_port = int(os.getenv('SELENIUM_PORT', 4444))
            browser_name = default_web_browser if mobile_web_test else 'android'
            create_node_config(avd_name, browser_name, appium_host, appium_port, selenium_host, selenium_port)
            cmd += ' --nodeconfig {file}'.format(file=CONFIG_FILE)
        except ValueError as v_err:
            logger.error(v_err)
    title = 'Appium Server'
    subprocess.check_call('xterm -T "{title}" -n "{title}" -e \"{cmd}\"'.format(title=title, cmd=cmd), shell=True)


def create_node_config(avd_name: str, browser_name: str, appium_host: str, appium_port: int, selenium_host: str,
                       selenium_port: int):
    """
    Create custom node config file in json format to be able to connect with selenium server.

    :param avd_name: Name of android virtual device / emulator
    :param appium_host: Host where appium server is running
    :param appium_port: Port number where where appium server is running
    :param selenium_host: Host where selenium server is running
    :param selenium_port: Port number where selenium server is running
    """
    config = {
        'capabilities': [
            {
                'platform': 'Android',
                'platformName': 'Android',
                'version': ANDROID_VERSION,
                'browserName': browser_name,
                'deviceName': avd_name,
                'maxInstances': 1,
            }
        ],
        'configuration': {
            'cleanUpCycle': 2000,
            'timeout': 30000,
            'proxy': 'org.openqa.grid.selenium.proxy.DefaultRemoteProxy',
            'url': 'http://{host}:{port}/wd/hub'.format(host=appium_host, port=appium_port),
            'host': appium_host,
            'port': appium_port,
            'maxSession': 6,
            'register': True,
            'registerCycle': 5000,
            'hubHost': selenium_host,
            'hubPort': selenium_port,
            'unregisterIfStillDownAfter': 120000
        }
    }
    logger.info('Appium node config: {config}'.format(config=config))
    with open(CONFIG_FILE, 'w') as cf:
        cf.write(json.dumps(config))


def run():
    """Run app."""
    device = os.getenv('DEVICE', 'Nexus 5')
    logger.info('Device: {device}'.format(device=device))

    avd_name = '{device}_{version}'.format(device=device.replace(' ', '_').lower(), version=ANDROID_VERSION)
    logger.info('AVD name: {avd}'.format(avd=avd_name))

    logger.info('Preparing emulator...')
    prepare_avd(device, avd_name)
    logger.info('Run emulator...')
    cmd = 'emulator -avd {name}'.format(name=avd_name)
    subprocess.Popen(cmd.split())

    appium = convert_str_to_bool(str(os.getenv('APPIUM', False)))
    if appium:
        logger.info('Run appium server...')
        appium_run(avd_name)

if __name__ == '__main__':
    run()
