#!/usr/bin/env python3
import subprocess
from typing import Union

import click
import logging
import os

from enum import Enum

from src.application import Application
from src.device import DeviceType
from src.device.emulator import Emulator
from src.device.geny_aws import GenyAWS
from src.device.geny_saas import GenySAAS
from src.helper import convert_str_to_bool, get_env_value_or_raise
from src.constants import ENV
from src.logger import log

log.init()
logger = logging.getLogger("App")


def get_device(given_input: str) -> Union[Emulator, GenyAWS, GenySAAS, None]:
    """
    Get Device object based on given input

    :param given_input: device in string
    :return: Platform object
    """

    input_lower = given_input.lower()

    if input_lower == DeviceType.EMULATOR.value.lower():
        emu_av = get_env_value_or_raise(ENV.EMULATOR_ANDROID_VERSION)
        emu_img_type = get_env_value_or_raise(ENV.EMULATOR_IMG_TYPE)
        emu_sys_img = get_env_value_or_raise(ENV.EMULATOR_SYS_IMG)

        emu_device = os.getenv(ENV.EMULATOR_DEVICE, "Nexus 5")
        emu_data_partition = os.getenv(ENV.EMULATOR_DATA_PARTITION, "550m")
        emu_additional_args = os.getenv(ENV.EMULATOR_ADDITIONAL_ARGS, "")

        emu_name = os.getenv(ENV.EMULATOR_NAME, "{d}_{v}".format(
            d=emu_device.replace(" ", "_").lower(), v=emu_av))
        emu = Emulator(emu_name, emu_device, emu_av, emu_data_partition,
                       emu_additional_args, emu_img_type, emu_sys_img)
        return emu
    elif input_lower == DeviceType.GENY_AWS.value.lower():
        return GenyAWS()
    elif input_lower == DeviceType.GENY_SAAS.value.lower():
        return GenySAAS()
    else:
        return None


@click.group(context_settings=dict(help_option_names=['-h', '--help']))
def cli():
    pass


def start_appium() -> None:
    if convert_str_to_bool(os.getenv(ENV.APPIUM)):
        cmd = f"/usr/bin/appium"
        app_appium = Application("Appium", cmd,
                                 os.getenv(ENV.APPIUM_ADDITIONAL_ARGS, ""), False)
        app_appium.start()
    else:
        logger.info("env APPIUM cannot be found, Appium is not started!")


def start_device() -> None:
    given_pt = get_env_value_or_raise(ENV.DEVICE_TYPE)
    selected_device = get_device(given_pt)
    if selected_device is None:
        raise RuntimeError(f"'{given_pt}' is invalid! Please check again!")
    selected_device.create()
    selected_device.start()
    selected_device.wait_until_ready()
    selected_device.reconfigure()
    selected_device.keep_alive()


def start_display_screen() -> None:
    cmd = "/usr/bin/Xvfb"
    args = f"{os.getenv(ENV.DISPLAY)} " \
           f"-screen {os.getenv(ENV.SCREEN_NUMBER)} " \
           f"{os.getenv(ENV.SCREEN_WIDTH)}x" \
           f"{os.getenv(ENV.SCREEN_HEIGHT)}x" \
           f"{os.getenv(ENV.SCREEN_DEPTH)}"
    d_screen = Application("d_screen", cmd, args, False)
    d_screen.start()


def start_display_wm() -> None:
    cmd = "/usr/bin/openbox-session"
    d_wm = Application("d_wm", cmd)
    d_wm.start()


def start_port_forwarder() -> None:
    import socket
    local_ip = socket.gethostbyname(socket.gethostname())
    cmd = f"/usr/bin/socat tcp-listen:5554,bind={local_ip},fork tcp:127.0.0.1:5554 & " \
          f"/usr/bin/socat tcp-listen:5555,bind={local_ip},fork tcp:127.0.0.1:5555"
    pf = Application("port_forwarder", cmd)
    pf.start()


