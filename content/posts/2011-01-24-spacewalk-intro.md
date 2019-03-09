---
type: post
author: hrafn
tags:
- management
- spacewalk
- software
- overview
comments: false
date: 2011-01-24T12:45:53Z
published: true
title: Spacewalk. Intro
Slug: spacewalk-intro
url: /articles/spacewalk-intro
---

[![](https://fedorahosted.org/spacewalk/attachment/wiki/WikiStart/logo.png?format=raw)](https://fedorahosted.org/spacewalk/attachment/wiki/WikiStart/logo.png?format=raw)

Управление и котроль большого количества операционных систем не простая
задача. Spacewalk - это инструмент , позволяющий сильно упростить выполнение
этих задач. Он хранит информацию об оборудовании и программном обеспечении
систем, позволяет управлять виртуальными системами, развертывать файлы,
запускать скрипты и устанавливать программное обеспечение.

В июне 2008 года компания Red Hat анонсировала проект Spacewalk, являющийся
open source решением для управления Linux-инфраструктурой. Spacewalk
представляет собой открытый по лицензии GPL2 продукт Red Hat Network Satellite
Server, имеющий давнюю, с 2001 года, историю разработки.

Вот как описывает Spacewalk [Андрей Маркелов](http://markelov.blogspot.com):

Сервер Spacewalk обслуживает весь жизненный цикл Linux-инфраструктуры и решает
следующие задачи:

  * Сбор информации о системах (аппаратное обеспечение и установленное ПО)
  * Установка и обновление операционных систем
  * Установка и обновление программного обеспечения
  * Установка систем при помощи kickstart-файлов
  * Управление и распространение конфигурационных файлов
  * Мониторинг систем
  * Установка виртуальных машин
  * Запуск/остановка/настройка виртуальных машин
  * Работа с географически-распределенной сетью
  * Автоматизация задач системного администрирования
  * Распределение ролей администраторов и группировка систем

**Управление программным обеспечением**

Spacewalk позволяет управлять программным обеспечением и его обновлением на
redhat-based дистрибутивах: Fedora, CentOS и Scientific Linux. Позволяет
распространять контент среди различного окружения, управлять развертыванием
обновлений на системах, а также позволяет отслеживать на какой стадии
обновления находится конкретная система в данном окружении. Простой
централизованный веб-интерфейс просматривать системы и их статус обновлений,
кроме того, инициализировать процесс обновления.

[![](http://spacewalk.redhat.com/img/screenshots/your_spacewalk.png)](http://spacewalk.redhat.com/img/screenshots/your_spacewalk.png)

_Пример главной страницы Spacewalk._


**Другие возможности управления**

Кроме управления программным обеспечением, Spacewalk обеспечивает возможность
инициализации и мониторинга. Например, развертыват системы с помощью
kickstart-файлов, так же как и управлять и распространять файлы конфигурации
на системы. Функции мониторинга позволяет отслеживать статус систем рядом со
статусом обновлений. Spacewalk также обладает поддержкой виртуализации, что
позволяет подготавливать, контролировать, управлять и мониторить виртуальные
гостевые системы Xen.

Ниже я выложил еще несколько скриншотов:

[![](http://spacewalk.redhat.com/img/screenshots/system-overview.png)](http://spacewalk.redhat.com/img/screenshots/system-overview.png)_Обзор системы._

_[![](http://spacewalk.redhat.com/img/screenshots/configuration-overview.png)](http://spacewalk.redhat.com/img/screenshots/configuration-overview.png)_Обзор конфигурации._

[![](http://spacewalk.redhat.com/img/screenshots/system-set-manager.png)](http://spacewalk.redhat.com/img/screenshots/system-set-manager.png)_System Set Manager._

[![](http://spacewalk.redhat.com/img/screenshots/kickstart_overview.png)](http://spacewalk.redhat.com/img/screenshots/kickstart_overview.png)_Обзор профиля kickstart._

Надеюсь, что из супермаленького обзора более-менее понятно, что из себя
представляет данный продукт. Процесс установки здесь и сейчас описывать не
буду. Для этого будет отдельная заметка. Лучше посмотрим другие вещи.

На данный момент последняя версия - 1.2. Вышла 19 ноября 2010 года. Некоторые
интересные моменты в этом релизе:

  * некоторые страницы веб-интерфейса были переписаны с Perl на Java
  * расширена локализация
  * ограниченная поддержка PostgreSQL в качестве бэк-энда, количество операций пока ограничено
  * поддержка работы на Fedora 14
  * Fedora 12 поддерживается последний выпуск, далее поддержки не будет

А вот что позволяет Spacewalk при работе с PostgreSQL:

  * синхронизация контента с помощью satellite-sync и spacewalk-repo-sync
  * rhnpush
  * регистрация клиентов
  * работа с yum

Таким образом, на данный момент возможно использование Spacewalk с PostgeSQL
для управления программным обеспечением на машине. К сожалению, полная
поддержка этой базы данных заявляет в версии 2.0. А вот что предполагается
сделать в ближайших релизах:

  * поддержка RHEL6
  * плагин для apt-get
  * поддержка клиента Oracle 11g

**_Использованные ресурсы:_**

  * [_https://fedorahosted.org/spacewalk/_](https://fedorahosted.org/spacewalk/)
  * [_http://markelov.blogspot.com/2008/08/spacewalk-open-source-linux.html_](http://markelov.blogspot.com/2008/08/spacewalk-open-source-linux.html)
  * [_http://spacewalk.redhat.com/_](http://spacewalk.redhat.com/)

