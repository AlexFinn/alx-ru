---
type: post
tags:
- Fedora 18
- Security
- SELinux
comments: false
date: 2012-11-08T00:00:00Z
title: 'Security in Fedora 18 Part 3: New Confined/Permissive Process Domains'
Slug: security-in-fedora-18-part-3-new-confinedpermissive-process-domains
url: /2012/11/08/new-security-feature-in-fedora-18-part-3-new-confined-slash-permissive-process-domains/
---

Третья часть из постов Dan Walsh касательно нововведений в политики безопасности в Fedora 18. А вот и оригинальная [заметка][1].

С каждой версией Fedora мы выпускаем пачку новых доменов, которые будут запущены в режиме **permissive** в релизе. После выхода нового релиза домены в permissive режиме переводятся в enforcing.

В одном из моих предыдущих сообщений, [10 вещей. которые вы, возможно, не знали о SELinux... #4][2], я описывал, каким образом можно взаимодействовать с permissive доменами.

В Fedora 7 мы добавили 11 новых permissive доменов, 10 из которых сейчас enforcing в Fedora 18. Политика matahari была удалена, поскольку проект был закрыт.

#### Permissive домены в Fedora 17/Теперь Confined в Fedora 18
	couchdb_t, blueman_t, httpd_zoneminder_script_t, zoneminder_t, selinux_munin_plugin_t, sge_shepherd_t, sge_execd_t,
	sge_job_t, keystone_t, pacemaker_t

#### Permissive домены в Fedora 18
	pkcsslotd_t (демон, управляющий объектами PKCS#11 между приложениями с включенным PKCS#11)
	slpd_t  (демон Server Location Protocol)
	sensord_t (демон Sensor information logging)
	mandb_t  (задание для Cron, использующееся для создания /var/cache/man content)
	glusterd_t (политика для службы glusterd)
	stapserver_t (Instrumentation System Server) Заметка: Было бэкпортировано в Fedora 17.
	realmd_t (системная служба dbus, которая управляет определением и регистрацией в реалмах и доменах Active Directory или IPA)
	phpfpm_t (FastCGI Process Manager) 

#### Confined домены в Fedora 18
Благодаря открытости OpenShift мы создали несколько новых доменов для процессов. openshift управляет разделением между пользователями и приложениями пользователей, что означает необходимость для него быть ограниченным из коробки. `openshift_t` - тип, который использует каждое приложение при запуске, с различными метками MCS. Я напишу еще о политике openshift в будующих сообщениях.
	openshift_app_t, openshift_cgroup_read_t, openshift_initrc_t, httpd_openshift_script_t, openshift_t

#### Удаленные домены в Fedora 18
	matahari (проект закрыт)

#### Реогранизация доменов в Fedora 18
Мы разделили политики sandbox и sandboxX на отдельные части в порядке уменьшения размера политики. И теперь выключили политику sandbox по умолчанию. Мы сделали это, поскольку мало кто использует sandbox вместо sandboxX. Политика sandbox очень большая и ее отключение по умолчанию уменьшило размер политики примерно на 8%.

[1]: http://danwalsh.livejournal.com/58178.html
[2]: http://danwalsh.livejournal.com/42394.html
