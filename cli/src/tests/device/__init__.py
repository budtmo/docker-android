import os

from src.constants import ENV
from src.tests import BaseTest


class BaseDeviceTest(BaseTest):
    DEVICE_ENVS = {
        ENV.WORK_PATH: "/home/androidusr",
        ENV.USER_BEHAVIOR_ANALYTICS: str(False),
        ENV.EMULATOR_NO_SKIN: str(False)
    }

    def setUp(self) -> None:
        for k, v in self.DEVICE_ENVS.items():
            os.environ[k] = v

    def tearDown(self) -> None:
        for k in self.DEVICE_ENVS.keys():
            if os.environ[k]:
                del os.environ[k]
