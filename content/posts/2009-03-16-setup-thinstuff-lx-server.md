---
type: post
tags:
- thinstuff
- howto
- rdp
comments: false
date: 2009-03-16T12:22:03Z
title: Установка Thinstuff LX Server
Slug: установка-thinstuff-lx-server
url: /articles/setup-thinstuff-lx-server
---

## Краткое вступление

Стоит напомнить, что Thinstuff LX Server позволяет получить удаленный доступ к
приложениям на основе X11 с помощью протокола Microsoft RDP (Remote Desktop).
Что обеспечивает возможность использования как приложений Linux, так и Windows
на одном рабочем столе — без необходимости внсить изменения в инфраструктуру.

Поскольку разговаривать мы будем о версии, предназначенной именно для машин с
установленным Linux, то все последующие упоминания будут только об этой
системе.

[![](/images/2009/03/16/lx.gif)]

Домашняя страница продукта находится по адресу:
[http://www.thinstuff.com/products/lx-server/](http://www.thinstuff.com/products/lx-server/)

Подробно останавливаться на описании и возможностях продукта я сейчас не буду,
с учетом того, что не так давно я вкратце описывал их ([_LX Server от Thinstuff_](/2009/03/lx-server-ot-thinstuff)).

Мне нравятся компании, которые дают возможность проверить работоспособность
продукта, предлагая версии с ограничением подключений или с ограничениями по
времени использования. Это дает возможность получить общее представление о
работоспособности и пригодности для использования в конкретной организации и в
конкретных условиях.

Компания Thinstuff также предоставляет такую возможность, чем мы и
воспользуемся. Заодно скажу, что для Windows-версии существует 14-дневная
триальная версия с полноценными возможностями, а для Linux — версия без
ограничений по времени, но зато с ограничением количества подключений и
сессий. Оба варианта доступны на следующей странице: [http://www.thinstuff.com/downloads-support/downloads/](http://www.thinstuff.com/downloads-support/downloads/) . Подробней на возможностях оценочной Linux-версии я
остановлюсь чуть позже.

На этой же странице
([https://www.thinstuff.com/licensing/](https://www.thinstuff.com/licensing/))
можно посмотреть варианты предоставляемого продукта, а также стоимость
лицензий на его использование, которая зависит от количества подключений.

## Установка

Для начала необходимо получить дистрибутив LX Server.

Переходим в произвольную директорию по вашему выбору. У меня будет /tmp:

		cd /tmp
		wget [http://www.thinstuff.com/releases/lxserver-1.2.1-5366.sh](http://www.thinstuff.com/releases/lxserver-1.2.1-5366.sh)

Размер — примерно 60 мегабайт, поэтому потребуется какое-то время на
скачивание.

		--2009-03-16 16:37:59-- http://www.thinstuff.com/releases/lxserver-1.2.1-5366.sh
		Распознаётся www.thinstuff.com... 78.46.51.238
		Устанавливается соединение с www.thinstuff.com|78.46.51.238|:80... соединение установлено.
		Запрос HTTP послан, ожидается ответ... 200 OK
		Длина: 62484766 (60M) [application/x-binary]
		Сохраняется в каталог: `lxserver-1.2.1-5366.sh'.
		100%[===============================================>] 62 484 766 115K/s в 7m 52s
		2009-03-16 16:45:50 (129 KB/s) - `lxserver-1.2.1-5366.sh' сохранён [62484766/62484766]

Для установки необходимо получить права пользователя root. Установка под
другим пользователем не поддерживается. Запускаем скрипт установщика:

		[root@off2 tmp]# bash lxserver-1.2.1-5366.sh
		checking archive integrity ...
		Thinstuff LX Server
		(c) Thinstuff s.r.o.
		http://www.thinstuff.com
		Welcome to the setup routine for the Thinstuff LX Server.
		This setup will install the RDP server on your computer in
		the directory /opt/thinstuff/rdpserver. The installation
		will take about 132 MB of harddisk space.
		For more information on non-interactive execution of this
		installer please use:
		lxserver-1.2.1-5366.sh --help
		Please press <enter> to continue

Здесь требуется нажать Enter для продолжения.

		detecting old installations ...
		Please choose one of the following actions:
		[I]nstall: This installs 1.2.1, build 5366.
		[E]xit: Exit installer without changing anything.
		Please enter choice (E/I):

В данном случае, поскольку я уже ставил этот продукт, то установщик обнаружил
ее. В данном случае нас интересует новая установка, поэтому выбираем I:

		Please enter choice (E/I): i
		Ready to begin installation. Please press <enter> to continue.

Установщик по любому поводу задаются вопросы ))) Что-то мне это напоминает, но
сейчас не об этом. Продолжим, нажав Enter.

		BY ANSWERING "Y" TO THE PROMPT AT THE END OF THIS TEXT, YOU ARE CONSENTING
		TO BE BOUND BY THIS AGREEMENT. IF YOU DO NOT AGREE TO ALL OF THE TERMS OF
		THIS AGREEMENT, ANSWER "N" TO THE PROMPT AT THE END OF THIS TEXT TO
		DISCONTINUE THE INSTALLATION. PLEASE PROMPTLY RETURN THE SOFTWARE PACKAGE
		TO Thinstuff s.r.o.
		THE FOLLOWING LICENSE GOVERNS YOUR RIGHTS TO THE THINSTUFF LX SERVER(tm)
		SOFTWARE. YOU ARE NOT GRANTED ANY RIGHTS IN ANY SOFTWARE INCLUDED IN THIS
		SOFTWARE DISTRIBUTION THAT YOU HAVE NOT LICENSED AND FOR WHICH YOU HAVE NOT
		PAID THE APPROPRIATE LICENSE FEES TO Thinstuff s.r.o.

		1. License. The enclosed computer software and documentation ("Software")
		is not being sold and purchased, but is being licensed to you by
		Thinstuff s.r.o. ("Thinstuff") under a personal, nonexclusive,
		nontransferable and paid-up license for use only under the following
		terms, and Thinstuff reserves any rights not expressly granted to you
		herein. Under the terms of this license you own the media on which the
		Software is recorded, but Thinstuff retains all of the rights of
		ownership to the Software and all copies of the Software. This license
		shall be governed by the laws of the Republic of Austria.

		2. Under this license you may:
		a.) Make copies of the Software solely for backup or archival purposes.
		b.) Make simultaneous use of the Software on a number of computers up
		to the number of licenses you purchased for the software.
		c.) Transfer your rights under this license for the Software, provided
		that you give Thinstuff prior written notice of such transfer and
		--Далее--

