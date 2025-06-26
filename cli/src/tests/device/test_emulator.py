import mock

from device.emulator import Emulator
from tests.device import BaseDeviceTest


class TestEmulator(BaseDeviceTest):
    def setUp(self) -> None:
        super().setUp()
        self.name = "my_emu"
        self.device = "Nexus 4"
        self.a_version = "10.0"
        self.d_partition = "550m"
        self.additional_args = ""
        self.i_type = "google_apis"
        self.s_img = "x86"
        self.emu = Emulator(self.name, self.device, self.a_version, self.d_partition,
                            self.additional_args, self.i_type, self.s_img)

    def tearDown(self) -> None:
        super().tearDown()

    def test_adb_name(self):
        my_emu = Emulator("my_other_emu", self.device, self.a_version, self.d_partition,
                          self.additional_args, self.i_type, self.s_img)
        self.assertNotEqual(self.emu.adb_name, my_emu.adb_name)

    def test_invalid_device(self):
        with self.assertRaises(RuntimeError):
            Emulator("my_other_emu", "unknown device", self.a_version, self.d_partition,
                     self.additional_args, self.i_type, self.s_img)
        with self.assertRaises(RuntimeError):
            Emulator("my_other_emu", "NEXUS 5", self.a_version, self.d_partition,
                     self.additional_args, self.i_type, self.s_img)

    def test_invalid_android_version(self):
        with self.assertRaises(RuntimeError):
            Emulator("my_other_emu", self.device, "0.0", self.d_partition,
                     self.additional_args, self.i_type, self.s_img)

    @mock.patch("os.path.exists", mock.MagicMock(return_value=False))
    def test_initialisation_config_not_exist(self):
        self.assertEqual(self.emu.is_initialized(), False)

    @mock.patch("os.path.exists", mock.MagicMock(return_value=True))
    @mock.patch("builtins.open", mock.mock_open(read_data=""))
    def test_initialisation_device_not_exist(self):
        self.assertEqual(self.emu.is_initialized(), False)

    @mock.patch("os.path.exists", mock.MagicMock(return_value=True))
    @mock.patch("builtins.open", mock.mock_open(read_data="hw.device.name=Nexus 4\n"))
    def test_initialisation_device_exists(self):
        self.assertEqual(self.emu.is_initialized(), True)

    def test_check_adb_command(self):
        with mock.patch("subprocess.check_output", mock.MagicMock(return_value="1".encode("utf-8"))):
            self.emu.check_adb_command(
                self.emu.ReadinessCheck.BOOTED, "mocked_command", "1", 3, 0)

    def test_check_adb_command_out_of_attempts(self):
        with mock.patch("subprocess.check_output", mock.MagicMock(return_value=" ".encode("utf-8"))):
            with self.assertRaises(RuntimeError):
                self.emu.check_adb_command(
                    self.emu.ReadinessCheck.BOOTED, "mocked_command", "1", 3, 0)

    def test_use_override_config_no_env(self):
        with mock.patch("os.getenv", return_value=None):
            self.emu._use_override_config()

    def test_use_override_config_file_not_exist(self):
        with mock.patch("os.getenv", return_value="mock/path/to/config"):
            with mock.patch("os.path.isfile", return_value=False):
                self.emu._use_override_config()

    def test_use_override_config_file_not_readable(self):
        with mock.patch("os.getenv", return_value="mock/path/to/config"):
            with mock.patch("os.path.isfile", return_value=True):
                with mock.patch("os.access", return_value=False):
                    self.emu._use_override_config()

    def test_use_override_config_malformed_content(self):
        with mock.patch("os.getenv", return_value="mock/path/to/config"):
            with mock.patch("os.path.isfile", return_value=True):
                with mock.patch("os.access", return_value=True):
                    with mock.patch("builtins.open", mock.mock_open(read_data="malformed data")):
                        self.emu._use_override_config()
