---
type: post
tags:
- Fedora 18
- SELinux
- Security
comments: false
date: 2012-11-06T00:00:00Z
title: 'Security in Fedora 18 Part 1: SELinux Systemd Access Control'
Slug: security-in-fedora-18-part-1-selinux-systemd-access-control
url: /2012/11/06/new-security-feature-in-fedora-18-part-1-selinux-systemd-access-control/
---

Давно я уже собирался начать перевод сообщений Дэна Уолша касательно изменений в SELinux, которые придут вместе с Fedora 18. И вот сейчас, поскольку новое место работы я пока так и не нашел, решил все реализовать задуманое. Итак, первая часть: [SELinux Systemd Access Control][2]

Для Fedora 17 у меня была серия сообщений про новые возможности безопасности. И я прикинул, что настало время сделать то же самое для Fedora 18.
Если у вас есть желание пообщаться на эту тему, пишите на dwalsh@redhat.com или в комментарии в блоге.

#### Контроль доступа к Systemd
В предыдущих версиях Fedora/RHEL SELinux мог контролировать, какие процессы могли запускать/останавливать службы на основе метки процесса или метки скрипта запуска.

Например, NetworkManager (`NetworkManager_t`) было разрешено выполнять `/etc/init.d/ntp` (`ntp_initrc_exec_t`), но не был разрешен доступ к `/etc/init.d/httpd` (`httpd_initrc_exec_t`).

С приходом systemd мы потеряли такую возможность, поскольку systemd запускает и останавливает все службы.

Мы можем разрешить NetworkManager (`NetworkManager_t`) выполнять systemctl, который мог бы отправить сообщение dbus к systemd, а systemd мог бы запустить/остановить ту службу, которую запрашивает NetworkManager. Фактически, мы так приходим к тому, что позволяем NetworkManager делать все то, что может делать systemctl. Мы также хотели бы определить ограничения для администраторов, но снова пришли к тому, что позволяем им или запускать и останавливать все службы, или вообще никакие. Мы не может больше разрешить `webadm_t` запустить или остановить только `httpd_t`.

В Fedora 18 мы исправили это, сделав systemd SELinux Access Manager. Теперь systemd будет восстанавливать метку процесса, запущенного через systemctl, или процесса, который отправил systemd сообщение dbus. Затем systemd будет искать метку отдельного файла, который процесс захочет настроить. В итоге, systemd спросит ядро, позволяет ли политика SELinux конкретный доступ между меткой процесса и меткой этого файла. Это означает, что взломанный NetworkManager или любое другое приложение, которому требуется взаимодействовать через systemd с конкретной службой, теперь может быть ограничен с помощью SELinux. Авторы политик смогут делать тонкую настройку для ограничения администраторов.

##### Изменения политики
Мы добавили новый класс в SELinux Policy под названием "service". Для класса service определены следующие права:

	start stop status reload kill load enable disable  

Это означает, что автор политики может разрешить домену получить статус службы или запустить или остановить службу, но запретить включать или отключать ее. Это позволяет нам получить больший контроль, чем был у нас в прошлом.

Для демонстрации я настроил `webadm_t` в качестве процесса root:
[Заметка: для получения информации о настройке ограниченных пользователей смотреть другое сообщение.][1]

	# id -Z
	staff_u:webadm_r:webadm_t:s0-s0:c0.c1023
	# /bin/systemctl status httpd.service
	httpd.service - The Apache HTTP Server
	      Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled)
	      Active: inactive (dead)
	      CGroup: name=systemd:/system/httpd.service

	# /bin/systemctl status NetworkManager.service
	Failed to issue method call: SELinux policy denies access.

В отдельном окне, запущенном как `unconfined_t`, я могу посмотреть на создание сообщения AVC.

	# id -Z
	staff_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
	# ausearch -m user_avc
	time->Thu Sep 27 08:54:10 2012
	type=USER_AVC msg=audit(1348750450.105:135): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='avc:  denied  { status } for auid=3267 uid=0 gid=0 path="/usr/lib/systemd/system/NetworkManager.service" cmdline="/bin/systemctl status NetworkManager.service" scontext=staff_u:webadm_r:webadm_t:s0-s0:c0.c1023 tcontext=system_u:object_r:NetworkManager_unit_file_t:s0 tclass=service  exe="/usr/lib/systemd/systemd" sauid=0 hostname=? addr=? terminal=?'

И, конечно, вы можете использовать audit2allow для написания политики для разрешения этого доступа.

	audit2allow -la
	#============= webadm_t ==============
	allow webadm_t NetworkManager_unit_file_t:service status;

	# audit2allow -laR
	#============= webadm_t ==============
	networkmanager_systemctl(webadm_t)

Убедитесь, что используете последнюю версию systemd и selinux-policy прежде, чем пробовать. Это мои текущие версии:

	# rpm -q selinux-policy systemd
	selinux-policy-3.11.1-26.fc18.noarch
	systemd-191-2.fc18.x86_64


[1]: http://danwalsh.livejournal.com/18578.html
[2]: http://danwalsh.livejournal.com/57377.html
