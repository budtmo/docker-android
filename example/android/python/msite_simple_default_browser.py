import unittest

from appium import webdriver


class MSiteDefaultBrowserAndroidUITests(unittest.TestCase):

    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'platformVersion': '4.2',
            'appPackage': 'com.android.browser',
            'appActivity': 'com.android.browser.BrowserActivity',
            'avd': 'emulator_4.2.2'
        }
        self.driver = webdriver.Remote('http://127.0.0.1:4723/wd/hub', desired_caps)

    def test_open_url(self):
        self.driver.get('http://targeturl.com')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(MSiteDefaultBrowserAndroidUITests)
    unittest.TextTestRunner(verbosity=2).run(suite)
