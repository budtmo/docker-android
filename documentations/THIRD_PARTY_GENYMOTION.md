Genymotion Cloud
----------------

![Genymotion](../images/logo_genymotion.png)

You can use Genymotion Android virtual devices in the cloud. They are available on [SaaS](http://bit.ly/2YP0P1l) or as virtual images on AWS, GCP or Alibaba Cloud.

1. On SaaS <br />
	Use [saas.json](../example/genymotion/saas.json) to define the devices that you want to use. You can specify the port on which the device will start so you don't need to change the device name in your tests every time you need to run those tests. Then run following command

	```
	export USER="xxx"
	export PASS="xxx"

	docker run -d -p 4723:4723 -v ${PWD}/example/genycloud/saas.json:/home/androidusr/genymotion_template/saas.json -e DEVICE_TYPE=geny_saas -e GENY_SAAS_USER=${USER} -e GENY_SAAS_PASS=${PASS} -e APPIUM=true --name android-container budtmo/docker-android:genymotion
	```

	The deployed device(s) are automatically connected with adb inside docker container. Stopping the emulator will remove all deployed device(s) on Genymotion SaaS and user will be logged out at the end.

	```
	docker stop android-container
	```


	In case you are interesed to play around with Genymotion on SaaS, you can register to [this link](http://bit.ly/2YP0P1l) to get free minutes for free.

2. On AWS <br />
	Use [aws.json](../example/genymotion/aws.json) to define the devices that you want to use. You can specify the port on which the device will start so you don't need to change the device name in your tests every time you need to run those tests. Then run following command

	```
	export AWS_ACCESS_KEY_ID="xxx"
	export AWS_SECRET_ACCESS_KEY="xxx"

	docker run -it --rm -p 4723:4723 -v ${PWD}/example/genycloud/aws.json:/home/androidusr/genymotion_template/aws.json -e DEVICE_TYPE=geny_aws -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e GENY_SAAS_PASS=${AWS_SECRET_ACCESS_KEY} -e APPIUM=true budtmo/docker-android:genymotion
	```

	The deployed device(s) are automatically connected with adb inside docker container. Stopping the emulator will remove all deployed device(s) on Genymotion SaaS and user will be logged out at the end. As destroying all deployed ressources take time in AWS (it takes around 3 min), you need to specify the waiting time on docker stop

	```
	docker stop --time=180 android-container
	```


[<- BACK TO README](../README.md)
