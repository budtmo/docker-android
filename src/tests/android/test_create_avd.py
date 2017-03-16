"""Unit test for android.py."""
from unittest import TestCase

import mock

from src import android


@mock.patch('subprocess.check_call')
@mock.patch('os.symlink')
class TestAvd(TestCase):
    """Unit test class to test method create_avd."""

    def setUp(self):
        self.android_path = '/root'
        self.avd_name = 'test_avd'
        self.api_level = 21

    def test_nexus_avd(self, mocked_suprocess, mocked_sys_link):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            android.create_avd(self.android_path, 'Nexus 5', self.avd_name, self.api_level)
            self.assertTrue(mocked_list_dir.called)
            self.assertTrue(mocked_sys_link.called)
            self.assertTrue(mocked_suprocess.called)

    def test_samsung_avd(self, mocked_suprocess, mocked_sys_link):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            android.create_avd(self.android_path, 'Samsung Galaxy S6', self.avd_name, self.api_level)
            self.assertTrue(mocked_list_dir.called)
            self.assertTrue(mocked_sys_link.called)
            self.assertTrue(mocked_suprocess.called)

    def test_default_avd(self, mocked_suprocess, mocked_sys_link):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            android.create_avd(self.android_path, 'emulator', self.avd_name, self.api_level)
            self.assertFalse(mocked_list_dir.called)
