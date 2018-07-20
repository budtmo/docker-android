#!/usr/bin/env python3

import json
import logging
import os
import subprocess

from src import CHROME_DRIVER, CONFIG_FILE, ROOT
from src import log

log.init()
logger = logging.getLogger('app')


def symlink_force(target, link_name):
    try:
        os.symlink(target, link_name)
    except OSError as e:
        import errno
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


def is_initialized() -> bool:
    return os.path.exists(INIT_FILE)


def finish_initialization():
    file = open(INIT_FILE, 'w+')
    file.close()


ANDROID_HOME = get_or_raise('ANDROID_HOME')
ANDROID_VERSION = get_or_raise('ANDROID_VERSION')
API_LEVEL = get_or_raise('API_LEVEL')
PROCESSOR = get_or_raise('PROCESSOR')
SYS_IMG = get_or_raise('SYS_IMG')
IMG_TYPE = get_or_raise('IMG_TYPE')
INIT_FILE = os.getenv('INIT_FILE', "/root/init")

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

    device_name_bash = device.replace(' ', '\ ')
    skin_name = device.replace(' ', '_').lower()

    # For custom hardware profile
    profile_dst_path = os.path.join(ROOT, '.android', 'devices.xml')
    if 'samsung' in device.lower():
        # profile file name = skin name
        profile_src_path = os.path.join(ROOT, 'devices', 'profiles', '{profile}.xml'.format(profile=skin_name))
        logger.info('Hardware profile resource path: {rsc}'.format(rsc=profile_src_path))
        logger.info('Hardware profile destination path: {dst}'.format(dst=profile_dst_path))
        symlink_force(profile_src_path, profile_dst_path)

    avd_path = '/'.join([ANDROID_HOME, 'android_emulator'])
    creation_cmd = 'avdmanager create avd -f -n {name} -b {img_type}/{sys_img} -k "system-images;android-{api_lvl};' \
                   '{img_type};{sys_img}" -d {device} -p {path}'.format(name=avd_name, img_type=IMG_TYPE,
                                                                        sys_img=SYS_IMG,
                                                                        api_lvl=API_LEVEL, device=device_name_bash,
                                                                        path=avd_path)
    logger.info('Command to create avd: {command}'.format(command=creation_cmd))
    subprocess.check_call(creation_cmd, shell=True)

    skin_path = '/'.join([ANDROID_HOME, 'devices', 'skins', skin_name])
    config_path = '/'.join([avd_path, 'config.ini'])
    with open(config_path, 'a') as file:
        file.write('skin.path={sp}'.format(sp=skin_path))
    logger.info('Skin was added in config.ini')


def appium_run(avd_name: str):
    """
    Run appium server.

    :param avd_name: Name of android virtual device / emulator
    """
    DEFAULT_LOG_PATH = '/var/log/supervisor/appium.log'
    cmd = 'appium --log {log}'.format(log=os.getenv('APPIUM_LOG', DEFAULT_LOG_PATH))

    relaxed_security = convert_str_to_bool(str(os.getenv('RELAXED_SECURITY', False)))
    logger.info('Relaxed security? {rs}'.format(rs=relaxed_security))
    if relaxed_security:
        cmd += ' --relaxed-security'

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
    is_first_run = not is_initialized()

    if is_first_run:
        logger.info('Preparing emulator...')
        prepare_avd(device, avd_name)
        finish_initialization()

    logger.info('Run emulator...')
    dp_size = os.getenv('DATAPARTITION', '550m')
    with open("/root/android_emulator/config.ini", "a") as cfg:
        cfg.write('\ndisk.dataPartition.size={dp}'.format(dp=dp_size))

    if is_first_run:
        cmd = 'emulator/emulator @{name} -gpu off -verbose -wipe-data'.format(name=avd_name)
    else:
        cmd = 'emulator/emulator @{name} -gpu off -verbose'.format(name=avd_name)
    appium = convert_str_to_bool(str(os.getenv('APPIUM', False)))
    if appium:
        subprocess.Popen(cmd.split())
        logger.info('Run appium server...')
        appium_run(avd_name)
    else:
        result = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE).communicate()


if __name__ == '__main__':
    run()
