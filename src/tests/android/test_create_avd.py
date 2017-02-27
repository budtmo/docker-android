"""Unit test for android.py."""
from unittest import TestCase

import mock

from src import android


class TestAvd(TestCase):
    """Unit test class to test method create_avd."""

    def setUp(self):
        self.android_path = '/root'
        self.avd_name = 'test'
        self.api_level = 21

    @mock.patch('os.symlink')
    @mock.patch('subprocess.check_call')
    def test_avd_creation(self, mocked_sys_link, mocked_suprocess):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            android.create_avd(self.android_path, self.avd_name, self.api_level)
            self.assertTrue(mocked_list_dir.called)
            self.assertTrue(mocked_sys_link.called)
            self.assertTrue(mocked_suprocess.called)
