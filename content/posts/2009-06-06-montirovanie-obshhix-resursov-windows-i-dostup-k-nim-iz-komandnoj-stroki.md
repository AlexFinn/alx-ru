---
type: post
author: hrafn
tags:
- share
- howto
- smb
comments: false
date: 2009-06-06T13:10:22Z
published: true
title: Монтирование общих ресурсов Windows и доступ к ним из командной строки
Slug: монтирование-общих-ресурсов-windows-и-доступ-к-ним-из-командной-строки
url: /2009/06/montirovanie-obshhix-resursov-i-dostup-k-nim-iz-komandnoj-stroki
---

Как всегда, в последнее время да и раньше, собственно, перевод
[статьи](http://www.novell.com/communities/node/8325/mount-and-access-windows-shares-command-line) господина
[kramarao](http://www.novell.com/communities/user/3617) из Novell
CoolSolutions. Сегодня поговорим о шарах Windows.

Если в вашей сети имеют место быть общие ресурсы на Windows-машинах и вы
хотите получить доступ к ним, я покажу вам, как можно сделать это из командной
строки. Я собираюсь рассказать о двух различных способах.

  1. Подключение к ресурсу интерактивно (этот способ подобен подключению по FTP)
  2. Монтирование ресурса к локальному каталогу для доступа к нему, как локальному каталогу

**Способ 1. Подключение к ресурсу/серверу интерактивно**

Допустим, что "mirage" - это имя Windows-ресурса. А вот необходимая команда
для интеактивного доступа к нему:

		mount //IP_ADDR_OF_Windows_machine/Sharename -Uusername

Пример:

		mount //192.168.1.14/mirage -Uadmin

В приведенном примере:

  * 192.168.1.14 - IP-адрес машина Windows
  * mirage - имя ресурса на этой машине
  * admin - имя пользователя для доступа к этому ресурсу

При запросе пароля вы увидите команду, подобную следующей 'smb: >'. А с
помощью команды 'Help' вы сможете получить список всех поддерживаемых команд.
На представленном скриншоте показаны именно они:

[![](/images/2009/06/06/8325-1.jpg)](/images/2009/06/06/8325-1.jpg)

Описание некоторых команд:

		get <remote file name > [local file name ]

Копировать файл с именем "remote file name" с ресурса/сервера на машину, с
запущенным клиентом smb. Если указано, то имя локального файла будет
соответствовать удаленному. Отметьте, что все передачи проходят в бинарном
виде.

		put <local file name > [remote file name ]

Копировать локальный файл с именем "local file name" с машины с smb-клиентом
на ресурс/сервер. Если указано, имя копии будет соответствовать локальному.

		open <file name>

Открыть удаленный файл и напечатать ID файла.

		close fileID

Закрыть файл, открытый командой open.

**Способ 2. Монтирование ресурса к локальному каталогу и доступ к нему.**

Далее показано необходимые шаги для монтирования Windows-ресурса к локальному
каталогу.

1. Создать локальный каталог

		mkdir test_dir

2. Примонтировать ресурс, используя следующую команду (заметьте, что эти
команды должны выполняться от пользователя root):

		mount -t cifs //Windows_IP/share_name target_folder_path -o username=user,password=pwd

В представленной команде ключ -t используется для указания типа файловой
системы или типа протокола для монтирования. Имя пользователя должны
принадлежать одному из существующих пользователей на Windows-машине и он
должен иметь соответствующие права доступа к этой машине.

Посмотрим пример:

		mount -t cifs //192.168.1.14/shared_folder ./test_dir -o username=user,password=abcdef

Для хранения информации о пользователе можно использовать текстовый файл и
использовать его для аутентификации пользователя. Фомат файла должен быть
следующим:

		username=value
		password=value

Используйте ключ credentials для указания файла с данными для аутентификации:

		mount -t cifs //192.168.1.14/shared_folder ./test_dir -o credentials=filename

3. Перейти в каталог 'test_dir'. Теперь можно будет посмотреть содержимое
общего ресурса.

Действия, которые можно выполнять на ресурсе, зависят от прав доступа к этому
ресурсу. Эти права могут быть настроены при создании ресурса.

Отмонтировать смонтированный ресурс можно с помощью следующей команды:

		umount mounted_folder_path

Например:

		umount ./test_dir

Наследующем скриншоте показаны команды для монтирования и отмонтирования
общего каталога.

[![](/images/2009/06/06/8325-2.jpg)](/images/2009/06/06/8325-2.jpg)

