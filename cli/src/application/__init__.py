import logging
import subprocess

from enum import Enum


class Application:
    class App(Enum):
        APPIUM = "appium"
        DEVICE = "device"
        DISPLAY_SCREEN = "display_screen"
        DISPLAY_WM = "display_wm"
        PORT_FORWARDER = "port_forwarder"
        VNC_SERVER = "vnc_server"
        VNC_WEB = "vnc_web"

    def __init__(self, name: str, command: str, additional_args: str = "", ui: bool = False) -> None:
        self.logger = logging.getLogger(self.__class__.__name__)
        self.name = name
        self.command = command
        self.additional_args = additional_args
        self.ui = ui

    def start(self) -> None:
        if self.ui:
            self.logger.info(f"{self.name} will be started with ui!")
            subprocess.check_call(f"/usr/bin/xterm -T {self.name} -n {self.name} "
                                  f"-e '{self.command} {self.additional_args}'", shell=True)
        else:
            self.logger.info(f"{self.name} will be started without ui!")
            subprocess.check_call(f"{self.command} {self.additional_args}", shell=True)

    def __repr__(self) -> str:
        return "Application(name={n}, command={c}, args={args}, ui={ui})".format(
            n=self.name, c=self.command, args=self.additional_args, ui=self.ui)
