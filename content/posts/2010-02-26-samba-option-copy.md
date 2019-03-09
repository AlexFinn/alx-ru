---
type: post
author: hrafn
tags:
- samba
- translate
- tips
comments: false
date: 2010-02-26T12:39:18Z
published: true
title: Samba и опция copy
Slug: samba-и-опция-copy
url: /2010/02/samba-option-copy
---

Нашел, на мой взгляд, интересную возможность в конфиге Самбы. [Оригинал тут](http://kbase.redhat.com/faq/docs/DOC-4868).

Одной из директив, доступных в smb.conf, является опция copy. Которая
обеспечивает возможность клонирования записей и аттрибутов общих ресурсов
Samba. Используя эту директиву, можно создать шаблон службы со всеми
необходимыми опциями вместо указания одних и тех же опций для каждой отдельной
расшарки.

Чтобы было проще, можно взглянуть на пример файла /etc/samba/smb.conf:

		[template1]
		browseable = yes
		writable = yes
		valid users = gpalis mnapolis rcamacho

		[template2]
		browseable = yes
		writable = no
		valid users = gpalis rcamacho peting

		[backup]
		path = /mnt/backup
		copy = template1

		[workfiles]
		path = /share
		copy = template1

		[csfiles]
		path /mnt/cs
		copy = template2

После изменения файла перезапустите службу smb:

		# service smb restart

