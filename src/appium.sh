#!/bin/bash

types=($TYPES)
echo "Available types: ${types[@]}"
echo "Selected type of deployment: $TYPE, Template file: $TEMPLATE"

function prepare_geny_cloud() {
	contents=$(cat $TEMPLATE)

	# LogIn
	echo "Log In"
	gmsaas auth login "${USER}" "${PASS}"

	# Start device(s)
	created_instances=()
	echo "Creating device(s) based on given json file..."
	for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
		get_value() {
			echo ${row} | base64 --decode | jq -r ${1}
    	}

	    template=$(get_value '.template')
	    device=$(get_value '.device')
	    port=$(get_value '.port')

		if [[ $device != null ]]; then
			echo "Starting \"$device\" with template name \"$template\"..."
			instance_uuid=$(gmsaas instances start "${template}" "${device}")
		else
			echo "Starting Device with Random name..."
			random_device_name=$(python3  -c 'import uuid; print(str(uuid.uuid4()).upper())')
			instance_uuid=$(gmsaas instances start "${template}" "${random_device_name}")
		fi

	    echo "Instance-ID: \"$instance_uuid\""
	    created_instances+=("${instance_uuid}")

	    if [[ $port != null ]]; then
			echo "Connect device on port \"$port\"..."
			gmsaas instances adbconnect "${instance_uuid}" --adb-serial-port "${port}"
	    else
			echo "Connect device on port..."
			gmsaas instances adbconnect "${instance_uuid}"
	    fi
	done

	# Store created instances in a file
	echo "All created instances: ${created_instances[@]}"
	echo "${created_instances[@]}" > "${INSTANCES_PATH}"
}

