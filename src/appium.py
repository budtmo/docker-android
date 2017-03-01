import json
import logging
import os
import subprocess

logger = logging.getLogger('appium')


def run(connect_to_grid, emulator_name, android_version):
    """
    Run appium server.

    :param connect_to_grid: option to connect with selenium grid
    :type connect_to_grid: bool
    :param emulator_name: name of emulator
    :type emulator_name: str
    :param android_version: android version
    :type android_version: str
    """
    cmd = 'appium'
    if connect_to_grid:
        from src import CONFIG_FILE
        try:
            appium_host = os.getenv('APPIUM_HOST', '127.0.0.1')
            appium_port = int(os.getenv('APPIUM_PORT', 4723))
            selenium_host = os.getenv('SELENIUM_HOST', '172.17.0.1')
            selenium_port = int(os.getenv('SELENIUM_PORT', 4444))
            create_node_config(CONFIG_FILE, emulator_name, android_version,
                               appium_host, appium_port, selenium_host, selenium_port)
            cmd += ' --nodeconfig {file}'.format(file=CONFIG_FILE)
        except ValueError as v_err:
            logger.error(v_err)
    titel = 'avd name: {name}'.format(name=emulator_name)
    subprocess.check_call('xterm -T "{titel}" -n "{titel}" -e \"{cmd}\"'.format(
        titel=titel, cmd=cmd), shell=True)


def create_node_config(config_file, emulator_name, android_version, appium_host, appium_port,
                       selenium_host, selenium_port):
    """
    Create custom node config file in json format to be able to connect with selenium server.

    :param config_file: config file
    :type config_file: str
    :param emulator_name: emulator name
    :type emulator_name: str
    :param android_version: android version of android emulator
    :type android_version: str
    :param appium_host: host where appium server is running
    :type appium_host: str
    :param appium_port: port number where where appium server is running
    :type appium_port: int
    :param selenium_host: host where selenium server is running
    :type selenium_host: str
    :param selenium_port: port number where selenium server is running
    :type selenium_port: int

    """
    config = {
        'capabilities': [
            {
                'platform': 'Android',
                'platformName': 'Android',
                'version': android_version,
                'browserName': emulator_name,
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
            'hubPort': selenium_port
        }
    }
    logger.info('appium node config: {config}'.format(config=config))
    with open(config_file, 'w') as cf:
        cf.write(json.dumps(config))
