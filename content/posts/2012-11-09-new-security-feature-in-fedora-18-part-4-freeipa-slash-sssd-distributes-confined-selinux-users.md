---
type: post
tags:
- Fedora 18
- Security
- SELinux
- FreeIPA
comments: false
date: 2012-11-09T00:00:00Z
title: 'Security in Fedora 18 Part 4: FreeIPA/SSSD distributes Confined SELinux Users'
Slug: security-in-fedora-18-part-4-freeipasssd-distributes-confined-selinux-users
url: /2012/11/09/new-security-feature-in-fedora-18-part-4-freeipa-slash-sssd-distributes-confined-selinux-users/
---

Четвертая часть про нововведения в систему безопасности в Fedora 18. [Оригинал статьи от Dan Walsh.][3]

#### FreeIPA теперь поддерживает распределение Пользователей SELinux
[Confined SELinux Users были представлены некоторое время назад.][1] Основная идея состоит в том, чтобы предоставить пользователям различный доступ в зависимости от машины, на которой они авторизуются.

Используем меня самого в качестве примера: я постоянно логинюсь на 5 различных машинах, не считая виртуальных. Мой ноутбук, моя тестовая машина, shell.devel.redhat.com, people.redhat.com и people.fedoraproject.com. 

- **people.redhat.com** и **people.fedoraproject.com**: мне нужно логиниться как `guest_u:guest_r:guest_t:s0`. Эти машины используются для распространения контента через веб-серверы. Мне должно быть позволено изменять только свою домашнюю директорию. У меня не должно быть доступа к сети, приложениям setuid, вроде su или sudo, и не должно быть возможности собирать или выполнять код в домашней директории.
- **shell.dev.redhat.com**. Эта машина предоставляет доступ к shell разработчикам и используется ими всеми. У меня должна быть возможность исполнять содержимое домашней директории и, возможно, настраивать и тестировать сетевые приложения, поскольку это машина для разработки. Но я не администратор, у меня не должно быть возможности использовать su или sudo. `user_u:user_r:user_t:s0-s0:c0.c1023` была бы хорошей меткой пользователя SELinux для этой машины.
- Мой ноутбук и тестовые машины (holycross и redsox) должны быть настроены для использования либо `unconfined_t`, либо `staff_t`. В моей случае, они запускаются с `staff_u:staff_r:staff_t:s0-s0:c0.c1023`, а процессы администратора как `staff_u:unconfined_r:unconfined_t:s0-s0:c0.c1023`.

Проблема подобной конфигурацией в том, что каждая из этих машин настраивается отдельно. Для аутентификации я использую сервер каталогов, а авторизация подтверждается kerberos. Но до сих пор не было стандартного способа настроить ограничения для пользователей на централизованном сервере.

Одно из больших преимуществ FreeIPA - возможность добавлять идентификатор к машинам. FreeIPA знает разницу между dwalsh на people.redhat.com и dwalsh на shell.devel.redhat.com. Команда FreeIPA добавила возможность хранить описания SELinux Users на основе сопоставления User/Machine.

В Fedora 18 вы сможете настроить ограничения для пользователей с помощью графического интерфейса FreeIPA.

![][2]

В Red Hat мы могли бы настроить маппинг пользователь/машина таким образом, что все пользователи на people.redhat.com логинились с SELinux User/Level - `guest_u:s0`.

#### SSSD играет огромную роль в назначении SELinux User/Level из IPA процессу пользователя при логине.
Когда пользователеь заходит на машину, скажем, через sshd, sshd использует стэк PAM. Один из первых модулей PAM, который используется - `pam_sss`. `pam_sss` отправляет запрос к SSSD, говоря ему, что dwalsh заходит в систему. SSSD контактирует с  сервером FreeIPA и спрашивает, какой SELinux User/Level следует выдать dwalsh, когда он логинится. SSSD берет полученный ответ и создает файл в `/etc/selinux/POLICYTYPE/logins/dwalsh`. Во время сессии стэка PAM вызывается модуль `pam_selinu`x. `pam_selinux` читает `/etc/selinux/POLICYTYPE/logins/dwalsh` и говорит ядру запустить процесс пользователя с SELinux User, указанные во FreeIPA, например, `guest_u:guest_r:guest_t:s0`.

В настоящее время SSD поддерживает только FreeIPA для такой транзакции. В будущем, он может быть изменен для возможности использования других источников об информации SELinux.

Заметка: Во FreeIPA вы можете настроить набор правил Host Based Access Control. Эти правила определяют, какие пользователи (и группы пользователей) к каким машинам (и группам машин) имеют доступ через какие службы входа в систему (ssh, ftp, sudo, su и пр.) Администратор может повторно использовать ассоциации user-host, определенные в правилах HBAC, для определения правил сопоставления пользователей SELinux. Это помогает избежать дублирования управления и более ясно выражаться: группа пользователей X может получить доступ к группе хостов Y и получит при этом права пользователя SELinux Z.

[1]: http://danwalsh.livejournal.com/18312.html
[2]: /images/2012/11/09/SELinux-User-Maps.png
[3]: http://danwalsh.livejournal.com/58508.html
