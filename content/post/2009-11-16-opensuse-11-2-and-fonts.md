---
type: post
author: hrafn
tags:
- suse
- fonts
comments: false
date: 2009-11-16T12:12:42Z
published: true
title: openSUSE 11.2 и шрифты
Slug: opensuse-112-и-шрифты
url: /2009/10/opensuse-11-2-and-fonts
---

Решил глянуть на свежевышедшую openSUSE. Поставил. После последней убунты
шрифты - полное говно. На самом деле. А исправить можно следующим образом.

Открываем терминал, получаем рута и пишем:

		cd /etc/zypp/repos.d/
		wget http://opensuse-community.org/subpixel/openSUSE_11.2/subpixel.repo
		zypper ref && zypper in freetype2-feature-subpixel-hinting

Все. Я перегрузился и выглядеть шрифты стали на порядок лучше. Я в последнее
время предпочитаю Droid от Google и в 11.2 они идут в поставке, так что можно
сразу же и выбрать.

