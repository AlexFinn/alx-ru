---
type: post
tags:
- fdisk
- howto
comments: false
date: 2009-03-03T00:00:00Z
title: Создание разделов с помощью fdisk
Slug: создание-разделов-с-помощью-fdisk
url: /2009/03/sozdanie-razdelov-s-pomoshhyu-fdisk
---

Временами ко мне заходят люди с поисковиком с запросами по поводу `fdisk`. Где-то в статьях упоминается эта команда. Но толком ничего у меня про нее не было. А я помню, как в свое время мучался с ней. Поскольку писать свое собственное что-то мне очень часто посто лень, то я потихоньку перевожу интересные и полезные для меня статьи. Вот и сейчас сделал то же самое. Может, пригодится кому-то. Хотя, как всегда, статья далеко не целиком раскрывает тему, а потому чтение манов никто не отменяет.

Итак, очередной перевод. Оригинал, как всегда, на [Novell Cool Solutions](http://www.novell.com/coolsolutions/feature/19350.html). Читайте.

Создать разделы через интерфейс командной строки - просто и быстро, также учитывая знание ядра о модифицированной таблице разделов и наличия схемы разделов, позволяет получить нужный эффект без необходимости перезагрузки рабочей станции/сервера и без необходимости использовать утилиты для разделения.

Первым делом необходимо посмотреть, какие жесткие диски доступны, и какой жесткий диск необходимо разделить. Если на вашей машине установлено несколько жестких дисков, `fdisk` сообщит вам об этом. Два жестких диска показано в следующем листинге как `sda` и `sdb`.

Команда `fdisk` с оператором `-l` (`fdisk -l`) покажет вам текущие таблицы разделов
наряду с жесткими дисками, подключенными к вашей рабочей станции или серверу:

	linux-1reo:~ # fdisk -l

	Disk /dev/sda: 80.0 GB, 80026361856 bytes 255 heads, 63 sectors/track, 9729 cylinders
	Units = cylinders of 16065 * 512 = 8225280 bytes

	Device Boot Start End Blocks Id System
	/dev/sda1 * 1 1402 11261533+ 7 HPFS/NTFS
	/dev/sda2 1403 1415 104422+ 83 Linux
	/dev/sda3 1416 1546 1052257+ 82 Linux swap / Solaris
	/dev/sda4 1547 9729 65729947+ 5 Extended
	/dev/sda5 1547 7920 51199123+ 8e Linux LVM

	Disk /dev/sdb: 80.0 GB, 80026361856 bytes
	255 heads, 63 sectors/track, 9729 cylinders
	Units = cylinders of 16065 * 512 = 8225280 bytes

	Device Boot Start End Blocks Id System
	/dev/sdb1 * 1 9729 78148161 8e Linux LVM

	Disk /dev/sdc: 500.1 GB, 500107862016 bytes
	255 heads, 63 sectors/track, 60801 cylinders
	Units = cylinders of 16065 * 512 = 8225280 bytes

Как только вы определили, какой жесткий диск вы хотите разделить, вы можете запустить команду fdisk, завершив ее нужным жестким диском (`fdisk /dev/sda`). В этой статье мы будем использовать первый жесткий диск - `sda`.

	linux-1reo:~ # fdisk /dev/sda
	The number of cylinders for this disk is set to 9729.
	There is nothing wrong with that, but this is larger than 1024,
	and could in certain setups cause problems with:
	1) software that runs at boot time (e.g., old versions of LILO)
	2) booting and partitioning software from other OSs
	(e.g., DOS FDISK, OS/2 FDISK)Command (m for help):

Как только `fdisk` будет запущен, ваше приглашение командной строки изменится на `Command (m for help):`, и вы будете готовы к проверке и разметке жесткого диска. Команды, которые поддерживает `fdisk`, можно просмотреть нажав клавишу `m`, а затем `Enter`. Команды, которые мы будем использовать:

  * `p` - для печати таблицы раздела
  * `n` - для создания нового раздела
  * `w` - для сохранения изменений и выхода

**Отображение текущей таблицы раздела**

Перед тем, как мы начнем делить жесткий диск, необходимо узнать какой объем дискового пространства нам доступен и как вообще выгдялит текущая таблица раздела. `p`, команда, которую мы будем использовать, выведет текущую таблицу
раздела:

	Command (m for help): p

	Disk /dev/sda: 80.0 GB, 80026361856 bytes
	255 heads, 63 sectors/track, 9729 cylinders
	Units = cylinders of 16065 * 512 = 8225280 bytes

	Device Boot Start End Blocks Id System
	/dev/sda1 * 1 1402 11261533+ 7 HPFS/NTFS
	/dev/sda2 1403 1415 104422+ 83 Linux
	/dev/sda3 1416 1546 1052257+ 82 Linux swap / Solaris
	/dev/sda4 1547 9729 65729947+ 5 Extended
	/dev/sda5 1547 7920 51199123+ 8e Linux LVM

