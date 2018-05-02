---
type: post
title: "ssh keys и нестандартное место хранения authorized_keys"
slug: "ssh-auth-keys-external-storage"
date: "2018-03-09"
tags:
  - "ssh"
  - "gcs"
  - "storage"
  - "ldap"
---

Как уже повелось в последних постах начну с небольшой предистории.
Итак, решил найти способ обновления списка публичных ключей на инстансах с минимальными трудозатратами. Прежде, список ключей формировался при создании базового образа (напомню, что мы используем Google Cloud). В дальнейшем, необходимые дополнительные изменения можно было произвести с помощью ansible, например, добавить ключик. А вот удаление производить не совсем удобно, кроме того,  пересобирать базовый образ каждый раз при добавлении ключа, а в последнее время регулярно приходят новые люди, не совсем удобно. Посему пустился я в поиски возможного решения.

Впрочем, решение нашлось достаточно быстро.

Если внимательно посмотреть на файл конфигурации `sshd` на любом сервере, можно найти такую штуку: `AuthorizedKeysCommand`. Она-то нам и поможет.
В файле конфигурации определяется она следующим образом:

``` bash
...
AuthorizedKeysCommand /path/to/script.sh
AuthorizedKeysCommandUser nobody
...
```

Скрипт должен что-то делать :) Например, что-нибудь проверить, а самое главное, получить как-то откуда-то так необходимые нам ключи. Например, это может быть файл на примонтированном томе, LDAP или еще что. В нашем же случае, вполне может подойти какое-либо облачное хранилище: Amazon S3 или Google Cloud Storage. Вот им и воспользуемся.
Но даже при хранении файла в бакете с нормально установленными правами всё равно желательно файл зашифровать. Поскольку мы уже используем `ansible`, то и воспользуемся.

Начнём с последнего. Добавим публичный ключ в файлик. Зашифруем для начала файл:

``` bash
→ ansible-vault encrypt secret-file
```

Как можно проверить содержимое файла:

``` bash
→ ansible-vault view secret-file
```

Но каждый раз вводить пароль - неудобно, можно воспользоваться переменной окружения или файлом с паролем для расшифровки. Далее сохраним файл с ключом в бакете.

Получить файл просто, просто воспользуемся утилитой `gsutil`. И попробуем все это дело объединить:

``` bash
→ gsutil cat gs://bucket/secret-file | ansible-vault decrypt --vault-password-file /path/to/file/with/password --output - || true
```

Сохранять файл с ключом нам не нужно, поэтому `cat` вместо `cp`, например. И вывести расшифрованное требуется в `stdout`.

Примерное содержимое скрипта:

``` bash
#!/bin/bash

logger "Fetching public key for ${1}"
gsutil cat gs://bucket/secret-file | ansible-vault decrypt --vault-password-file /path/to/file/with/password --output - || true
```

`${1}` - это переменная, значение которой - имя пользователя, под которым совершается вход. Соответственно, если скрипт потребуется использовать для входа различных пользователей, нужно будет проверять именно это переменную.

Если воспользоваться поиском, то можно найти множество вариантов применения:

1. [https://blog.heckel.xyz/2015/05/04/openssh-authorizedkeyscommand-with-fingerprint/](https://blog.heckel.xyz/2015/05/04/openssh-authorizedkeyscommand-with-fingerprint/ "https://blog.heckel.xyz/2015/05/04/openssh-authorizedkeyscommand-with-fingerprint/")
2. [https://blather.michaelwlucas.com/archives/1562](https://blather.michaelwlucas.com/archives/1562 "https://blather.michaelwlucas.com/archives/1562")
3. [http://pig.made-it.com/ldap-openssh.html](http://pig.made-it.com/ldap-openssh.html "http://pig.made-it.com/ldap-openssh.html")
4. [https://jmorano.moretrix.com/2013/09/openssh-6-2-x-ldap-authentication/](https://jmorano.moretrix.com/2013/09/openssh-6-2-x-ldap-authentication/ "https://jmorano.moretrix.com/2013/09/openssh-6-2-x-ldap-authentication/")