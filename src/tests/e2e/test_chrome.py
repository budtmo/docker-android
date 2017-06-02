"""e2e test to test chrome application inside docker-android"""
from unittest import TestCase

from appium import webdriver


class TestE2EChrome(TestCase):

    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'appPackage': 'com.android.chrome',
            'appActivity': 'com.google.android.apps.chrome.Main',
            'browserName': 'chrome'
        }
        self.driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)

    def test_open_url(self):
        self.driver.get('http://google.com')

        # Handle Welcome Home
        self.driver.switch_to.context('NATIVE_APP')
        self.driver.find_element_by_id('terms_accept').click()
        self.driver.find_element_by_id('negative_button').click()

        # Search for Github
        self.driver.switch_to.context('CHROMIUM')
        search = self.driver.find_element_by_name('q')
        search.send_keys('butomo1989 docker-android')
        search.submit()

    def tearDown(self):
        self.driver.quit()
