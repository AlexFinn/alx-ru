---
type: post
title: "kvm, bridge и виртуальные машины"
slug: "kvm-bridge-i-virtualnye-mashiny"
date: "2009-12-04"
tags:
  - kvm
  - network
  - howto
---

Полноценной статьи не будет. Тем более, что и писать об установке очередную
статью писать смысла не вижу. Подобные вещи описаны в большом количестве в
Сети и на русском, и на английском. Посему больше хотелось бы написать про те
вопросы, которые возникли у меня.

Итак, дело обстоит так - есть достаточно мощный сервер: Core i7, 8 гигабайт
оперативки и 1.5 терабайта места. Необходимо поднять на нем виртуальную
машину, операционка в которой будет иметь внешний IP-адрес. И, самый главный
момент, сервер удаленный. Доступ к нему имеется исключительно по SSH.

По идее сложного ничего нет. Но некоторые вещи были для меня настолько не
очевидны (сам, конечно, виноват, признаю), что пришлось потратить на все это
дело какое-то время. Начнем с того, что до этого момента мне с бриджем
сталкиваться не приходилось. Вот не приходилось и все. Кстати, в качестве
операционной системы для хоста был выбран Дебиан, поэтому относительно этого
дистрибутива описания и будут.

В качестве системы виртуализации я остановился на KVM. Во-первых, потому что
уже в ядре, во-вторых, по моим личным ощущениям работает чуть быстрее и менее
нагружает систему, чем Xen. Может и не прав я, но все же.

Процесс установки KVM описывать не буду, как я и говорил, статей написано уже
море. Первый момент был таков: раз нужен внешний айпишник на виртуалке, значит
без бриджа не обойтись. Но... Сервер удаленный, я мосты не поднимал никогда, и
в случае каких-либо проблем связь с машиной будет потеряна. Особых проблем это
не доставит, есть возможность удаленного включения Rescue Mode, но это
занимает времени не мало. После нескольких попыток попробовать поднять бридж и
нескольких возвратов конфигурации после невозможности поднять сеть на сервере,
я вдруг вспомнил про возможность дать интерфейсу алиас. Это позволяло
настраивать бридж безболезненно для основного интерфейса. Итак, несколько
листингов будет.

напомню, что в Дебиане сетевые настройки расположены в файле
/etc/network/interfaces.

		# Loopback device:
		auto lo
		iface lo inet loopback

		# device: eth0
		#auto  eth0
		#iface eth0 inet static
		#  address   88.198.52.135
		#  broadcast 88.198.52.159
		#  netmask   255.255.255.224
		#  gateway   88.198.52.129

		auto eth0
		iface eth0 inet manual
		auto br0
		iface br0 inet static
		address   88.198.52.135
		netmask   255.255.255.224
		network   88.198.52.128
		broadcast 88.198.52.159
		gateway   88.198.52.129
		bridge_ports eth0
		bridge_fd 9
		bridge_hello 2
		bridge_maxage 12
		bridge_stp off

		# default route to access subnet
		up route add -net 88.198.52.128 netmask 255.255.255.224 gw 88.198.52.129 eth0

		# Loopback device:
		auto lo
		iface lo inet loopback

		# device: eth0
		auto  eth0
		iface eth0 inet static
		address   xx.xx.xx.135
		broadcast xx.xx.xx.159
		netmask   255.255.255.224
		gateway   xx.xx.xx.129

Это настройки системы по умолчанию. Добавим алиас. Для этого допишем
следующее:

		# device: eth0:0
		auto  eth0:0
		iface eth0 inet static
		address   xx.xx.xx.151
		broadcast xx.xx.xx.159
		netmask   255.255.255.224

После редактирования конфига перезапускаем сеть и проверяем, что интерфейс
eth0 имеет алиас.

Теперь можно баловаться с бриджем. Снова открываем тот же файл и приводим его
к такому виду:

		# Loopback device:
		auto lo
		iface lo inet loopback

		# device: eth0
		auto  eth0
		iface eth0 inet static
		address   xx.xx.xx.135
		broadcast xx.xx.xx.159
		netmask   255.255.255.224
		gateway   xx.xx.xx.129

		auto eth0:0
		iface eth0:0 inet manual

		auto br0
		iface br0 inet static
		address   xx.xx.xx.151
		netmask   255.255.255.224
		network   xx.xx.xx.128
		broadcast xx.xx.xx.159
		gateway   xx.xx.xx.129
		bridge_ports eth0:0

		# default route to access subnet
		up route add -net xx.xx.xx.128 netmask 255.255.255.224 gw xx.xx.xx.129 eth0

