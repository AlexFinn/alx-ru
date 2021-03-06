---
type: post
author: hrafn
tags:
- fedora
- fonts
- howto
comments: false
date: 2011-04-19T09:17:27Z
published: true
title: Fedora and Infinality patches
Slug: fedora-and-infinality-patches
url: /2011/04/fedora-and-infinality-patches
---

На мой взгляд, патчи для Cairo и Freetype от [Infinality](http://www.infinality.net/blog/) довольно существенно улучшают отображение шрифтов в Fedora. Я долгое время ими пользовался. Кроме того, в случае, когда ставил Fedora другим людям, пакеты с патчами также ставил. Но в последнее время сталкиваюсь с проблемами при их использовании. Начнем по порядку.

Обычно, после установки системы, я подключаю [репозиторий Infinality](http://www.infinality.net/fedora/linux/) и ставлю пакеты оттуда. Пакеты следующие:

- `cairo-freeworld`
- `freetype-infinality`
- `libXft-freeworld`
- `fonts-config`

Начиная примерно с альфа-версии Fedora 15, приходится не ставить совсем cairo-freeworld, иначе Иксы просто не запускаются. Как я понимаю, не совместимость с нынешним Xorg. Соответственно, внешний вид становится немного другим, но тоже вполне себе пригодный :)

А вчера столкнулся с тем, что некоторые документы при попытке открытия с помощью Writer просто рушили как OpenOffice, так и LibreOffice. Проверял и на том, и на другом. Долго не мог понять, что происходит, пока не посмотрел в
логи. Оказалось, офисный пакет падал с руганью на libfreetype. Уж не знаю, что не нравилось именно в этом конкретном документе, но после удаления freetype-infinality все стало нормально.

Получается несколько странная ситуация, с которой я сталкивался при использовании OpenSUSE. Там многие полезные пакеты собираются в OBS. Но порой авторы этих сборок при выходе новой версии дистрибутива то ли забывают
поддерживать далее свое творение, то ли просто не хотят. Я понимаю, что они и не обязаны делать это, но эффект получается неприятным. В данной ситуации происходит нечто подобное. Последние версии пакетов в репозитории относятся
еще к октябрю-ноябрю прошлого года. Сейчас же пошла вторая половина апреля. И пока приходится искать какие-то способы обойти проблемные места. Но чувствую, что вся надежда на [Tigro](http://tigro.info/wp/) :)

