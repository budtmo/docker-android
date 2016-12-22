"""Unit test for start.py."""
from unittest import TestCase

import mock

from service import start


class TestService(TestCase):
    """Unit test class to test method run."""

    @mock.patch('service.start.create_android_emulator')
    @mock.patch('subprocess.check_call')
    def test_service(self, mocked_creation, mocked_subprocess):
        self.assertFalse(mocked_creation.called)
        self.assertFalse(mocked_subprocess.called)
        start.run()
        self.assertTrue(mocked_creation.called)
        self.assertTrue(mocked_subprocess.called)
