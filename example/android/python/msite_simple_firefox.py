import unittest

from appium import webdriver


class MSiteFirefoxAndroidUITests(unittest.TestCase):

    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'platformVersion': '4.2',
            #  For emulator type armeabi, please use browser apk :
            # /root/browser_apk/firefox_51.0-2015466281_min_android4.0.3_armeabi-v7a.apk
            'app': '/root/browser_apk/firefox_51.0-2015466284_min_android4.0.3_x86.apk',
            'appPackage': 'org.mozilla.firefox',
            'appActivity': 'org.mozilla.gecko.LauncherActivity',
            'avd': 'emulator_4.2.2'
        }
        self.driver = webdriver.Remote('http://127.0.0.1:4723/wd/hub', desired_caps)

    def test_open_google(self):
        self.driver.get('http://targeturl.com')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(MSiteFirefoxAndroidUITests)
    unittest.TextTestRunner(verbosity=2).run(suite)
