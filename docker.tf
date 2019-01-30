provider "docker" {
	host 	= "unix:///var/run/docker.sock"
}

resource "docker_image" "selenium_hub_img" {
	name 	= "selenium/hub:3.14.0-curium"
}

resource "docker_image" "docker_android_img" {
	name 	= "budtmo/docker-android-x86-8.1:latest"
}

resource "docker_network" "private_network" {
	name 	= "private_network"
}

resource "docker_container" "selenium_hub_con" {
	image 		= "${docker_image.selenium_hub_img.latest}"
	name  		= "selenium_hub_con"
	networks    = ["${docker_network.private_network.id}"]
	ports {
		internal = 4444
		external = 4444
	}
}

resource "docker_container" "samsung_s6_con" {
	image 		= "${docker_image.docker_android_img.latest}"
	name  		= "samsung_s6_con"
	privileged	= true
	depends_on	= ["docker_container.selenium_hub_con"]
	networks  	= ["${docker_network.private_network.id}"]
	ports {
		internal = 6080
		external = 6080
	}
	env = [
		"DEVICE=Samsung Galaxy S6", 
		"CONNECT_TO_GRID=true",
		"APPIUM=true",
		"MOBILE_WEB_TEST=true",
		"AUTO_RECORD=true"
	]
}
