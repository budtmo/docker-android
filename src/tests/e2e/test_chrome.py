"""e2e test to test chrome application inside docker-android"""
from unittest import TestCase

from appium import webdriver


class TestE2EChrome(TestCase):

    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'appPackage': 'com.android.chrome',
            'appActivity': 'com.google.android.apps.chrome.Main'
        }
        self.driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)

    def test_open_url(self):
        self.driver.get('http://google.com')

    def tearDown(self):
        self.driver.quit()
