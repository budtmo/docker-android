"""Unit test for start.py."""
import os

from unittest import TestCase

import mock

from service import start


class TestService(TestCase):
    """Unit test class to test method run."""

    def setUp(self):
        os.environ['ANDROID_VERSION'] = '4.2.2'
        os.environ['EMULATOR_TYPE'] = start.TYPE_X86
        os.environ['CONNECT_TO_GRID'] = str(False)

    @mock.patch('subprocess.check_call')
    @mock.patch('service.start.get_android_bash_commands')
    def test_without_selenium_server(self, mocked_subprocess, mocked_bash_cmd):
        self.assertFalse(mocked_subprocess.called)
        self.assertFalse(mocked_bash_cmd.called)
        start.run()
        self.assertTrue(mocked_subprocess.called)
        self.assertTrue(mocked_bash_cmd.called)

    @mock.patch('subprocess.check_call')
    @mock.patch('service.appium.create_node_config')
    @mock.patch('service.start.get_android_bash_commands')
    def test_with_selenium_server(self, mocked_subprocess, mocked_config, mocked_bash_cmd):
        os.environ['CONNECT_TO_GRID'] = str(True)
        self.assertFalse(mocked_subprocess.called)
        self.assertFalse(mocked_config.called)
        self.assertFalse(mocked_bash_cmd.called)
        start.run()
        self.assertTrue(mocked_subprocess.called)
        self.assertTrue(mocked_config.called)
        self.assertTrue(mocked_bash_cmd.called)

    @mock.patch('subprocess.check_call')
    @mock.patch('service.appium.create_node_config')
    @mock.patch('service.start.get_android_bash_commands')
    def test_invalid_integer(self, mocked_subprocess, mocked_config, mocked_bash_cmd):
        os.environ['CONNECT_TO_GRID'] = str(True)
        os.environ['APPIUM_PORT'] = 'test'
        self.assertFalse(mocked_subprocess.called)
        self.assertFalse(mocked_config.called)
        self.assertFalse(mocked_bash_cmd.called)
        start.run()
        self.assertTrue(mocked_subprocess.called)
        self.assertFalse(mocked_config.called)
        self.assertTrue(mocked_bash_cmd.called)
        self.assertRaises(ValueError)

    @mock.patch('service.start.get_android_bash_commands')
    @mock.patch('subprocess.check_call')
    @mock.patch('service.start.logger.warning')
    def test_empty_android_cmd(self, mocked_bash_cmd, mocked_subprocess, mocked_logger_warning):
        mocked_bash_cmd.return_value = None
        self.assertFalse(mocked_subprocess.called)
        self.assertFalse(mocked_logger_warning.called)
        start.run()
        self.assertTrue(mocked_subprocess.called)
        self.assertTrue(mocked_logger_warning.called)

    def tearDown(self):
        del os.environ['ANDROID_VERSION']
        del os.environ['EMULATOR_TYPE']
        if os.getenv('CONNECT_TO_GRID') == str(True):
            del os.environ['CONNECT_TO_GRID']
        if os.getenv('APPIUM_PORT'):
            del os.environ['APPIUM_PORT']
