---
type: post
author: hrafn
tags:
  - suse
  - wifi
  - broadcom
  - howto
comments: false
date: 2009-04-23T23:43:34Z
published: true
title: Broadcom Wireless Drivers для SLED 11
Slug: broadcom-wireless-drivers-для-sled-11
url: /2009/04/broadcom-wireless-drivers-dlya-sled-11
---

Проще всего привести перевод заметки с блога [SUSE Linux Enterprise in Americas](http://opsamericas.com/?p=1226).

"Многие годы беспроводные карты broadcom приносили страдания в беспроводное существование пользователей Linux.

Однако сейчас я рад сообщить, что появились драйвера Broadcom Wireless для SUSE Linux Enterprise Desktop 11. Для установки драйверов просто укажите в качестве источника установки этот адрес:
[http://www.broadcom.com/docs/linux_sta/repo/Novell/Novell-Common/sle11/install/](http://www.broadcom.com/docs/linux_sta/repo/Novell/Novell-Common/sle11/install/)

После его добавления, определитесь, какое ядро используется у вас:

	uname -r

Откройте в YaST управление программным обеспечением:

	yast2 sw_single

и ищите по запросу "broadcom". Установите модуль, подходящий для вашего ядра.

Удачи!"

От себя же добавлю, что мне лично в таком случае удобней пользоваться штуковиной под названием zypper:

	home:~ # zypper lr
	# | Alias                                 | Name                                  | Enabled | Refresh
	--+---------------------------------------+---------------------------------------+---------+--------
	1 | SUSE-Linux-Enterprise-Desktop-11 11-0 | SUSE-Linux-Enterprise-Desktop-11 11-0 | Yes     | No
	2 | nVidia-Driver-SLE11                   | nVidia-Driver-SLE11                   | Yes     | Yes

	home:~ # zypper ar http://www.broadcom.com/docs/linux_sta/repo/Novell/Novell-Common/sle11/install/broadcom
	Adding repository 'broadcom' [done]
	Repository 'broadcom' successfully added
	Enabled: Yes
	Autorefresh: No
	URI: http://www.broadcom.com/docs/linux_sta/repo/Novell/Novell-Common/sle11/install/

	home:~ # zypper lr
	# | Alias                                 | Name                                  | Enabled | Refresh
	--+---------------------------------------+---------------------------------------+---------+--------
	1 | SUSE-Linux-Enterprise-Desktop-11 11-0 | SUSE-Linux-Enterprise-Desktop-11 11-0 | Yes     | No
	2 | broadcom                              | broadcom                              | Yes     | No
	3 | nVidia-Driver-SLE11                   | nVidia-Driver-SLE11                   | Yes     | Yes

	home:~ # zypper ref

	File 'content' from repository 'broadcom' is signed with an unknown key '6EA40DA62345ED2E'.
	Continue? [yes/NO]: yes
	Retrieving repository 'broadcom' metadata [done]
	Building repository 'broadcom' cache [done]
	Repository 'nVidia-Driver-SLE11' is up to date.
	All repositories have been refreshed.

	home:~ # zypper search broadcom
	Loading repository data...
	Reading installed packages..

	S | Name                          | Summary                            | Type
	--+-------------------------------+------------------------------------+-----------
	  | broadcom-wireless             | Broadcom wireless driver for Linux | srcpackage
	  | broadcom-wireless-kmp-default | Broadcom Wireless for Linux        | package
	  | broadcom-wireless-kmp-pae     | Broadcom Wireless for Linux        | package
	  | broadcom-wireless-kmp-trace   | Broadcom Wireless for Linux        | package
	  | broadcom-wireless-kmp-vmi     | Broadcom Wireless for Linux        | package
	  | broadcom-wireless-kmp-xen     | Broadcom Wireless for Linux        | package

Поскольку у меня сего девайса не имеется, то работоспособность проверить не могу. Пробуйте!

