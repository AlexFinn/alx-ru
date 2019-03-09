---
type: post
author: hrafn
tags:
- ejabberd
- failed
- tips
comments: false
date: 2010-01-12T13:45:32Z
published: true
title: 'ejabberd: RPC failed on the node'
Slug: ejabberd-rpc-failed-on-the-node
url: /2010/01/ejabberd-rpc-failed-on-the-node
---

Устанавливал сей джаббер-сервер у клиентов на совершенно древнючей Генте и вылезла такая ошибка. Хоть сразу об стену бейся.

Генту я практически не знаю, предыдущие админы почему-то своевременно не обновляли эту ось, а сам с "незаточеннымиподгенту" руками обновлять не решусь. В скором времени просто заменим уже умирающий физически сервер на новый, заодно и CentOS поставлю вместо Генту. Так вот, при появлении этой ошибки мне помог (мало ли забудется, а потом пригодится) вики: [http://en.gentoo-wiki.com/wiki/Ejabberd](http://en.gentoo-wiki.com/wiki/Ejabberd), а конкретно
вот такая команда:

		/etc/init.d/ejabberd zap
