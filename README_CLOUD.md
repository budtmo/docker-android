Azure
-----

Make sure that the nodes, pods, containers for your emulators are generated within a **VM** of series **Dv3** or **Ev3**.
Reference: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nested-virtualization

AWS
-----
Make sure that containers for your emulators are generated within a EC2 Bare Metal Instance(i3.metal)
Reference: https://aws.amazon.com/jp/blogs/aws/new-amazon-ec2-bare-metal-instances-with-direct-access-to-hardware/

Google Cloud (GCE)
------------------
Make sure your instances for your emulators have Nested Virtualization enabled
Reference: https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances

One the disk and instance are created as [specified here](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances#enablenestedvirt),
the emulator can be brought up as follows:

    # Assume app.apk is in /tmp
    docker run --privileged -d -e DEVICE="Samsung Galaxy S6" --volume /tmp:/APK \
         --name android_em budtmo/docker-android-x86-8.1

    docker exec android_em adb wait-for-device 
    docker exec android_em adb install /APK/app.apk