Вывод, приведенный выше, показывает, что у нас доступно 1809 цилиндров (9729 - 7920 = 1809), и мы можем выполнить вычисление (1809 * 16065 * 512) = 14879531520байтов, что примерно равно 14 гигабайт.

**Создание нового раздела**

Следующий шаг - создание нашего нового раздела. Для примера, мы создадим раздел с типом `Linux` и размером 1 гигабайт. Мы используем команду `n` для создания нового раздела. Нас спросят, с какого цилиндра будет начинаться раздел (я советую оставить по умолчанию) и необходимый размер раздела:

	Command (m for help): n
	First cylinder (7921-9729, default 7921):
	Using default value 7921
	Last cylinder or +size or +sizeM or +sizeK (7921-9729, default 9729): +1024M

После того, как раздел будет создан, мы, используя команду `p`, можем отобразить на экране нашу новую таблицу раздела:

	Command (m for help): p

	Disk /dev/sda: 80.0 GB, 80026361856 bytes
	255 heads, 63 sectors/track, 9729 cylinders
	Units = cylinders of 16065 * 512 = 8225280 bytes

	Device Boot Start End Blocks Id System
	/dev/sda1 * 1 1402 11261533+ 7 HPFS/NTFS
	/dev/sda2 1403 1415 104422+ 83 Linux
	/dev/sda3 1416 1546 1052257+ 82 Linux swap / Solaris
	/dev/sda4 1547 9729 65729947+ 5 Extended
	/dev/sda5 1547 7920 51199123+ 8e Linux LVM
	/dev/sda6 7921 8045 1004031 83 Linux

**Запись нового раздела на диск**

Теперь, когда раздел был успешно создан, вы можете записать изменения на диск, нажав клавишу `w`, а затем `Enter`:

	Command (m for help): w
	The partition table has been altered!

	Calling ioctl() to re-read partition table.

	WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
	The kernel still uses the old table.
	The new table will be used at the next reboot.
	Syncing disks.

**Активирование вновь созданного раздела**

Как только новая таблица раздела записана на жесткий диск, ядро имеет возможность читать новую таблицу раздела без необходимости перезагрузки. Первый шаг - создание точки монтирования для нового раздела, в нашем примере мы будем использовать `/newpart`, а также использование команды `partprobe` для того, чтобы ядро имело возможность перечитать таблицу разделов:

	linux-1reo:~ # mkdir /newpart
	linux-1reo:~ # partprobe

Теперь, когда новая точка монтирования создана и ядро перечитало таблицу разделов, вы можете отформатировать раздел и разместить на нем файловую систему на ваш выбор (ext2, ext3, reiserfs и т.д.). В нашем примере, мы выбрали reiserfs:

	linux-1reo:~ # mkfs.reiserfs /dev/sda6
	mkfs.reiserfs 3.6.19 (2003 www.namesys.com)

	A pair of credits:
	The Defense Advanced Research Projects Agency (DARPA, www.darpa.mil) is the
	primary sponsor of Reiser4. DARPA does not endorse this project; it merely
	sponsors it.

	Alexander Lyamin keeps our hardware running, and was very generous to our
	project in many little ways.

	Guessing about desired format.. Kernel 2.6.16.21-0.8-default is running.
	Format 3.6 with standard journal
	Count of blocks on the device: 126496
	Number of blocks consumed by mkreiserfs formatting process: 8215
	Blocksize: 4096
	Hash function used to sort names: “r5″
	Journal Size 8193 blocks (first block 18)
	Journal Max transaction length 1024
	inode generation number: 0
	UUID: e20e2dc1-7277-4ab1-930c-038e54548540
	ATTENTION: YOU SHOULD REBOOT AFTER FDISK!
	ALL DATA WILL BE LOST ON ‘/dev/sda3′!
	Continue (y/n):y
	Initializing journal - 0%….20%….40%….60%….80%….100%
	Syncing..ok
	ReiserFS is successfully created on /dev/sda3.

Как только размер будет отформатирован, вы можете примонтировать и использовать ваш вновь созданный раздел:

	linux-1reo:~ # mount /dev/sda6 /partnew

**Заключение**

После монтирования созданного и отформатированного раздела вы можете хранить ваши файлы на этом разделе безо всяких пробле, вы можете также добавить ваш новый раздел в файл `/etc/fstab` для того, чтобы ваш раздел монтировался после
каждой перезагрузки.

**Протестировано на:**

  * SUSE Linux Enterprise Desktop 10
  * SUSE Linux Enterprise Server 10

