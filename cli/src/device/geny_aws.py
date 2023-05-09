import json
import logging
import os
import shutil
import subprocess
import time

from src.device import Genymotion, DeviceType
from src.helper import get_env_value_or_raise
from src.constants import ENV, UTF8


class GenyAWS(Genymotion):
    port = 5555

    def __init__(self) -> None:
        super().__init__()
        self.logger = logging.getLogger(self.__class__.__name__)
        self.device_type = DeviceType.GENY_AWS.value
        self.workdir = get_env_value_or_raise(ENV.WORK_PATH)
        self.aws_credentials_path = os.path.join(self.workdir, ".aws")
        self.remove_cred_at_the_end = False  # for logout
        self.geny_aws_template_path = os.path.join(self.workdir, "docker-android", "mixins",
                                                   "templates", "genymotion", "aws")
        self.created_devices = {}

    def login(self) -> None:
        aws_credentials_file = os.path.join(self.aws_credentials_path, "credentials")
        if os.path.exists(self.aws_credentials_path):
            self.logger.info(".aws is found! It will be used as credentials")
        else:
            self.logger.info(".aws cannot be found! the template will be used!")
            self.remove_cred_at_the_end = True
            aws_credentials_template_path = os.path.join(self.geny_aws_template_path, ".aws")
            shutil.move(aws_credentials_template_path, self.aws_credentials_path)

            aws_key_id = get_env_value_or_raise(ENV.AWS_ACCESS_KEY_ID)
            aws_secret_key = get_env_value_or_raise(ENV.AWS_SECRET_ACCESS_KEY)
            replacements_cred = {
                f"<{ENV.AWS_ACCESS_KEY_ID.lower()}>": aws_key_id,
                f"<{ENV.AWS_SECRET_ACCESS_KEY.lower()}>": aws_secret_key
            }
            with open(aws_credentials_file, 'r+') as cred_file:
                cred_file_contents = cred_file.read()
                for old_str, new_str in replacements_cred.items():
                    cred_file_contents = cred_file_contents.replace(old_str, new_str)
                cred_file.seek(0)
                cred_file.write(cred_file_contents)
                cred_file.truncate()
            self.logger.info("aws credentials is set!")

    def create_ssh_key(self) -> None:
        subprocess.check_call('ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""', shell=True)
        self.logger.info("ssh key is created!")

    def create_tf_files(self) -> None:
        try:
            for item in self.get_data_from_template(ENV.GENY_AWS_TEMPLATE_FILE_NAME):
                name = item["name"]
                region = item["region"]
                ami = item["ami"]
                instance_type = item["instance_type"]
                if "security_group" in item:
                    sg = item["security_group"]
                    tf_content = f'''
                    provider "aws" {{
                        alias  = "provider_{name}"
                        region = "{region}"
                    }}
    
                    resource "aws_key_pair" "geny_key_{name}" {{
                        provider = aws.provider_{name}
                        public_key = file("~/.ssh/id_rsa.pub")
                    }}
    
                    resource "aws_instance" "geny_aws_{name}" {{
                        provider = aws.provider_{name}
                        ami = "{ami}"
                        instance_type = "{instance_type}"
                        vpc_security_group_ids = ["{sg}"]
                        key_name = aws_key_pair.geny_key_{name}.key_name
                        tags = {{
                            Name = "DockerAndroid-GenyAWS-{ami}.id}}"
                        }}
    
                        provisioner "remote-exec" {{
                            connection {{
                                type = "ssh"
                                user = "shell"
                                host = self.public_ip
                                private_key = file("~/.ssh/id_rsa")
                            }}
                            script = "/home/androidusr/docker-android/mixins/scripts/genymotion/aws/enable_adb.sh"
                        }}
                    }}
    
                    output "public_dns_{name}" {{
                        value = aws_instance.geny_aws_{name}.public_dns
                    }}
                    '''
                else:
                    ingress_rules = json.dumps(item["ingress_rules"])
                    egress_rules = json.dumps(item["egress_rules"])
                    tf_content = f'''
                    locals {{
                        ingress_rules = {ingress_rules}
                        egress_rules = {egress_rules}
                    }}
                    
                    provider "aws" {{
                        alias  = "provider_{name}"
                        region = "{region}"
                    }}
                    
                    resource "aws_security_group" "geny_sg_{name}" {{
                        provider = aws.provider_{name}
                        dynamic "ingress" {{
                            for_each = local.ingress_rules
                            content {{
                                from_port   = ingress.value.from_port
                                to_port     = ingress.value.to_port
                                protocol    = ingress.value.protocol
                                cidr_blocks = ingress.value.cidr_blocks
                            }}
                        }}
                        
                        dynamic "egress" {{
                            for_each = local.egress_rules
                            content {{
                                from_port   = egress.value.from_port
                                to_port     = egress.value.to_port
                                protocol    = egress.value.protocol
                                cidr_blocks = egress.value.cidr_blocks
                            }}
                        }}
                    }}
        
                    resource "aws_key_pair" "geny_key_{name}" {{
                        provider = aws.provider_{name}
                        public_key = file("~/.ssh/id_rsa.pub")
                    }}
                    
                    resource "aws_instance" "geny_aws_{name}" {{
                        provider = aws.provider_{name}
                        ami = "{ami}"
                        instance_type = "{instance_type}"
                        vpc_security_group_ids = [aws_security_group.geny_sg_{name}.name]
                        key_name = aws_key_pair.geny_key_{name}.key_name
                        tags = {{
                            Name = "DockerAndroid-GenyAWS-{ami}.id}}"
                        }}
                        
                        provisioner "remote-exec" {{
                            connection {{
                                type = "ssh"
                                user = "shell"
                                host = self.public_ip
                                private_key = file("~/.ssh/id_rsa")
                            }}
                            script = "/home/androidusr/docker-android/mixins/scripts/genymotion/aws/enable_adb.sh"
                        }}
                    }}
        
                    output "public_dns_{name}" {{
                        value = aws_instance.geny_aws_{name}.public_dns
                    }}
                    '''
                tf_deployment_filename = f"{name}.tf"
                self.created_devices[name] = GenyAWS.port
                GenyAWS.port += 1
                with open(tf_deployment_filename, "w") as df:
                    df.write(tf_content)
            self.logger.info("Terraform files are created!")
        except Exception as e:
            self.logger.error(e)
            self.shutdown_and_logout()

    def deploy_tf(self) -> None:
        try:
            cmds = (
                "terraform init",
                "terraform plan",
                "terraform apply -auto-approve"
            )
            for c in cmds:
                subprocess.check_call(c, shell=True)
            self.logger.info("Genymotion-Device(s) are deployed on AWS")
        except subprocess.CalledProcessError as cpe:
            self.logger.error(cpe)
            self.shutdown_and_logout()

    def connect_with_local_adb(self) -> None:
        self.logger.info(f"created devices: {self.created_devices}")
        try:
            for d, p in self.created_devices.items():
                dns_cmd = f"terraform output public_dns_{d}"
                dns_ip = subprocess.check_output(dns_cmd.split()).decode(UTF8).replace('"', '')
                tunnel_cmd = f"ssh -i ~/.ssh/id_rsa -o ServerAliveInterval=60 -o StrictHostKeyChecking=no -q -NL " \
                             f"{p}:localhost:5555 shell@{dns_ip}"
                subprocess.Popen(tunnel_cmd.split())
                time.sleep(10)
                subprocess.check_call(f"adb connect localhost:{p} >/dev/null 2>&1", shell=True)
        except Exception as e:
            self.logger.error(e)
            self.shutdown_and_logout()

    def create(self) -> None:
        super().create()
        self.create_ssh_key()
        self.create_tf_files()
        self.deploy_tf()
        self.connect_with_local_adb()

    def shutdown_and_logout(self) -> None:
        try:
            subprocess.check_call("terraform destroy -auto-approve -lock=false", shell=True)
            self.logger.info("device(s) is successfully removed!")
        except subprocess.CalledProcessError as cpe:
            self.logger.error(cpe)
        finally:
            if self.remove_cred_at_the_end:
                subprocess.check_call(f"rm -rf {self.aws_credentials_path}", shell=True)
                self.logger.info("successfully logged out!")
