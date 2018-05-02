---
type: post
tags:
- lsof
- netstat
date: 2009-03-03T00:00:00Z
title: lsof and netstat
Slug: lsof-and-netstat
url: /2009/03/lsof-netstat
---

Очередной перевод очередной заметки с [Cool Solutions](http://www.novell.com/coolsolutions/feature/19999.html)

### Поиск открытых файлов и сетевых соединений

Одной из многих выгод использования операционной системы Linux является то, что есть возможность получить обширую информацию о процессах, работающих в данный момент, и ресурсах, которые они потребляют. Эта статья описывает две очень полезные команды: `lsof` и `netstat`, которые покажут вам список всех открытых файлов или сетевых соединений на системе наряду с соответствующими им процессами.

Их еще одно очевидное преимущество — безопасность. Например, если бы spyware или какая-либо другая malware-программа отправляли бы информацию с вашего компьютера в Интернет или в файл на вашем жестком диске, это можно было увидеть в выводе этих команд.

#### lsof — список открытых файлов

Эта простая команда часто запускается без аргументов и делает только то, что ей сказано: отображать список из каждых открытых файлов каждой программы, запущенной в данной момент.

Обычно вывод lsof выглядит так:

	$ lsof
	COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME
	init 1 root cwd unknown /proc/1/cwd
	init 1 root rtd unknown /proc/1/root
	init 1 root txt unknown /proc/1/exe
	init 1 root mem REG 8,22 509596 60081 /sbin/init
	init 1 root mem REG 0,0 0 [heap]
	init 1 root NOFD /proc/1/fd
	kthreadd 2 root cwd unknown /proc/2/cwd
	kthreadd 2 root rtd unknown /proc/2/root
	kthreadd 2 root txt unknown /proc/2/exe
	...

Обычно `lsof` выводит слишком много информации, чтобы она могла поместиться в буфер прокрутки консоли. Таким образом у вас может возникнуть желание сбросить эту информацию на диск (через `lsof > lsof-output.txt`) или отфильтровать ее, используя различные pipe-команды.

Например, если хотите увидеть, открыт ли специальный файл `/dev/dsp` (звуковая карта) каким-нибудь процессом, запустите следующую команду:

	$ lsof|grep dsp
	game 3835 kain mem CHR 195,0 13940 /dev/dsp

Теперь мы можем убить процесс, если хотим освободить звуковую карту:

	$ kill -9 3835
	$ killall -9 game # это также сработает

В дополнение к списку открытых файлов `lsof` может также оторбражать открытые сокеты (сетевые соединения), если вы запустите его в ключом `-i`:

	$ lsof -i
	COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME
	kded 4140 kain 15u IPv4 15400 TCP localhost:37435 (LISTEN)
	kded 4140 kain 19u IPv6 15483 TCP *:5800 (LISTEN)
	kded 4140 kain 20u IPv6 15488 TCP *:5900 (LISTEN)
	pidgin 4530 kain 14u IPv4 17075 TCP 192.168.1.104:54623-&gt;205.188.9.158:aol (ESTABLISHED)
	pidgin 4530 kain 15u IPv4 17072 TCP 192.168.1.104:56693-&gt;205.188.5.214:aol (ESTABLISHED)
	pidgin 4530 kain 16u IPv4 49002 TCP 192.168.1.104:37275-&gt;64.12.30.80:aol (ESTABLISHED)
	pidgin 4530 kain 17u IPv4 17092 TCP 192.168.1.104:57145-&gt;oam-d09b.blue.aol.com:aol (ESTABLISHED)
	pidgin 4530 kain 18u IPv4 50809 TCP 192.168.1.104:42839-&gt;64.12.30.92:aol (ESTABLISHED)
	pidgin 4530 kain 23u IPv4 17107 TCP 192.168.1.104:43997-&gt;oam-d23c.blue.aol.com:aol (ESTABLISHED)
	firefox-b 9464 kain 10u IPv4 55549 TCP 192.168.1.104:37274-&gt;mu-in-f91.google.com:http (ESTABLISHED)
	firefox-b 9464 kain 44u IPv4 54630 TCP 192.168.1.104:43427-&gt;132.235.194.70:http (ESTABLISHED)
	firefox-b 9464 kain 45u IPv4 54631 TCP 192.168.1.104:43428-&gt;132.235.194.70:http (ESTABLISHED)
	firefox-b 9464 kain 46u IPv4 54635 TCP 192.168.1.104:49242-&gt;132.235.194.69:http

Можно заметить, что когда я запустил эту команду, у меня уже были запущены pidgin и firefox. В колонке содержится адрес соединения, его номер порта или имя сервиса, и действительно ли сокет `LISTEN` или `ESTABLISHED`. Прослушиваемые сокеты соответствуют процессам сервера, запущенным на вашей машине, которые ожидают соединений от других частей. Любые подозрительные слушающие процессы должны быть проверены на предметбезопасности. Если номер порта будет в списке известных сервисов на системе, то он отображается как именованный сервис (например, http или aol в листинге выше). Вы можете поискать файл `/etc/services`, чтобы узнать, что это такое:

	$ cat /etc/services|grep aol
	aol 5190/tcp # America-Online

Чтобы быть уверенным, что вы получаете полный вывод lsof, вы должны быть пользователем root.

#### netstat — инструмент сетевой статистики

В то время, как `lsof -i` удобный способ отображения списка сетевых соединений, netstat обеспечивает альтернативный и более подробный способ получаения информации о вашей сети.

Вывод netstat обычно более длинный, чем `lsof -i`:

	$ netstat
	Active Internet connections (w/o servers)
	Proto Recv-Q Send-Q Local Address Foreign Address State
	tcp 0 0 192.168.1.104:56693 205.188.5.214:aol ESTABLISHED
	tcp 0 0 192.168.1.104:55219 64.12.30.80:aol ESTABLISHED
	tcp 0 0 192.168.1.104:43997 oam-d23c.blue.aol.c:aol ESTABLISHED
	tcp 0 0 192.168.1.104:54623 205.188.9.158:aol ESTABLISHED
	tcp 0 0 192.168.1.104:57145 oam-d09b.blue.aol.c:aol ESTABLISHED
	tcp 0 0 192.168.1.104:44775 64.12.30.92:aol ESTABLISHED
	Active UNIX domain sockets (w/o servers)
	Proto RefCnt Flags Type State I-Node Path
	unix 2 [ ] DGRAM 15294 /var/run/NetworkManager/wpa_ctrl_3020-1
	unix 2 [ ] DGRAM 15215 /var/run/wpa_supplicant-global
	unix 3 [ ] DGRAM 15292 /var/run/wpa_supplicant/eth1
	unix 2 [ ] DGRAM 3300 @/org/kernel/udev/udevd
	unix 2 [ ] DGRAM 8419 /var/lib/dhcp/dev/log
	...

Заметьте, что netstat указывает также локальный адрес для каждого соединения, а также размер отправленной и полученной очереди, что помогает контролировать активность каждого соединения. В дополнение к этому, она отображает соединения, созданные поверх сокетов Unix, другой механизм для соединений между процессами в Linux.

Вывод netstat можно сделать подобным выводу lsof, добавив `-A inet` и `–program`, которые указывают netstat печатать только нелокальные соединения, включая процессы, чьей собственностью они являются:

	# netstat -A inet --program
	Active Internet connections (w/o servers)
	Proto Recv-Q Send-Q Local Address Foreign Address State PID/Program name
	tcp 0 0 192.168.1.104:56693 205.188.5.214:aol ESTABLISHED 4530/pidgin
	tcp 0 0 192.168.1.104:55219 64.12.30.80:aol ESTABLISHED 4530/pidgin
	tcp 0 0 192.168.1.104:43997 oam-d23c.blue.aol.c:aol ESTABLISHED 4530/pidgin
	tcp 0 0 192.168.1.104:54623 205.188.9.158:aol ESTABLISHED 4530/pidgin
	tcp 0 0 192.168.1.104:57145 oam-d09b.blue.aol.c:aol ESTABLISHED 4530/pidgin
	tcp 0 0 192.168.1.104:44775 64.12.30.92:aol ESTABLISHED 4530/pidgin

Вот и все, что можно сказать по этому поводу. Обе эти команды имеют гораздо больше возможностей, которые вы можете узнать, прочитав соответствующие man-страницы — `man lsof` и `man netstat`.
