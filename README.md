# Build-VMWare
Build VMware Appliances with Packer on Linux

Recently I set up automated VMware virtual appliance builds using Packer and Ansible. I had manually tested and pieced together the various steps on OS X, and thought everything would Just Work™ when I transferred it over to Linux to run on our automated build infrastructure. I was wrong…

It turns out building on Linux can be a painfully cryptic experience. To begin with, it’s not well documented what you actually need to install to get a functioning set up, and even once you have a set up you expect to work the various VMware components can often return generic error messages which Packer unhelpfully parrots. You frequently have to resort to installing a desktop environment to get the real error message via a dialog in the VMware Workstation UI. Below is a brain dump to help anyone else out that finds themselves with a similar need. It assumes you’re already familiar with Packer and have a VMware based build ready to run on Linux.

Requirements
Firstly, I never got VMware Player to work on Linux, despite the odd scrap of Packer documentation that might suggest otherwise. I found various GitHub issues where others had the same experience. So the first requirement is to use VMware Workstation (specifically I use version 10).

Secondly, you will need a valid license key for VMware Workstation.

Next up, you need to install the VMware Vix component. You need the version that corresponds to the version of Workstation you’re using. I used version 1.14.2 which corresponds to VMware Workstation 10.

Finally, if you want to distribute a virtual appliance that can be loaded on any version of the desktop apps (Workstation, Player, Fusion etc.) as well as the server offerings (vSphere, ESXi etc.) then you will want to produce an OVA (single-file OVF, effectively) instead of a VMX file, so you need to install OVF Tool. You can grab the latest version of this, independently of what Workstation version you use.

Automation
If you’re like me you want to automate the provisioning of build servers. Here is the Ansible role I use to install VMware on Ubuntu 14.04 ready for appliance builds. Even if you’re not interested in Ansible you can follow the steps manually in your shell:
