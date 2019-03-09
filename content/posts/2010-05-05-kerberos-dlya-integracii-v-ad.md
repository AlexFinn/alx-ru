---
type: post
author: hrafn
tags:
- AD
- kerberos
- translate
comments: false
date: 2010-05-05T11:36:00Z
published: true
title: '[RH Knowledgebase] Kerberos для интеграции в AD'
Slug: rh-knowledgebase-kerberos-для-интеграции-в-ad
url: /2010/05/kerberos-dlya-integracii-v-ad
---

Давно не писал ничего. Очень занят. А когда выдается свободное минутка, делать совершенно ничего не хочется ))

Посему, добавлю чуть-чуть переводов. На сей раз про настройку Kerberos для интеграции в Active Directory. [Оригинал заметки](http://kbase.redhat.com/faq/docs/DOC-4735).

Следует также заметить, что многие заметки на Red Hat Knowledgebase отнюдь не являются полными руководствами, а всего лишь именно ЗАМЕТКАМИ что ли. Для реальной настройки многих вещей необходимо обязательно читать, как минимум, документацию дистрибутива. А лучше также файлы настройки нужной программы и документацию к ней.

Все написанное относится к Samba 3, действия для более ранних версий могут отличаться.

Измените файл `/etc/krb5.conf`, как показано в примере ниже. Заметьте, что `EXAMPLE.DIRECTORY` необходимо заменить именем вашего домена Active Directory, `10.0.0.1` - заменить IP-адресом вашего контроллера домена, а также. что все
записи регистрозависимы.

Пример файла `/etc/krb5.conf`:

	[logging]
	default = FILE:/var/log/krb5libs.log
	kdc = FILE:/var/log/krb5kdc.log
	admin_server = FILE:/var/log/kadmind.log

	[libdefaults]
	ticket_lifetime = 24000
	default_realm = EXAMPLE.DIRECTORY
	dns_lookup_realm = false
	dns_lookup_kdc = false

	[realms]
	EXAMPLE.DIRECTORY = {
		kdc = 10.0.0.1
		default_domain = example.directory
	}

	[domain_realm]
	.example.directory = EXAMPLE.DIRECTORY
	example.directory = EXAMPLE.DIRECTORY

	[kdc]
	profile = /var/kerberos/krb5kdc/kdc.conf

	[appdefaults]
	pam = {
		debug = false
		ticket_lifetime = 36000
		renew_lifetime = 36000
		forwardable = true
		krb4_convert = false
	}

При этих настройках файлы логов `/var/log/krb5libs.log`, `/var/log/krb5kdc.log` и `/var/log/kadmind.log` содержат множество полезной информации. Для получения более подробных логов измените параметр `debug = false` на `debug = true`.

За более детальной настройкой, пожалуйста, обратитесь к документации:

[http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/5.4/html/Deployment_Guide/ch-kerberos.html](http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/5.4/html/Deployment_Guide/ch-kerberos.html)

