---
type: post
comments: false
date: 2016-10-21T00:00:00Z
title: Wordpress, Varnish и Jetpack
Slug: 'wordpress-varnish-and-jetpack'
tags:
- wordpress
- varnish
- jetpack
---

Меня попросили посмотреть, в чем может быть проблема с настройками [Jetpack](https://jetpack.com/).
Проблема заключалось в том, что при попытке подключения любого из аккантов социальных сетей выдавалась ошибка:

	Something which should never happen, happened. Sorry about that. If you try again, maybe it will work.

	Error code: -32601

При включении Debug-режима у Jetpack выяснилось, что Jetpack не может получить доступ к файлу `xmlrpc.php`. ПРи этом доступ к этому файлу из браузера работал, выдавая:

	XML-RPC server accepts POST requests only.

На сервер используется Wordpress в связке с nginx, php-fpm и varnish. Как в итоге мне удалось выяснить, проблема была именно в Varnish. Кстати, еще один способ проверить работоспособность Jetpack состоит в том, чтобы в браузере запросить страницу `http://example.com/xmlrpc.php?rsd`. Само собой, требуется указать верное имя домена.
Если результат будет тот же, что и при запросе `xmlrpc.php`, то проблема существует. При правильной настройке должно выдаваться что-то вроде:

	<rsd xmlns="http://archipelago.phrasewise.com/rsd" version="1.0">
	  <service>
	    <engineName>WordPress</engineName>
	    <engineLink>https://wordpress.org/</engineLink>
	    <homePageLink>http://example.com</homePageLink>
	    <apis>
	      <api name="WordPress" blogID="1" preferred="true" apiLink="http://example.com/xmlrpc.php"/>
	      <api name="Movable Type" blogID="1" preferred="false" apiLink="http://example.com/xmlrpc.php"/>
	      <api name="MetaWeblog" blogID="1" preferred="false" apiLink="http://example.com/xmlrpc.php"/>
	      <api name="Blogger" blogID="1" preferred="false" apiLink="http://example.com/xmlrpc.php"/>
	      <api name="WP-API" blogID="1" preferred="false" apiLink="http://example.com/wp-json/"/>
	    </apis>
	  </service>
	</rsd>

Решается достаточно просто. Необходимо добавить в wp-config.php следующую строку:

	$_SERVER['SERVER_PORT'] = 80;

Порт указывается `80`, если блог доступен по http, и `443`, если https.
