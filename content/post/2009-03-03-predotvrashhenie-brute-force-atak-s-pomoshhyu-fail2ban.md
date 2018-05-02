---
type: post
tags:
- security
- fail2ban
comments: false
date: 2009-03-03T00:00:00Z
title: Предотвращение Brute Force атак с помощью fail2ban
Slug: предотвращение-brute-force-атак-с-помощью-fail2ban
url: /2009/03/predotvrashhenie-brute-force-atak-s-pomoshhyu-fail2ban
---

Оригинал лежит на
[Howtoforge](http://www.howtoforge.com/fail2ban_opensuse10.3).

В этой статье я покажу, как установить и настроить **fail2ban** на системе
openSUSE 10.3. **Fail2ban** - это инструмент, который отслеживает попытки
залогиниться к раз личным сервисам, таким, как SSH, FTP, SMTP, Apache и
другим, и если он находит постоянно повторяющиеся неудачные попытки с одного и
того же IP-адреса или хоста, **fail2ban** остановит дальнейшие попытки
залогиниться с этого IP-адреса/хоста, блокируя их с помощью правила iptables.

Этот документ не дает никаких гарантий! Я хочу сказать, что это не
единственный способ установки такой системы. Есть много других способов
достигнуть этой цели, но это путь, который выбрал я. Я не даю никакой
гарантии, что это будет у вас работать!

**Предварительное примечание**

**Fail2ban** подобен **DenyHosts**, который я описывал в этом руководстве: http://www.howtoforge.com/preventing_ssh_dictionary_attacks_with_denyhosts, но в отличие от **DenyHosts**, который фокусируется на SSH,** fail2ban** может контролировать любой сервис, который записывает попытки входа, и, вместо использования /etc/hosts.deny для блокировки IP-адреса хоста, **fail2ban** может использовать iptables и /etc/hosts.deny.

В этом примере, я настрою **fail2ban** для мониторинга попыток залогиниться к
серверу SSH, серверу ProFTPD, .htaccess/.htpasswd, защищающим веб-сайт,
Courier POP3 и Courier IMAP, и SASL (для отправленных писем). Я установлю
пакет** fail2ban**, который доступен в openSUSE 10.3. Он включает в себя
конфигурацию по умолчанию, но, к сожалению, эта конфигурация не всегда
работает для всех перечисленных сервисов.

**Установка fail2ban**

**Fail2ban** доступен в репозитории Packman:

		yast2

В YaST идите _Software > Community Repositories_

[![](/images/2009/03/03/11.png)](/images/2009/03/03/11.png)

Затем отметьте _Packman Repository_ и выберите _[Finish]_

[![](/images/2009/03/03/12.png)](/images/2009/03/03/12.png)

Затем покиньте YaST

[![](/images/2009/03/03/13.png)](/images/2009/03/03/13.png)

Далее можно установить **fail2ban**:

		# yast2 -i fail2ban

Затем мы должны создать ссылки для запуска и запустить его:

		# chkconfig –add fail2ban
		# /etc/init.d/fail2ban start

Вы найдете все конфигурационные файлы **fial2ban** в директории /etc/fail2ban.

**Конфигурирование fail2ban**

Стандартное поведение **fail2ban** настроивается в файле
/etc/fail2ban/jail.conf. Взгляните на него, он не сложен для понимания. Там
имеется секция [Defaults], которая применяется ко всем другим секциям, если
только опции по умолчанию не перезаписаны в других секциях.

Здесь я объясню некоторые опции конфигурации:

  * **ignoreip** - это разделенный пробелами список ip-адресов, которые не могут быть блокированы **fail2ban**. Например, если компьютер, с которого вы подключаетесь к серверу, имеет статический IP-адрес, вы, возможно, захотите поместить его здесь.
  * **bantime** - время в секунда, на которое блокируется хост, если он был пойман **fail2ban** (600 секунд = 10 минут).
  * **maxretry** - Максимальное число неудавшихся попыток логина, прежде чем хост будет заблокирован **fail2ban**.
  * **filter** - Ссылается на соответствующий файл фильтра в /etc/fail2ban/filter.d.
  * **action** - Ссылается на соответствующий файл действия в /etc/fail2ban/action.d.
  * **logpath** - Файл логов, который **fail2ban** проверяет для неудавшихся попыток логина.

Это то, как выглядит мой файл /etc/fail2ban/jail.conf:

		# Fail2Ban configuration file
		#
		# Author: Cyril Jaquier
		#
		# $Revision: 611 $
		#
		# The DEFAULT allows a global definition of the options. They can be override
		# in each jail afterwards.

		[DEFAULT]

		# "ignoreip" can be an IP address, a CIDR mask or a DNS host. Fail2ban will not
		# ban a host which matches an address in this list. Several addresses
		can be
		# defined using space separator.
		ignoreip = 127.0.0.1 192.168.0.99

		# "bantime" is the number of seconds that a host is banned.
		bantime  = 600

		# A host is banned if it has generated "maxretry" during the last
		"findtime"

		# seconds.

		findtime  = 600

		# "maxretry" is the number of failures before a host get banned.
		maxretry = 3

		# "backend" specifies the backend used to get files modification.
		Available

		# options are "gamin", "polling" and "auto". This option can be
		overridden in

		# each jail too (use "gamin" for a jail and "polling" for another).
		#
		# gamin:   requires Gamin (a file alteration monitor) to be installed.
		If Gamin

		#          is not installed, Fail2ban will use polling.
		# polling: uses a polling algorithm which does not require external
		libraries.

		# auto:    will choose Gamin if available and polling otherwise.

		backend = auto

		# This jail corresponds to the standard configuration in Fail2ban 0.6.
		# The mail-whois action send a notification e-mail with a whois request
		# in the body.

		[ssh-iptables]

		enabled  = true
		filter   = sshd
		action   = iptables[name=SSH, port=ssh, protocol=tcp]
			sendmail-whois[name=SSH, dest=you@mail.com,
			sender=fail2ban@mail.com]
		logpath  = /var/log/messages
		maxretry = 5

		[proftpd-iptables]
		enabled  = true
		filter   = proftpd
		action   = iptables[name=ProFTPD, port=ftp, protocol=tcp]
			   sendmail-whois[name=ProFTPD, dest=you@mail.com]
		logpath  = /var/log/messages
		maxretry = 6

		# This jail forces the backend to "polling".

		[sasl-iptables]
		enabled  = true
		filter   = sasl
		backend  = polling
		action   = iptables[name=sasl, port=smtp, protocol=tcp]
			   sendmail-whois[name=sasl, dest=you@mail.com]
		logpath  = /var/log/mail

		# Here we use TCP-Wrappers instead of Netfilter/Iptables. "ignoreregex"
		is
		# used to avoid banning the user "myuser".

		[ssh-tcpwrapper]
		enabled     = false
		filter      = sshd
		action      = hostsdeny
			      sendmail-whois[name=SSH, dest=you@mail.com]

		ignoreregex = for myuser from
		logpath     = /var/log/messages


		# This jail demonstrates the use of wildcards in "logpath".
		# Moreover, it is possible to give other files on a new line.

		[apache-tcpwrapper]

		enabled  = true
		filter   = apache-auth
		action   = hostsdeny
		logpath  = /var/log/apache2/error_log
		maxretry = 6

		# The hosts.deny path can be defined with the "file" argument if it is
		# not in /etc.

		[postfix-tcpwrapper]

		enabled  = true
		filter   = postfix
		action   = hostsdeny
			   sendmail[name=Postfix, dest=you@mail.com]
		logpath  = /var/log/mail
		bantime  = 300

		# Do not ban anybody. Just report information about the remote host.
		# A notification is sent at most every 600 seconds (bantime).

		[vsftpd-notification]

		enabled  = false
		filter   = vsftpd
		action   = sendmail-whois[name=VSFTPD, dest=you@mail.com]
		logpath  = /var/log/messages
		maxretry = 5
		bantime  = 1800

		# Same as above but with banning the IP address.

		[vsftpd-iptables]

		enabled  = false
		filter   = vsftpd
		action   = iptables[name=VSFTPD, port=ftp, protocol=tcp]
			   sendmail-whois[name=VSFTPD, dest=you@mail.com]
		logpath  = /var/log/messages
		maxretry = 5
		bantime  = 1800

		# Ban hosts which agent identifies spammer robots crawling the web
		# for email addresses. The mail outputs are buffered.

		[apache-badbots]

		enabled  = true
		filter   = apache-badbots
		action   = iptables-multiport[name=BadBots, port="http,https"]
			    sendmail-buffered[name=BadBots, lines=5, dest=you@mail.com]
		logpath  = /var/log/apache2/access_log
		bantime  = 172800
		maxretry = 1

		[courierpop3]

		enabled  = true
		port     = pop3
		filter   = courierlogin
		action   = iptables[name=%(__name__)s, port=%(port)s]
		logpath  = /var/log/mail
		maxretry = 5

		[courierimap]

		enabled  = true
		port     = imap2
		filter   = courierlogin
		action   = iptables[name=%(__name__)s, port=%(port)s]
		logpath  = /var/log/mail
		maxretry = 5

Мой клиентский компьютер имеет статический IP-адрес 192.168.0.99, и поскольку
я не хочу быть заблокированным, я внес его в список **ignoreip**.

Я хочу контролировать попытки логина к SSH, Apache, Proftpd, Courier-POP3,
Courier-IMAP и Sasl, поэтому я установил значение “true” для этих сервисов и
отключил с помощью “false” для всех остальных. Заметьте, что некоторые
сервисы, например, SSH, могут блокироваться или iptables, или **TCPWrappers**
(/etc/host.deny). Решите для себя, какой метод для вас предпочтительнее.

Убедитесь, что заменили адрес электронной почты _you@mail.com_ на свой
собственный адрес для получения уведомлений, когда **fail2ban** что-нибудь
заблокирует.

Если вы сравните этот файл с файлом конфигурации по умолчанию
/etc/fail2ban/jail.conf, вы заметите также, что я поменял несколько файлов
логов, потому что log-файлы в стандартной комплектации не подходят для
openSUSE 10.3.

Каждый раз, как мы меняем файл конфигурации, мы должен рестартануть
**fail2ban**, что мы сейчас и сделаем:

		/etc/init.d/fail2ban restart

Все готово. **Fail2ban** записывает логи в /var/log/fail2ban.log, так что вы
можете проверить этот файл для выяснения почему/какие хосты были блокированы.
Если хост заблокирован **fail2ban**, это выглядит примерно так:

		2007-10-07 17:49:09,466 fail2ban.actions: WARNING [apache-tcpwrapper] Ban 1.2.3.4
		2007-10-07 18:08:33,213 fail2ban.actions: WARNING [sasl-iptables] Ban 1.2.3.4
		2007-10-07 18:26:37,769 fail2ban.actions: WARNING [courierlogin] Ban 1.2.3.4
		2007-10-07 18:39:06,765 fail2ban.actions: WARNING [courierimap] Ban 1.2.3.4

Вы также можете проверить свой файерволл, чтобы посмотреть, заблокированы ли
какие-либо хосты. Для этого просто запустите:

		# iptables -L

Про сервисы, которые используют **TCPWrapper** для блокировки хостов, смотрите
/etc/hosts.deny.

**Ссылки:**

  * **Fail2ban**: http://www.fail2ban.org/
  * **openSUSE**: http://www.opensuse.org/

