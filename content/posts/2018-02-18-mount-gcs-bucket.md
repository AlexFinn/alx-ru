---
type: post
title: "Монтирование GCS"
slug: "mount-gcs-bucket"
date: "2018-02-18"
tags:
  - "systemd"
  - "fuse"
  - "gcsfuse"
  - "goofys"
  - "s3fs-fuse"
---

Регулярно требуется обрабатывать множество файлов различного размера. Файлы приходят от различных источников, включая нас самих. И лежат эти файлы на GCS.
Часть из них обрабатывается одновременно на нескольких машинах. Для этого каждая машина должна требуемые файлы каким-то образом получить. Были испробованы разные варианты получения файлов на конкретную машину. Среди вариантов были:

- скачивать непосредственно на инстанс для обработки
- монтировать бакет к инстансу

Основной задачей было: как можно быстрее получить файл и приступить к его обработке.

Первый вариант оказался самым медленным. Размер файлов и их количество могло меняться, но в целом общий размер был около 25-30 GB.

Второй вариант оказался гораздо многообещающим. Для подключения были опробованы следующие драйверы:

- [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse)
- [goofys](https://github.com/kahing/goofys)
- [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse)

Запускались тесты по 10 раз каждый с каждым драйвером.
Условия были следующие: сервис скачивает необходимые файлы и обрабатывает их совершенно одинаковым способом. Общее количество файлов: 2500. Общий объем: 27.67 GB.

Результаты:

	## gcsfuse

	01. real 9m14.670s
	02. real 8m33.348s
	03. real 8m35.500s
	04. real 8m32.533s
	05. real 8m58.443s
	06. real 8m33.600s
	07. real 8m40.910s
	08. real 9m38.806s
	09. real 10m7.476s
	10. real 8m33.300s

	## goofys

	01. real 2m22.758s
	02. real 2m47.278s
	03. real 2m26.362s
	04. real 2m23.326s
	05. real 2m22.532s
	06. real 2m40.063s
	07. real 2m16.148s
	08. real 3m9.711s
	09. real 2m55.547s
	10. real 2m4.730s

Здесь нет `s3fs-fuse`, поскольку на тот момент из-за моих кривых рук результаты оказались просто ужасными. Почти через полтора месяца я снова тестировал `s3fs-fuse` уже с новыми настройками и результаты оказались практически идентичными результатам тестирования `goofys`.

Следует добавить еще несколько слов по этому поводу.
На данный момент мы остановились на использовании `gcsfuse`. Почему? К сожалению, `goofys` имеет некоторые проблемы со стабильностью. В целом все работает очень быстро и безпроблемно, но периодически возникали странные ошибки с доступом к примонтированному бакету. Например:

- [￼https://github.com/kahing/goofys/issues/266￼](https://github.com/kahing/goofys/issues/266￼)
- ￼[https://github.com/kahing/goofys/issues/265￼](https://github.com/kahing/goofys/issues/265￼)
- ￼[https://github.com/kahing/goofys/issues/247](https://github.com/kahing/goofys/issues/247)￼

Пока мне не удалось локализовать проблему. Поэтому на данный момент в наших объемах его использовать не удаётся. Кроме того, следует упомянуть, что чтение с бакета шло практически постоянно, круглые сутки. Думаю, что если использовать при меньшей нагрузке, то проблем может и не быть.

`s3fs-fuse` в реальном использовании, с большой нагрузкой, проверить мне не удалось, поэтому сказать что-то определенное тяжело. По крайней мере, скорость получения файлов очень высока.

Если же требуется очень стабильная работа, то на данный момент альтернативы `gcsfuse` не существует. Или я её не нашел. Да, скорость не столь высока, но и вылетов за последние полгода выявлено не было.  Ну и [там есть пара моих пулл-реквестов](https://github.com/GoogleCloudPlatform/gcsfuse/pulls?q=is%3Apr+author%3AAlexFinn+is%3Aclosed￼)

И немного дополнительной информации.

У `gcsfuse` есть отдельный бинарник `mount.gcsfuse`, что позволяет использовать для монтирования `systemd.mount`. У `goofys` такого нет, поэтому только `systemd.service`, что вынуждает как-то дополнительно проверять корректность отмонтирования бакета при падении сервиса. В целом, написать и для него `mount` часть не так сложно, но пока я или кто-то ещё этого не сделал. Хотя мысли такие есть.