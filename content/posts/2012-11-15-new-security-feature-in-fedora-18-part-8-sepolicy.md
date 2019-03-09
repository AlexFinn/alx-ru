---
type: post
tags:
  - Fedora 18
  - Security
  - SELinux
comments: false
date: 2012-11-15T00:00:00Z
title: 'Security in Fedora 18 Part 8: sepolicy'
Slug: security-in-fedora-18-part-8-sepolicy
url: /2012/11/15/new-security-feature-in-fedora-18-part-8-sepolicy/
---

На момент написания - это последняя часть из написанного Дэном про нововведения в систему безопасности в Fedora 18.
В его блоге эта часть разделена на 4 более мелкие, описывающие отдельные части sepolicy. Я решил объединить перевод в единое целое.
Много места в той статье занимают описания man-страниц. Я постарался, как мог, адекватно перевести их на русский. но если встретите какие-то ошибки и неточности - пишите в комментарии здесь или в Google+.

### [Введение в sepolicy][1]

В течение многих лет люди пытались понять политики SELinux и то, каким образом они ограничивают приложения. Администраторы хотели бы знать, какие типы процесс Apache может читать и записывать. Какие булевы значения доступны для Samba. Может ли домен производить запись в домашние директории пользователей?

#### sepolicy python bindings

Набор инструментов, который мы использовали для этого, назывался `setools`, включая в себя `apol` (графический инструмент tcl/tk), `sesearch` и `seinfo`. Я понял, что я сам почти никогда не использую `apol`, а в основном используется `sesearch` и `seinfo`. Но я хотел большей управляемости. Я решил добавить биндинги для python для этих двух команд, которые в предыдущих релизах входили в пакет `setools`. Эти биндинги для python отказались включить в основную ветку по какой-то причине. И я решил поместить их в свой отдельный пакет `sepolicy`.

	> python
	Python 2.7.3 (default, Aug  9 2012, 17:23:57)
	[GCC 4.7.1 20120720 (Red Hat 4.7.1-5)] on linux2
	Type "help", "copyright", "credits" or "license" for more information.
	>>> import sepolicy
	>>> sepolicy.info(sepolicy.ATTRIBUTE)

Возвращает словарь со всей информацией об аттрибутах SELinux

	>>>sepolicy.search([sepolicy.ALLOW])

Возвращает словарь всех разрешающих правил в политике.

#### команда sepolicy

Используя биндинги для python мы начали создавать новую серию команд, которые я посчитал полезными для понимания политики. Я решил объединить эти инструменты в единый инструмент командной строки - `sepolicy`. О некоторых из этих инструментах я писал раньше в этом блоге, но сейчас я объединил их в единый инструмент и сделал его частью дистрибутива. В нескольких следующих поостах в этом блоге я расскажу о нем.

	> man sepolicy

	sepolicy(8)                                                                                  sepolicy(8)

	ИМЯ
	       sepolicy - Инструмент для контроля политики SELinux

	СИНТАКСИС
	       semanage {manpage,network,communicate,transition,generate} ОПЦИИ

	       Аргументы:

	       communicate
	       Запрашивает у политики SELinux информацию о том, могут ли домены общаться друг с другом sepolicy-communicate(8)

	       generate
	       Создает шаблон модуля политики SELinux sepolicy-generate(8)

	       manpage
	       Создает man-страницы SELinux sepolicy-manpage(8)

	       network
	       Запрашивает информацию сетевой политики SELinux sepolicy-network(8)

	       transition
	       Запрашивает политику SELinux о том, как исходный домен процесса может перейти в целевойдомен процесса sepolicy-transition(8)

	ОПИСАНИЕ
	       sepolicy  - это набор инструментов, который позволяет делать запросы к установленной политике SELinux и создавать полезные отчеты, man-страницы или даже новые модули политики.
	       Обратитесь к man-страницам определенного аргумента для просмотра опций и описания.


### [Введение в sepolicy network][2]

