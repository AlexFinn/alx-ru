---
type: post
title: "Cabot. Как мигрировал с MySQL на PostgreSQL"
Slug: "cabotapp-migrate-to-postgres-from-mysql"
date: "2016-04-28"
tags:
  - "cabotapp"
  - "mysql"
  - "postgresql"
---

Наступил момент, когда мне потребовалось мигрировать базу данных Cabot с MySQL в PostgreSQL.
Официально, [Cabot](http://cabotapp.com) поддерживает только вторую, но по какой-то причине изначально он был развернут в связке с MySQL.

Итак, дано:

- Cabot (версию указать не могу, поскольку у них нет релизов)
- MySQL (версия 5.6, хотя это не столь важно, Amazon RDS)
- PostgreSQL (версия 9.4 на данный момент, расположен на Amazon RDS)

База была не очень большая, но содержала множество различных данных, которые потерять не хотелось бы.
Поиски конвертера из одной базы в другую привели меня к нескольким вариантам. Во-первых, я просмотрел возможные утилиты на [странице вики](https://wiki.postgresql.org/wiki/Converting_from_other_Databases_to_PostgreSQL) самого Postgre. В разделе, относящемся к MySQL выбрал несколько для пробы. Кратенько об этом:

- [**pgloader**](https://github.com/dimitri/pgloader): написан на Common Lisp. Есть в репозитории дистрибутива и ставится легко: `apt-get install pgloader`. Миграция сработала, но приложение после запуска отказалось работать, в логах celery что-то типа следующего:

		[2016-04-19 20:10:49,177: ERROR/MainProcess] Task cabot.cabotapp.tasks.run_all_checks[41217f7d-e3f1-40eb-ac34-0303fd20050c] raised unexpected: DoesNotExist('ContentType matching query does not exist.',)
		Traceback (most recent call last):
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/celery/app/trace.py", line 240, in trace_task R = retval = fun(*args, **kwargs)
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/celery/app/trace.py", line 438, in __protected_call__
			return self.run(*args, **kwargs)
		File "/home/ubuntu/2016-04-19-1d29d71/cabot/cabotapp/tasks.py", line 45, in run_all_checks
			for check in checks:
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/django/db/models/query.py", line 96, in __iter__
			self._fetch_all()
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/django/db/models/query.py", line 857, in _fetch_all
			self._result_cache = list(self.iterator())
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/polymorphic/query.py", line 280, in iterator real_results = self._get_real_instances(base_result_objects)
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/polymorphic/query.py", line 176, in _get_real_instances real_concrete_class = base_object.get_real_instance_class()
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/polymorphic/polymorphic_model.py", line 106, in get_real_instance_class model = ContentType.objects.get_for_id(self.polymorphic_ctype_id).model_class()
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/django/contrib/contenttypes/models.py", line 106, in get_for_id ct = self.get(pk=id)
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/django/db/models/manager.py", line 151, in get return self.get_queryset().get(*args, **kwargs)
		File "/home/ubuntu/venv/local/lib/python2.7/site-packages/django/db/models/query.py", line 310, in get self.model._meta.object_name)
		Exception: ContentType matching query does not exist.

- [**FromMySqlToPostgreSql**](https://github.com/AnatolyUss/FromMySqlToPostgreSql): используется PHP, так что пропустил.
- [**py-mysql2pgsql**](https://github.com/philipsoutham/py-mysql2pgsql): написан на Python. Именно этот скрипт я в итоге и выбрал. Подробней расскажу чуть позже.
- [**mysql-postgresql-converter**](https://github.com/lanyrd/mysql-postgresql-converter): тоже написан на Python. Проверить так и не удалось, поскольку предыдущий вариант меня в целом устроил.

Итак, я остановился на **py-mysql2pgsql**.
Использование очень простое. Установка через PIP:

	$ sudo pip install py-mysql2pgsql

При первом запуске без параметров предлагает создать файл с настройками, где указывается опции подключения к базам.

	$ py-mysql2pgsql
	No configuration file found.
	A new file has been initialized at: mysql2pgsql.yml
	Please review the configuration and retry...

Пример конфигурационного файла приводить не буду, там все просто и очевидно.

После указания настроек подключения к базам при указании параметра `-v` еще и будет показывать, что делается в процессе (пример взят с гитхаба проекта):

	$ py-mysql2pgsql -v -f mysql2pgsql.yml
	START PROCESSING table_one
	  START  - CREATING TABLE table_one
	  FINISH - CREATING TABLE table_one
	  START  - WRITING DATA TO table_one
	  24812.02 rows/sec [20000]
	  FINISH - WRITING DATA TO table_one
	  START  - ADDING INDEXES TO table_one
	  FINISH - ADDING INDEXES TO table_one
	  START  - ADDING CONSTRAINTS ON table_one
	  FINISH - ADDING CONSTRAINTS ON table_one
	FINISHED PROCESSING table_one

	START PROCESSING table_two
	  START  - CREATING TABLE table_two
	  FINISH - CREATING TABLE table_two
	  START  - WRITING DATA TO table_two

	  FINISH - WRITING DATA TO table_two
	  START  - ADDING INDEXES TO table_two
	  FINISH - ADDING INDEXES TO table_two
	  START  - ADDING CONSTRAINTS ON table_two
	  FINISH - ADDING CONSTRAINTS ON table_two
	FINISHED PROCESSING table_two

Сконвертировалось все отлично. Cabot заработал после перезапуска без видимых проблем, данные вручную обновлялись. Минут через 30 я заметил, что автоматических проверок не происходит. В логах обнаружилось следующее:

	[2016-04-20 09:33:58,831: ERROR/MainProcess] Task cabot.cabotapp.tasks.run_all_checks[cc141897-3c80-4960-acaf-e913751f862d] raised unexpected: TypeError("can't compare offset-naive and offset-aware datetimes",)
	Traceback (most recent call last):
	  File "/home/ubuntu/venv/local/lib/python2.7/site-packages/celery/app/trace.py", line 240, in trace_task
	    R = retval = fun(*args, **kwargs)
	  File "/home/ubuntu/venv/local/lib/python2.7/site-packages/celery/app/trace.py", line 438, in __protected_call__
	    return self.run(*args, **kwargs)
	  File "/home/ubuntu/2016-04-19-1d29d71/cabot/cabotapp/tasks.py", line 48, in run_all_checks
	    if (not check.last_run) or timezone.now() > next_schedule:
	TypeError: can't compare offset-naive and offset-aware datetimes

Долго не мог понять, в чем собственно сложность, пока не посмотрел на таблицу конвертации типов данных: [Data Type Conversion Legend](https://github.com/philipsoutham/py-mysql2pgsql#data-type-conversion-legend).
Пришлось лезть руками в базу и менять тип в некоторых таблицах с `timestamp without time zone` на `timestamp with time zone`.
Вот список таких таблиц:

- cabotapp_alertacknowledgement (Columns: `time`, `cancelled_time`)
- cabotapp_instance (`Columns: last_alert_sent`)
- cabotapp_instancestatussnapshot(Columns: `time`)
- cabotapp_service (Columns: `last_alert_sent`)
- cabotapp_servicestatussnapshot (Columns: `time`)
- cabotapp_shift (Columns: `start`, `end`)
- cabotapp_statuscheck (Columns: `last_run`)
- cabotapp_statuscheckresult (Columns: `time`, `time_complete`)
- celery_taskmeta (Columns: `date_done`)
- celery_tasksetmeta (Columns: `date_done`)
- djcelery_periodictask (Columns: `expires`, `last_run_at`, `date_changed`)
- djcelery_periodictasks (Columns: `last_update`)
- djcelery_taskstate (Columns: `tstamp`, `eta`, `expires`)
- djcelery_workerstate (Columns: `last_heartbeat`)
- south_migrationhistory (Columns: `applied`)

Вроде ничего не забыл из таблиц.
Вероятно, следовало написать скрипт для смены типов, но на тот момент я этого не сделал. Впрочем, и сейчас тоже его нет :)

После изменения типа проблемы ушли.
