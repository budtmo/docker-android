"""Unit test for android virtual device creation.py."""
import os
from unittest import TestCase

import mock

from src import app


@mock.patch('subprocess.check_call')
class TestAvd(TestCase):
    """Unit test class to test method create_avd."""

    def setUp(self):
        self.avd_name = 'test_avd'

    @mock.patch("builtins.open", create=True)
    def test_nexus_avd_as_default(self, mocked_suprocess, mocked_open):
        self.assertFalse(mocked_suprocess.called)
        self.assertFalse(mocked_open.called)
        app.prepare_avd('Nexus 5', self.avd_name, '550m')
        self.assertTrue(mocked_suprocess.called)
        self.assertTrue(mocked_open.called)

    @mock.patch('os.symlink')
    @mock.patch("builtins.open", create=True)
    def test_samsung_avd(self, mocked_suprocess, mocked_sys_link, mocked_open):
        self.assertFalse(mocked_sys_link.called)
        self.assertFalse(mocked_suprocess.called)
        self.assertFalse(mocked_open.called)
        app.prepare_avd('Samsung Galaxy S6', self.avd_name, '550m')
        self.assertTrue(mocked_sys_link.called)
        self.assertTrue(mocked_suprocess.called)
        self.assertTrue(mocked_open.called)

    def tearDown(self):
        if os.getenv('DEVICE'):
            del os.environ['DEVICE']
