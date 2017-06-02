"""e2e test to test sample android application inside docker-android"""
from unittest import TestCase

from appium import webdriver


class TestE2EAndroidApk(TestCase):

    def setUp(self):
        desired_caps = {
            'platformName': 'Android',
            'deviceName': 'Android Emulator',
            'automationName': 'UIAutomator2',
            'app': '/root/tmp/sample_apk_debug.apk'
        }
        self.driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)

    def test_calculation(self):
        text_fields = self.driver.find_elements_by_class_name('android.widget.EditText')
        text_fields[0].send_keys(4)
        text_fields[1].send_keys(6)

        btn_calculate = self.driver.find_element_by_class_name('android.widget.Button')
        btn_calculate.click()

        self.assertEqual('10', text_fields[2].text)

    def tearDown(self):
        self.driver.quit()
