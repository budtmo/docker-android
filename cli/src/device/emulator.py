import logging
import os
import subprocess
import time

from enum import Enum

from src.device import Device, DeviceType
from src.helper import convert_str_to_bool, get_env_value_or_raise, symlink_force
from src.constants import ENV, UTF8


class Emulator(Device):
    DEVICE = (
        "Nexus 4",
        "Nexus 5",
        "Nexus 7",
        "Nexus One",
        "Nexus S",
        "Samsung Galaxy S6",
        "Samsung Galaxy S7",
        "Samsung Galaxy S7 Edge",
        "Samsung Galaxy S8",
        "Samsung Galaxy S9",
        "Samsung Galaxy S10"
    )

    API_LEVEL = {
        "9.0": "28",
        "10.0": "29",
        "11.0": "30",
        "12.0": "32",
        "13.0": "33",
        "14.0": "34"
    }

    adb_name_id = 5554

    class ReadinessCheck(Enum):
        BOOTED = "booted"
        RUN_STATE = "in running state"
        WELCOME_SCREEN = "in welcome screen"
        POP_UP_WINDOW = "pop up window"

    def __init__(self, name: str, device: str, android_version: str, data_partition: str,
                 additional_args: str, img_type: str, sys_img: str) -> None:
        super().__init__()
        self.logger = logging.getLogger(self.__class__.__name__)
        self.adb_name = f"emulator-{Emulator.adb_name_id}"
        self.device_type = DeviceType.EMULATOR.value
        self.name = name
        if device in self.DEVICE:
            self.device = device
        else:
            raise RuntimeError(f"device '{device}' is not supported!")
        if android_version in self.API_LEVEL.keys():
            self.android_version = android_version
        else:
            raise RuntimeError(f"android version '{android_version}' is not supported!")
        self.api_level = self.API_LEVEL[self.android_version]
        self.data_partition = data_partition
        self.additional_args = additional_args
        self.img_type = img_type
        self.sys_img = sys_img
        workdir = get_env_value_or_raise(ENV.WORK_PATH)
        self.path_device_profile_target = os.path.join(workdir, ".android", "devices.xml")
        self.path_emulator = os.path.join(workdir, "emulator")
        self.path_emulator_config = os.path.join(workdir, "emulator", "config.ini")
        self.path_emulator_profiles = os.path.join(workdir, "docker-android", "mixins",
                                                   "configs", "devices", "profiles")
        self.path_emulator_skins = os.path.join(workdir, "docker-android", "mixins",
                                                "configs", "devices", "skins")
        self.file_name = self.device.replace(" ", "_").lower()
        self.no_skin = convert_str_to_bool(os.getenv(ENV.EMULATOR_NO_SKIN))
        self.interval_after_booting = 15
        Emulator.adb_name_id += 2
        self.form_data.update({
            self.form_field[Device.FORM_SCREEN_RESOLUTION]: f"{os.getenv(ENV.SCREEN_WIDTH)}x"
                                                            f"{os.getenv(ENV.SCREEN_HEIGHT)}x"
                                                            f"{os.getenv(ENV.SCREEN_DEPTH)}",
            self.form_field[Device.FORM_EMU_DEVICE]: self.device,
            self.form_field[Device.FORM_EMU_ANDROID_VERSION]: self.android_version,
            self.form_field[Device.FORM_EMU_NO_SKIN]: self.no_skin,
            self.form_field[Device.FORM_EMU_DATA_PARTITION]: self.data_partition,
            self.form_field[Device.FORM_EMU_ADDITIONAL_ARGS]: self.additional_args
        })

    def is_initialized(self) -> bool:
        import re
        if os.path.exists(self.path_emulator_config):
            self.logger.info("Config file exists")
            with open(self.path_emulator_config, 'r') as f:
                if any(re.match(r'hw\.device\.name ?= ?{}'.format(self.device), line) for line in f):
                    self.logger.info("Selected device is already created")
                    return True
                else:
                    self.logger.info("Selected device is not created")
                    return False

        self.logger.info("Config file does not exist")
        return False

    def _add_profile(self) -> None:
        if "samsung" in self.device.lower():
            path_device_profile_source = os.path.join(self.path_emulator_profiles,
                                                      "{fn}.xml".format(fn=self.file_name))
            symlink_force(path_device_profile_source, self.path_device_profile_target)
            self.logger.info("Samsung device profile is linked")

    def _add_skin(self) -> None:
        device_skin_path = os.path.join(
            self.path_emulator_skins, "{fn}".format(fn=self.file_name))
        with open(self.path_emulator_config, "a") as cf:
            cf.write("hw.keyboard=yes\n")
            cf.write("disk.dataPartition.size={dp}\n".format(dp=self.data_partition))
            cf.write("skin.path={sp}\n".format(
                sp="_no_skin" if self.no_skin else device_skin_path))
        self.logger.info(f"Skin is added in: '{self.path_emulator_config}'")

    def create(self) -> None:
        super().create()
        first_run = not self.is_initialized()
        if first_run:
            self.logger.info(f"Creating the {self.device_type}...")
            self._add_profile()
            creation_cmd = "avdmanager create avd -f -n {n} -b {it}/{si} " \
                           "-k 'system-images;android-{al};{it};{si}' " \
                           "-d {d} -p {pe}".format(n=self.name, it=self.img_type, si=self.sys_img,
                                                   al=self.api_level, d=self.device.replace(" ", "\ "),
                                                   pe=self.path_emulator)
            self.logger.info(f"Command to create emulator: '{creation_cmd}'")
            subprocess.check_call(creation_cmd, shell=True)
            self._add_skin()
            self.logger.info(f"{self.device_type} is created!")

    def change_permission(self) -> None:
        kvm_path = "/dev/kvm"
        if os.path.exists(kvm_path):
            cmds = (f"sudo chown 1300:1301 {kvm_path}",
                    "sudo sed -i '1d' /etc/passwd")
            for c in cmds:
                subprocess.check_call(c, shell=True)
            self.logger.info("KVM permission is granted!")
        else:
            raise RuntimeError("/dev/kvm cannot be found!")

    def deploy(self):
        self.logger.info(f"Deploying the {self.device_type}")

        basic_cmd = "emulator @{n}".format(n=self.name)
        basic_args = "-gpu swiftshader_indirect -accel on -writable-system -verbose"
        wipe_arg = "-wipe-data" if not self.is_initialized() else ""

        start_cmd = f"{basic_cmd} {basic_args} {wipe_arg} {self.additional_args}"
        self.logger.info(f"Command to run {self.device_type}: '{start_cmd}'")
        subprocess.Popen(start_cmd.split())

    def start(self) -> None:
        super().start()
        self.change_permission()
        self.deploy()

    def check_adb_command(self, readiness_check_type: ReadinessCheck, bash_command: str,
                          expected_keyword: str, max_attempts: int, interval_waiting_time: int,
                          adb_action: str = None) -> None:
        success = False
        for _ in range(1, max_attempts):
            if success:
                break
            else:
                try:
                    output = subprocess.check_output(
                        bash_command.split()).decode(UTF8)
                    if expected_keyword in str(output).lower():
                        if readiness_check_type is self.ReadinessCheck.POP_UP_WINDOW:
                            subprocess.check_call(adb_action, shell=True)
                        else:
                            self.logger.info(
                                f"{self.device_type} is {readiness_check_type.value}!")
                            success = True
                    else:
                        self.logger.info(f"[attempt: {_}] {self.device_type} is not {readiness_check_type.value}! "
                                         f"will check again in {interval_waiting_time} seconds")
                        time.sleep(interval_waiting_time)
                except subprocess.CalledProcessError:
                    self.logger.warning("command cannot be executed! will continue...")
                    time.sleep(2)
                    continue
        else:
            if readiness_check_type is self.ReadinessCheck.POP_UP_WINDOW:
                self.logger.info(f"Pop up windows '{expected_keyword}' is not found!")
            else:
                raise RuntimeError(
                    f"{readiness_check_type.value} is checked {_} times!")

    def wait_until_ready(self) -> None:
        super().wait_until_ready()
        booting_cmd = f"adb -s {self.adb_name} wait-for-device shell getprop sys.boot_completed"
        focus_cmd = f"adb -s {self.adb_name} shell dumpsys window | grep -i mCurrentFocus"
        self.check_adb_command(self.ReadinessCheck.BOOTED,
                               booting_cmd, "1", 60, self.interval_waiting)
        time.sleep(self.interval_after_booting)

        interval_pop_up = 0
        max_attempt_pop_up = 3
        pop_up_system_ui = "Not Responding: com.android.systemui"
        system_ui_cmd = f"adb shell su root 'kill $(pidof com.android.systemui)'"
        pop_up_key_enter = {
            "Not Responding: com.google.android.gms",
            "Not Responding: system",
            "ConversationListActivity"
        }
        key_enter_cmd = "adb shell input keyevent KEYCODE_ENTER"
        self.check_adb_command(self.ReadinessCheck.POP_UP_WINDOW, focus_cmd, pop_up_system_ui,
                               max_attempt_pop_up, interval_pop_up, system_ui_cmd)
        for pe in pop_up_key_enter:
            self.check_adb_command(self.ReadinessCheck.POP_UP_WINDOW, focus_cmd, pe, max_attempt_pop_up,
                                   interval_pop_up, key_enter_cmd)

        self.check_adb_command(self.ReadinessCheck.WELCOME_SCREEN,
                               focus_cmd, "launcheractivity", 60, self.interval_waiting)
        self.logger.info(f"{self.device_type} is ready to use")

    def tear_down(self, *args) -> None:
        self.logger.warning("Sigterm is detected! Nothing to do!")

    def __repr__(self) -> str:
        try:
            return "Emulator(name={n}, device={d}, adb_name={an}, android_version={av}, api_level={al}, " \
                   "data_partition={dp}, additional_args={aa}, img_type={it}, sys_img={si}, " \
                   "path_device_profile_target={pdpt}, path_emulator={pe}, path_emulator_config={pec}, " \
                   "file={f})".format(n=self.name, d=self.device, an=self.adb_name, av=self.android_version,
                                      al=self.api_level, dp=self.data_partition, aa=self.additional_args,
                                      it=self.img_type, si=self.sys_img, pdpt=self.path_device_profile_target,
                                      pe=self.path_emulator, pec=self.path_emulator_config, f=self.file_name)
        except AttributeError as ae:
            self.logger.error(ae)
            return ""