def start_vnc_server() -> None:
    cmd = "/usr/bin/x11vnc"
    vnc_pass = os.getenv(ENV.VNC_PASSWORD)
    if vnc_pass:
        pass_path = os.path.join(os.getenv(ENV.WORK_PATH), ".vncpass")
        subprocess.check_call(f"{cmd} -storepasswd {vnc_pass} {pass_path}", shell=True)
        last_arg = f"-rfbauth {pass_path}"
    else:
        last_arg = "-nopw"

    display = os.getenv(ENV.DISPLAY)
    args = f"-display {display} -forever -shared {last_arg}"
    vnc_server = Application("vnc_web", cmd, args, False)
    vnc_server.start()


def start_vnc_web() -> None:
    if convert_str_to_bool(os.getenv(ENV.WEB_VNC)):
        vnc_port = get_env_value_or_raise(ENV.VNC_PORT)
        vnc_web_port = get_env_value_or_raise(ENV.WEB_VNC_PORT)
        cmd = "/opt/noVNC/utils/novnc_proxy"
        args = f"--vnc localhost:{vnc_port} localhost:{vnc_web_port}"
        vnc_web = Application("vnc_web", cmd, args, False)
        vnc_web.start()
    else:
        logger.info("env WEB_VNC cannot be found, VNC_WEB is not started!")


@cli.command()
@click.argument("app", type=click.Choice([app.value for app in Application.App]))
def start(app):
    selected_app = str(app).lower()
    if selected_app == Application.App.APPIUM.value.lower():
        start_appium()
    elif selected_app == Application.App.DEVICE.value.lower():
        start_device()
    elif selected_app == Application.App.DISPLAY_SCREEN.value.lower():
        start_display_screen()
    elif selected_app == Application.App.DISPLAY_WM.value.lower():
        start_display_wm()
    elif selected_app == Application.App.PORT_FORWARDER.value.lower():
        start_port_forwarder()
    elif selected_app == Application.App.VNC_SERVER.value.lower():
        start_vnc_server()
    elif selected_app == Application.App.VNC_WEB.value.lower():
        start_vnc_web()
    else:
        logger.error(f"application '{selected_app}' is not supported!")


class SharedComponent(Enum):
    LOG = "log"


def shared_log() -> None:
    if convert_str_to_bool(os.getenv(ENV.WEB_LOG)):
        from http.server import BaseHTTPRequestHandler, HTTPServer

        log_path = get_env_value_or_raise(ENV.LOG_PATH)
        log_port = int(get_env_value_or_raise(ENV.WEB_LOG_PORT))
        logger.info(f"Shared log is enabled! all logs can be found on port '{log_port}'")

        class LogSharedHandler(BaseHTTPRequestHandler):
            def do_GET(self):
                # root path
                if self.path == "/":
                    html = "<html><body>"
                    for f in os.listdir(log_path):
                        html += f"<p><a href=\"{f}\">{f}</a></p>"
                    html += "</body></html>"

                    self.send_response(200)
                    self.send_header("Content-type", "text/html")
                    self.end_headers()
                    self.wfile.write(html.encode())
                # open each selected log file
                else:
                    p = log_path + self.path
                    try:
                        with open(p, "rb") as file:
                            self.send_response(200)
                            self.send_header("Content-type", "text/plain")
                            self.end_headers()
                            self.wfile.write(file.read())
                    except FileNotFoundError:
                        self.send_error(404, "File not found")

        httpd = HTTPServer(('0.0.0.0', log_port), LogSharedHandler)
        httpd.serve_forever()
    else:
        logger.info(f"Shared log is disabled! nothing to do!")


@cli.command()
@click.argument("component", type=click.Choice([component.value for component in SharedComponent]))
def share(component):
    selected_component = str(component).lower()
    if selected_component == SharedComponent.LOG.value.lower():
        shared_log()
    else:
        logger.error(f"component '{component}' is not supported!")


if __name__ == '__main__':
    cli()
