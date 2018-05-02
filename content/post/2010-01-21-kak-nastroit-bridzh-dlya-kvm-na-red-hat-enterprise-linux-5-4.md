---
type: post
author: hrafn
tags:
- kvm
- virtualization
- bridge
- rhel
- translate
comments: false
date: 2010-01-21T12:02:01Z
published: true
title: '[RH Knowledgebase] Как настроить бридж для KVM на Red Hat Enterprise Linux
  Slug: rh-knowledgebase-как-настроить-бридж-для-kvm-на-red-hat-enterprise-linux
5.4'
url: /2010/01/kak-nastroit-bridzh-dlya-kvm-na-red-hat-enterprise-linux-5-4
---

[Оригинал статьи.](http://kbase.redhat.com/faq/docs/DOC-19071)

**Решение**

По умолчанию KVM использует NAT через бридж с именем virbr0. Если необходимо, чтобы гостевая система была видна в той же самой сети как отдельный хост, можно использовать bridged interface. Однако хосты виртуализации, настроенные
на использование KVM, автоматически не создают bridged interface для устройств Ethernet, как это часто бывает в окружении Xen. Таким образом, необходимо создать настройки для того, чтобы бридж создавался при старте сети.

**_Заметка_**: Для хоста должен быть доступ к физической или последовательной консоли, так как изменение файлов конфигурации может привести к потере сетевого соединения (**прим.пер**. Это не совсем верно. Все настройки могут быть произведены и при удаленном доступе. Единственное и очень важное замечание - необходимо убедиться в правильности сделанных изменений и настроек в том случае, если отсутствует возможность попасть на машину в Rescue Mode или просто сбросить настройки).

Если интерфейс, настройки которого будет меняться, в данное время работает, необходимо его остановить его с помощью команды `ifdown` (**прим.пер**. Совершенно необязательно. Файл конфигурации можно менять и при работающем
интерфейсе. Настройки будут применены при перезапуске сети в дальнейшем или после перезагруки). Например:

	# ifdown eth0

Теперь необходимо создать или изменить настройки моста (`ifcfg-brX`) и сетевого интерфейса (`ifcfg-ethX`). Перейдите в директорию `/etc/sysconfig/network-scripts`:

	# cd /etc/sysconfig/network-scripts

Откройте файл устройства, которое необходимо добавить к бриджу с помощью текстового редактора. Например, ifcfg-eth0 определяет физическое сетевое устройство, которое станет частью моста:

	DEVICE=eth0
	# change the hardware address to match the hardware address your NIC uses
	HWADDR=00:16:76:D6:C9:45
	ONBOOT=yes
	BRIDGE=br0
	NM_CONTROLLED=no

Далее следует создать новый скрипт в директории `/etc/sysconfig/network-scripts` и назвать его, допустим, `ifcfg-br0` или что-то вроде того. `br0` - это имя моста, которое может быть как любой длины, так и именем файла, соответствующим
параметру `DEVICE`, а также это имя должно соответствовать указанному в файле конфигурации для `ifcfg-eth0`.

	DEVICE=br0
	TYPE=Bridge
	BOOTPROTO=dhcp
	ONBOOT=yes
	DELAY=0

Если используется статический адрес, конфигурация будет выглядеть подобно этому:

	DEVICE=br0
	TYPE=Bridge
	BOOTPROTO=static
	IPADDR=<Static IP address>
	NETMASK=<Netmask>
	GATEWAY=<Gateway>
	ONBOOT=yes

Запустите устройство Ethernet и бридж, используя команду `ifup`:

	# ifup eth0
	# ifup br0

Далее следует проверить и убедиться, что хост все еще может подключаться к сети:

	# ping www.redhat.com

Если на системе запущен файерволл, потребуется добавить показанное ниже новое правило в файл `/etc/sysconfig/iptables`:

	-A RH-Firewall-1-INPUT -i br0 -j ACCEPT

И перезапустить файерволл:

	# service iptables restart

За более подробной информацией бридже в окружении KVM обращайтесь к следующему официальному документу:

[http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/5.4/html/Virtualization_Guide/sect-Virtualization-Network_Conf iguration-Bridged_networking_with_libvirt.html](http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/5.4/html/Virtualization_Guide/sect-Virtualization-Network_Configuration-Bridged_networking_with_libvirt.html)

**Заметка**

Для того, чтобы убедиться, что ранее созданный мост определяется virt-manager, службы `haldaemon` и `messagebus` должны быть запущены.

