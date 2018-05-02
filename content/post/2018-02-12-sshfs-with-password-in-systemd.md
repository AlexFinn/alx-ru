---
type: post
title: "Монтирование sshfs с паролем с помощью systemd.mount"
slug: "sshfs-with-password-in-systemd"
date: "2018-02-12"
tags:
  - "systemd"
  - "sshfs"
  - "fuse"
---

Маленькая предистория для начала.
Есть некий поставщик неких данных, который предоставляет доступ к этим данным исключительно через `sftp` или `sshfs` с помощью логина и пароля. К сожалению, никакого ключа не дается, уговорить пытались, но не вышло. Им просто всё равно: или так, или никак. Поэтому пришлось работать с тем, что есть.

Итак, как получить файлы на удаленном сервере?
Зайти через `sftp` и скачать. Хорошо, но поскольку эти файлы необходимо загрузить в GCS, не хотелось бы копировать их сначала на инстанс, а потом уже на GCS. Кроме того, их общий объём может быть больше размера диска инстанса.
Другой вариант - примонтировать через `sshfs`, например так:

	→ sshfs user@instance:/remote/path /local/path

Это отлично работает при использовании ключей SSH для подключения, но в нашем случае такой возможности нет, как я уже упоминал, поэтому можно воспользоваться следующей штукой:

	→ sshfs -o password_stdin user@instance:/remote/path /local/path <<< "password"

либо

	→ echo 'password' | sshfs user@instance:/remote/path /local/path -o password_stdin

Уже лучше, но вариант тоже не очень удобный. Какое-то время оно проработало именно в таком виде, с ручным мониторингом состояния, но после нескольких падений подключения стало ясно, что необходимо всё это дело как-то автоматизировать. Во-первых, хотелось бы монтировать автоматически при загрузке инстанса, кроме того желательно восстанавливать подключение при обрыве.

При помощи твиттера (спасибо, [￼@\_vpol\_](https://twitter.com/_vpol_)￼ и [￼@AndyClarkii](https://twitter.com/AndyClarkii)￼) я узнал про `sshpass` и задача чуть облегчилась:

	→ sshpass -p "password" sshfs user@instance:/remote/path /local/path

если хочется вводить пароль. Впрочем есть еще варианты:

`sshpass -f filename` - чтобы прочитать пароль из файла

`sshpass -e` - чтобы получить пароль из переменной окружения `SSHPASS`

Вариант с паролем в файле меня вполне устраивал. Оставалось запихать найденное в `systemd`. Быть может я плохо искал, но я не смог найти примеров использования `sshfs` вместе с `systemd` без запуска дополнительных баш скриптов. Может плохо искал, может оно не нужно никому )

## systemd.service

Начать я решил с простого `.service` файла. Получилось следующее:

	[Unit]
	Description=sshfs service script
	Requires=network-online.target network.target
	After=network-online.service network.target

	[Install]
	WantedBy=multi-user.target

	[Service]
	Type=simple
	User=user
	Group=group
	ExecStart=/usr/bin/sshpass -f /path/to/passfile sshfs -f -o allow_other user@instance:/remote/path /local/path -o nonempty
	ExecStopPost=/bin/fusermount -u /local/path
	Restart=on-failure

Нужно только не забыть, что директория, в которую монтируется, должна быть уже создана.

## systemd.mount

Предыдущий вариант работал, но хотелось бы использовать именно `.mount`, поскольку эта штука умеет перемонтировать при ошибках.

Итак, мой вариант `.mount` файла для `sshfs`:

	[Install]
	WantedBy=multi-user.target

	[Unit]
	Description=sshfs mount script
	Requires=network-online.target network.target
	After=network-online.service network.target

	[Mount]
	What=user@instance:/remote/path
	Where= /local/path
	Options=allow_other,uid=<user_id>,gid=<group_id>,default_permissions,_netdev,nonempty,UserKnownHostsFile=/dev/null,StrictHostKeyChecking=no,ssh_command=sshpass\040-f\040/path/to/passfile\040ssh
	Type=fuse.sshfs

Здесь следует обратить внимание на следующие вещи, которые мне пришлось добавить.
Во-первых, я добавил `StrictHostKeyChecking=no` и `UserKnownHostsFile=/dev/null`. Не очень безопасно, но позволяет не думать о согласии на принятия ключа удаленного сервера при развертывании нового инстанса.
Во-вторых, обратите внимание на `ssh_command=sshpass\040-f\040/path/to/passfile\040ssh`. Связано с тем, что требуется заэкранировать пробелы в команде `sshpass -f /path/to/passfile`. Попытка сделать что-то вроде `ssh_command="sshpass -f /path/to/passfile ssh"` не удалась, хотя вполне вероятно, что на момент попытки я что-то упустил.

Теперь осталось только `sudo systemctl daemon-reload` и запустить `sudo systemctl start local-path.mount`.
