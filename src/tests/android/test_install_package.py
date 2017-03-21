"""Unit test for android.py."""
from unittest import TestCase

import mock

from src import android


class TestInstallPackage(TestCase):
    """Unit test class to test method install_package."""

    def setUp(self):
        self.emulator_file = 'emulator64-arm'
        self.api_level = 21
        self.sys_img = 'armeabi-v7a'

    @mock.patch('os.symlink')
    @mock.patch('subprocess.check_call')
    def test_package_installation(self, mocked_sys_link, mocked_suprocess):
        self.assertFalse(mocked_sys_link.called)
        self.assertFalse(mocked_suprocess.called)
        android.install_package(self.emulator_file, self.api_level, self.sys_img)
        self.assertTrue(mocked_sys_link.called)
        self.assertTrue(mocked_suprocess.called)
