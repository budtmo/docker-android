#!/bin/bash

types=($TYPES)
echo "Available types: ${types[@]}"
echo "Selected type of deployment: $TYPE, Template file: $TEMPLATE"

function prepare_geny_cloud() {
	contents=$(cat $TEMPLATE)

	# Register
	echo "Register user"
	gmtool config username="${USER}" password="${PASS}"
	gmtool license register "${LICENSE}"

	# Start device(s)
	echo "Creating device(s) based on given json file..."
	for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
		get_value() {
			echo ${row} | base64 --decode | jq -r ${1}
    	}

	    template=$(get_value '.template')
	    device=$(get_value '.device')
	    port=$(get_value '.port')

	    if [[ $port != null ]]; then
	    	echo "Starting \"$device\" with template name \"$template\" on port \"$port\"..."
	    	gmtool --cloud admin startdisposable "${template}" "${device}" --adb-serial-port "${port}"
	    else
	    	echo "Starting \"$device\" with template name \"$template\"..."
			gmtool --cloud admin startdisposable "${template}" "${device}"
	    fi
	done
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


	    echo $region
	    echo $android_version
	    echo $instance

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

provider "aws" {
	alias = "provider_$index"
	region  = "\${var.aws_region_$index}"
}

resource "aws_security_group" "geny_sg_$index" {
	provider      = "aws.provider_$index"
	ingress {
		from_port		= 0
		to_port			= 65535
		protocol		= "tcp"
		cidr_blocks		= ["0.0.0.0/0"]
	}
	egress {
		from_port		= 0
		to_port			= 65535
		protocol		= "udp"
		cidr_blocks		= ["0.0.0.0/0"]
    }
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
	ami           = "\${data.aws_ami.geny_aws_$index.id}"
	instance_type = "\${var.instance_type_$index}"
	vpc_security_group_ids = ["\${aws_security_group.geny_sg_$index.name}"]
	key_name      = "\${aws_key_pair.geny_key_$index.key_name}"
	tags {
		Name = "EK-\${data.aws_ami.geny_aws_$index.id}"
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
		((sleep ${interval_sleep} && adb connect localhost:${port}) > /dev/null & ssh -i ~/.ssh/id_rsa -oStrictHostKeyChecking=no -q -NL ${port}:localhost:5555 shell@${dns}) &
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
  	$CMD
}

if [ "$REAL_DEVICE" = true ]; then
	echo "Using real device"
	run_appium
elif [ "$GENYMOTION" = true ]; then
	echo "Using Genymotion"
	echo "${types[@]}"
	case $TYPE in
    "${types[0]}" )
        echo "Using Genymotion-Cloud"
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
