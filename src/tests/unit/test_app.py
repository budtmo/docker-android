"""Unit test to test app."""
import os
from unittest import TestCase

import mock

from src import app


class TestApp(TestCase):
    """Unit test class to test other methods in the app."""

    @classmethod
    def test_symlink(self):
        res = os.path.join('testFile1.txt')
        dest = os.path.join('link_testFile1.txt')
        open(res, 'a').close()
        app.symlink_force(res, dest)
        os.remove(res)
        os.remove(dest)

    @classmethod
    def test_symlink_already_exist(self):
        res = os.path.join('testFile1.txt')
        dest = os.path.join('link_testFile1.txt')
        open(res, 'a').close()
        open(dest, 'a').close()
        app.symlink_force(res, dest)
        os.remove(res)
        os.remove(dest)

    def test_valid_env(self):
        key = 'ENV_1'
        os.environ[key] = 'test'
        app.get_or_raise(key)
        del os.environ[key]

    def test_invalid_env(self):
        with self.assertRaises(RuntimeError):
            app.get_or_raise('ENV_2')

    def test_valid_bool(self):
        self.assertEqual(app.convert_str_to_bool('True'), True)
        self.assertEqual(app.convert_str_to_bool('t'), True)
        self.assertEqual(app.convert_str_to_bool('1'), True)
        self.assertEqual(app.convert_str_to_bool('YES'), True)

    def test_invalid_bool(self):
        self.assertEqual(app.convert_str_to_bool(''), False)
        self.assertEqual(app.convert_str_to_bool('test'), False)

    def test_invalid_format(self):
        self.assertEqual(app.convert_str_to_bool(True), None)

    @mock.patch('src.app.prepare_avd')
    @mock.patch('builtins.open')
    @mock.patch('subprocess.Popen')
    def test_run_with_appium(self, mocked_avd, mocked_open, mocked_subprocess):
        with mock.patch('src.app.appium_run') as mocked_appium:
            os.environ['APPIUM'] = str(True)
            app.run()
            self.assertTrue(mocked_avd.called)
            self.assertTrue(mocked_open.called)
            self.assertTrue(mocked_subprocess.called)
            self.assertTrue(mocked_appium.called)

    @mock.patch('src.app.prepare_avd')
    @mock.patch('builtins.open')
    @mock.patch('subprocess.Popen')
    def test_run_withhout_appium(self, mocked_avd, mocked_open, mocked_subprocess):
        with mock.patch('src.app.appium_run') as mocked_appium:
            os.environ['APPIUM'] = str(False)
            app.run()
            self.assertTrue(mocked_avd.called)
            self.assertTrue(mocked_open.called)
            self.assertTrue(mocked_subprocess.called)
            self.assertFalse(mocked_appium.called)
