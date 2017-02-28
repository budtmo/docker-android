"""Unit test for appium.py."""
import os
from unittest import TestCase

import mock

from src import appium


@mock.patch('subprocess.check_call')
class TestAppiumConfig(TestCase):
    """Unit test class to test method run."""

    def setUp(self):
        self.emulator_name = 'test'
        self.android_version = '4.2.2'

    def test_without_selenium_grid(self, mocked_subprocess):
        with mock.patch('src.appium.create_node_config') as mocked_config:
            self.assertFalse(mocked_config.called)
            self.assertFalse(mocked_subprocess.called)
            appium.run(False, self.emulator_name, self.android_version)
            self.assertFalse(mocked_config.called)
            self.assertTrue(mocked_subprocess.called)

    def test_with_selenium_grid(self, mocked_subprocess):
        with mock.patch('src.appium.create_node_config') as mocked_config:
            self.assertFalse(mocked_config.called)
            self.assertFalse(mocked_subprocess.called)
            appium.run(True, self.emulator_name, self.android_version)
            self.assertTrue(mocked_config.called)
            self.assertTrue(mocked_subprocess.called)

    def test_invalid_integer(self, mocked_subprocess):
        os.environ['APPIUM_PORT'] = 'test'
        with mock.patch('src.appium.create_node_config') as mocked_config:
            self.assertFalse(mocked_config.called)
            self.assertFalse(mocked_subprocess.called)
            appium.run(True, self.emulator_name, self.android_version)
            self.assertFalse(mocked_config.called)
            self.assertTrue(mocked_subprocess.called)
            self.assertRaises(ValueError)

    def tearDown(self):
        if os.getenv('APPIUM_PORT'):
            del os.environ['APPIUM_PORT']
