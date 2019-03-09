---
type: post
author: hrafn
tags:
- yum
- software
- repo
comments: false
date: 2010-02-25T10:38:04Z
published: true
title: '[RH Knowledgebase] Yum. Свой репозиторий'
Slug: rh-knowledgebase-yum-свой-репозиторий
url: /2010/02/yum-ustanovka-i-obnovlenie-paketov-iz-sobstvennogo-repozitoriya
---

[Оригинал заметки на Red HatKnowledgebase](http://kbase.redhat.com/faq/docs/DOC-9893).

**Решение**

Чтобы использовать yum для установки или обновления пакетов из файла ISO,
необходимо будет создать свой собственный репозиторий. Сделать это можно двумя
способами:

**Способ 1.**

1. Необходимо создать директорию, в которой и будет хранится репозиторий:

		# mkdir -p /usr/share/repository

2. Для создания репозитория скопируйте в этот каталог все пакеты RPM, которые
необходимо использовать:

		# cd /usr/share/repository
		# createrepo .
		# yum clean all

**_Заметка:_** Прежде, чем эта команда будет выполнена, пакет createrepo уже должен быть установлен в системе.

3. Создайте файл /etc/yum.repos.d/file.repo со следующим содержимым:

		# cat /etc/yum.repos.d/file.repo
		[RHEL_5_Repository]
		baseurl=file:///usr/share/repository
		enabled=1

4. Получите список пакетов:

		# yum list

5. Теперь можно будет установить необходимый пакет. Например:

		# yum install httpd

**Способ 2.**

Здесь описывается другой способ создания репозитория, при котором нет
необходимости копировать файлы RPM на жесткий диск. Файл ISO уже содержит в
себе директории с данными, и ими можно пользоваться напрямую.

1. Смонтируйте файл ISO:

		# mount -o loop,ro rhel-5.2-server-i386-dvd.iso /mnt/iso

2. Создайте файл /etc/yum.repos.d/file.repo:

		# cat /etc/yum.repos.d/file.repo
		[RHEL_5_Server_Repository]
		baseurl=file:///mnt/iso/Server
		enabled=1
		[RHEL_5_VT_Repository]
		baseurl=file:///mnt/iso/VT
		enabled=1

3. Теперь можно установить необходимый пакет:

		# yum install httpd

