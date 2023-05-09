import logging
import subprocess

from src.device import Genymotion, DeviceType
from src.helper import get_env_value_or_raise
from src.constants import ENV, UTF8


class GenySAAS(Genymotion):
    def __init__(self) -> None:
        super().__init__()
        self.logger = logging.getLogger(self.__class__.__name__)
        self.device_type = DeviceType.GENY_SAAS.value
        self.created_devices = []

    def login(self) -> None:
        user = get_env_value_or_raise(ENV.GENY_SAAS_USER)
        password = get_env_value_or_raise(ENV.GENY_SAAS_PASS)
        subprocess.check_call(f"gmsaas auth login {user} {password} > /dev/null 2>&1", shell=True)
        self.logger.info("successfully logged in!")

    def create(self) -> None:
        super().create()
        for item in self.get_data_from_template(ENV.GENY_SAAS_TEMPLATE_FILE_NAME):
            name = ""
            template = ""
            local_port = ""

            # implement like this because local_port param is not a must
            for k, v in item.items():
                if k.lower() == "name":
                    name = v
                elif k.lower() == "template":
                    template = v
                elif k.lower() == "local_port":
                    local_port = v
                else:
                    self.logger.warning(f"'{k}' is not supported! Please check the documentation!")

            if not name:
                import uuid
                name = str(uuid.uuid4())

            if not template:
                self.shutdown_and_logout()
                raise RuntimeError(f"'template' is a must parameter and not given!")
            else:
                self.logger.info(f"name: {name}, template: {template}")
                creation_cmd = f"gmsaas instances start {template} {name}"
                try:
                    instance_id = subprocess.check_output(creation_cmd.split()).decode(UTF8).replace("\n", "")
                    created_device = {f"{name}": {instance_id}}
                    self.created_devices.append(created_device)
                    additional_args = ""
                    if local_port:
                        additional_args = f"--adb-serial-port {local_port}"
                    connect_cmd = f"gmsaas instances adbconnect {instance_id} {additional_args}"
                    subprocess.check_call(f"{connect_cmd}", shell=True)
                except Exception as e:
                    self.shutdown_and_logout()
                    self.logger.error(e)
                    exit(1)

    def shutdown_and_logout(self) -> None:
        if bool(self.created_devices):
            self.logger.info("Created device(s) will be removed!")
            for d in self.created_devices:
                for n, i in d.items():
                    subprocess.check_call(f"gmsaas instances stop {i}", shell=True)
                    self.logger.info(f"device '{n}' is successfully removed!")
        subprocess.check_call("gmsaas auth logout", shell=True)
        self.logger.info("successfully logged out!")
