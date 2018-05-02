---
type: post
author: hrafn
tags:
- mbr
- howto
comments: false
date: 2009-05-23T15:10:29Z
published: true
title: MBR (Master Boot Record) backup and restore
Slug: mbr-master-boot-record-backup-and-restore
url: /2009/05/mbr-master-boot-record-backup-restore
---

Полезность с сайта[ shell-fu$](http://www.shell-fu.org/lister.php?id=803)

Резервная копия MBR:

		dd if=/dev/sda of=/root/mbr.img bs=1 count=512

Восстановление MBR:

		dd if=/root/mbr.img of=/dev/sda bs=1 count=512

Восстановить только bootstrap (часть MBR):

		dd if=/temp/mbr.img of=/dev/sda bs=1 count=446

Восстановление только таблицы разделов (часть MBR):

		dd if=/temp/mbr.img of=/dev/sda skip=446 seek=446 bs=1 count=64

