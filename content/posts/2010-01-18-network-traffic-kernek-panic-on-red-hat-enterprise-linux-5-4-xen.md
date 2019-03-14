---
type: post
author: hrafn
tags:
- rhel
- xen
- network
- translate
comments: false
date: 2010-01-18
published: true
title: '[RH Knowledgebase] Сетевой трафик приводит к панике ядра на ядре Red Hat Enterprise Linux'
Slug: rh-knowledgebase-сетевой-трафик-приводит-к-панике-ядра-на-ядре-red-hat-enterprise
url: /2010/01/network-traffic-kernel-panic-on-red-hat-enterprise-linux-5-4-xen
---

Начну из далека. Я понемногу отхожу от использования Сусе в любом варианте. И
перехожу потихоньку на RedHat-based дистрибутивы. И этим постом начинаю
периодические переводы заметок и статей из Red Hat Knowledgebase, которые этим
тэгом и будут помечаться.
[Оригинал](http://kbase.redhat.com/faq/docs/DOC-23816).

**Проблема**

Использование сети (scp, ftp, веб-браузер и др.) приводит к панике ядра на
ядре RHEL5.4 Xen kernel (2.6.18-164.el5xen).

**Окружение**

Red Hat Enterprise Linux 5.4 Xen kernel (2.6.18-164.el5xen). Проверьте с
помощью:

		uname -a

Generic receive offload (GRO) активно на карте, которая передает данные на
карту с отключенным TCP segmentation offload (TSO). Эта ситуация может
встречаться между двумя сетевыми картами или между реальных и виртуальным
интерфейсами. В примере, который привел к созданию этой записи интерфейсы
peth0 и eth0 на одной и той же карте приводят к этой проблеме. Проверьте
состояние этой возможности с помощью команды, запущенной на каждом сетевом
интерфейсе системы:

		ethtool -k (p)ethX

Если вы увидите, что GRO активен на карте, получающей данные, а TSO отключен
на карте, отправляющей данные, переходите к секции с решением.

**Решение**

Отключите GRO на карте, получающей данные:

		ethtool -K (p)ethX gro off

Заметьте, что после перезагрузке любые результаты выполнения команды не
сохранятся. Для из сохранения поместите эту команду в /etc/rc.local.

Постоянное решение в данный момент проверяется перед включением в Red Hat
Enterprise Linux 5.5: [https://bugzilla.redhat.com/show_bug.cgi?id=537876](https://bugzilla.redhat.com/show_bug.cgi?id=537876)

