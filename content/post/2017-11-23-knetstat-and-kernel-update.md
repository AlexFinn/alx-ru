---
type: post
title: "История с knetstat и обновлением ядра"
slug: "knetstat-and-kernel-update"
date: "2017-11-23"
tags:
  - "kernel module"
  - "knetstat"
  - "linux"
---

### Что это вообще
Для начала коротко о том, что такое `knetstat` и зачем оно вообще нужно.

knetstat это простой модуль ядра, добавляющий четыре новых файла к `/proc/net`: `tcpstat`, `tcp6stat`, `udpstat` и `udp6stat`. Содержимое этих файлов приблизительно аналогично выводу команды `netstat` с параметрами `-t4an`, `-t6an`, `-u4an` и `-u6an` соответственно, то есть в них представлена информация о сокетах TCP и UDP в человекочитаемом формате. Разница с соответствующим выводом команды `netstat` лишь в том, что новые файлы имеют дополнительную колонку с параметры сокета.

Примерный вывод такой:

	$ cat /proc/net/tcpstat
	Recv-Q Send-Q Local Address           Foreign Address         Stat Diag Options
	     0      0 127.0.0.1:3307          0.0.0.0:*               LSTN      SO_REUSEADDR=1,SO_REUSEPORT=0,SO_KEEPALIVE=0,TCP_NODELAY=0
	     0      0 0.0.0.0:22              0.0.0.0:*               LSTN      SO_REUSEADDR=1,SO_REUSEPORT=0,SO_KEEPALIVE=0,TCP_NODELAY=0
	     1      0 10.240.0.2:9838         169.254.169.254:80      CLSW      SO_REUSEADDR=0,SO_REUSEPORT=0,SO_KEEPALIVE=1,TCP_NODELAY=1
	     0      0 10.240.0.2:29084        169.254.169.254:80      ESTB      SO_REUSEADDR=0,SO_REUSEPORT=0,SO_KEEPALIVE=0,TCP_NODELAY=1
	     0      0 10.240.0.2:22           185.202.212.175:51238   ESTB      SO_REUSEADDR=1,SO_REUSEPORT=0,SO_KEEPALIVE=1,TCP_NODELAY=1
	     0      0 10.240.0.2:29080        169.254.169.254:80      ESTB      SO_REUSEADDR=0,SO_REUSEPORT=0,SO_KEEPALIVE=0,TCP_NODELAY=1
	     0      0 10.240.0.2:29082        169.254.169.254:80      ESTB      SO_REUSEADDR=0,SO_REUSEPORT=0,SO_KEEPALIVE=0,TCP_NODELAY=1
	     0      0 10.240.0.2:29076        169.254.169.254:80      CLSW      SO_REUSEADDR=0,SO_REUSEPORT=0,SO_KEEPALIVE=0,TCP_NODELAY=1

