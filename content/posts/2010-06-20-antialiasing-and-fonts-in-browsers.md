---
type: post
author: hrafn
tags:
  - fonts
  - browser
comments: false
date: 2010-06-20T18:21:05Z
published: true
title: Антиалиасинг и шрифты в браузерах
Slug: антиалиасинг-и-шрифты-в-браузерах
url: /2010/06/antialiasing-and-fonts-in-browsers
---

Памятка на будущее. Может пригодится еще кому.

На данный момент у меня стоит Fedora Rawhide. И как я заметил, периодически в предварительных релизах различных дистрибутивов в браузерах (проверял на Firefox, Google Chrome и Chromium) отображение шрифтов на страницах не
соответствует дистрибутивному. Часто даже просто не применяются шрифты, которые указаны в настройках. Я с этим столкнулся на openSUSE 11.3 Milestine 7 и сегодня на Fedora Rawhide. Гуглил на эту тему я и раньше, но вот нашел
решение только сейчас. Спасибо за это форуму [ubuntuforums.org](http://ubuntuforums.org) :)

Итак, открываем файл ~/.fonts.conf, если он существует, или создаем при отсутствии. Вписываем туда следующее:

			<?xml version='1.0'?>
			<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
			<fontconfig>
			<match target="font" >
			<edit mode="assign" name="rgba" >
			<const>none</const>
			</edit>
			</match>
			<match target="font" >
			<edit mode="assign" name="hinting" >
			<bool>true</bool>
			</edit>
			</match>
			<match target="font" >
			<edit mode="assign" name="hintstyle" >
			<const>hintslight</const>
			</edit>
			</match>
			<match target="font" >
			<edit mode="assign" name="antialias" >
			<bool>true</bool>
			</edit>
			</match>
			</fontconfig>

Сохраняем и выходим. Если браузер был запущен - перезапускаем. Наслаждаемся улучшенным видом :)

Проверялось на Fedora Rawhide с браузерами Firefox, Google Chrome, Opera.

Конфиг взят отсюда: [http://ubuntuforums.org/showthread.php?p=8704572#post8704572](http://ubuntuforums.org/showthread.php?p=8704572#post8704572)