function prepare_geny_aws() {
	contents=$(cat $TEMPLATE)

	# Creating aws tf file(s)
	echo "Creating tf file(s)"
	index=1
	port=5555
	for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
		get_value() {
			echo ${row} | base64 --decode | jq -r ${1}
		}

		region=$(get_value '.region')
		android_version=$(get_value '.android_version')
		instance=$(get_value '.instance')
		ami=$(get_value '.AMI')
		sg=$(get_value '.SG')
		subnet_id=$(get_value '.subnet_id')
		if [[ $subnet_id == null ]]; then
			subnet_id=""
		fi

		echo $region
		echo $android_version
		echo $instance
		echo $ami
		echo $sg
		echo $subnet_id

	    #TODO: remove this dirty hack
		if [[ $android_version == null ]]; then
			echo "[HACK] Version cannot be empty! version will be added!"
			android_version="6.0"
		fi

		#Custom Security Group
		if [[ $sg != null ]]; then
			echo "Custom security group is found!"
			security_group=""

			is_array=$(echo "${sg}" | jq 'if type=="array" then true else false end')
			if [ $is_array == "true" ]; then
				echo "New security group with given rules will be created"
				for i in $(echo "${sg}" | jq -r '.[] | @base64'); do
					get_value() {
						echo ${i} | base64 --decode | jq -r ${1}
					}

					type=$(get_value '.type')
					configs=$(get_value '.configurations')


					for c in $(echo "${configs}" | jq -r '.[] | @base64'); do
						get_value() {
							echo ${c} | base64 --decode | jq -r ${1}
						}

						from_port=$(get_value '.from_port')
						to_port=$(get_value '.to_port')
						protocol=$(get_value '.protocol')
						cidr_blocks=$(get_value '.cidr_blocks')
						security_group+=$(cat <<_EOF

	$type {
		from_port	= $from_port
		to_port		= $to_port
		protocol	= "$protocol"
		cidr_blocks	= ["$cidr_blocks"]
	}
_EOF
	)
					done
				done
			else
				#TODO: remove this dirty hack
				echo "Given security group will be used!"
				is_array="false"
				security_group=$(cat <<_EOF
	ingress {
		from_port       = 22
		to_port         = 22
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
_EOF
)
			fi
		else
			echo "Custom security is not found! It will use default security group!"
			security_group=$(cat <<_EOF
	ingress {
		from_port       = 22
		to_port         = 22
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
	ingress {
		from_port       = 80
		to_port         = 80
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
	ingress {
		from_port       = 443
		to_port         = 443
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
	ingress {
		from_port       = 51000
		to_port         = 51100
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
	ingress {
		from_port       = 51000
		to_port         = 51100
		protocol        = "udp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
	egress {
		from_port       = 0
		to_port         = 65535
		protocol        = "udp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
_EOF
)
		fi

	    aws_tf_content=$(cat <<_EOF
variable "aws_region_$index" {
	type	= "string"
	default = "$region"
}

variable "android_version_$index" {
	type    = "string"
	default = "$android_version"
}

variable "instance_type_$index" {
	type    = "string"
	default = "$instance"
}

variable "subnet_id_$index" {
	type	= "string"
	default = "$subnet_id"
}

provider "aws" {
	alias = "provider_$index"
	region  = "\${var.aws_region_$index}"
}

resource "aws_security_group" "geny_sg_$index" {
	provider = "aws.provider_$index"
	$security_group
}

data "aws_ami" "geny_aws_$index" {
    provider    = "aws.provider_$index"
    most_recent = true

    filter {
        name   = "name"
        values = ["genymotion-ami-\${var.android_version_$index}-*"]
    }

	owners = ["679593333241"] #Genymotion
}

resource "aws_key_pair" "geny_key_$index" {
	provider 	  = "aws.provider_$index"
	public_key	  = "\${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "geny_aws_$index" {
	provider      = "aws.provider_$index"
	ami="\${data.aws_ami.geny_aws_$index.id}"
	instance_type = "\${var.instance_type_$index}"
	subnet_id = "\${var.subnet_id_$index}"
	vpc_security_group_ids=["\${aws_security_group.geny_sg_$index.name}"]
	key_name      = "\${aws_key_pair.geny_key_$index.key_name}"
	tags {
		Name = "DockerAndroid-\${data.aws_ami.geny_aws_$index.id}"
	}
	count = 1

	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "shell"
			private_key = "\${file("~/.ssh/id_rsa")}"
		}

		script = "/root/enable_adb.sh"
    }
}

output "public_dns_$index" {
    value = "\${aws_instance.geny_aws_$index.public_dns}"
}
_EOF
)
		echo "$aws_tf_content" > /root/aws_tf_$index.tf

		if [[ $ami != null ]]; then
			echo "Using given AMI!"
			sed -i "s/.*ami=.*/        ami=\"$ami\"/g" /root/aws_tf_$index.tf
		else
			echo "Custom AMI is not found. It will use the latest AMI!"
		fi

		if [[ $sg != null ]] && [[ $is_array == "false" ]]; then
			echo "Using given security group: $sg"
			sed -i "s/.*vpc_security_group_ids=.*/        vpc_security_group_ids=[\"$sg\"]/g" /root/aws_tf_$index.tf
		fi

		echo "---------------------------------------------------------"

	    ((index++))
	    ((port++))
	done

	# Deploy EC2 instance(s)
	echo "Deploy EC2 instance(s) on AWS with Genymotion image based on given json file..."
	./terraform init
	./terraform plan 
	./terraform apply -auto-approve

	# Workaround to connect adb remotely because there is a issue by using local-exec
	time_sleep=5
	interval_sleep=1
	echo "Connect to adb remotely"
	for ((i=index;i>=1;i--)); do	
		dns=$(./terraform output public_dns_$i)	
		((sleep ${interval_sleep} && adb connect localhost:${port}) > /dev/null & ssh -i ~/.ssh/id_rsa -o ServerAliveInterval=60 -o StrictHostKeyChecking=no -q -NL ${port}:localhost:5555 shell@${dns}) &
		((port--))
		time_sleep=$((time_sleep+interval_sleep))
	done
	echo "It will wait for ${time_sleep} until all device(s) to be connected"
	sleep ${time_sleep}
	adb devices
	echo "Process is completed"
}

function run_appium() {
	echo "Preparing appium-server..."
	CMD="appium --log $APPIUM_LOG"
	if [ "$CONNECT_TO_GRID" = true ]; then
		NODE_CONFIG_JSON="/root/src/nodeconfig.json"
		/root/generate_config.sh $NODE_CONFIG_JSON
		CMD+=" --nodeconfig $NODE_CONFIG_JSON"
  	fi

	if [ "$RELAXED_SECURITY" = true ]; then
		CMD+=" --relaxed-security"
	fi

	echo "Preparation is done"  	
	TERM="xterm -T AppiumServer -n AppiumServer -e $CMD"
	$TERM
}

function ga(){
	if [ "$GA" = true ]; then
		echo "Collecting data for improving the project"
		description="PROCESSOR: ${SYS_IMG}; VERSION: ${ANDROID_VERSION}; DEVICE: ${DEVICE}; APPIUM: ${APPIUM}; SELENIUM: ${CONNECT_TO_GRID}; MOBILE_TEST: ${MOBILE_WEB_TEST}"
		random_user=$(cat /proc/version 2>&1 | sed -e 's/ /_/g' | sed -e 's/[()]//g' | sed -e 's/@.*_gcc_version/_gcc/g' | sed -e 's/__/_/g' | sed -e 's/Linux_version_//g' | sed -e 's/generic_build/genb/g')
		random_user="${APP_RELEASE_VERSION}_${random_user}"
		payload=(
			--data v=${GA_API_VERSION}
			--data aip=1
			--data tid="${GA_TRACKING_ID}"
			--data cid="${random_user}"
			--data t="event"
			--data ec="${APP_TYPE}"
			--data ea="${random_user}"
			--data el="${description}"
			--data an="docker-android"
			--data av="${APP_RELEASE_VERSION}"
		)
		curl ${GA_ENDPOINT} "${payload[@]}" --silent 
	else
		echo "Nothing to do"
	fi
}

function saltstack(){
	if [ ! -z "${SALT_MASTER}" ]; then
		echo "ENV SALT_MASTER it not empty, salt-minion will be prepared"
		echo "master: ${SALT_MASTER}" >> /etc/salt/minion
		salt-minion &
		echo "salt-minion is running..."
	else
		echo "SaltStack is disabled"
	fi
}

ga
saltstack
if [ "$REAL_DEVICE" = true ]; then
	echo "Using real device"
	run_appium
elif [ "$GENYMOTION" = true ]; then
	echo "Using Genymotion"
	echo "${types[@]}"
	case $TYPE in
	"${types[0]}" )
		echo "Using Genymotion-Cloud (SaaS)"
		prepare_geny_cloud
		run_appium
		;;
	"${types[1]}" )
		echo "Using Genymotion-AWS"
		prepare_geny_aws
		run_appium
		;;
	esac
else
	echo "Using Emulator"
	python3 -m src.app
fi
