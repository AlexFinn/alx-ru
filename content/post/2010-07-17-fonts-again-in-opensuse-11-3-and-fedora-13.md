---
type: post
author: hrafn
tags:
- suse
- fedora
- fonts
comments: false
date: 2010-07-17T21:19:06Z
published: true
title: И снова шрифты. openSUSE 11.3 и Fedora 13
Slug: и-снова-шрифты-opensuse-113-и-fedora-13
url: /2010/07/fonts-again-in-opensuse-11-3-and-fedora-13
---

Честно говоря, после Ubuntu отображение шрифтов по умолчанию во многих дистрибутивах оставляет желать лучшего. Это же относится и к свежевышедшему релизу openSUSE - 11.3. Сколько лет еще должно пройти, пока разработчики решат
сделать хоть что-то с этой проблемой, мне не известно. А решать проблему необходимо, поскольку выглядит все это дело просто погано.

Итак, что касается openSUSE, то тут сделать исправления достаточно легко, если, конечно, удастся найти нужное руководство и нужный репозиторий среди множества реп openSUSE :)

Кликаем по этой ссылке: [http://opensuse-community.org/subpixel/subpixel.ymp](http://opensuse-community.org/subpixel/subpixel.ymp), отвечаем на вопросы. У меня ругнулось на какие-то зависимости python'а и библиотеки, но я предупреждения просто проигнорировал. После установки для надежности перегружаемся. Вот. И чувствуем
разницу.

Update. Благодаря товарищу Anixx (или [Nxx](http://www.linux.org.ru/people/Nxx/profile)) есть необходимые
дополнения. Для установки пропатченного Cairo на openSUSE:

[http://software.opensuse.org/ymp/home:anshuljain:ubuntu_patch_11.3/openSUSE_11.3/cairo.ymp](http://software.opensuse.org/ymp/home:anshuljain:ubuntu_patch_11.3/openSUSE_11.3/cairo.ymp) и забросить файлик local.conf, который брать по ссылке [http://www.infinality.net/files/local.conf](http://www.infinality.net/files/local.conf)

С Федорой все несколько сложнее и проще одновременно. Вообще, по умолчанию шрифты в оной достаточно приличны и так, но всегда есть, что подправить, да и мнения людей могут довольно сильно разниться. Потому можно попробовать сделать
следующее:

1. Скачиваем и устанавливаем следующий пакет:
[http://www.infinality.net/fedora/linux/infinality-repo-1.0-1.noarch.rpm](http://www.infinality.net/fedora/linux/infinality-repo-1.0-1.noarch.rpm)

После его установки в систему будет добавлен репозиторий, в котором, в том числе, присутствует пропатченный freetype.

2. Я ставил следующие пакеты:

  * cairo-freeworld
  * freetype-subpixel
  * libXft-freeworld

		yum install -y cairo-freeworld freetype-subpixel libXft-freeworld

Но это еще не все. Скачиваем файл:[ http://www.infinality.net/files/local.conf](http://www.infinality.net/files/local.conf)

Помещаем его в /etc/fonts. Перегружаемся и наслаждаемся. Лично я предпочитаю использовать шрифты либо Liberation, либо Droid.

Благодарности:

  * за рецепт для openSUSE - Google!
  * для Fedora - сайт [infinality.net](http://infinality.net) & Google!

