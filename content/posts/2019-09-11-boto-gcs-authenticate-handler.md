---
type: post
title: "Boto, GCS и 'No handler was ready to authenticate'"
slug: "boto-gcs-authenticate-handler"
date: "2019-09-11"
tags:
  - "boto"
  - "gcs"
  - "python3"
---

Вполне вероятно, что, на момент прочтения, информация будет уже неактуальна, но я решил описать, в чем была проблема и как я её решил.

Пару месяцев назад натолкнулись на странный баг на запускаемых инстансах. При попытке подключения к Google Cloud Storage из скриптов на Python, получали ошибку с сообщением проверить права:

    >>> import boto,gcs_oauth2_boto_plugin
    >>> boto.storage_uri('ubiprod', 'gs').connect()
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
      File "/usr/local/lib/python3.6/dist-packages/boto/storage_uri.py", line 140, in connect
        **connection_args)
      File "/usr/local/lib/python3.6/dist-packages/boto/gs/connection.py", line 47, in __init__
        suppress_consec_slashes=suppress_consec_slashes)
      File "/usr/local/lib/python3.6/dist-packages/boto/s3/connection.py", line 194, in __init__
        validate_certs=validate_certs, profile_name=profile_name)
      File "/usr/local/lib/python3.6/dist-packages/boto/connection.py", line 569, in __init__
        host, config, self.provider, self._required_auth_capability())
      File "/usr/local/lib/python3.6/dist-packages/boto/auth.py", line 1021, in get_auth_handler
        'Check your credentials' % (len(names), str(names)))
    boto.exception.NoAuthHandlerFound: No handler was ready to authenticate. 3 handlers were checked. ['OAuth2Auth', 'OAuth2ServiceAccountAuth', 'HmacAuthV1Handler'] Check your credentials

Для собственных нужд мы собираем некий базовый образ с необходимыми пакетами. В старых образах такого не наблюдалось, а во вновь собранных повторялось в завидным постоянством. Для сборки используется актуальный образ из семейства `ubuntu-1804-lts`. Как вариант, решили просто отказаться на какое-то время от использования свежих образов.

На днях решил проверить, изменилось ли что-то. Изменилось примерно ничего и я решил поискать причину.

Итак, при первом запуске инстанса запускается сервис `google-instance-setup.service`. Он запускает несколько скриптов на Python, которые, в свою очередь, делают определенные настройки системы и готовят инстанс для работы в облачном окружении. В частности, эти скрипты создают файл `/etc/boto.cfg`, в котором прописываются глобальные настройки для Boto. Вот это примерное содержание:

    # This file is automatically created at boot time by the /usr/lib/python
    # 3/dist-packages/google_compute_engine/boto/boto_config.py script. Do
    # not edit this file directly. If you need to add items to this file,
    # create or edit /etc/boto.cfg.template instead and then re-run
    # google_instance_setup.

    [GSUtil]
    default_project_id = <numeric-project-id>
    default_api_version = 2

    [GoogleCompute]
    service_account = default

    [Plugin]
    plugin_directory = /usr/lib/python3/dist-packages/google_compute_engine/boto

По какой-то причине этот файл не создавался при старте. При создании вручную всё работало отлично.
Я решил выяснить, в чем причина, и полез копаться в коммитах в проекте `GoogleCloudPlatform/compute-image-packages` на гитхабе. Выяснилось следующее: 14 мая 2019 был добавлен [коммит][1], который отключал создание файла `/etc/boto.cfg`, если основной системной версией Python является `> 3.0`. Не знаю, какой логикой руководствовался автор, но этот коммит попал в пакет `python3-google-compute-engine` версии `20190522-0ubuntu1~18.04.0 `.
Чуть позже мейнтейнеры одумались и [поправили это][2]. И исправление даже попало в новую версию пакета, который, к сожалению, на данный момент пока не попал в репозиторий.

Итак, часть настроек системы при старте `google-instance-setup` применяется в соответствие с параметрами, указанными в файле `/etc/default/instance_configs.cfg`. А там есть интересный параметр в секции `[InstanceSetup]`: `set_boto_config`, который был установлен в `false`. В качестве варианта исправления, пока фикс не попал в репозиторий, можно указать `set_boto_config = true` и запустить:

    -> systemctl start google-instance-setup.service

После этого стоит проверить, что файл `/etc/boto.cfg` существует и ради проверки запустить:

    python3 -c "import boto,gcs_oauth2_boto_plugin; boto.storage_uri('<bucket-name>', 'gs').connect()"

Ошибок быть не должно.

[1]: https://github.com/GoogleCloudPlatform/compute-image-packages/commit/64213603ea6b37714d5cbcc452f3fc954fcbd6c5#diff-8a8f1dc706546c1117ff42d1d196ff5c
[2]: https://github.com/GoogleCloudPlatform/compute-image-packages/commit/66b0268f237da0d046a97c6db42071cea1b6efb0#diff-8a8f1dc706546c1117ff42d1d196ff5c

