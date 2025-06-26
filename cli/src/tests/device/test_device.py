from device import Device
from tests.device import BaseDeviceTest


class TestDevice(BaseDeviceTest):
    def test_create_device(self):
        with self.assertRaises(TypeError):
            Device()
