---
type: post
title: "systemd и логи"
slug: "systemd-and-logs"
date: "2019-03-08"
tags:
  - "systemd"
  - "rsyslog"
  - "log"
---

Всегда, если записать, лучше запомнится :) А может кому и пригодится.

По умолчанию, `systemd` пишет и хранит логи в бинарном виде. Просмотреть же их в нормальном можно с помощью команды `journalctl`: например, `journalctl -u <service-name>`.

Сейчас чуть подробнее о нюансах.
Рассмотрим такой `.service` файл:

```
[Service]
EnvironmentFile=/etc/default/airflow
User=user
Group=group
Type=simple
ExecStart=/opt/airflow/bin/run_script.sh airflow webserver
Restart=on-failure
RestartSec=5s
PrivateTmp=true
```

Кстати, для `airflow-scheduler` параметр `ExecStart` будет похожим:

```
ExecStart=/home/prod/vm/airflow/bin/run_script.sh airflow scheduler
```

Проблема здесь в том, что все логи от `airflow-web` и `airflow-scheduler` будут записаны в `syslog` с идентификатором `run_script.sh`. Согласитесь, что это не совсем удобно.
Для того, чтобы это исправить, можно добавить параметр `SyslogIdentifier`. Например, `SyslogIdentifier=airflow-web` и `SyslogIdentifier=airflow-scheduler` соответственно.
Теперь стало получше.

Но всё равно, логи все свалены в одном месте - в `/var/log/syslog`, что может оказаться неудобным, если, скажем, захочется сделать разные настройки ротации логов для разных сервисов. (И да, я знаю про существование `ELK` и `graylog`. )))
В этом случае можно воспользоваться `rsyslog`. Вот два файлика для упомянутых выше сервисов.

```
if $programname == 'airflow-web' then /var/log/airflow/web.log
& stop
```
```
if $programname == 'airflow-scheduler' then /var/log/airflow/scheduler.log
& stop
```

Кидаем их в `/etc/rsyslog.d` и перезапускаем `rsyslog`. Главное, не забыть создать директорию `/var/log/airflow`, на всякий случай, и выставить на нее права (`syslog:adm`, в случае с Ubuntu).

В процессе коррекции тасков для ansible выяснил еще одну штуку. Оказывается, в `systemd`, начиная с версии 236 можно сделать немного по-другому, но только если не требуется, чтобы логи попадали в `syslog`. Для параметров `StandardOutput` и `StandardError` можно указать путь до файла. Выглядит это так:

```
...
StandardOutput=file:/var/log/airflow/web.log
StandardError=file:/var/log/airflow/web-error.log
...
```

Путь до файла должен быть абсолютным. Как пишет нам [`man systemd.exec`](https://www.freedesktop.org/software/systemd/man/systemd.exec.html):

> The file:path option may be used to connect a specific file system object to standard input. An absolute path following the ":" character is expected, which may refer to a regular file, a FIFO or special file. If an AF\_UNIX socket in the file system is specified, a stream socket is connected to it.