Одной из проблем использования SELinux является понимание защиты сети. SELinux управляет тем, на какие порты домен может подключаться и какие порты может использовать. Так как SELinux - система ограничения по типу, она контролирует доступ к портам через типы. Процессы получают назначенный тип и номера портов получают назначенный тип. Поскольку пользователи мыслят в понятиях номеров портов, мы создали инструмент облегчающий пользователям понимание этих отношений. [Изначально этот инструмент назывался `senetwork`, но сейчас он поставляется как часть комплекта `sepolicy`.][3]

	> man sepolicy-network
	sepolicy-network(8)                                                                			sepolicy-network(8)

	NAME
	       sepolicy-network - Проверяет политику SELinux и создает отчет по сети

	СИНТАКСИС
	       sepolicy network [-h] (-l | -p PORT [PORT ...] | -t TYPE [TYPE ...] | -d DOMAIN [DOMAIN ...])

	ОПИСАНИЕ
	       Используйте sepolicy network для проверки политики SELinux и создания отчетов касательно сети.

	ОПЦИИ
	       -d, --domain
	            Создает отчет, в котором перечисляются порты к которым конкретному домену разрешено подключаться или которые разрешено использовать.

	       -l, --list
	            Выводить список всех типов сетевых портов, определенных в политике SELinux

	       -h, --help
	            Отображает справку по команде

	       -t, --type
	            Создает отчет, в котором перечислены номера портов, ассоциированные с конкретным типом порта SELinux.

	       -p, --port
	            Создает отчет, в котором перечислены типы портов SELinux, ассоциированные с конкретным номером порта.

`sepolicy network` позволяет запрашивать у SELinux, какой тип порта ассоциирован с конкретным номером порта.

	# sepolicy network --port 8080
	8080: tcp unreserved_port_t 1024-32767
	8080: udp unreserved_port_t 1024-32767
	8080: tcp http_cache_port_t 8080

Или какой номер порта ассоциирован с типом порта.

	# sepolicy network -t dns_port_t
	dns_port_t: tcp: 53
	dns_port_t: udp: 53

Заметьте, что `sepolicy` также поддерживает автодополнение в bash.

	# sepolicy network -t d<tab>
	daap_port_t     dccm_port_t     dhcpc_port_t    dict_port_t     dns_port_t      dogtag_port_t  
	dbskkd_port_t   dcc_port_t      dhcpd_port_t    distccd_port_t  dnssec_port_t  

В итоге, вы можете спросить, к какому порту разрешено подключаться или использовать типу домена процесса:

	# sepolicy network -d cupsd_t
	cupsd_t: tcp name_connect
	    all ports
	cupsd_t: tcp name_bind
	    reserved_port_t: 1-511
	    rpc_port_type: all ports > 500 and  < 1024
	    ipp_port_t: 631,8610-8614
	cupsd_t: udp name_bind
	    howl_port_t: 5353
	    ipp_port_t: 631,8610-8614


### [Введение в sepolicy transition][5]

Другая популярная тема касательно SELinux - сложность понимания перехода процессов. В принципе, это механизм, позволяющий большей части процессов получать свою метку. Домен `init_t` переходит в домен `initrc_t`, когда выполняется скрипт назначения метки `initrc_exec_t`. `initrc_t` переходит в `httpd_t`, когда он выполняется и файл помечается `httpd_exec_t` ...

И из этого появляются два вопроса:

- Какие домены процесса могут из одного домена процесса перейти в другой?
- Может ли один домен процесса перейти в другой?

[Изначально этот инструмент назывался `setrans`, но сейчас он поставляется как часть комплекта `sepolicy`.][4]

	> man sepolicy-transition
	sepolicy-transition(8)                                  sepolicy-transition(8)

	ИМЯ
	       sepolicy-transition - Проверяет политику SELinux и создает отчет о переходах процессов

	СИНТАКСИС
	       sepolicy transition [-h] -s SOURCE

	       sepolicy transition [-h] -s SOURCE -t TARGET

	ОПИСАНИЕ
	       sepolicy transition покажет все домены, в которые могут переходить исходные домены SELinux, включая точку входа.

	       Если указан целевой домен, sepolicy transition будет проверять политику для всех путей перехода от исходного домена к целевому и выведет список этих путей. Если переход возможен, этот инструмент выведет все пути перехода от исходного домена к целевому.

	ОПЦИИ
	       -h, --help
	            Отобразить справку по команде.

	       -s, --source
	            Указать исходный тип домена SELinux.

	       -t, --target
	            Указать целевой тип домена SELinux.

