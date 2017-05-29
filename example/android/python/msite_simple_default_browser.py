import unittest

from appium import webdriver


class MSiteDefaultBrowserAndroidUITests(unittest.TestCase):

    def setUp(self):

        # Default browser does not exist for android >= 6.0
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'appPackage': 'com.android.browser',
            'appActivity': 'com.android.browser.BrowserActivity',
            'browserName': 'browser'
        }
        self.driver = webdriver.Remote('http://127.0.0.1:4444/wd/hub', desired_caps)

    def test_open_url(self):
        self.driver.get('http://targeturl.com')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(MSiteDefaultBrowserAndroidUITests)
    unittest.TextTestRunner(verbosity=2).run(suite)
