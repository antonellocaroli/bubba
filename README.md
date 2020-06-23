
# Bubba overlay for [gentoo-on-b3](https://github.com/sakaki-/gentoo-on-b3/)

#### Description

<img src="https://raw.githubusercontent.com/gordonb3/cache/master/Bubba/Excito-B3.jpg" alt="Excito B3" width="250px" align="right"/>
This project contains an overlay for Gentoo that will bring the original Excito web based User Interface back to the B3 miniserver. The port is however not an exact mirror of the original Bubba OS. The old Horde webmail app was replaced by Roundcube and I selected SQLite as the database backend, which saves a lot of memory on the box. For the same reason I did not add bubba-album to this overlay but I did put in a replacement that use csv files and may optionally also use SQLite: Singapore Gallery.

Unlike the original interface you may select what you want or don't want on the box. This speeds up updates because you don't need to build packages you don't use. Most of them at least. Some packages also contain USE flags that allow you even more control over what gets installed. If you want to have the full Bubba OS experience, simply run `emerge @bubba3`

Note: on Bubba|2 you should run `emerge @bubba2`. This set excludes forked-daapd and contains a source build for LogitechMediaServer while the B3 set references a prebuilt binary.

#### Prerequisits for running the Bubba web admin
An Excito B2 or B3 running Gentoo of course!

The web admin interface requires a web server to operate. Supported web servers are apache2 and nginx, but it must be noted that if you want to use file uploads you should choose apache or find the maximum file size to be very restricted (with apache it will be essentially unlimited). The packages default to using apache2 and if you're okay with that there's no need for changing anything. If however you like to use nginx you must at the same time disable apache2 USE flag on the bubba packages. This may seem like a lot of fuzz, but it prevents building (and needing to maintain) a lot of packages you don't actually need.

<p><br>Current optional packages are:</p>

#### Singapore 0.10.1 (unmaintained)
This is a web image gallery I'm offering as a replacement for bubba album. Quite fond of this app myself and a pre is that it does not require bulky, memory consuming, MySQL to run.
(Apache configured systems only - should work with nginx configured systems as well but will require manual configuration of the web server)

#### 'Bubba-ized' Roundcube
The original portage ebuild for this app uses an install scheme that appears to be intended for much larger schemes than we're going for with this personal device. We also like to obfuscate web content that should be readily available (i.e. can not be deleted through the samba share) and this install matches the vhost definition we created for the bubba web admin interface.
(Apache configured systems only - should work with nginx configured systems as well but will require manual configuration of the web server)

#### File Transfer Daemon
This package adds download and upload capabilities to the bubba web admin. Uploading files requires the use of apache web server running the web admin. The original additional feature to download torrents was removed in March 2020 as conflicts with supporting libraries could no longer be resolved.

#### Gentoo sources
Currently contains kernel versions 4.0.1, 4.1.6, 4.3.0, 4.4.39 and 4.9.49-r1, matching the kernels from sakaki's <a href="https://github.com/sakaki-/gentoo-on-b3">gentoo-on-b3</a> releases. These are copies of retired original gentoo releases, kept here for your convenience whenever you need need to build additional (3th party) modules.

#### Sysvinit-2.93_p1 (masked)
The patch number is to keep out of the way of the main gentoo development and to keep this version on top as long as version 2.93 stays in use. The package contains a patched shutdown command that handles the hardware specific routine required for the Excito B3, meaning you can simply type 'halt' while in console, rather than running the prescribed flash writing tool 'write-magic' and then reboot as done by the Bubba web frontend. Also eliminates the regular TTY terminals which are useless on the B3 and sets the correct speed for the serial console. A sanity check is included by verifying that the system runs on a Kirkwood Feroceon SoC.

#### Bubba Easyfind 2.6 (deprecated - replaced by Forked Easyfind Client)
Originally this is part of the bubba-backend package, but I've decided to make this a separate package. Contains the various methods that allow you to use the myownb3.com dynamic DNS service. Only works with registered Excito brand B3's. By default all methods are installed, but you may control this by disabling the USE flags for non required methods (dhcp hook script | service to verify public address if behind a remote router).

Update: as of 27-07-2015 Rodeus, who now owns Excito, has taken control over the old Excito infrastructure that was temporarily and very gracefully hosted on the mybubba.org domain. New B3's should now also be able to use this service.

#### Forked Easyfind Client
This is a fork of a new easyfind client written in C by Charles Leclerc (MouettE). Its functionality has been extended to allow seemless integration with the existing Bubba UI and the Gentoo package makes it a plug-in replacement for the original Perl and Python based Bubba Easyfind scripts.

#### Logitech Media Server (bin and source)
Although being meant a binary distribution, they stopped shipping the platform dependant libraries for ARMv5 and PowerPC a long time ago. I do offer the missing libraries for ARMv5 though for specific versions of perl and I advise that you install the bin package if possible. The source build and it's perl dependencies may pull in up to ~100 additional packages and will take quite some time to complete.

#### Domoticz
This is a home automation system. Information about the project can be found here: http://www.domoticz.com/ This is a rolling release using a git source but I do create ebuilds for specific commits on a regular base.

#### Oikomaticz
My personal port of Domoticz. This is a rolling release using a git source but I do create ebuilds for specific commits on a regular base.

#### Anti-Spam SMTP Proxy Server (ASSP)
An Anti-SPAM filter that sits between the internet and your SMTP receiving email server.

#### Cryptodev paired with openssl (masked)
This serves no actual use but is merely a play thing. The B3 CPU contains a hardware encryption module that theoretically could speed up certain processes. Not so much because the hardware crypto engine is a lot quicker, but because it runs in parallel with your other processes. The trouble is that the supported encryption has fallen out of grace and is in fact no longer enabled by default in openssl. Try if you like, but don't expect any miracles.
