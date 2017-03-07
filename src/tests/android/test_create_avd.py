"""Unit test for android.py."""
from unittest import TestCase

import mock

from src import android


@mock.patch('os.symlink')
@mock.patch('subprocess.check_call')
class TestAvd(TestCase):
    """Unit test class to test method create_avd."""

    def setUp(self):
        self.android_path = '/root'
        self.device = 'Nexus\ 5'
        self.skin = 'nexus_5'
        self.avd_name = 'nexus_5_5.0'
        self.api_level = 21

    def test_avd_creation_x86_64(self, mocked_sys_link, mocked_suprocess):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            android.create_avd(self.android_path, self.device, self.skin, self.avd_name, android.TYPE_X86_64,
                               self.api_level)
            self.assertTrue(mocked_list_dir.called)
            self.assertTrue(mocked_sys_link.called)
            self.assertTrue(mocked_suprocess.called)

    def test_avd_creation_x86(self, mocked_sys_link, mocked_suprocess):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            android.create_avd(self.android_path, self.device, self.skin, self.avd_name, android.TYPE_X86,
                               self.api_level)
            self.assertFalse(mocked_list_dir.called)
