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


[<- BACK TO README](../README.md)
