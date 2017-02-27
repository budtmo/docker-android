"""Unit test for appium.py."""
import os

from unittest import TestCase

from src import CONFIG_FILE, appium


class TestAppiumConfig(TestCase):
    """Unit test class to test method create_node_config."""

    def test_config_creation(self):
        self.assertFalse(os.path.exists(CONFIG_FILE))
        appium.create_node_config(CONFIG_FILE, 'emulator_name', '4.2.2', '127.0.0.1', 4723, '127.0.0.1', 4444)
        self.assertTrue(os.path.exists(CONFIG_FILE))
        os.remove(CONFIG_FILE)
