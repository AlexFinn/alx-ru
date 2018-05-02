---
type: post
author: hrafn
tags:
- samba
- ldap
- failed
- howto
comments: false
date: 2010-02-26T11:51:15Z
published: true
title: 'Samba+LDAP: slapd: '
Slug: sambaldap-slapd
url: /2010/02/samba-ldap-not-indexed
---

Поскольку мне по работе периодически приходится сталкиваться со связкой
Samba+LDAP, то решил поместить сюда решение проблемы, вынесеной в название
поста.

А проблема, если чуть потише взглянуть, такова. В логах slapd появляются
следующие ошибки:

		Feb 25 20:23:53 dc02 slapd[5677]: <= bdb_equality_candidates: (gidNumber) not
		indexed
		Feb 25 20:23:53 dc02 slapd[5677]: <= bdb_equality_candidates: (sambaSID) not
		indexed
		Feb 25 20:23:53 dc02 slapd[5677]: <= bdb_equality_candidates: (sambaSID) not
		indexed
		Feb 25 20:23:55 dc02 slapd[5677]: <= bdb_equality_candidates: (uid) not
		indexed
		Feb 25 20:23:55 dc02 slapd[5677]: <= bdb_equality_candidates: (uid) not
		indexed

Для решения сей проблемы необходимо в конфиг /etc/ldap/slapd.conf в раздел в
директивами database добавить следующее:

		# Indices to maintain for this database
		index objectClass eq,pres
		index ou,cn,sn,mail,givenname eq,pres,sub
		index uidNumber,gidNumber,memberUid eq,pres
		index loginShell eq,pres

		# I also added this line to stop warning in syslog ..
		index uniqueMember eq,pres

		## required to support pdb_getsampwnam
		index uid pres,sub,eq

		## required to support pdb_getsambapwrid()
		index displayName pres,sub,eq

		# These attributes don't exist in this database ..
		#index nisMapName,nisMapEntry eq,pres,sub
		index sambaSID eq
		index sambaPrimaryGroupSID eq
		index sambaDomainName eq
		index default sub

После этого:

		# /etc/init.d/slapd stop
		# slapindex
		WARNING!
		Runnig as root!
		There's a fair chance slapd will fail to start.
		Check file permissions!

		# chown openldap:openldap /var/lib/ldap/*
		# /etc/init.d/slapd start
		Starting OpenLDAP: slapd

Добавляемые в конфиг строки примерны, поскольку наличие дополнительных строк
или их отсутствие зависит от конфигурации.

Информация взята [отсюда](http://www.gacosta.net/Linux-Apache-MySQL-PHP/openldap-and-samba-pdc.html).

