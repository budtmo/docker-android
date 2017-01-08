"""Unit test for start.py."""
from unittest import TestCase

import mock

from service import start


class TestService(TestCase):
    """Unit test class to test method run."""

    @mock.patch('service.start.get_android_bash_commands')
    @mock.patch('subprocess.check_call')
    def test_service(self, mocked_bash_cmd, mocked_subprocess):
        self.assertFalse(mocked_bash_cmd.called)
        self.assertFalse(mocked_subprocess.called)
        start.run()
        self.assertTrue(mocked_bash_cmd.called)
        self.assertTrue(mocked_subprocess.called)

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
