"""Unit test for android.py."""
from unittest import TestCase

import mock

from src import android


class TestAvailablePackages(TestCase):
    """Unit test class to test method get_available_sdk_packages."""

    @mock.patch('subprocess.check_output')
    def test_valid_output(self, mocked_output):
        mocked_output.return_value = 'package 1 \n package 2'
        output = android.get_available_sdk_packages()
        self.assertEqual(['package 1', 'package 2'], output)

    @mock.patch('subprocess.check_output')
    def test_without_line_break(self, mocked_output):
        mocked_output.return_value = 'package 1, package 2'
        output = android.get_available_sdk_packages()
        self.assertEqual(['package 1, package 2'], output)

    @mock.patch('subprocess.check_output')
    def test_empty_string(self, mocked_output):
        mocked_output.return_value = None
        output = android.get_available_sdk_packages()
        self.assertEqual(None, output)
