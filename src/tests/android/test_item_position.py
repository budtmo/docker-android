"""Unit test for android.py."""
from unittest import TestCase

from src import android


class TestItemPosition(TestCase):
    """Unit test class to test method get_item_position."""

    def setUp(self):
        self.items = ['android 4.1', 'android 4.2.2', 'android 4.3', 'android 4.4', 'android 4.4.2']

    def test_valid_params(self):
        keyword = '4.2'
        output = android.get_item_position(keyword, self.items)
        self.assertEqual(1, output)

    def test_invalid_keyword(self):
        keyword = 'fake'
        output = android.get_item_position(keyword, self.items)
        self.assertEqual(0, output)

    def test_empty_array(self):
        items = []
        keyword = '4.2'
        output = android.get_item_position(keyword, items)
        self.assertEqual(0, output)
