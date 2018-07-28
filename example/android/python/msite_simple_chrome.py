import unittest

from time import sleep

from appium import webdriver


class MSiteChromeAndroidUITests(unittest.TestCase):

    def setUp(self):

        # Default google chrome does not exist for android < 6.0
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'appPackage': 'com.android.chrome',
            'appActivity': 'com.google.android.apps.chrome.Main',
            'browserName': 'chrome'
        }
        self.driver = webdriver.Remote('http://127.0.0.1:4444/wd/hub', desired_caps)

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
        sleep(2)

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(MSiteChromeAndroidUITests)
    unittest.TextTestRunner(verbosity=2).run(suite)
