import unittest

from appium import webdriver


class MSiteChromeAndroidUITests(unittest.TestCase):

    def setUp(self):

        # Default google chrome does not exist for android < 6.0
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'appPackage': 'com.android.chrome',
            'appActivity': 'com.google.android.apps.chrome.Main',
            'avd': 'samsung_galaxy_s6_7.1.1'
        }
        self.driver = webdriver.Remote('http://127.0.0.1:4723/wd/hub', desired_caps)

    def test_open_url(self):
        self.driver.get('http://targeturl.com')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(MSiteChromeAndroidUITests)
    unittest.TextTestRunner(verbosity=2).run(suite)
