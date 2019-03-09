---
type: post
author: hrafn
tags:
  - kvm
  - virsh
  - network
comments: false
date: 2011-06-10T19:20:00Z
published: true
title: '[RH Knowledgebase] Упрощенная настройка bridge для KVM'
Slug: rh-knowledgebase-упрощенная-настройка-bridge-для-kvm
url: /2011/06/bridge-kvm-again
---

Снова перевод очередной заметки из базы знаний Red Hat - [DOC-57734](https://access.redhat.com/kb/docs/DOC-57734).

**Проблема**: Как настроит бридж для KVM на Red Hat Enterprise Linux 5.5 без редактирования множества файлов вручную?
**Решение:**

Хост должен быть доступен физически либо через последовательный порт, поскольку изменения в конфигурации сети могут привести к тому, что доступ по сети будет потерян. Необходимо произвести следующее:

    # virsh net-list
    # virsh net-create bridge_custom (bridge name)

    default1
    f7e96e6f-7946-46f4-96c4-29f288d88c21

    ## Change 'forward mode' to 'route'

После этого новый файл конфигурации необходимо поместить в `/etc/libvirt/quemu/networks/` с названием файла тем же, что и название бриджа.

    # /etc/libvirt/qemu/networks/bridge_custom.xml

Затем определить новый бридж, используя команду, указанную далее:

      # virsh define /etc/libvirt/qemu/networks/bridge_custom.xml

Для получения более подробной информации о конфигурации бриджа можно также  посмотреть в этой статье: [https://access.redhat.com/kb/docs/DOC-19071](https://access.redhat.com/kb/docs/DOC-19071).
