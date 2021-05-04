# Build-VMWare
Build VMware Appliances with Packer on Linux

![immagine](https://user-images.githubusercontent.com/56889513/117019679-eb534500-acf5-11eb-9f38-9e3e75377bdc.png)
![immagine](https://user-images.githubusercontent.com/56889513/117019561-cced4980-acf5-11eb-89e0-83f74b223830.png)

Recently I set up automated VMware virtual appliance builds using Packer and Ansible. I had manually tested and pieced together the various steps on OS X, and thought everything would Just Work™ when I transferred it over to Linux to run on our automated build infrastructure. I was wrong…

It turns out building on Linux can be a painfully cryptic experience. To begin with, it’s not well documented what you actually need to install to get a functioning set up, and even once you have a set up you expect to work the various VMware components can often return generic error messages which Packer unhelpfully parrots. You frequently have to resort to installing a desktop environment to get the real error message via a dialog in the VMware Workstation UI. Below is a brain dump to help anyone else out that finds themselves with a similar need. It assumes you’re already familiar with Packer and have a VMware based build ready to run on Linux.

Requirements
Firstly, I never got VMware Player to work on Linux, despite the odd scrap of Packer documentation that might suggest otherwise. I found various GitHub issues where others had the same experience. So the first requirement is to use VMware Workstation (specifically I use version 10).

Secondly, you will need a valid license key for VMware Workstation.

Next up, you need to install the VMware Vix component. You need the version that corresponds to the version of Workstation you’re using. I used version 1.14.2 which corresponds to VMware Workstation 10.

Finally, if you want to distribute a virtual appliance that can be loaded on any version of the desktop apps (Workstation, Player, Fusion etc.) as well as the server offerings (vSphere, ESXi etc.) then you will want to produce an OVA (single-file OVF, effectively) instead of a VMX file, so you need to install OVF Tool. You can grab the latest version of this, independently of what Workstation version you use.

Automation
If you’re like me you want to automate the provisioning of build servers. Here is the Ansible role I use to install VMware on Ubuntu 14.04 ready for appliance builds. Even if you’re not interested in Ansible you can follow the steps manually in your shell:

Building OVAs
By default Packer will produce a VMX based virtual machine (via the vmware-vmx builder). If you want to package this in to a single file for easy distribution, or you want to make sure it can be used on vSphere, then you need to convert it to an OVA.

There is a community provided post-processor for Packer here that you can then invoke from your packer.json file. I opted not to use this, as I didn’t a) want to install golang on my build servers just to compile/install this or b) didn’t want to manage my own pre-compiled binaries for it. Instead I chose to use a shell script to call OVF Tool after Packer has finished.

Here’s an example of that script - I’ve left some of the skeleton of our main build-vm.sh script in place, so that you can see how we drive Packer and convert the VMX to an OVA if appropriate.

Troubleshooting
The virtual machine has exited.
At some point you’ll probably see this horrifically unhelpful error message in the Packer logs:

The virtual machine has exited.
This comes from VMware, and it can mean a wide variety of things. These are some of the things to check before falling back to the last resort:

Did you license VMware Workstation with a valid license key?

Does the host machine you’re building on have enough memory to support the VM you’re trying to start?

Does the host machine you’re building on have enough CPU to support the VM you’re trying to start?

Does the machine you’re building on have VT-X enabled? e.g. If you’re building inside a nested virtual machine you will need to enable nested virtualization. Don’t even bother to try on public clouds like AWS or GCE etc. as they don’t enable this.

Can’t think of anything you’ve done wrong? Then sadly the last resort is to install a desktop environment and attempt to manually start the VM through the VMware Workstation UI - you’ll get the real error message in a pop up dialog.

Failed to build vmnet. Failed to execute the build command.
This one only recently started happening to me with the release of kernel 3.19. I initially received the generic error message above and after falling back to installing a desktop environment and starting the Workstation UI was prompted to recompile VMware kernel modules for the new kernel. After clicking OK and waiting a while the process failed with this message:

Failed to build vmnet. Failed to execute the build command.
Some Googling lead me to this helpful thread. I followed the instructions in this answer (after making sure I was happy with the content of the patch) and that brought VMware back to life.