Предлагается прочитать лицензию на использование. И принять ее:

		Do you accept the license (yes/no) ? Yes

Далее будет предложено отправить производителю анонимную информацию о
платформе, на которой будет использоваться данный продукт. Эта информация
включает в себя тип процессора, версию ядра и другие подобные данные,
собранные во время установки. Это опционально, можно отказаться, потому нажмем
No.

		We would like to collect anonymous information about
		the platforms where this product is installed. These
		informations would include CPU type, Kernel version
		and similar data and would be collected only once
		during this setup.
		This step is OPTIONAL. If you do not want to send any
		information, just answer no to the next question. If
		you agree, then the information that is about to be
		sent will be displayed before it is actually trans-
		mitted.
		Would you like to send anonymous system information (yes/no) ? No

И далее следует подготовка и извлечение из архива:

		preparing Archive ...
		extracting Archive ...
		WARNING: enabling "trust" authentication for local connections
		You can change this by editing pg_hba.conf or using the -A option the
		next time you run initdb.

		* CORBA already running -> skipping
		* Starting PostgreSQL: .Done
		* lighttpd is already running -> skipping

		Finished starting system services...
		FINISHED installing database
		starting server ...

		* Starting Configuration Server: .Done
		* Proxy Service is already running -> skipping
		* Application Launcher is already running -> skipping
		* Waiting for RDP server to complete startup:

		Finished starting terminalserver services - accepting connections to the
		terminalserver
		Configuring default session program. Please choose one of the following
		options:
		[G]nome
		[T]wm: Built-in simple windowmanager (default).
		Please enter choice (G/T):

