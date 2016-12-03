---
layout: post
tags: [ubuntu, linux]
---
Solutions for this issue can be found on the internet, but this will work basically
as a reminder for myself.

The reasons for freeze during restarts could be some but in most cases it is caused
because Linux (kernel) doesn't know how to perform restart given the BIOS that is
present on the machine. Fortunately kernel has a few methods to perform restarts
from which we can choose one that will work for our PC. I was experiencing the
problem on DELL Latitude with Ubuntu 13.10 system.

So to fix the issue we need to pass `reboot` parameter to the kernel at the boot
time. To do so in Ubuntu we can edit `/etc/default/grub` file. We need to search for
the following line:

{% highlight bash %}
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
{% endhighlight %}

Here we can provide command line options that will be passed to kernel during boot.
In my case following fixed the issue:

{% highlight bash %}
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash reboot=pci"
{% endhighlight %}

It looks that option `reboot=pci` in general solves the issue for DELL laptops.

After you change the option you need to execute:

{% highlight bash %}
sudo update-grub
{% endhighlight %}

And reboot machine in order to make provided options to take effect. You can check that
by executing:

{% highlight bash %}
$ cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-3.11.0-12-generic root=UUID=b5fd9a8a-4675-4277-9843-56a5c44fefb4 ro quiet splash reboot=pci
{% endhighlight %}

Once you ensure that linux was booted with correct `reboot` option you can test if
reboot is working.

Other options that can be passed are as follows:

* **warm** - don’t set the cold reboot flag
* **cold** - set the cold reboot flag
* **bios** - reboot by jumping through the BIOS (only for X86_32)
* **smp** (reboot by executing reset on BSP or other CPU - only for X86_32)
* **triple** - force a triple fault - init
* **kbd** - use the keyboard controller. cold reset (default)
* **acpi** - use the RESET_REG in the FADT
* **efi** - use efi reset_system runtime service
* **pci** - use the so-called “PCI reset register”, CF9
* **force** - avoid anything that could hang

In most cases `bios`, `acpi` or `pci` will fix the problem.

You can pass multiple parameters at the same time and let Linux kernel to try them
in order specified. So if you want to check if any of the parameters will fix
the issue try following:

{% highlight bash %}
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash reboot=warm,cold,bios,smp,triple,kbd,acpi,efi,pci,force"
{% endhighlight %}

If this solves the restart issue you can binary search for the exact option that
will work for your PC.
