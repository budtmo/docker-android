#!/usr/bin/env python3

import json
import logging
import os
import re
import subprocess
import uuid
import toml

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

def replace_str_in_file(file_path: str, find: str, replace: str):
    """
    Replace string in a file.

    :param file_path: target file path
    :param find: string to find
    :param replace: string to replace
    """
    # Read in the file
    with open(file_path, 'r') as file :
        filedata = file.read()

    # Replace the target string
    filedata = filedata.replace(find, replace)

    # Write the file out again
    with open(file_path, 'w') as file:
        file.write(filedata)

def get_selenium_jar_url():
    """
    Get the latest selenium server jar url 
    """
    # Command to find jar url
    command = 'curl -sk https://github.com/SeleniumHQ/selenium/releases/ | grep ".jar" | head -n 1 | grep -Eo "/[a-zA-Z0-9./?=_%:-]*"'
    
    # Call to shell process to get the jar url
    process = subprocess.Popen(command, stdout=subprocess.PIPE, universal_newlines=True, shell=True)
    try:
        stdout, errs = process.communicate(timeout=10)
        return stdout.strip()
    except subprocess.TimeoutExpired:
        process.kill()
        stdout, errs = process.communicate()
        logger.error(errs)

def is_initialized(device_name) -> bool:
    config_path = os.path.join(ROOT, 'android_emulator', 'config.ini')

    if os.path.exists(config_path):
        logger.info('Found existing config file at {}.'.format(config_path))
        with open(config_path, 'r') as f:
            if any(re.match(r'hw\.device\.name ?= ?{}'.format(device_name), line) for line in f):
                logger.info('Existing config file references {}. Assuming device was previously initialized.'.format(device_name))
                return True
            else:
                logger.info('Existing config file does not reference {}. Assuming new device.'.format(device_name))
                return False

    logger.info('No config file file was found at {}. Assuming new device.'.format(config_path))
    return False


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


def prepare_avd(device: str, avd_name: str, dp_size: str):
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
        profile_src_path = os.path.join(ANDROID_HOME, 'devices', 'profiles', '{profile}.xml'.format(profile=skin_name))
        logger.info('Hardware profile resource path: {rsc}'.format(rsc=profile_src_path))
        logger.info('Hardware profile destination path: {dst}'.format(dst=profile_dst_path))
        symlink_force(profile_src_path, profile_dst_path)

    avd_path = '/'.join([ROOT, 'android_emulator'])
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
        file.write('\ndisk.dataPartition.size={dp}'.format(dp=dp_size))

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
    cmd += ' --chromedriver-executable {driver}'.format(driver=CHROME_DRIVER)
    cmd_connect_grid_4 = ''

    grid_connect = convert_str_to_bool(str(os.getenv('CONNECT_TO_GRID', False)))
    logger.info('Connect to selenium grid? {connect}'.format(connect=grid_connect))
    grid4_connect = convert_str_to_bool(str(os.getenv('CONNECT_TO_GRID_4', False)))
    logger.info('Connect to selenium grid 4? {connect}'.format(connect=grid4_connect))
    if grid_connect and grid4_connect == False:
        # Ubuntu 16.04 -> local_ip = os.popen('ifconfig eth0 | grep \'inet addr:\' | cut -d: -f2 | awk \'{ print $1}\'').read().strip()
        local_ip = os.popen('ifconfig eth0 | grep \'inet\' | cut -d: -f2 | awk \'{ print $2}\'').read().strip()
        try:
            mobile_web_test = convert_str_to_bool(str(os.getenv('MOBILE_WEB_TEST', False)))
            appium_host = os.getenv('APPIUM_HOST', local_ip)
            appium_port = int(os.getenv('APPIUM_PORT', 4723))
            selenium_host = os.getenv('SELENIUM_HOST', '172.17.0.1')
            selenium_port = int(os.getenv('SELENIUM_PORT', 4444))
            selenium_timeout = int(os.getenv('SELENIUM_TIMEOUT', 30))
            selenium_proxy_class = os.getenv('SELENIUM_PROXY_CLASS', 'org.openqa.grid.selenium.proxy.DefaultRemoteProxy')
            browser_name = default_web_browser if mobile_web_test else 'android'
            create_node_config(avd_name, browser_name, appium_host, appium_port, selenium_host, selenium_port,
                               selenium_timeout, selenium_proxy_class)
            cmd += ' --nodeconfig {file}'.format(file=CONFIG_FILE)
        except ValueError as v_err:
            logger.error(v_err)
    elif grid4_connect == True:
        local_ip = os.popen('ifconfig eth0 | grep \'inet\' | cut -d: -f2 | awk \'{ print $2}\'').read().strip()
        try:
            mobile_web_test = convert_str_to_bool(str(os.getenv('MOBILE_WEB_TEST', False)))
            appium_host = os.getenv('APPIUM_HOST', local_ip)
            appium_port = int(os.getenv('APPIUM_PORT', 4723))
            plafform_name = 'android'
            device_name = os.getenv('DEVICE', 'chrome')
            browser_name = default_web_browser if mobile_web_test else device_name
            create_node_config_selenium_grid_4(browser_name, appium_host, appium_port, plafform_name)
            # Get the latest selenium server release version
            proc = subprocess.popen('curl -s https://github.com/SeleniumHQ/selenium/releases/ | grep ".jar" | head -n 1 | grep -Eo "/[a-zA-Z0-9./?=_%:-]*"').read().strip()
            try:
                outs, errs = proc.communicate(timeout=15)
                logger.info('Latest selenium server jar found: {outs}'.format(outs=outs))
            except subprocess.TimeoutExpired:
                proc.kill()
                outs, errs = proc.communicate()
            logger.info('Latest selenium server jar found: {selenium_jar_version}'.format(selenium_jar_version=outs))
            download_selenium_server_url = 'https://github.com{selenium_jar_version}'.format(selenium_jar_version=outs)
            jar_url = '/opt/selenium/'
            if not os.path.isdir(jar_url):
                os.mkdir(jar_url)
            start_selenium_node = "/opt/bin/start-selenium-grid-node-docker.sh"
            subprocess.check_call('wget -O /opt/selenium/selenium-server.jar {selenium_jar_url}'.format(selenium_jar_url=download_selenium_server_url), shell=True)
            cmd_connect_grid_4 += "& sleep 3s; bash {start_node}".format(appium_host=appium_host, appium_port=appium_port, start_node=start_selenium_node)
        except ValueError as v_err:
            logger.error(v_err)
    else:
        logger.info('Skipping selenium grid connection')

    title = 'Appium Server'
    subprocess.check_call('xterm -T "{title}" -n "{title}" -e \"{cmd}\" {cmd_connect_grid_4}'.format(title=title, cmd=cmd, cmd_connect_grid_4=cmd_connect_grid_4), shell=True)