Чуть более подробно можно почитать в README проекта на гитхабе: [https://github.com/veithen/knetstat](https://github.com/veithen/knetstat). Там есть даже мой маленький патчик для версий ядра > 4.4.0 :)

### Предистория
Наши разработчики используют информацию, предоставляемую модулем, поэтому каждый инстанс должен модуль иметь. Я не знаю, каким образом модуль доставлялся на инстансы до моего прихода, но я решил использовать `dkms` как самый адекватный способ как установки модуля текущего ядра, так и для его простого переноса при обновлении ядра.

### dkms
Установим необходимые пакеты:

	$ sudo apt install linux-headers-$(uname -r) make gcc git debhelper

Получим исходники с гитхаба:

	$ git clone https://github.com/veithen/knetstat.git

Создадим файлик `dkms.conf` со следующим содержимым:

	$ cat knetstat/dkms.conf
	MAKE="make -C . KERNELDIR=/lib/modules/${kernelver}/build"
	CLEAN="make -C . clean"
	BUILTMODULENAME=knetstat
	BUILTMODULELOCATION=.
	PACKAGENAME=knetstat
	PACKAGEVERSION=0.1
	REMAKEINITRD=yes
	DESTMODULELOCATION0="/updates"
	AUTOINSTALL=yes

В целом ничего особенного, прототип файла был взят с вики проекта Ubuntu.

Теперь, когда у нас все готово, можно поработать с `dkms`:

	$ sudo cp -R . /usr/src/knetstat-0.1
	$ sudo dkms add -m knetstat -v 0.1
	$ sudo dkms build -m knetstat -v 0.1
	$ sudo dkms mkdeb -m knetstat -v 0.1

После последней команды мы получим в директории `/var/lib/dkms/knetstat/0.1/deb/` наш deb-пакет, который можно установить на нужный инстанс или добавить при сборке нового инстанса.

### Проблема
Больше года все шло хорошо, пока однажды я не получил следующую ошибку после обновления ядра:

	kernel: [11.639702] knetstat: version magic '4.10.0-38-generic SMP mod_unload ' should be '4.10.0-40-generic SMP mod_unload '

На версии ядра можно не обращать внимания, я взял этот вывод с одной из машин, на которой тестировал  свой маленький костыль.

Проверка, загружен ли модуль:

	$ lsmod|grep knetstat
	$

Пусто.
ОК, пробуем загрузить:

	$ sudo modprobe knetstat
	modprobe: ERROR: could not insert 'knetstat': Exec format error

Ну и в логах можно увидеть то же самое:

	$ sudo journalctl -k -p err
	-- Logs begin at Wed 2017-11-22 11:51:02 UTC, end at Thu 2017-11-23 16:16:09 UTC. --`
	kernel: knetstat: version magic '4.10.0-38-generic SMP mod_unload ' should be '4.10.0-40-generic SMP mod_unload '

### Попытка решения
Почему попытка… Мне нынешнее решение не нравится. Подозреваю, что существует более адекватный способ исправить ситуацию, но, к сожалению, я его пока не нашел. Впрочем, у меня есть пара вариантов, что можно попробовать сделать, и я их добавлю сюда, если хоть какой-то из них поможет.

Итак, решение на данный момент такое: при старте системы определять, соответствует ли вывод версии ядра в команде `modinfo knetstat` версии текущего ядра, и в случае, если нет, пересобрать и заново установить модуль.

Итак, скрипт:

	# !/bin/bash
	#
	# Compare knetstat vermagic and kernel release,
	# if not equal build and install knetstat.ko again

	vermagic=$(modinfo knetstat -F vermagic | awk '{print $1}')
	kernelrel=$(uname -r)
	if [[ $vermagic != $kernelrel ]]; then
	  dkms remove -m knetstat -v 0.1 -k $(uname -r)
	  rm /lib/modules/$(uname -r)/updates/dkms/knetstat.ko
	  dkms build -m knetstat -v 0.1 -k $(uname -r)
	  dkms install -m knetstat -v 0.1 -k $(uname -r)
	  modprobe -v knetstat
	else
	  echo OK
	fi

Назовем его `knetstat-vermagic`.

Прибавим сюда еще и файл для systemd - `/etc/systemd/system/knetstat-vermagic.service`:

	[Unit]
	Description=Compare knetstat vermagic and kernel release

	[Service]
	ExecStart=/usr/local/bin/knetstat-vermagic

	[Install]
	WantedBy=multi-user.target

Переносим `knetstat-vermagic` в `/usr/local/bin`. Обновляем ядро, отправляем машину в ребут и смотрим логи после загрузки:

	kernel: knetstat: version magic '4.10.0-38-generic SMP mod_unload ' should be '4.10.0-40-generic SMP mod_unload '
	systemd[1]: Started Compare knetstat vermagic and kernel release.
	knetstat-vermagic[4949]: modinfo: ERROR: could not get modinfo from 'knetstat': No such file or directory
	knetstat-vermagic[4949]: -------- Uninstall Beginning --------
	knetstat-vermagic[4949]: Module:  knetstat
	knetstat-vermagic[4949]: Version: 0.1
	knetstat-vermagic[4949]: Kernel:  4.10.0-40-generic (x86_64)
	knetstat-vermagic[4949]: -------------------------------------
	knetstat-vermagic[4949]: Status: Before uninstall, this module version was ACTIVE on this kernel.
	knetstat-vermagic[4949]: knetstat.ko:
	knetstat-vermagic[4949]:  - Uninstallation
	knetstat-vermagic[4949]:    - Deleting from: /lib/modules/4.10.0-40-generic/
	knetstat-vermagic[4949]: depmod....
	knetstat-vermagic[4949]: DKMS: uninstall completed.
	knetstat-vermagic[4949]: Kernel preparation unnecessary for this kernel. Skipping...
	knetstat-vermagic[4949]: Building module:
	knetstat-vermagic[4949]: cleaning build area....
	knetstat-vermagic[4949]: make KERNELRELEASE=4.10.0-40-generic all....
	knetstat-vermagic[4949]: cleaning build area....
	knetstat-vermagic[4949]: DKMS: build completed.
	knetstat-vermagic[4949]: knetstat:
	knetstat-vermagic[4949]: Running module version sanity check.
	knetstat-vermagic[4949]:  - Original module
	knetstat-vermagic[4949]:    - No original module exists within this kernel
	knetstat-vermagic[4949]:  - Installation
	knetstat-vermagic[4949]:    - Installing to /lib/modules/4.10.0-40-generic/updates/dkms/
	knetstat-vermagic[4949]: depmod....
	knetstat-vermagic[4949]: DKMS: install completed.
	kernel: knetstat: loading out-of-tree module taints kernel.
	kernel: knetstat: module verification failed: signature and/or required key missing - tainting kernel
	knetstat-vermagic[4949]: insmod /lib/modules/4.10.0-40-generic/updates/dkms/knetstat.ko

Я убрал время и имя хоста из вывода, чтобы строки получились не такие длинные.

В случае же если ядро не обновлялось, вывод будет следующим:

	systemd[1]: Started Compare knetstat vermagic and kernel release.
	knetstat-vermagic[6533]: OK


