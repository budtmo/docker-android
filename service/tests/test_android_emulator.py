"""Unit test for start.py."""
from unittest import TestCase

import mock

from service import start


@mock.patch('service.start.get_available_sdk_packages')
class TestRunService(TestCase):
    """Unit test class to test method create_android_emulator."""

    def test_create_emulator(self, mocked_packages):
        mocked_packages.return_value = ['9- SDK Platform Android 4.4.2, API 19, revision 4',
                                        '10- SDK Platform Android 4.3.1, API 18, revision 3',
                                        '11- SDK Platform Android 4.2.2, API 17, revision 3']
        with mock.patch('subprocess.check_call') as mocked_subprocess:
            self.assertFalse(mocked_subprocess.called)
            android_version = '4.2.2'
            start.create_android_emulator(android_version)
            self.assertTrue(mocked_subprocess.called)

    def test_empty_packages(self, mocked_packages):
        mocked_packages.return_value = None
        with self.assertRaises(RuntimeError):
            start.create_android_emulator('4.2.2')

    def test_index_error(self, mocked_packages):
        mocked_packages.return_value = ['9 SDK Platform Android 4.4.2, API 19, revision 4',
                                        '10 SDK Platform Android 4.3.1, API 18, revision 3',
                                        '11 SDK Platform Android 4.2.2, API 17, revision 3']
        android_version = '4.2.2'
        start.create_android_emulator(android_version)
        self.assertRaises(IndexError)
