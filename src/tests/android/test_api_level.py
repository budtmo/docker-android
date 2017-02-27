"""Unit test for android.py."""
from unittest import TestCase

import mock

from src import android


@mock.patch('src.android.get_available_sdk_packages')
class TestApiLevel(TestCase):
    """Unit test class to test method get_api_level."""

    def setUp(self):
        self.android_version = '4.2.2'

    def test_get_api_level(self, mocked_packages):
        mocked_packages.return_value = ['9- SDK Platform Android 4.4.2, API 19, revision 4',
                                        '10- SDK Platform Android 4.3.1, API 18, revision 3',
                                        '11- SDK Platform Android 4.2.2, API 17, revision 3']
        api_level = android.get_api_level(self.android_version)
        self.assertEqual(api_level, '17')

    def test_empty_packages(self, mocked_packages):
        mocked_packages.return_value = None
        with self.assertRaises(RuntimeError):
            android.get_api_level(self.android_version)

    def test_index_error(self, mocked_packages):
        mocked_packages.return_value = ['9 SDK Platform Android 4.4.2, API 19, revision 4',
                                        '10 SDK Platform Android 4.3.1, API 18, revision 3',
                                        '11 SDK Platform Android 4.2.2, API 17, revision 3']
        android.get_api_level(self.android_version)
        self.assertRaises(IndexError)
