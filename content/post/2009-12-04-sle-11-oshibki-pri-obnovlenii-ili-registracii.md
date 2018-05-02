---
type: post
author: hrafn
tags:
- suse
- registration
comments: false
date: 2009-12-04T13:06:28Z
published: true
title: SLE 11. Ошибки при обновлении или регистрации
Slug: sle-11-ошибки-при-обновлении-или-регистрации
url: /2009/10/oshibki-pri-obnovlenii-ili-registracii
---

Собственно, может я бы и не стал переводить сей документ, если бы не так давно
сам не столкнулся с точно такой же проблемой.

Итак, при попытке зарегистрировать систему или при запуске Online Update вы
получаете следующую ошибку: "Error occured while setting download (curl)
options for https://nu.novell.com/?credentials=NCCcredentials"  Что делать?

Скачайте вручную, к сожалению, с сайта Novell следующие патчи ТОЛЬКО для
архитектуры, которая у вас используется:

SUSE Linux Enterprise Server x86:

[http://download.novell.com/Download?buildid=8eM5XSIXVTM~](http://download.novell.com/Download?buildid=8eM5XSIXVTM~)

SUSE Linux Enterprise Server x86_64:

[http://download.novell.com/Download?buildid=SodoY-EnzRs~](http://download.novell.com/Download?buildid=SodoY-EnzRs~)

SUSE Linux Enterprise Server ppc:

[http://download.novell.com/Download?buildid=TkMGQ15OKxM~](http://download.novell.com/Download?buildid=TkMGQ15OKxM~)

SUSE Linux Enterprise Server s390x:

[http://download.novell.com/Download?buildid=32N8O9s_z9U~](http://download.novell.com/Download?buildid=32N8O9s_z9U~)

SUSE Linux Enterprise Desktop x86:

[http://download.novell.com/Download?buildid=9PpUx85QTUc~](http://download.novell.com/Download?buildid=9PpUx85QTUc~)

SUSE Linux Enterprise Desktop x86_64:

[http://download.novell.com/Download?buildid=5PXBAYCg9EE~](http://download.novell.com/Download?buildid=5PXBAYCg9EE~)

Затем установите их с помощью команды:

		rpm -Fhv *.rpm

Сама ошибка является следствием того, что последнее обновление пакета zypper
имеет потерянную зависимость от обновления пакета curl от 2009/08/07, по этой
причине его необходимо установить вручную.

[Оригинал: TID **7004839**](http://www.novell.com/support/search.do?cmd=displayKC&docType=kc&externalId=7004839&sliceId=1&docTypeID=DT_TID_1_1&dialogID=107509765&stateId=0%200%20107513256)

