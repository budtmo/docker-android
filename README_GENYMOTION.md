Genymotion Cloud
----------------

![Genymotion](images/logo_genymotion.png)

You can easily scale your Appium tests on Genymotion Android virtual devices in the cloud. They are available on [SaaS](http://bit.ly/2YP0P1l) or as virtual images on AWS, GCP or Alibaba Cloud.

1. On SaaS <br />
	Use [device.json](genymotion/example/sample_devices/devices.json) to define the device to start. You can specify the port on which the device will start so you don't need to change the device name in your tests every time you need to run those tests. Then run following command

	```bash
	export USER="xxx"
	export PASS="xxx"

	docker run -it --rm -p 4723:4723 -v $PWD/genymotion/example/sample_devices:/root/tmp -e TYPE=SaaS -e USER=$USER -e PASS=$PASS budtmo/docker-android-genymotion
	```

	In case you are interesed to play around with Genymotion on SaaS, you can register to [this link](http://bit.ly/2YP0P1l) to get 1000 free minutes for free.

2. On PaaS (AWS) <br />
	Use [aws.json](genymotion/example/sample_devices/aws.json) to define configuration of EC2 instance and run following command:

	```bash
	docker run -it --rm -p 4723:4723 -v $PWD/genymotion/example/sample_devices:/root/tmp -v ~/.aws:/root/.aws -e TYPE=aws budtmo/docker-android-genymotion
	```

	Existing security group and subnet can be used:

	```json
	[
		{
			"region": "us-west-2",
			"instance": "t2.small",
			"AMI": "ami-0673cbd39ef84d97c",
			"SG": "sg-000aaa",
			"subnet_id": "subnet-000aaa"
		}
	]
	``` 

You can also use [this docker-compose file](genymotion/example/geny.yml). 
