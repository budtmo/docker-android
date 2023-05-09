import json
import logging
import os
import platform
import requests
import signal
import time

from abc import ABC, abstractmethod
from enum import Enum

from src.helper import convert_str_to_bool, get_env_value_or_raise
from src.constants import DEVICE, ENV


class DeviceType(Enum):
    EMULATOR = "emulator"
    GENY_SAAS = "geny_saas"
    GENY_AWS = "geny_aws"


class Device(ABC):
    FORM_ID = "1FAIpQLSdrKWQdMh6Nt8v8NQdYvTIntohebAgqWCpXT3T9NofAoxcpkw"
    FORM_USER = "user"
    FORM_CITY = "city"
    FORM_REGION = "region"
    FORM_COUNTRY = "country"
    FORM_APP_VERSION = "app_version"
    FORM_APPIUM = "appium"
    FORM_APPIUM_ADDITIONAL_ARGS = "appium_additional_args"
    FORM_WEB_LOG = "web_log"
    FORM_WEB_VNC = "web_vnc"
    FORM_SCREEN_RESOLUTION = "screen_resolution"
    FORM_DEVICE_TYPE = "device_type"
    FORM_EMU_DEVICE = "emu_device"
    FORM_EMU_ANDROID_VERSION = "emu_android_version"
    FORM_EMU_NO_SKIN = "emu_no_skin"
    FORM_EMU_DATA_PARTITION = "emu_data_partition"
    FORM_EMU_ADDITIONAL_ARGS = "emu_additional_args"

    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__name__)
        self.device_type = None
        self.interval_waiting = int(os.getenv(ENV.DEVICE_INTERVAL_WAITING, 2))
        self.user_behavior_analytics = convert_str_to_bool(os.getenv(ENV.USER_BEHAVIOR_ANALYTICS, "true"))
        self.form_field = {
            Device.FORM_USER: "entry.108751316",
            Device.FORM_CITY: "entry.2083022547",
            Device.FORM_REGION: "entry.1083141079",
            Device.FORM_COUNTRY: "entry.1946159560",
            Device.FORM_APP_VERSION: "entry.818050927",
            Device.FORM_APPIUM: "entry.181610571",
            Device.FORM_APPIUM_ADDITIONAL_ARGS: "entry.727759656",
            Device.FORM_WEB_LOG: "entry.1225589007",
            Device.FORM_WEB_VNC: "entry.2055392048",
            Device.FORM_SCREEN_RESOLUTION: "entry.709976626",
            Device.FORM_DEVICE_TYPE: "entry.207096546",
            Device.FORM_EMU_DEVICE: "entry.1960740382",
            Device.FORM_EMU_ANDROID_VERSION: "entry.671872491",
            Device.FORM_EMU_NO_SKIN: "entry.403556951",
            Device.FORM_EMU_DATA_PARTITION: "entry.1052258875",
            Device.FORM_EMU_ADDITIONAL_ARGS: "entry.57529972"
        }
        self.form_data = {}
        signal.signal(signal.SIGTERM, self.tear_down)

    def set_status(self, current_status) -> None:
        bashrc_file = f"{os.getenv(ENV.WORK_PATH)}/device_status"
        with open(bashrc_file, "w+") as bf:
            bf.write(current_status)
        # It won't work using docker exec
        # os.environ[constants.ENV_DEVICE_STATUS] = current_status

    def _prepare_analytics_payload(self) -> None:
        self.form_data.update({
            self.form_field[Device.FORM_USER]: f"{platform.platform()}_{platform.version().replace(' ', '_')}",
            self.form_field[Device.FORM_APP_VERSION]: os.getenv(ENV.DOCKER_ANDROID_VERSION),
            self.form_field[Device.FORM_DEVICE_TYPE]: self.device_type,
            self.form_field[Device.FORM_WEB_VNC]: convert_str_to_bool(os.getenv(ENV.WEB_VNC)),
            self.form_field[Device.FORM_WEB_LOG]: convert_str_to_bool(os.getenv(ENV.WEB_LOG)),
            self.form_field[Device.FORM_APPIUM]: convert_str_to_bool(os.getenv(ENV.APPIUM))
        })

        try:
            res = requests.get("https://ipinfo.io")
            if res.ok:
                json_res = res.json()
                self.form_data.update({
                    self.form_field[Device.FORM_CITY]: json_res[Device.FORM_CITY],
                    self.form_field[Device.FORM_REGION]: json_res[Device.FORM_REGION],
                    self.form_field[Device.FORM_COUNTRY]: json_res[Device.FORM_COUNTRY]
                })
        except requests.exceptions.RequestException as rer:
            self.logger.warning(rer)
            pass
        except KeyError as ke:
            self.logger.warning(ke)
            pass

    def create(self) -> None:
        if self.user_behavior_analytics:
            self.logger.info("Sending user behavior analytics to improve the tool")
            try:
                form_url = f"https://docs.google.com/forms/d/e/{Device.FORM_ID}/formResponse"
                self._prepare_analytics_payload()
                requests.post(url=form_url, data=self.form_data)
            except requests.exceptions.RequestException as rer:
                self.logger.warning(rer)
                pass
        self.set_status(DEVICE.STATUS_CREATING)

    def start(self) -> None:
        self.set_status(DEVICE.STATUS_STARTING)

    def wait_until_ready(self) -> None:
        self.set_status(DEVICE.STATUS_BOOTING)

    def reconfigure(self) -> None:
        self.set_status(DEVICE.STATUS_RECONFIGURING)

    def keep_alive(self) -> None:
        self.set_status(DEVICE.STATUS_READY)
        self.logger.warning(f"{self.device_type} process will be kept alive to be able to get sigterm signal...")
        while True:
            time.sleep(2)

    @abstractmethod
    def tear_down(self, *args) -> None:
        pass


class Genymotion(Device):
    def __init__(self) -> None:
        super().__init__()
        self.logger = logging.getLogger(self.__class__.__name__)

    def get_data_from_template(self, filename: str) -> dict:
        path_template_json = os.path.join(get_env_value_or_raise(ENV.GENYMOTION_TEMPLATE_PATH), filename)
        data = {}
        if os.path.isfile(path_template_json):
            try:
                self.logger.info(path_template_json)
                with open(path_template_json, "r") as f:
                    data = json.load(f)
            except FileNotFoundError as fnf:
                self.shutdown_and_logout()
                self.logger.error(f"File cannot be found: {fnf}")
            except json.JSONDecodeError as jde:
                self.shutdown_and_logout()
                self.logger.error(f"Error Decoding Json: {jde}")
            except Exception as e:
                self.shutdown_and_logout()
                self.logger.error(e)
        else:
            self.shutdown_and_logout()
            raise RuntimeError(f"'{path_template_json}' cannot be found!")
        return data

    @abstractmethod
    def login(self) -> None:
        pass

    def create(self) -> None:
        super().create()
        self.login()

    @abstractmethod
    def shutdown_and_logout(self) -> None:
        pass

    def tear_down(self, *args) -> None:
        self.shutdown_and_logout()
