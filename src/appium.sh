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
	for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
		get_value() {
			echo ${row} | base64 --decode | jq -r ${1}
		}

	    region=$(get_value '.region')
	    ami=$(get_value '.ami')
	    instance=$(get_value '.instance')


	    echo $region
	    echo $ami
	    echo $instance

	    aws_tf_content=$(cat <<_EOF
variable "aws_region_$index" {
	type	= "string"
	default = "$region"
}

variable "ami_id_$index" {
	type    = "string"
	default = "$ami"
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
	name          = "geny_sg_$index"
	description   = "Security group for EC2 instance of Genymotion"
	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "geny_aws_$index" {
	provider      = "aws.provider_$index"
	ami           = "\${var.ami_id_$index}"
	instance_type = "\${var.instance_type_$index}"

	vpc_security_group_ids = ["\${aws_security_group.geny_sg_$index.name}"]

	tags {
		Name = "EK-\${var.ami_id_$index}"
	}
	count = 1
}

output "instance_id_$index" {
	value = "\${aws_instance.geny_aws_$index.*.id}"
}

output "public_dns_$index" {
	value = "\${aws_instance.geny_aws_$index.*.public_dns}"
}
_EOF
)
		echo "$aws_tf_content" > /root/aws_tf_$index.tf
	    ((index++))
	done

	# Deploy EC2 instance(s)
	echo "Deploy EC2 instance(s) on AWS with Genymotion image based on given json file..."
	./terraform init
	./terraform plan 
	./terraform apply -auto-approve

	# Connect with adb
	# TODO
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
        # TODO: please activate this: run_appium
        ;;
    esac
else
	echo "Using Emulator"
	python3 -m src.app
fi