Если я хочу посмотреть, какие домены процесса `guest_t` можно перевести в другой, я могу выполнить следующее:

	# sepolicy transition -s guest_t
	guest_t @ abrt_helper_exec_t --> abrt_helper_t
	guest_t @ loadkeys_exec_t --> loadkeys_t
	guest_t @ chkpwd_exec_t --> chkpwd_t
	guest_t @ passwd_exec_t --> passwd_t
	guest_t @ updpwd_exec_t --> updpwd_t
	guest_t @ chfn_exec_t --> chfn_t
	guest_t @ oddjob_mkhomedir_exec_t --> oddjob_mkhomedir_t
	guest_t @ shell_exec_t --> httpd_user_script_t

Если я хочу увидеть, как `httpd_t` может прочитать `system_mail_t`:

	# sepolicy transition -s httpd_t -t system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_mojomojo_script_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> postfix_showq_t --> spamc_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> dovecot_deliver_t --> uux_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> dovecot_deliver_t --> sendmail_t --> uux_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> dovecot_deliver_t --> sendmail_t --> procmail_t --> clamscan_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> dovecot_deliver_t --> sendmail_t --> postfix_master_t --> postfix_local_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> dovecot_deliver_t --> sendmail_t --> postfix_master_t --> postfix_pipe_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> uux_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_openshift_script_t --> openshift_initrc_t --> openshift_domain --> openshift_t --> openshift_mail_t --> exim_t --> clamscan_t --> system_mail_t
	httpd_t --> httpd_suexec_t --> httpd_bugzilla_script_t --> system_mail_t
	httpd_t --> abrt_retrace_worker_t --> mock_t --> mount_t --> lvm_t --> insmod_t --> initrc_t --> daemon --> system_mail_t
	httpd_t --> abrt_retrace_worker_t --> mock_t --> mount_t --> lvm_t --> insmod_t --> initrc_t --> systemprocess --> system_mail_t
	httpd_t --> abrt_retrace_worker_t --> mock_t --> mount_t --> lvm_t --> insmod_t --> initrc_t --> sulogin_t --> unconfined_t --> dhcpc_t --> NetworkManager_t --> pppd_t --> system_mail_t
	httpd_t --> abrt_retrace_worker_t --> mock_t --> mount_t --> lvm_t --> insmod_t --> initrc_t --> sulogin_t --> unconfined_t --> rpm_t --> rpm_script_t --> system_mail_t
	httpd_t --> abrt_retrace_worker_t --> mock_t --> mount_t --> lvm_t --> insmod_t --> initrc_t --> sulogin_t --> unconfined_t --> rpm_script_t --> system_mail_t
	httpd_t --> passenger_t --> system_mail_t
	httpd_t --> httpd_bugzilla_script_t --> system_mail_t
	httpd_t --> httpd_mojomojo_script_t --> system_mail_t

Заметьте, что на данный момент эта команда не берет настройки булевых значений аккаунта, а просто показывает, что это возможно. В будущем улучшение коснется списка булевых значений, требующихся для разрешения доступа. 

### [Введение в sepolicy generate][6]

#### sepolgen

`sepolgen` - это инструмент, который я рекомендовал использовать, чтобы начать генерировать политики. Мы решили включить этот инструмент в комплект `sepolicy`.

