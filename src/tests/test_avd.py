"""Unit test for android virtual device creation.py."""
import os
from unittest import TestCase

import mock

from src import app


@mock.patch('subprocess.check_call')
@mock.patch('os.symlink')
class TestAvd(TestCase):
    """Unit test class to test method create_avd."""

    def setUp(self):
        self.avd_name = 'test_avd'

    def test_nexus_avd_as_default(self, mocked_suprocess, mocked_sys_link):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            app.prepare_avd('Nexus 5', self.avd_name)
            self.assertTrue(mocked_list_dir.called)
            self.assertTrue(mocked_sys_link.called)
            self.assertTrue(mocked_suprocess.called)

    def test_samsung_avd(self, mocked_suprocess, mocked_sys_link):
        with mock.patch('os.listdir') as mocked_list_dir:
            mocked_list_dir.return_value = ['file1', 'file2']
            self.assertFalse(mocked_list_dir.called)
            self.assertFalse(mocked_sys_link.called)
            self.assertFalse(mocked_suprocess.called)
            app.prepare_avd('Samsung Galaxy S6', self.avd_name)
            self.assertTrue(mocked_list_dir.called)
            self.assertTrue(mocked_sys_link.called)
            self.assertTrue(mocked_suprocess.called)

    def tearDown(self):
        if os.getenv('DEVICE'):
            del os.environ['DEVICE']
