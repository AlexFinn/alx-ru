---
type: post
author: hrafn
tags:
- fedora
- virtualization
- failed
comments: false
date: 2010-12-02T12:56:18Z
published: true
title: Fedora 14. Ошибка при создании виртуальной машины
Slug: fedora-14-ошибка-при-создании-виртуальной-машины
url: /2010/12/fedora-14-oshibka-pri-sozdanii-virtualnoj-mashiny
---

Решил я еще раз попробовать привести шрифты в openSUSE в нормальный вид. Ставить на ноут будучи неуверенным, что все получится до конца и завершится удачно, у меня не было, надумал поставить дистр в виртуалке.

Поскольку KVM я люблю и не люблю Virtualbox, но его и выбрал :) Создаю виртуалку, выбираю
всякие-разные опции и в итоге получаю такое:

	Uncaught Error: Не удалось завершить установку: 'Unable to deny all devices for opensuse: No such file or directory
	Traceback (most recent call last):
	File "/usr/share/virt-manager/virtManager/create.py", line 1567, in do_install
	dom = guest.start_install(False, meter = meter)
	File "/usr/lib/python2.7/site-packages/virtinst/Guest.py", line 1023, in start_install
	return self._do_install(consolecb, meter, removeOld, wait)
	File "/usr/lib/python2.7/site-packages/virtinst/Guest.py", line 1088, in _do_install
	"install")
	File "/usr/lib/python2.7/site-packages/virtinst/Guest.py", line 1059, in _create_guest
	dom = self.conn.createLinux(start_xml, 0)
	File "/usr/lib64/python2.7/site-packages/libvirt.py", line 1277, in createLinux
	if ret is None:raise libvirtError('virDomainCreateLinux() failed', conn=self)
	libvirtError: Unable to deny all devices for opensuse: No such file or directory

Я считаю: "Восхитительно!" Особенно меня радует понятность описания проблемы и легкость поиска решения проблемы. Впрочем, virt-manager этим отличался всегда. Если кто-то столкнется с таким же чудом, то должно помочь следующее:

	# /etc/init.d/cgconfig start

или

	# service cgconfig start

поскольку libvirt не может найти правил для новой виртуальной машины.

Единственно, что мне не понятно, почему разработчики Fedora не сделали проверку при создании виртуальной машины: запущена ли эта служба или нет. К тому же, cgroup сейчас не настолько широко развита и далеко не на всех дистрах
так широко используется, чтобы запуск ее стал очевидным решением.

Ладно, не сделали и не сделали. В любом случае, дабы избежать таких проблем в дальнейшем, либо перед запуском виртуальной машины запускайте службу руками, либо же добавьте ее в автозагрузку при помощи ntsysv или chkconfig.

