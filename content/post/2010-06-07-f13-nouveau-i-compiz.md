---
type: post
author: hrafn
tags:
- fedora
- nvidia
comments: false
date: 2010-06-07T13:50:41Z
published: true
title: F13, nouveau и compiz
Slug: f13-nouveau-и-compiz
url: /2010/06/f13-nouveau-i-compiz
---

Честно скажу, compiz сам по себе я люблю. Правда, из всех его возможностей я использую, наверно, всего пару: колебание окон при перемещении и прозрачность (в терминале. в частности).

На домашнем ноуте проблем с компизом нет, поскольку видео от Intel. А вот на рабочей машине стоит видяха NVidia. Пока сидел на Fedora 12, использовал дрова из репозиториев, настроенные по советам на форуме forum.russianfedora.ru. В
F13 была заявлена поддержка 3D с драйверами Nouveau. Вот это я наконец и сподобился проверить.

	$ lspci
	00:00.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a2)
	00:01.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a3)
	00:01.1 SMBus: nVidia Corporation MCP55 SMBus (rev a3)
	00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1)
	00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2)
	00:04.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1)
	00:05.0 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a3)
	00:05.1 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a3)
	00:05.2 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a3)
	00:06.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2)
	00:06.1 Audio device: nVidia Corporation MCP55 High Definition Audio (rev a2)
	00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
	00:0f.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a3)
	00:18.0 Host bridge: Advanced Micro Devices [AMD] K10 [Opteron, Athlon64,
	Sempron] HyperTransport Configuration
	00:18.1 Host bridge: Advanced Micro Devices [AMD] K10 [Opteron, Athlon64,
	Sempron] Address Map
	00:18.2 Host bridge: Advanced Micro Devices [AMD] K10 [Opteron, Athlon64,
	Sempron] DRAM Controller
	00:18.3 Host bridge: Advanced Micro Devices [AMD] K10 [Opteron, Athlon64,
	Sempron] Miscellaneous Control
	00:18.4 Host bridge: Advanced Micro Devices [AMD] K10 [Opteron, Athlon64,
	Sempron] Link Control
	01:0a.0 FireWire (IEEE 1394): Texas Instruments TSB43AB23 IEEE-1394a-2000
	Controller (PHY/Link)
	02:00.0 VGA compatible controller: nVidia Corporation G96 [GeForce 9500 GT]
	(rev a1)

Просто установка nouveau ничего не дала. Но после установки mesa-dri-drivers-
experimental и последующей перезагрузки компиз соизволил включиться.

Вот так все просто и под музыку :)

