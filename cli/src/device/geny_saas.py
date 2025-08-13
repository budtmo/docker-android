import logging
import os
import subprocess
import concurrent.futures
import uuid

from device import Genymotion, DeviceType
from helper import get_env_value_or_raise
from constants import ENV, UTF8

class GenySAAS(Genymotion):
    def __init__(self) -> None:
        super().__init__()
        self.logger = logging.getLogger(self.__class__.__name__)
        self.device_type = DeviceType.GENY_SAAS.value
        self.created_devices = []
    
    def login(self) -> None:
        if os.getenv(ENV.GENY_AUTH_TOKEN):
            auth_token = get_env_value_or_raise(ENV.GENY_AUTH_TOKEN)
            subprocess.check_call(f"gmsaas auth token {auth_token} > /dev/null 2>&1", shell=True)
        else:
            user = get_env_value_or_raise(ENV.GENY_SAAS_USER)
            password = get_env_value_or_raise(ENV.GENY_SAAS_PASS)
            subprocess.check_call(f"gmsaas auth login {user} {password} > /dev/null 2>&1", shell=True)
        self.logger.info("successfully logged in!")
    
    def create(self) -> None:
        super().create()
        
        # Collect all items first
        items = []
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
                name = str(uuid.uuid4())
            
            if not template:
                self.shutdown_and_logout()
                raise RuntimeError(f"'template' is a must parameter and not given!")
            
            items.append({
                'name': name,
                'template': template,
                'local_port': local_port
            })
        
        # Start all devices in parallel
        with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
            try:
                # Submit all tasks
                future_to_item = {executor.submit(self.create_instance, item): item for item in items}
                
                # Collect results as they complete
                for future in concurrent.futures.as_completed(future_to_item):
                    item = future_to_item[future]
                    try:
                        created_device = future.result()
                        self.created_devices.append(created_device)
                        self.logger.info(f"Successfully created device: {created_device}")
                    except Exception as e:
                        self.logger.error(f"Instance creation failed for {item['name']}: {e}")
                        self.shutdown_and_logout()
                        exit(1)
                        
            except Exception as e:
                self.shutdown_and_logout()
                self.logger.error(f"Parallel execution failed: {e}")
                exit(1)

    def create_instance(self, item_data):
        """Create a single instance and return the result"""
        name = item_data['name']
        template = item_data['template']
        local_port = item_data['local_port']

        self.logger.info(f"name: {name}, template: {template}")
        creation_cmd = f"gmsaas instances start {template} {name}"

        try:
            instance_id = subprocess.check_output(creation_cmd.split()).decode(UTF8).replace("\n", "")

            # Connect to ADB
            additional_args = ""
            if local_port:
                additional_args = f"--adb-serial-port {local_port}"
            connect_cmd = f"gmsaas instances adbconnect {instance_id} {additional_args}"
            subprocess.check_call(f"{connect_cmd}", shell=True)

            return {f"{name}": instance_id}

        except Exception as e:
            self.logger.error(f"Failed to create instance {name}: {e}")
            raise e

    def stop_instance(self, device_info):
        """Stop a single instance"""
        for name, instance_id in device_info.items():
            try:
                subprocess.check_call(f"gmsaas instances stop {instance_id}", shell=True)
                self.logger.info(f"device '{name}' is successfully removed!")
                return True
            except Exception as e:
                self.logger.error(f"Failed to stop device '{name}': {e}")
                return False

    def shutdown_and_logout(self) -> None:
        if bool(self.created_devices):
            self.logger.info("Created device(s) will be removed!")
            
            # Stop all devices in parallel
            with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
                # Submit all stop tasks
                futures = [executor.submit(self.stop_instance, device) for device in self.created_devices]
                
                # Wait for all to complete
                for future in concurrent.futures.as_completed(futures):
                    try:
                        future.result()
                    except Exception as e:
                        self.logger.error(f"Error during device shutdown: {e}")
        
        # Logout after all devices are stopped
        if os.getenv(ENV.GENY_AUTH_TOKEN):
            subprocess.check_call("gmsaas auth reset", shell=True)
        else:
            subprocess.check_call("gmsaas auth logout", shell=True)
        self.logger.info("successfully logged out!")