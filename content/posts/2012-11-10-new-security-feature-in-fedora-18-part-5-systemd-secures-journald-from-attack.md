---
type: post
tags:
- Fedora 18
- Systemd
- Journald
- Security
comments: false
date: 2012-11-10T00:00:00Z
title: 'Security in Fedora 18 Part 5: Systemd Secures Journald from attack'
Slug: security-in-fedora-18-part-5-systemd-secures-journald-from-attack
url: /2012/11/10/new-security-feature-in-fedora-18-part-5-systemd-secures-journald-from-attack/
---

Пятая часть от [Dan Walsh: selinux, systemd, journald][1]

Forward Secure Sealing (FSS) - это новая функциональность systemd/jourlnald в Fedora 18.

Если ваша машина взломана (вы выключили SELinux?), и взломщик получил права администратора, он захочет скрыть следы своего пребывания, изменив файлы системных логов. Все это является проблемой, поскольку вы можете не знать, когда машина была взломана и были ли изменены лог-файлы. До появления FSS единственный способ быть уверенным, что лог-файлы не изменены - хранить их на другой машине, например, настроив rsyslog и auditlog на отправку на другую машину. С приходом FSS вы можете проверить логи journald на вашей системе и узнать, были ли они сфальсифицированы. И что даже лучше, вы узнаете, когда взломщик начал их изменять, и какая часть логов до сих пор цела.

Основная идея - вы создаете verification ID и храните его где-то в другом месте или просто используете QR-код и храните его на смартфоне.

[По этому поводу можно почитать сообщение Леннарта Поттеринга на Google+.][2]

![][3]

[1]: http://danwalsh.livejournal.com/58647.html
[2]: https://plus.google.com/115547683951727699051/posts/g1E6AxVKtyc
[3]: /images/2012/11/10/sealing.png


