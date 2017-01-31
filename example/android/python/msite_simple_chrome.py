import unittest

from appium import webdriver


class MSiteChromeAndroidUITests(unittest.TestCase):

    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'platformVersion': '4.2',
            #  For emulator type armeabi, please use browser apk :
            # /root/browser_apk/chrome_55.0.2883.91-288309100_min_android4.1_armeabi-v7a.apk
            'app': '/root/browser_apk/chrome_55.0.2883.91_min_android4.1_x86.apk',
            'appPackage': 'com.android.chrome',
            'appActivity': 'com.google.android.apps.chrome.Main',
            'avd': 'emulator_4.2.2'
        }
        self.driver = webdriver.Remote('http://127.0.0.1:4723/wd/hub', desired_caps)

    def test_open_url(self):
        self.driver.get('http://targeturl.com')

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(MSiteChromeAndroidUITests)
    unittest.TextTestRunner(verbosity=2).run(suite)
