"""Unit test for android.py."""
from unittest import TestCase

from src import android


class TestApiLevel(TestCase):
    """Unit test class to test method get_api_level."""

    def setUp(self):
        self.android_version = '4.2.2'

    def test_get_api_level(self):
        api_level = android.get_api_level('4.2')
        self.assertEqual(api_level, 19)

    def test_wrong_type(self):
        api_level = android.get_api_level(4)
        self.assertRaises(TypeError)
        self.assertEqual(api_level, None)
