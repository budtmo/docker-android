"""Unit test to test appium service."""
import os
from unittest import TestCase

import mock

from src import app


class TestAppium(TestCase):
    """Unit test class to test appium methods."""

    def setUp(self):
        os.environ['CONNECT_TO_GRID'] = str(True)
        self.avd_name = 'test_avd'

    @mock.patch('subprocess.check_call')
    def test_chrome_driver(self, mocked_subprocess):
        os.environ['CONNECT_TO_GRID'] = str(False)
        os.environ['BROWSER'] = 'chrome'
        self.assertFalse(mocked_subprocess.called)
        app.appium_run(self.avd_name)
        self.assertTrue(mocked_subprocess.called)

    @mock.patch('subprocess.check_call')
    def test_without_selenium_grid(self, mocked_subprocess):
        os.environ['CONNECT_TO_GRID'] = str(False)
        self.assertFalse(mocked_subprocess.called)
        app.appium_run(self.avd_name)
        self.assertTrue(mocked_subprocess.called)

    @mock.patch('os.popen')
    @mock.patch('subprocess.check_call')
    def test_with_selenium_grid(self, mocked_os, mocked_subprocess):
        with mock.patch('src.app.create_node_config') as mocked_config:
            self.assertFalse(mocked_config.called)
            self.assertFalse(mocked_os.called)
            self.assertFalse(mocked_subprocess.called)
            app.appium_run(self.avd_name)
            self.assertTrue(mocked_config.called)
            self.assertTrue(mocked_os.called)
            self.assertTrue(mocked_subprocess.called)

    @mock.patch('os.popen')
    @mock.patch('subprocess.check_call')
    def test_invalid_integer(self, mocked_os, mocked_subprocess):
        os.environ['APPIUM_PORT'] = 'test'
        with mock.patch('src.app.create_node_config') as mocked_config:
            self.assertFalse(mocked_config.called)
            self.assertFalse(mocked_os.called)
            self.assertFalse(mocked_subprocess.called)
            app.appium_run(self.avd_name)
            self.assertFalse(mocked_config.called)
            self.assertTrue(mocked_os.called)
            self.assertTrue(mocked_subprocess.called)
            self.assertRaises(ValueError)

    def test_config_creation(self):
        from src import CONFIG_FILE
        self.assertFalse(os.path.exists(CONFIG_FILE))
        app.create_node_config('test', 'android', '127.0.0.1', 4723, '127.0.0.1', 4444, 30,
                               'org.openqa.grid.selenium.proxy.DefaultRemoteProxy')
        self.assertTrue(os.path.exists(CONFIG_FILE))
        os.remove(CONFIG_FILE)

    def tearDown(self):
        del os.environ['CONNECT_TO_GRID']
        if os.getenv('APPIUM_PORT'):
            del os.environ['APPIUM_PORT']
        if os.getenv('BROWSER'):
            del os.environ['BROWSER']