Здесь немного остановимся. В комплекте с rdpserver поставляется база данных
PostgreSQL и веб-сервер lighttd. При установке проверяется установка этих
компонентов и проверка их работоспособности. На некоторых дистрибутивах Linux
у меня были проблемы именно на этом шаге. База данных и веб-сервер
устанавливались, но установщик не мог подключиться к ним для проверки. При
этом lighttpd не мог обнаружить свой файл конфигурации. Это имело место при
установке на openSUSE 11.1 и SLED 11 RC1. Может быть, это просто случайность,
может еще что-то. Успешная установка была проведена на Fedora 10 и SLES 10
SP2.

Итак, при установке можно выбрать, какой оконный менеджер будет запускаться
при входе в систему. В данном случае, поскольку я использую Gnome, то он в
пунктах выбора и присутствует. А вот Twm поставляется вместе с LX Server и,
если на вашем сервере не ставилась X Window Sustem, то есть возможность
использовать именно Twm. Я выбираю Gnome:

		Please enter choice (G/T): G
		Password (for user root):

Требуется ввести пароль пользователя root. А также потом ответить на вопрос,
установить ли скрипт запуска и запускать ли сервис во время старта системы:

		Do you want to install the init.d script and start the service on system start
		(yes/no) ? Yes
		INSTALLATION COMPLETE
		Please copy your license to "/opt/thinstuff/rdpserver/licenses"
		Default configuration: you can connect to this host with your RDP
		client. For server management please connect to this host
		using the https protocol (e.g. https://localhost). By default
		only the user root has access to the management interface.
		Please see the documentation at "/opt/thinstuff/rdpserver/doc"
		for further setup and configuration instructions.

На этом процесс установки заканчивается. Для управления сервером необходимо в
браузере открыть адрес [https://localhost](https://localhost/), если
устанавливали на локальную машину, а также можно использовать ip-адрес или имя
компьютера, при удаленной установке. В данной статье ставилось все на
локальном, потому его ip-адрес использовать и будем.

### Кратко о получившемся

LX Server устанавливается только в директорию /opt/thinstuff/rdpserver.
Установка в другую директорию не поддерживается. Это позволяет гарантировать,
что будет установлена только одна копию сервера. LX Server содержит все
библиотеки, необходимые для успешного запуска, в своей директории, что
позволяет обойтись без необходимости установки каки-либо дополнительных
приложений.

## Настройка и Администрирование

Поскольку при установке сервера мы решили сразу его и запустить, то он уже
работает. Но все же хотелось бы как-то управлять им и в дальнейшем. Для этого
предоставляется скрипт для Thinstuff LX Server, находящийся в файле
/opt/thinstuff/rdpserver/scripts/rdp-server.init.d-template, который
необходимо установить. Дальнейшие шаги будут немного отличаться для различных
дистрибутивов, но для основных достаточно будет проделать следующее:

		cp /opt/thinstuff/rdpserver/scripts/rdp- server.init.d-template \
		/etc/init.d/rdp-server

		/usr/lib/lsb/install_initd /etc/init.d/rdp-server

Также, для дальнейшей работы представляют интерес следующие скрипты и
директории:

  * /opt/thinstuff/rdpserver/scripts/startall.sh Запустить сервер.
  * /opt/thinstuff/rdpserver/scripts/stopall.sh Остановить сервер.
  * /opt/thinstuff/rdpserver/scripts/init.sh Перезапустить сервер, действует так же, как остановка и последующий запуск.
  * /opt/thinstuff/rdpserver/licenses/ В этой директории содержатся все текущие лицензии. Лицензии должно храниться только в этом месте; установить лицензию можно простым копированием или перемещением в это место. И для установки или удаления лицензии не требуется перезапускать сервер.

LX Server администрируется и настраивается через веб-интерфейс. Итак,
попробуем:

[![](/images/2009/03/16/enter_lx.png)]

Для входа необходимо ввести следующие данные:

Login — root
Password - <пароль пользователя root>

### Интерфейс

Интерфейс состоит из четырех частей.

  * **Server Status**Позволяет быстро определить существующие проблемы.
  * **Sessions**Показывает, какие пользователи используют сервисы, и позволяет управлять ими.
  * **Rights**Позволяет настроить права доступа к веб-интерфейсу.
  * **Settings**Здесь можно настроить параметры для терминального сервера и сессий.

Предлагаю пройтись слегка по выше перечисленным пунктам и посмотреть, что они
из себя представляют.

**Server Status**

**Server Health**

[![](/images/2009/03/16/lx_server_health.png)]

В этом разделе можно получить общее представление о статусе терминального
сервера. Для лучшего понимания статус подсвечивается, при возникновении
проблем будет показано статусное сообщение.

Существует четыре различных уровня статуса:

  * **Running (зеленый)** — Все работает без проблем.

  * **Warning** **(желтый) **— Сервер работает, но один или несколько компонентов испытывают сложности. Это позволяет отслеживать состояние сервера и определить временная ли это проблема или необходимо модернизировать сервер. Пробемы включают:

    * Центральный процессор, память или другие ресурсы достигли критической точки.

    * Один или несколько компонентов, но не все, сообщают об ошибках во время операций.

  * **Critical (красный)** — Проблемы, подобные описанным в Warning, но они касаются всехрезервных и нерезервных компонентов.

  * **Error (красный)** — Один или несколько компонентов не работоспособны и сервер больше не дееспособен. Необходимо перезапустить терминальный сервер.

**License Info**

Во втором разделе секции отображается информация о ваших текущих лицензиях.
Статус лицензий обозначается также цветами, значение которых мы вкратце и
опишем:

  * **Valid (зеленый)** — Лицензия на данный момент действительна.

  * **Grace (желтый)** — Лицензия существует, но срок действия ее истечет в скором времени.

  * **Invalid (красный)** — Может иметь несколько причин (неверный hardware id , неверный файл лицензии...)

[![](/images/2009/03/16/lx_license.png)]

**Sessions**

[![](/images/2009/03/16/lx_sessions.png)]

В этой секции отображается список всех активных сессий и подключений к
терминальному серверу. На данный момент у меня подключений нет, как видите.
Каждая сессия может иметь ни одного, одно или больше подключений.

**Rights**

**Пользователи**

[![](/images/2009/03/16/lx_rights.png)]

Вебсайт и терминальный сервер используют системных пользователей и их
паролями. От себя могу сказать, что при тестовой установке на SLES 10, учетные
записи пользователей на котором хранятся в LDAP, все эти учетные записи были
совершенно прозрачно определены, мне не пришлось вводить какие-либо данные для
подключения к серверу каталогов. Список пользователей синхронизируется с
системным каждые несколько секунд, потому при добавлении нового пользователя
он сможет в скором времени приступить к работе.

Здесь же можно установить права для конкретного пользователя.

[![](/images/2009/03/16/lx_user_rights.png)]

**Группы**

[![](/images/2009/03/16/lx_groups.png)]

Список групп подобен списку пользователей. Он также синхронизируется с
системным списком групп каждые несколько секунд. Также можно изменить права
для конкретной группы, кликнув на Rights.

**Settings**

Эта секция позволяет настроить различные аспекты поведения LX Server: от
интервала портов до различной оптимизации ЦП и пропускной способности.
Существует два вида настроек:

  * **Global Settings**

Действуют глобально на весь сервер. Включают в себя в том числе и номер порта,
который будет слушать сервер RDP.

  * **Profile Settings**

Они действуют только на конкретную сессию или подключение. Каждая сессия или
подключение работает под конкретным профилем, и различные профили могут разные
значения для этих настроек.

Количество настроек, которые будут отображаться, зависит от уровня просмотра,
котрых существует три:

  * Level 0 (Standard) — Содержит только часто используемые настройки.
  * Level 1 (Advanced) — Содержит настройки, присутствующие в Level 0 и дополнительные настройки, контролирующие поведение сервера.
  * Level 2 (Expert) — Содержит все настройки.

[![](/images/2009/03/16/lx_global_set.png)]

**Global Settings**

Это настройки, необходимые серверы во время запуска.

**Profiles**

Часто бывает необходимо указать настройки для конкретного пользователя,
подключенного к серверу, в зависимости от того оборудования, которое этот
пользователь имеет. Для обеспечения этой возможности у терминального сервера
существует концепция профилей. Каждый профиль хранит набор значений настроек,
и когда пользователь подключается к серверу, этот профиль выбирается.
Количество необходимых профилей зависит от конкретного случая, но, в основном,
создается один профиль для каждой группы пользователей, которым необходимы
различные настройки.

**Settings**

[![](/images/2009/03/16/lx_settings.png)]

Используя Мастер Настроек наиболее общие установки легким способом.

**Advanced Settings**

В этой секции вы можете как изменить настройки профиля, так и управлять этими
профилями.

[![](/images/2009/03/16/lx_advsettings.png)]

Поскольку я не вижу смысла в данном документе описывать все подробности всех
вариантов настроек, тем более что они могут сильно зависить от конкретных
требований, то ограничиваюсь кратким описанием. На сайте Thinstuff выложена
достаточно подробная и понятная документация. Она, правда, на английском
языке, но особых сложностей в тексте нет, потому вполне понятна. Ссылки на
документацию смотрите в конце этого руководства.

## Подключение

Теперь, когда практически все готово, можно попробовать подключиться к
серверу. В Linux-клиенте будем использовать для этого Gnome-RDP, в Windows —
встроенный клиент RDP. В целом, могу сказать, что в подключении сложности нет
никакой, при условии, что все предыдущие шаги проделаны верно. И есть еще один
момент, на машине, на которую устанавливали RDP-сервер, не забудьте открыть
порты 3389 tcp и 3389 udp.

Итак:

[![](/images/2009/03/16/gnome-RDP.png)]

Для начала подключимся к тестовому серверу на этой же машине.

[![](/images/2009/03/16/gnome-rdp-session.png)]

[![](/images/2009/03/16/gnome-rdp-rdp.png)]

На двух верхним рисунках показаны мои настройки. В принципе, они практически
дефолтные.

[![](/images/2009/03/16/rdesktop%20-%20192.168.1.7.png)]

В открывшемся окне вводим имя пользователя и пароль и...

[![](/images/2009/03/16/screenshot-desktop.png)]

Получаем Рабочий стол на Рабочем столе.

[![](/images/2009/03/16/Screenshot.png)]

А тут Opera запущенная на «удаленном Рабочем Столе».

Стоит заменить, что можно входить и под пользователем, вход которого уже
выполнен. Работа проходит фактически параллельно. Правда, если попытаться
запустить Firefox, который уже был запущен при основном входе, то получится
вот что:

[![](/images/2009/03/16/Screenshot-Close%20Firefox.png)]

## Заключение

Честно говоря, опыт использования LX Server у меня не большой. Да и, по
большому счету, этот опыт сводится к тестовому использованию его в пределах
локальной сети на работе. Поскольку я ставил RDP-сервер на арендованный сервер
в дата-центре, то была возможность попробовать поработать через сеть Интернет.
С достаточно нормальным подключением, а на работе канал 2 мегабита, работать
можно нормально. Если местами и подтормаживает, то не сильно и не критично. Но
при выходе в Интернет через телефон с подключением к оператору «Скайлинк» в
зоне 1х (если кто не в курсе, скорость до 153 килобит), работа с удаленным
сервером не комфортна совершенно. Отображение раочего стола тормозит очень
заметно. Правда, я не искал и не пытался настроить сам сервер, возможно и есть
варианты, но подсказать на данный момент не могу ничего конкретного.

Мой вердикт будет таковым: достаточно хороший вариант для локальной сети,
допустим для сервера 1С. Тем более, что сейчас 1С можно использовать
установленным на Linux и в версии терминального сервера от Thinstuff для ОС
Linux нет ограничения работоспособности по времени, только по клиентам. В
Windows-версии, напомню, ограничение в 14 дней. Хотя и в том, и в другом
варианте лицензионным соглашением запрещено использование тестовой версии на
производстве.

Использование же подключения к действительно удаленному серверу возможно
исключительно при достаточно адекватной скорости подключения к сети Интернет,
в любом другом случае возможны проблемы.

-----------------------------------------------------------------------------
type: post

При написание статьи использовалось:

  1. [Дистрибутив Thinstuff LX Server](http://www.thinstuff.com/releases/lxserver-1.2.1-5366.sh)
  2. [LX Server Manual](http://www.thinstuff.com/releases/lx_server_manual-5366.pdf)



