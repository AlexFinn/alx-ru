---
type: post
tags:
- CentOS
- Repository
- Yum
comments: false
date: 2012-09-15T00:00:00Z
published: true
title: Проблемы с зависимостями VLC в CentOS6
Slug: проблемы-с-зависимостями-vlc-в-centos6
url: /2012/09/15/vlc-dependencies-centos6/
---

Время от времени использую [RERemix][6] на своем ноутбуке. Как известно (или неизвестно кому-то, быть может) он (дистрибутив) основан на [Scientific Linux][7], который, в свою очередь, на [RHEL][8]. Отличается, в основном, доступными сразу после установки сторонними известными репозиториями, патчеными пакетами для нормального отображения шрифтов и другими вещами, полезными для своего рода LTS Desktop :)

Среди мультимедиа-проигрыватель существует достаточно популярный VLC. С установкой его проблем нет никаких, достаточно, чтобы был подключен нужный репозиторий, например, [RPMForge (Repoforge)][10]. Или же, как это сделано в RERemix, [PUIAS][9].
Однако при установке из этих репозиториев, после появления обновлений некоторых пакетов в EPEL, есть большая вероятность получить нечто, вроде этого:

    Error: Package: gstreamer-plugins-bad-0.10.19-3.el6.rf.i686 (@rpmforge)
               Requires: libmodplug.so.0
               Removing: libmodplug-0.8.7-1.el6.rf.i686 (@rpmforge)
                   libmodplug.so.0
               Updated By: 1:libmodplug-0.8.8.3-2.el6.i686 (epel)
                   Not found
    Error: Package: vlc-1.1.13-1.el6.rf.i686 (@rpmforge)
               Requires: libthreadutil.so.2
               Removing: libupnp-1.6.6-1.el6.rf.i686 (@rpmforge)
                   libthreadutil.so.2
               Updated By: libupnp-1.6.13-1.el6.i686 (epel)
                   Not found
    Error: Package: vlc-1.1.13-1.el6.rf.i686 (@rpmforge)
               Requires: libmatroska.so.2
               Removing: libmatroska-1.0.0-1.el6.rf.i686 (@rpmforge)
                   libmatroska.so.2
               Updated By: libmatroska-1.2.0-1.el6.i686 (epel)
                   Not found
    Error: Package: vlc-1.1.13-1.el6.rf.i686 (@rpmforge)
               Requires: libmodplug.so.0
               Removing: libmodplug-0.8.7-1.el6.rf.i686 (@rpmforge)
                   libmodplug.so.0
               Updated By: 1:libmodplug-0.8.8.3-2.el6.i686 (epel)
                   Not found
    Error: Package: vlc-1.1.13-1.el6.rf.i686 (@rpmforge)
               Requires: libupnp.so.3
               Removing: libupnp-1.6.6-1.el6.rf.i686 (@rpmforge)
                   libupnp.so.3
               Updated By: libupnp-1.6.13-1.el6.i686 (epel)
                   Not found
    Error: Package: vlc-1.1.13-1.el6.rf.i686 (@rpmforge)
               Requires: libebml.so.2
               Removing: libebml-1.0.0-1.el6.rf.i686 (@rpmforge)
                   libebml.so.2
               Updated By: libebml-1.2.1-1.el6.i686 (epel)
                   Not found

Проблемы с разрешением зависимостей налицо.

После некоторых размышлений я нашел два способа использовать VLC и постараться избежать подобного. Во-первых, можно попробовать поиграться с настройкой приоритетов репозиториев и запретом или разрешением установки определенных пакетов из оных. Но тут однажды можно было столкнуться с аналогичной проблемой, но с другими пакетами.

Второй вариант немного другой. Воспользовавшись ресурсом [pkgs.org][1] я нашел VLC еще и в репозитории RPMFusion, про который, такое ощущение, в последнее время как-то подзабыли, хотя и для этого есть некоторые причины. Например, пустой репозиторий [rpmfusion][2], и пакеты, находящиеся в [rpmfusion-updates][3]. Но это тема другого разговора.

Итак, если кратко, то предлагаю такой способ решения проблемы.

1. Удалить установленный VLC и все пакеты, которые вызывают конфликты при обновлении.
2. Подключить RPMFusion. Для этого достаточно установить пару пакетов: [один][4] и [второй][5].
3. Поставить VLC. Пакет установится именно из RPMFusion по той причине, что там версия новее.

При таком варианте все должно работать нормально. Проверил на себе.

[1]: http://pkgs.org/
[2]: http://mirror.yandex.ru/fedora/rpmfusion/free/el/releases/6/Everything/x86_64/os/
[3]: http://mirror.yandex.ru/fedora/rpmfusion/free/el/updates/6/x86_64/
[4]: http://mirror.yandex.ru/fedora/rpmfusion/free/el/updates/6/x86_64/rpmfusion-free-release-6-1.noarch.rpm
[5]: http://mirror.yandex.ru/fedora/rpmfusion/nonfree/el/updates/6/x86_64/rpmfusion-nonfree-release-6-1.noarch.rpm
[6]: http://mirror.yandex.ru/fedora/russianfedora/releases/RERemix/6.2/
[7]: https://www.scientificlinux.org/
[8]: http://www.redhat.com/products/enterprise-linux/
[9]: http://puias.math.ias.edu/
[10]: http://repoforge.org/