def create_node_config_selenium_grid_4(browser_name: str, appium_host: str, appium_port: int, platform_name: str):
    """
    Create custom appium node config file in toml format to be able to connect with new selenium grid 4 architecture.
    Documentation on this can be found here: https://www.selenium.dev/documentation/grid/configuration/toml_options/#relaying-commands-to-a-service-endpoint-that-supports-webdriver

    :param browser_name: According to Relay options this can be whatever the browser name is set by default, even though, if not browser is provided we can just put the name of android virtual device / emulator
    :param appium_host: Host where appium server is running
    :param appium_port: Port number where where appium server is running
    :param platform_name: Always set to android
    """

    config = {
        "server": {
            "port": 5556
        },
        "node": {
            "detect-drivers": False
        },
        "relay": {
            "url": 'http://{host}:{port}/wd/hub'.format(host=appium_host, port=appium_port),
            "status-endpoint": "/status",
            "configs": [
                "1",
                '{{"browserName": "{browser}", "platformName": "{platform}", "appium:platformVersion": "{version}"}}'.format(browser=browser_name, platform=platform_name, version=ANDROID_VERSION)
            ]
        }
    }

    logger.info('Creating new appium service endpoint configuration to connect to selenium server 4')
    file_dir = '/opt/bin/'
    output_file = os.path.join(file_dir, 'config.toml')
    if not os.path.isdir(file_dir):
        os.mkdir(file_dir)
    with open(output_file, "w") as toml_file:
        toml_string = toml.dump(config, toml_file)
    replace_str_in_file(output_file, ',]', ']')
    logger.info('Appium node config: {config}'.format(config=toml_string))

def create_node_config(avd_name: str, browser_name: str, appium_host: str, appium_port: int, selenium_host: str,
                       selenium_port: int, selenium_timeout: int, selenium_proxy_class: str):
    """
    Create custom node config file in json format to be able to connect with selenium server.

    :param avd_name: Name of android virtual device / emulator
    :param appium_host: Host where appium server is running
    :param appium_port: Port number where where appium server is running
    :param selenium_host: Host where selenium server is running
    :param selenium_port: Port number where selenium server is running
    :param selenium_timeout: Selenium session timeout in seconds
    :param selenium_proxy_class: Selenium Proxy class created in Selenium hub
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
            'timeout': selenium_timeout,
            'proxy': selenium_proxy_class,
            'url': 'http://{host}:{port}/wd/hub'.format(host=appium_host, port=appium_port),
            'host': appium_host,
            'port': appium_port,
            'maxSession': 1,
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
    custom_args=os.getenv('EMULATOR_ARGS', '')
    logger.info('Custom Args: {custom_args}'.format(custom_args=custom_args))

    avd_name = os.getenv('AVD_NAME', '{device}_{version}'.format(device=device.replace(' ', '_').lower(), version=ANDROID_VERSION))
    logger.info('AVD name: {avd}'.format(avd=avd_name))
    is_first_run = not is_initialized(device)

    dp_size = os.getenv('DATAPARTITION', '550m')

    if is_first_run:
        logger.info('Preparing emulator...')
        prepare_avd(device, avd_name, dp_size)

    logger.info('Run emulator...')

    if is_first_run:
        logger.info('Emulator was not previously initialized. Preparing a new one...')
        cmd = 'emulator @{name} -gpu swiftshader_indirect -accel on -wipe-data -writable-system -verbose {custom_args}'.format(name=avd_name, custom_args=custom_args)
    else:
        logger.info('Using previously initialized AVD...')
        cmd = 'emulator @{name} -gpu swiftshader_indirect -accel on -verbose -writable-system {custom_args}'.format(name=avd_name, custom_args=custom_args)

    appium = convert_str_to_bool(str(os.getenv('APPIUM', False)))
    if appium:
        subprocess.Popen(cmd.split())
        logger.info('Run appium server...')
        appium_run(avd_name)
    else:
        result = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE).communicate()


if __name__ == '__main__':
    run()
