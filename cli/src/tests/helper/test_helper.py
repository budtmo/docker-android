import os
import mock

from src.helper import convert_str_to_bool, get_env_value_or_raise, symlink_force
from src.tests import BaseTest


class TestHelperMethods(BaseTest):
    def test_boolean_converter_with_valid_str(self):
        self.assertEqual(convert_str_to_bool("TRUE"), True)
        self.assertEqual(convert_str_to_bool("true"), True)
        self.assertEqual(convert_str_to_bool("T"), True)
        self.assertEqual(convert_str_to_bool("Yes"), True)
        self.assertEqual(convert_str_to_bool("1"), True)
        self.assertEqual(convert_str_to_bool("False"), False)
        self.assertEqual(convert_str_to_bool("f"), False)
        self.assertEqual(convert_str_to_bool("0"), False)

    def test_boolean_converter_with_empty(self):
        self.assertEqual(convert_str_to_bool(None), False)
        self.assertEqual(convert_str_to_bool(""), False)

    def test_boolean_converter_with_invalid_str(self):
        self.assertEqual(convert_str_to_bool(" "), False)
        self.assertEqual(convert_str_to_bool("test"), False)

    def test_boolean_converter_with_invalid_format(self):
        with self.assertRaises(AttributeError):
            convert_str_to_bool(True)

    def test_get_env_value_from_valid_key(self):
        env_key = "env_key01"
        os.environ[env_key] = "env_value01"
        get_env_value_or_raise(env_key)
        del os.environ[env_key]

    def test_get_env_value_with_empty_string(self):
        with self.assertRaises(RuntimeError):
            env_key = "env_key01"
            os.environ[env_key] = "    "
            get_env_value_or_raise(env_key)
            del os.environ[env_key]

    def test_get_env_value_from_invalid_key(self):
        with self.assertRaises(RuntimeError):
            get_env_value_or_raise("env_key02")

    def test_get_env_value_with_invalid_format(self):
        with mock.patch("src.logger"):
            get_env_value_or_raise(True)

    def test_symlink(self):
        s = os.path.join("source.txt")
        t = os.path.join("target_file.txt")
        open(s, "a").close()
        symlink_force(s, t)
        os.remove(s)
        os.remove(t)

    def test_symlink_already_exist(self):
        s = os.path.join("source.txt")
        t = os.path.join("target_file.txt")
        open(s, "a").close()
        open(t, "a").close()
        symlink_force(s, t)
        os.remove(s)
        os.remove(t)

    def test_symlink_file_not_exists(self):
        s = os.path.join("source.txt")
        t = os.path.join("target_file.txt")
        symlink_force(s, t)
        os.remove(t)