#### sepolicy generate

	man sepolicy-generate

	sepolicy-generate(8)                                                                  sepolicy-generate(8)

	ИМЯ
	       sepolicy-generate - Создает исходный шаблон модуля политики SELinux.

	СИНТАКСИС
	       sepolicy generate [-h] [-t TYPE] [-n NAME] [-T TEST] [ command | confineduser ]

	ОПИСАНИЕ
	       Испольуйте sepolicy generate для создания модуля политики SELinux.  sepolicy generate создаст 4 файла.

	       Файл типа ограничения NAME.te
	       Этот файл может быть использован для указания правил всех типов для конкретного домена.

	       Файл интерфейса NAME.if
	       Этот файл определяет интерфейсы для типов, созданных в te-файле, которые могут быть использованы другими доменами политики.

	       Файл контекстов NAME.fc
	       Этот файл определяет контекст файла по умолчанию для системы, он берет типы файла, созданные в te-файле и ассоциирует пути файлов с их типом.  Инструменты вроде restorecon и RPM будут использовать эти пути для записи меток.

	       Файл RPM Spec NAME_selinux.spec
	       Этот файл - это spec-файл RPM, который может быть использован для установки политики SELinux на машины, а также для выставления меток.spec-файл также устанавливает файл интерфейсов и man-страницу, описывающую политику. Можно использовать use sepolicy manpage -d NAME для создания man-страницы.

	       Файл установки NAME.sh
	       Это вспомогательный shell-скрипт для сборки, установки и исправления меток на тестовой системе. Он также создает man-страницу, на основе установленной политики, и собирает RPM пакет. пригодный для установки на другие машины.

	       Если создание возможно, этот инструмент выведен на экран все пути создания от исходного домена к целевому домену.

	ОПЦИИ
	       -h, --help
	            Показать справку по команде

	       -t, --type
	            Указать тип политики, которую необходимо создать
	            Доступные опции:
	              0 : Стандартный Init Daemon (по умолчанию)
	              1 : DBUS System Daemon
	              2 : Internet Services Daemon
	              3 : Web-приложение/скрипт (CGI)
	              4 : Приложение пользователя
	              5 : Песочница
	              6 : Минимальная роль терминального пользователя
	              7 : Минимальная роль пользователя системы X Window
	              8 : Роль пользователя
	              9 : Роль администратора
	              10 : Роль пользователя root
	       -n, --name
	              Указать альтернативное имя политики. По умолчанию имя политики берется из имени указанного исполняемого файла или его имени..

	ПРИМЕР
	       sepolicy generate /usr/sbin/rwhod
	       Создание политики для  /usr/sbin/rwhod под названием rwhod
	       Создает следующие файлы:
	       rwhod.te # Файл типа ограничения
	       rwhod.if # Файл интерфейса
	       rwhod.fc # Файл контекстов
	       rwhod_selinux.spec # Spec-файл
	       rwhod.sh # Скрипт установки

`sepolicy generate` обладает несколькими прекрасными преимуществами перед `sepolgen`.

1. `sepolicy generate` нет необходимости запускать от пользователя root
2. `sepolicy generate` теперь генерирует файл RPM spec. Этот spec-файл может быть использован для сборки RPM пакета, который установит файл пакета политики (policy package - pp) и файл интерфейса (inteface file - if) в нужное место, установит их в ядро и исправит метку.
3. Скрипты настройки, созданные с помощью `sepolicy generate`, остаются для установки политики и настройки меток, а также создают man-страницу на основе установленной политики, используя sepolicy manpage, и в итоге `sepolicy generate` создает и компилирует политику и man-страницу в rpm-пакет, пригодный для установки на другие машины.

`selinux-polgengui` больше также не требует запуска от пользователя root, поскольку он использует биндинги для python от `sepolicy generate` для создания файлов политики. Команда `sepolgen` теперь просто запускает `sepolicy generate` как shell-скрипт.


[1]: http://danwalsh.livejournal.com/60135.html
[2]: http://danwalsh.livejournal.com/60528.html
[3]: http://danwalsh.livejournal.com/53182.html
[4]: http://danwalsh.livejournal.com/46653.html
[5]: http://danwalsh.livejournal.com/60801.html
[6]: http://danwalsh.livejournal.com/61107.html
