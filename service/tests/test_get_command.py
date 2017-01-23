"""Unit test for start.py."""
from unittest import TestCase

import mock

from service import start


@mock.patch('service.start.get_available_sdk_packages')
class TestRunService(TestCase):
    """Unit test class to test method get_android_bash_commands."""

    def setUp(self):
        self.android_version = '4.2.2'
        self.emulator_type = start.TYPE_ARMEABI

    def test_create_emulator(self, mocked_packages):
        mocked_packages.return_value = ['9- SDK Platform Android 4.4.2, API 19, revision 4',
                                        '10- SDK Platform Android 4.3.1, API 18, revision 3',
                                        '11- SDK Platform Android 4.2.2, API 17, revision 3']
        cmd = start.get_android_bash_commands(self.android_version, self.emulator_type)
        self.assertIsNotNone(cmd)
        self.assertTrue('android update sdk' in cmd)
        self.assertTrue('android create avd' in cmd)

    def test_empty_packages(self, mocked_packages):
        mocked_packages.return_value = None
        with self.assertRaises(RuntimeError):
            start.get_android_bash_commands(self.android_version, self.emulator_type)

    def test_index_error(self, mocked_packages):
        mocked_packages.return_value = ['9 SDK Platform Android 4.4.2, API 19, revision 4',
                                        '10 SDK Platform Android 4.3.1, API 18, revision 3',
                                        '11 SDK Platform Android 4.2.2, API 17, revision 3']
        start.get_android_bash_commands(self.android_version, self.emulator_type)
        self.assertRaises(IndexError)