Сохраняем и перезапускаем сеть. Можно перегрузиться даже для того, чтобы
убедиться, что все нормально поднимается. Если будут какие-то ошибки, смотрим
логи и исправляем.

Если же все прошло нормально, после перезагрузки сеть поднялась и сервер
доступен и пингуется обеим IP-адресам, то самое время снова поправить конфиг,
удалив оттуда алиас и подняв мост уже на основном интерфейсе. У меня в итоге
получилось вот так:

		# Loopback device:
		auto lo
		iface lo inet loopback

		# device: eth0
		auto eth0
		iface eth0 inet manual

		auto br0
		iface br0 inet static
		address   xx.xx.xx.135
		netmask   255.255.255.224
		network   xx.xx.xx.128
		broadcast xx.xx.xx.159
		gateway   xx.xx.xx.129
		bridge_ports eth0

		# default route to access subnet
		up route add -net xx.xx.xx.128 netmask 255.255.255.224 gw xx.xx.xx.129 eth0

Очередная перезагрузка, дабы убедиться, что все в порядке и работает
нормально. И смотрим вывод inconfig:

		br0       Link encap:Ethernet  HWaddr 40:61:86:2b:87:a6
		inet addr:xx.xx.xx.135  Bcast:xx.xx.xx.159  Mask:255.255.255.224
		inet6 addr: fe80::4261:86ff:fe2b:87a6/64 Scope:Link
		UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
		RX packets:76585400 errors:0 dropped:0 overruns:0 frame:0
		TX packets:83969297 errors:0 dropped:0 overruns:0 carrier:0
		collisions:0 txqueuelen:0
		RX bytes:41794612663 (41.7 GB)  TX bytes:61647808570 (61.6 GB)

		eth0      Link encap:Ethernet  HWaddr 40:61:86:2b:87:a6
		inet6 addr: fe80::4261:86ff:fe2b:87a6/64 Scope:Link
		UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
		RX packets:43576052 errors:0 dropped:0 overruns:0 frame:0
		TX packets:45777515 errors:0 dropped:0 overruns:0 carrier:0
		collisions:0 txqueuelen:1000
		RX bytes:29177835387 (29.1 GB)  TX bytes:32751417722 (32.7 GB)
		Interrupt:249 Base address:0x2000

		lo        Link encap:Local Loopback
		inet addr:127.0.0.1  Mask:255.0.0.0
		inet6 addr: ::1/128 Scope:Host
		UP LOOPBACK RUNNING  MTU:16436  Metric:1
		RX packets:233995 errors:0 dropped:0 overruns:0 frame:0
		TX packets:233995 errors:0 dropped:0 overruns:0 carrier:0
		collisions:0 txqueuelen:0
		RX bytes:870168643 (870.1 MB)  TX bytes:870168643 (870.1 MB)

		vnet0     Link encap:Ethernet  HWaddr 76:8c:af:d9:40:b6
		inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.255.0
		inet6 addr: fe80::748c:afff:fed9:40b6/64 Scope:Link
		UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
		RX packets:0 errors:0 dropped:0 overruns:0 frame:0
		TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
		collisions:0 txqueuelen:0
		RX bytes:0 (0.0 B)  TX bytes:468 (468.0 B)

Вот и готово. Теперь можно ставить систему в виртуальную машину, выбрав в
качестве способа подключения к сети существующий на данный момент bridge.

И на последок есть маленькое замечание о настройке сети уже в виртуалке. У
меня после установки операционной системы в виртуальной машине не пинговался
присвоенный ей IP-адрес. Причина оказалась достаточно банальна - маршрут по
умолчанию. Полные сетевые настройки с виртуалки я приводить не буду, только
одну строку:

		gateway xx.xx.xx.135

Здесь в качестве шлюза выступает созданный ранее мост.

Да возможно проблемы и с мостом, и с настройкой сети несколько надуманные. Но
я с ними столкнулся и потратил n-ное количество времени на их решение. Может
быть кому-то пригодится и он, этот кто-то, съэкономит себе время. Я буду
только рад. :)

