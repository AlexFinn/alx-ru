---
type: post
tags:
- suse
- skype
- bluetooth
date: 2009-03-03T00:00:00Z
title: Использование Skype вместе с Bluetooth-гарнитурой в SLED 10
Slug: использование-skype-вместе-с-bluetooth-гарнитурой-в-sled-10
url: /2009/03/ispolzovanie-skype-vmeste-s-bluetooth-garnituroj-v-sled-10
---

Как всегда, перевод )) Оригинал статьи находится [здесь](http://www.novell.com/communities/node/3758/using-skype-with-a-bluetooth-headset-sled-10), а авторство принадлежит samtingleff.

Подключите bluetooth-адаптер к вашему компьютеру. Вы должны увидеть что-то похожее на это в /var/log/messages:

	usb 1-1: new full speed USB device using uhci_hcd and address 2
	usb 1-1: new device found, idVendor=0a12, idProduct=0001
	usb 1-1: new device strings: Mfr=0, Product=0, SerialNumber=0
	usb 1-1: configuration #1 chosen from 1 choice
	Bluetooth: Core ver 2.8
	NET: Registered protocol family 31
	Bluetooth: HCI device and connection manager initialized
	Bluetooth: HCI socket layer initialized
	Bluetooth: HCI USB driver ver 2.9
	usbcore: registered new driver hci_usb

Включите bluetooth, используя Yast: Hardware -> Bluetooth

![](/images/2009/03/03/3758-1.jpg)

Включите аутентификацию и шифрование (Yast -> Bluetooth -> Security Options)

![](/images/2009/03/03/3758-2.jpg)

Установите следующие пакеты, используя Yast, rug или zypper: automake, autoconf, gcc, alsa, alsa-tools, alsa-devel, m4, cvs, kernel-source. Добавьте самого себя в группу `audio` (используя права пользователя root): отредактируйте файл /etc/group и добавьте свое имя в конец строки группы «audio» (мое имя пользователя — stingleff): (Прим.переводчика: на мой взгляд нет необходимости лезть руками в этот файл. Подобную вещь можно сделать, используя Yast в консольном или gui-виде или просто выполнив команду от root’а — `usermod -G audio stingleff`):

	audio:x:17:stingleff

Убедитесь, что bluetooth запущен, и определите MAC-адрес вашего bluetooth-адаптера. Напоминаю, что увидев надпись XX:XX:XX:XX:XX:XX вы должны поменять ее на актуальное значение вашего устройства:

	# sudo hcitool dev
	Devices:
	hci0    XX:XX:XX:XX:XX:XX

Отредактируйте `/etc/bluetooth/rfcomm.conf`, включив туда MAC-адрес вашего адаптера:

	...
	device XX:XX:XX:XX:XX:XX;
	...

Создайте shell-скрипт `/etc/bluetooth/feed-pin.sh` для отправки пин-кода для вашей гарнитуры:

	#!/bin/sh
	echo "PIN:0000"

Сделайте скрипт исполняемым:

	# chmod 700 /etc/bluetooth/feed-pin.sh

Задайте опцию pin_helper в файле `/etc/bluetooth/hcid.conf` для использования этого скрипта:

	...
	pin_helper /etc/bluetooth/feed-pin.sh
	...

Перезапустите сервисы bluetooth:

	# sudo /etc/init.d/bluetooth restart

Перевести гарнитуру в режим подключения и выяснить MAC-адрес. Напомню, что MAC-адрес YY:YY:YY:YY:YY:YY необходимо поменять на тот, который существует у вас:

	# sudo hcitool scan
	Scanning ...
	YY:YY:YY:YY:YY:YY       Jabra BT 250v

Соединиться с гарнитурой:

	# sudo hcitool cc YY:YY:YY:YY:YY:YY

Проверим исходный код btsco. btsco используется для подключения гарнитуры к звуковому устройству:

	# cvs -d:pserver:anonymous@cvs.sf.net:/cvsroot/bluetooth-alsa co btsco

Соберем и установим btsco:

	# cd btsco
	# ./bootstrap
	# ./configure
	# make
	# sudo make install

Соберем и установим модуль ядра btsco:

	# cd kernel
	# make
	# sudo make install
	# sudo /sbin/depmod -e

Загрузите модуль ядра emu10k1 (добавьте команду `/sbin/modprobe emu10k1` (без кавычек) в файл `/etc/rc.d/boot.local` для загрузки модуля автоматически во время старта системы):

	# sudo /sbin/modprobe emu10k1

Добавьте команду `/sbin/modprobe snd-bt-sco` в файл `/etc/rc.d/boot.local` для загрузки модуля автоматически во время старта системы:

	# sudo /sbin/modprobe snd-bt-sco

Соедините btsco с гарнитурой:

	# sudo btsco -v YY:YY:YY:YY:YY:YY

Настройте skype на использования /dev/dsp1 (Tools -> Options -> Hand/Headsets)

![](/images/2009/03/03/3758-3.jpg)

Для автоматизации процесса каждый раз во время запуска Skype сохраните этот скрипт как `~/bin/skype.sh` и выполняйте вместо стандартной команды для запуска Skype:

	#!/bin/bash
	gnomesu btsco -v YY:YY:YY:YY:YY:YY &
	skype
	gnomesu pkill btsco
