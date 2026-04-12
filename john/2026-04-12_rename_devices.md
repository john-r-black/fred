# Device Rename Report - 2026-04-12

Target naming convention: name ends with `[XXXX]` (last 4 hex of MAC, no colon).

Items below could not be renamed via MCP. The UniFi Network MCP only exposes list/block/unblock/reconnect actions for clients, and list/restart/locate/upgrade/power_cycle for devices - no rename action is available. These need to be renamed manually in the UniFi Network controller UI.

## unifi-church - Network (clients + devices)

| IP Address | Current Name | New Name | MAC |
|---|---|---|---|
| 10.1.10.101 | Broadcast PC 30F6 | Broadcast PC [30F6] | 04:42:1a:8d:30:f6 |
| 10.1.10.102 | Concourse BirdDog 3F83 | Concourse BirdDog [3F83] | d4:20:00:a0:3f:83 |
| 10.1.10.121 | TL-SG108E 2BED | TL-SG108E [2BED] | e8:48:b8:71:2b:ed |
| 10.1.10.205 | Worship PC 28D9 | Worship PC [28D9] | f0:2f:74:cf:28:d9 |
| 10.1.10.238 | Announcements Mac 326B | Announcements Mac [326B] | 5c:1b:f4:9f:32:6b |
| 10.1.10.240 | e4:77:d4:08:b9:e2 | [B9E2] | e4:77:d4:08:b9:e2 |
| 76.143.85.189 | DPUMC-Gateway | DPUMC-Gateway [3159] | 24:5a:4c:99:31:59 |
| 192.168.1.2 | 6022326b187b06a6b0a606f6d04106306a488.id.ui.direct | 6022326b187b06a6b0a606f6d04106306a488.id.ui.direct [187C] | 60:22:32:6b:18:7c |
| 192.168.1.3 | Admin - Pro-48-PoE | Admin - Pro-48-PoE [3928] | d0:21:f9:c2:39:28 |
| 192.168.1.4 | MWS - Pro-24-PoE | MWS - Pro-24-PoE [BED8] | d0:21:f9:d6:be:d8 |
| 192.168.1.5 | MWS - Flex Mini | MWS - Flex Mini [F8A7] | 60:22:32:4f:f8:a7 |
| 192.168.1.6 | East - Pro-24-PoE | East - Pro-24-PoE [0F2E] | 78:45:58:e7:0f:2e |
| 192.168.1.7 | Pastor - Lite-8-PoE | Pastor - Lite-8-PoE [A37A] | d0:21:f9:4d:a3:7a |
| 192.168.1.8 | FLC - Pro-24-PoE | FLC - Pro-24-PoE [BDFD] | d0:21:f9:d6:bd:fd |
| 192.168.1.9 | FLC - Lite 16 PoE | FLC - Lite 16 PoE [0492] | 70:a7:41:cd:04:92 |
| 192.168.1.10 | Staging - US 24 PoE 250W | Staging - US 24 PoE 250W [47B8] | b4:fb:e4:1f:47:b8 |
| 192.168.1.11 | WiFi FLC - AC HD | WiFi FLC - AC HD [5774] | b4:fb:e4:25:57:74 |
| 192.168.1.12 | WiFi Admin - Nano HD | WiFi Admin - Nano HD [71F8] | b4:fb:e4:26:71:f8 |
| 192.168.1.13 | WiFi Front - UK Ultra | WiFi Front - UK Ultra [C96D] | 9c:05:d6:76:c9:6d |
| 192.168.1.14 | WiFi MWS - U6 Pro | WiFi MWS - U6 Pro [616E] | d0:21:f9:83:61:6e |
| 192.168.1.15 | WiFi Children - UK Ultra | WiFi Children - UK Ultra [C96A] | 9c:05:d6:76:c9:6a |
| 192.168.1.16 | WiFi Concourse - AC HD | WiFi Concourse - AC HD [9BB8] | fc:ec:da:d5:9b:b8 |
| 192.168.1.17 | WiFi East - Nano HD | WiFi East - Nano HD [69BB] | b4:fb:e4:26:69:bb |
| 192.168.1.18 | WiFi Sanctuary - AC HD | WiFi Sanctuary - AC HD [577C] | b4:fb:e4:25:57:7c |
| 192.168.1.19 | WiFi Choir - Nano HD | WiFi Choir - Nano HD [6A2A] | b4:fb:e4:26:6a:2a |
| 192.168.1.20 | WiFi FP - Nano HD | WiFi FP - Nano HD [6D30] | b4:fb:e4:26:6d:30 |
| 192.168.1.21 | Church Printer Sharp 4141N | Church Printer Sharp 4141N [D44F] | 24:26:42:bd:d4:4f |
| 192.168.1.22 | WiFi Sign - AC LR | WiFi Sign - AC LR [A37B] | 68:d7:9a:d3:a3:7b |
| 192.168.1.26 | FLC Power Strip | FLC Power Strip [5002] | d0:21:f9:88:50:02 |
| 192.168.1.27 | MWS Power Strip | MWS Power Strip [381E] | d0:21:f9:63:38:1e |
| 192.168.1.28 | East Power Strip | East Power Strip [4DDD] | d0:21:f9:88:4d:dd |
| 192.168.1.29 | Admin Power Strip | Admin Power Strip [E64E] | d0:21:f9:55:e6:4e |
| 192.168.1.30 | FLC2H2 - G3 Flex F861 | FLC2H2 - G3 Flex [F861] | d0:21:f9:90:f8:61 |
| 192.168.1.31 | Thermostat Computer | Thermostat Computer [E279] | 1c:69:7a:6a:e2:79 |
| 192.168.1.32 | Amazon Echo Pop d0:fd | Amazon Echo Pop [D0FD] | 08:c2:24:72:d0:fd |
| 192.168.1.33 | echoshow-8e63f44b2984ee8e 60:82 | echoshow-8e63f44b2984ee8e [6082] | 08:c2:24:af:60:82 |
| 192.168.1.35 | 124-G3-Flex | 124-G3-Flex [607A] | d0:21:f9:91:60:7a |
| 192.168.1.38 | MWS Interior | MWS Interior [6C47] | 24:5a:4c:a9:6c:47 |
| 192.168.1.40 | Pastor2023 be:6c | Pastor2023 [BE6C] | 58:11:22:75:be:6c |
| 192.168.1.41 | FLC202 - G3 Flex F9DA | FLC202 - G3 Flex [F9DA] | d0:21:f9:90:f9:da |
| 192.168.1.42 | NPIF845FA 0d:5a | NPIF845FA [0D5A] | 64:6c:80:66:0d:5a |
| 192.168.1.43 | Front Desk - Max FB92 | Front Desk - Max [FB92] | 68:d7:9a:7f:fb:92 |
| 192.168.1.47 | flc205a-g3-flex ca:be | flc205a-g3-flex [CABE] | 58:a8:e8:1f:ca:be |
| 192.168.1.50 | Synology 1 | Synology 1 [022F] | 00:11:32:9b:02:2f |
| 192.168.1.51 | Synology 2 | Synology 2 [0230] | 00:11:32:9b:02:30 |
| 192.168.1.54 | Pastor - Max 7C33 | Pastor - Max [7C33] | 60:22:32:0d:7c:33 |
| 192.168.1.55 | FLC203 - G3 Flex F87B | FLC203 - G3 Flex [F87B] | d0:21:f9:90:f8:7b |
| 192.168.1.56 | Concourse - Exit | Concourse - Exit [FD02] | 24:5a:4c:f4:fd:02 |
| 192.168.1.57 | Front Desk Computer | Front Desk Computer [E2AD] | 8c:8c:aa:7e:e2:ad |
| 192.168.1.58 | FP Interior | FP Interior [0B5E] | f4:e2:c6:d7:0b:5e |
| 192.168.1.59 | FP Interior - Exit | FP Interior - Exit [EB2E] | e4:38:83:ba:eb:2e |
| 192.168.1.60 | MWS - ATA 347F | MWS - ATA [347F] | 70:a7:41:ff:34:7f |
| 192.168.1.61 | iPhone 77:30 | iPhone [7730] | d2:7a:77:ca:77:30 |
| 192.168.1.63 | FP Exterior - Entry | FP Exterior - Entry [ECD7] | 9c:05:d6:34:ec:d7 |
| 192.168.1.65 | Protect Viewport | Protect Viewport [3BB6] | d8:b3:70:8c:3b:b6 |
| 192.168.1.76 | iPhone f2:1e | iPhone [F21E] | 1a:41:6d:f4:f2:1e |
| 192.168.1.78 | MWS Front - Exit  | MWS Front - Exit [53CE] | 24:5a:4c:f2:53:ce |
| 192.168.1.81 | amazon-35f272b6d1081e1c 99:26 | amazon-35f272b6d1081e1c [9926] | 0c:dc:91:cb:99:26 |
| 192.168.1.89 | Finance - Touch 3312 | Finance - Touch [3312] | 68:d7:9a:7f:33:12 |
| 192.168.1.90 | FLC205A - G3 Flex 008B | FLC205A - G3 Flex [008B] | d0:21:f9:91:00:8b |
| 192.168.1.92 | East Concourse | East Concourse [6094] | d0:21:f9:91:60:94 |
| 192.168.1.93 | West Concourse | West Concourse [49FC] | d0:21:f9:90:49:fc |
| 192.168.1.94 | Pura-C074 c0:74 | Pura-C074 [C074] | b0:a7:32:c7:c0:74 |
| 192.168.1.97 | Touch 1617 | Touch [1617] | 68:d7:9a:7f:16:17 |
| 192.168.1.101 | MWS Interior - Entry | MWS Interior - Entry [FD32] | 24:5a:4c:f4:fd:32 |
| 192.168.1.102 | 85onnRokuTV 21:18 | 85onnRokuTV [2118] | d4:3a:2f:ec:21:18 |
| 192.168.1.104 | East Door - Exit | East Door - Exit [B613] | 24:5a:4c:f0:b6:13 |
| 192.168.1.105 | FLC1H1 - G3 Flex FA94 | FLC1H1 - G3 Flex [FA94] | d0:21:f9:90:fa:94 |
| 192.168.1.106 | flc205b-g3-flex 4c:4b | flc205b-g3-flex [4C4B] | 20:be:b8:99:4c:4b |
| 192.168.1.107 | MWS Desktop | MWS Desktop [AC22] | 94:c6:91:1c:ac:22 |
| 192.168.1.108 | FLC Back | FLC Back [685C] | 24:5a:4c:a9:68:5c |
| 192.168.1.109 | East Door | East Door [2D7E] | 78:45:58:e5:2d:7e |
| 192.168.1.111 | Nursery-G3 Flex | Nursery-G3 Flex [A039] | d0:21:f9:90:a0:39 |
| 192.168.1.112 | FLC205B - G3 Flex 009A | FLC205B - G3 Flex [009A] | d0:21:f9:91:00:9a |
| 192.168.1.115 | Front Interior - Exit | Front Interior - Exit [F9DE] | 24:5a:4c:f4:f9:de |
| 192.168.1.116 | MWS Front | MWS Front [BC7C] | d0:21:f9:50:bc:7c |
| 192.168.1.117 | MWS Back - Exit | MWS Back - Exit [FB26] | 24:5a:4c:f4:fb:26 |
| 192.168.1.118 | East Door | East Door [A040] | d0:21:f9:90:a0:40 |
| 192.168.1.119 | FLC Back - Exit | FLC Back - Exit [FA9B] | 24:5a:4c:f4:fa:9b |
| 192.168.1.120 | MWS-E | MWS-E [5D5E] | d0:21:f9:91:5d:5e |
| 192.168.1.121 | FLC2H3 - G3 Flex F8BA | FLC2H3 - G3 Flex [F8BA] | d0:21:f9:90:f8:ba |
| 192.168.1.125 | West Door | West Door [67D1] | d0:21:f9:91:67:d1 |
| 192.168.1.130 | MWS Office Echo  | MWS Office Echo [9B8E] | 74:a7:ea:3c:9b:8e |
| 192.168.1.132 | MWS-W | MWS-W [599F] | d0:21:f9:91:59:9f |
| 192.168.1.136 | Front Interior | Front Interior [001E] | f4:e2:c6:d7:00:1e |
| 192.168.1.139 | Admin 1 | Admin 1 [A07D] | d0:21:f9:90:a0:7d |
| 192.168.1.140 | CrossOver - Max FDDB | CrossOver - Max [FDDB] | 68:d7:9a:7f:fd:db |
| 192.168.1.142 | FLC1H2 - G3 Flex FF14 | FLC1H2 - G3 Flex [FF14] | d0:21:f9:90:ff:14 |
| 192.168.1.145 | FP Interior - Entry | FP Interior - Entry [FD5E] | 24:5a:4c:f4:fd:5e |
| 192.168.1.147 | FLC Closets | FLC Closets [4867] | 0c:ea:14:fd:48:67 |
| 192.168.1.148 | Pura-B7A0 b7:a0 | Pura-B7A0 [B7A0] | b0:a7:32:c7:b7:a0 |
| 192.168.1.151 | East FP | East FP [5EE2] | d0:21:f9:91:5e:e2 |
| 192.168.1.153 | G3-Flex | G3-Flex [A08B] | d0:21:f9:90:a0:8b |
| 192.168.1.154 | FLC202 - Flex 3271 | FLC202 - Flex [3271] | 74:83:c2:bf:32:71 |
| 192.168.1.155 | MWS Printer | MWS Printer [2701] | f8:0d:ac:bc:27:01 |
| 192.168.1.158 | Front Interior - Entry | Front Interior - Entry [9006] | e4:38:83:b6:90:06 |
| 192.168.1.159 | iPhone 99:d1 | iPhone [99D1] | 94:bd:be:67:99:d1 |
| 192.168.1.160 | MWS Back | MWS Back [688C] | 24:5a:4c:a9:68:8c |
| 192.168.1.161 | FLC Gym | FLC Gym [BCAC] | d0:21:f9:50:bc:ac |
| 192.168.1.163 | MWS Back - Entry | MWS Back - Entry [FCDD] | 24:5a:4c:f4:fc:dd |
| 192.168.1.166 | West Kitchen | West Kitchen [615A] | d0:21:f9:91:61:5a |
| 192.168.1.167 | FLC Gym - Entry | FLC Gym - Entry [D198] | 84:78:48:b8:d1:98 |
| 192.168.1.168 | FLC204 - Flex 323F | FLC204 - Flex [323F] | 74:83:c2:bf:32:3f |
| 192.168.1.169 | 102 - Touch 32D6 | 102 - Touch [32D6] | 68:d7:9a:7f:32:d6 |
| 192.168.1.170 | flc2h1-g3-flex 22:28 | flc2h1-g3-flex [2228] | 58:a8:e8:1b:22:28 |
| 192.168.1.171 | FLC203 - Flex 3242 | FLC203 - Flex [3242] | 74:83:c2:bf:32:42 |
| 192.168.1.172 | Front Exterior | Front Exterior [CFD9] | 24:5a:4c:7f:cf:d9 |
| 192.168.1.174 | MWS 134 | MWS 134 [318A] | fc:49:2d:8b:31:8a |
| 192.168.1.175 | Family - Touch 3204 | Family - Touch [3204] | 68:d7:9a:7f:32:04 |
| 192.168.1.177 | FLC Back - Entry | FLC Back - Entry [E2C9] | 9c:05:d6:34:e2:c9 |
| 192.168.1.179 | FLC204 - G3 Flex FF3E | FLC204 - G3 Flex [FF3E] | d0:21:f9:90:ff:3e |
| 192.168.1.183 | MWS Front - Entry  | MWS Front - Entry [F990] | 78:45:58:f6:f9:90 |
| 192.168.1.185 | FLC201 - G3 Flex 8B31 | FLC201 - G3 Flex [8B31] | d0:21:f9:90:8b:31 |
| 192.168.1.186 | MWS Office Echo | MWS Office Echo [C5E5] | 00:71:47:9e:c5:e5 |
| 192.168.1.187 | EPSONEAB153 b1:53 | EPSONEAB153 [B153] | 38:1a:52:ea:b1:53 |
| 192.168.1.188 | MWS-N | MWS-N [59D5] | d0:21:f9:91:59:d5 |
| 192.168.1.195 | Foyer | Foyer [A0B5] | d0:21:f9:90:a0:b5 |
| 192.168.1.197 | MWS 131 | MWS 131 [4B7A] | 4c:17:44:2a:4b:7a |
| 192.168.1.201 | FLC205 - Flex B389 | FLC205 - Flex [B389] | 74:83:c2:bf:b3:89 |
| 192.168.1.204 | Front Exterior - Entry | Front Exterior - Entry [FCA6] | 24:5a:4c:9f:fc:a6 |
| 192.168.1.205 | Admin 2 | Admin 2 [66E3] | d0:21:f9:91:66:e3 |
| 192.168.1.206 | FP Exterior - Exit | FP Exterior - Exit [940B] | e4:38:83:b6:94:0b |
| 192.168.1.208 | FLC2H1 - G3 Flex FECE | FLC2H1 - G3 Flex [FECE] | d0:21:f9:90:fe:ce |
| 192.168.1.214 | Nursery - Flex 61C2 | Nursery - Flex [61C2] | 74:83:c2:bf:61:c2 |
| 192.168.1.218 | FP Exterior | FP Exterior [0CC9] | f4:e2:c6:d7:0c:c9 |
| 192.168.1.219 | FLC201 - Flex 32B0 | FLC201 - Flex [32B0] | 74:83:c2:bf:32:b0 |
| 192.168.1.220 | Front Exterior - Exit | Front Exterior - Exit [2C36] | f4:92:bf:34:2c:36 |
| 192.168.1.221 | East Door - Entry | East Door - Entry [FC5F] | f4:92:bf:7e:fc:5f |
| 192.168.1.222 | MWS Laptop | MWS Laptop [7659] | a4:6b:b6:f8:76:59 |
| 192.168.1.224 | MWS Interior - Exit | MWS Interior - Exit [99A6] | e4:38:83:b6:99:a6 |
| 192.168.1.225 | MWS 133 | MWS 133 [D066] | dc:54:d7:64:d0:66 |
| 192.168.1.226 | Touch 3420 | Touch [3420] | 68:d7:9a:7f:34:20 |
| 192.168.1.227 | Touch 339C | Touch [339C] | 68:d7:9a:7f:33:9c |
| 192.168.1.231 | Concourse | Concourse [68D3] | 24:5a:4c:a9:68:d3 |
| 192.168.1.232 | FLC1H3 - G3 Flex 002E | FLC1H3 - G3 Flex [002E] | d0:21:f9:91:00:2e |
| 192.168.1.233 | MWS 135 | MWS 135 [2FB8] | dc:54:d7:e9:2f:b8 |
| 192.168.1.241 | Finance Computer | Finance Computer [7588] | 6c:4b:90:ad:75:88 |
| 192.168.1.242 | Food Pantry - Touch 342C | Food Pantry - Touch [342C] | 68:d7:9a:7f:34:2c |
| 192.168.1.244 | Concourse - Entry | Concourse - Entry [E667] | 9c:05:d6:34:e6:67 |
| 192.168.1.249 | wlan0 46:d3 | wlan0 [46D3] | 7c:f6:66:fc:46:d3 |
| 192.168.1.251 | MWS 136 | MWS 136 [03FD] | dc:54:d7:cb:03:fd |
| 192.168.1.252 | Protect Viewport | Protect Viewport [3658] | d8:b3:70:8c:36:58 |
| 192.168.1.254 | FLC Gym - Exit | FLC Gym - Exit [5232] | 24:5a:4c:f2:52:32 |
| 192.168.10.12 | 02 - PINK | 02 - PINK [D075] | 1c:4d:66:a7:d0:75 |
| 192.168.10.29 | Thermostat Choir | Thermostat Choir [32A9] | 48:a2:e6:23:32:a9 |
| 192.168.10.31 | Thermostat Children | Thermostat Children [32AB] | 48:a2:e6:23:32:ab |
| 192.168.10.34 | Thermostat Concourse West | Thermostat Concourse West [32AE] | 48:a2:e6:23:32:ae |
| 192.168.10.35 | John's Office Echo | John's Office Echo [6774] | 00:f3:61:c2:67:74 |
| 192.168.10.36 | Thermostat Sanctuary East | Thermostat Sanctuary East [32B0] | 48:a2:e6:23:32:b0 |
| 192.168.10.39 | Thermostat Admin | Thermostat Admin [18B8] | 48:a2:e6:28:18:b8 |
| 192.168.10.66 | Thermostat FLC Upstairs | Thermostat FLC Upstairs [2D28] | 48:a2:e6:18:2d:28 |
| 192.168.10.84 | Thermostat FLC Downstairs | Thermostat FLC Downstairs [2D3A] | 48:a2:e6:18:2d:3a |
| 192.168.10.88 | Thermostat Gym East | Thermostat Gym East [2D3E] | 48:a2:e6:18:2d:3e |
| 192.168.10.102 | DESKTOP-4J2P8ET 8b:3f | DESKTOP-4J2P8ET [8B3F] | 3c:91:80:48:8b:3f |
| 192.168.10.125 | Thermostat Sanctuary West | Thermostat Sanctuary West [63B4] | 48:a2:e6:0f:63:b4 |
| 192.168.10.134 | Linux PC ae:d1 | Linux PC [AED1] | a0:d0:dc:bf:ae:d1 |
| 192.168.10.155 | 01 - RED | 01 - RED [0DF1] | 08:12:a5:67:0d:f1 |
| 192.168.10.168 | Thermostat Gym West | Thermostat Gym West [17B0] | 48:a2:e6:28:17:b0 |
| 192.168.10.173 | Sanctuary Echo 1 | Sanctuary Echo 1 [6E92] | 44:00:49:7c:6e:92 |
| 192.168.10.174 | Sanctuary Echo 2 | Sanctuary Echo 2 [F949] | 88:71:e5:f5:f9:49 |
| 192.168.10.208 | HS200 8a:8d | HS200 [8A8D] | 00:5f:67:d5:8a:8d |
| 192.168.10.224 | Thermostat MWS | Thermostat MWS [3273] | 48:a2:e6:23:32:73 |
| 192.168.10.248 | Thermostat Concourse East | Thermostat Concourse East [7EFD] | b8:2c:a0:a1:7e:fd |
| 192.168.10.250 | GatewayA26C23 6c:23 | GatewayA26C23 [6C23] | 48:a2:e6:a2:6c:23 |
| 192.168.20.6 | Apple iPad Air 2 9d:44 | Apple iPad Air 2 [9D44] | 52:2d:52:33:9d:44 |
| 192.168.20.29 | f6:21:87:b7:54:a4 | [54A4] | f6:21:87:b7:54:a4 |
| 192.168.20.39 | Amazon Echo Pop 88:8d | Amazon Echo Pop [888D] | 08:c2:24:4f:88:8d |
| 192.168.20.43 | 0a:13:8d:3c:d6:39 | [D639] | 0a:13:8d:3c:d6:39 |
| 192.168.20.62 | ea:c0:da:b6:94:8b | [948B] | ea:c0:da:b6:94:8b |
| 192.168.20.68 | Apple iPad Pro d2:9e | Apple iPad Pro [D29E] | 72:67:c1:56:d2:9e |
| 192.168.20.99 | Vizio P Series 09:52 | Vizio P Series [0952] | 00:bd:3e:c0:09:52 |
| 192.168.20.103 | 04 - BLUE | 04 - BLUE [9FF0] | 0c:ee:99:85:9f:f0 |
| 192.168.20.114 | CrossOver Camera Monitor | CrossOver Camera Monitor [F57B] | a0:6a:44:21:f5:7b |
| 192.168.20.115 | NPIC8F4FF fd:89 | NPIC8F4FF [FD89] | d4:6a:6a:1d:fd:89 |
| 192.168.20.133 | 4e:b8:7d:cc:6f:1c | [6F1C] | 4e:b8:7d:cc:6f:1c |
| 192.168.20.139 | Debra-s-S21-Ultra 45:9a | Debra-s-S21-Ultra [459A] | 86:ef:71:80:45:9a |
| 192.168.20.166 | Apple iPhone 33:b5 | Apple iPhone [33B5] | ce:25:e1:d9:33:b5 |
| 192.168.20.189 | DESKTOP-IRDRHGI f0:57 | DESKTOP-IRDRHGI [F057] | 9a:51:91:46:f0:57 |
| 192.168.20.191 | DESKTOP-IRDRHGI b8:2d | DESKTOP-IRDRHGI [B82D] | 8a:a3:22:8f:b8:2d |
| 192.168.20.192 | 22:a5:ea:b2:36:5f | [365F] | 22:a5:ea:b2:36:5f |
| 192.168.20.195 | 0e:31:a7:9a:57:15 | [5715] | 0e:31:a7:9a:57:15 |
| 192.168.20.219 | wlan0 75:90 | wlan0 [7590] | 38:1f:8d:74:75:90 |
| 192.168.20.229 | C5 3a:aa | C5 [3AAA] | 16:5f:61:fb:3a:aa |
| 192.168.20.236 | 03 - GREEN | 03 - GREEN [5274] | 1c:4d:66:1d:52:74 |

## unifi-home - Network (clients + devices)

| IP Address | Current Name | New Name | MAC |
|---|---|---|---|
| 99.122.140.237 | Dream Machine Pro | Dream Machine Pro [65AB] | d0:21:f9:66:65:ab |
| 192.168.0.6 | wlan0 9e:12 | wlan0 [9E12] | 10:d5:61:81:9e:12 |
| 192.168.0.9 | Bathroom Fan | Bathroom Fan [265E] | 38:1f:8d:07:26:5e |
| 192.168.0.13 | Hall 3 | Hall 3 [E350] | 38:1f:8d:03:e3:50 |
| 192.168.0.16 | Dishwasher | Dishwasher [49D8] | 38:1f:8d:04:49:d8 |
| 192.168.0.35 | GEModule850C 85:0c | GEModule850C [850C] | d8:28:c9:2f:85:0c |
| 192.168.0.39 | Aura-4115 8b:7d | Aura-4115 [8B7D] | 04:c2:9b:1a:8b:7d |
| 192.168.0.41 | Master Bedroom Lights | Master Bedroom Lights [8D38] | 40:f5:20:f0:8d:38 |
| 192.168.0.42 | Hall 1 | Hall 1 [E388] | 40:f5:20:f0:e3:88 |
| 192.168.0.43 | Bedroom 1 Lights | Bedroom 1 Lights [AED7] | 38:1f:8d:09:ae:d7 |
| 192.168.0.44 | wlan0 4f:51 | wlan0 [4F51] | 10:d5:61:12:4f:51 |
| 192.168.0.54 | ESP_0B79AD 79:ad | ESP_0B79AD [79AD] | 24:a1:60:0b:79:ad |
| 192.168.0.55 | Office Echo | Office Echo [AEA7] | 4c:53:fd:36:ae:a7 |
| 192.168.0.58 | Petkit_D4 1b:24 | Petkit_D4 [1B24] | 34:86:5d:5e:1b:24 |
| 192.168.0.63 | Breakfast Light | Breakfast Light [3B58] | 38:1f:8d:04:3b:58 |
| 192.168.0.65 | Doorbell | Doorbell [844F] | 34:3e:a4:d5:84:4f |
| 192.168.0.67 | Garage Lights | Garage Lights [31D3] | 38:1f:8d:04:31:d3 |
| 192.168.0.71 | Living Room AP - U6-LR | Living Room AP - U6-LR [70A6] | d0:21:f9:6b:70:a6 |
| 192.168.0.78 | Front Porch Lights | Front Porch Lights [E531] | 70:03:9f:cd:e5:31 |
| 192.168.0.80 | Amazon-Smart-Thermostat 53:71 | Amazon-Smart-Thermostat [5371] | 40:f6:bc:4b:53:71 |
| 192.168.0.81 | Living Room Fan | Living Room Fan [8E96] | 70:03:9f:ce:8e:96 |
| 192.168.0.88 | Dining Room Dot | Dining Room Dot [3F2D] | 08:a6:bc:d2:3f:2d |
| 192.168.0.93 | Mistys-Air-2 6e:7e | Mistys-Air-2 [6E7E] | f8:ff:c2:32:6e:7e |
| 192.168.0.98 | Attic Dot | Attic Dot [861E] | 50:dc:e7:7b:86:1e |
| 192.168.0.99 | Ring Chime cb:46 | Ring Chime [CB46] | 9c:76:13:dd:cb:46 |
| 192.168.0.101 | Apple iPad Pro 12.9 (2nd Gen) 54:86 | Apple iPad Pro 12.9 (2nd Gen) [5486] | 8a:b4:fb:9f:54:86 |
| 192.168.0.108 | Office Lights | Office Lights [7A8F] | 10:5a:17:f3:7a:8f |
| 192.168.0.114 | Govee Lyra 3d:ad | Govee Lyra [3DAD] | 98:17:3c:01:3d:ad |
| 192.168.0.124 | Disposal | Disposal [40C4] | 10:5a:17:f7:40:c4 |
| 192.168.0.125 | wlan0 4e:1b | wlan0 [4E1B] | 10:d5:61:12:4e:1b |
| 192.168.0.129 | wlan0 bd:4b | wlan0 [BD4B] | 38:1f:8d:72:bd:4b |
| 192.168.0.130 | iPhone 5f:66 | iPhone [5F66] | 2a:e3:e1:04:5f:66 |
| 192.168.0.131 | Kitchen Echo Show | Kitchen Echo Show [D9EB] | d4:91:0f:07:d9:eb |
| 192.168.0.134 | iPhone 8c:d2 | iPhone [8CD2] | 26:73:ff:93:8c:d2 |
| 192.168.0.136 | Leak Sensor Hub | Leak Sensor Hub [346F] | d8:8b:4c:fe:34:6f |
| 192.168.0.137 | Garage Door Opener | Garage Door Opener [7DAB] | 20:57:9e:52:7d:ab |
| 192.168.0.138 | ESP_F923A8 23:a8 | ESP_F923A8 [23A8] | 40:f5:20:f9:23:a8 |
| 192.168.0.141 | Fireplace Light | Fireplace Light [78B9] | 70:03:9f:ce:78:b9 |
| 192.168.0.146 | Master Bath Lights | Master Bath Lights [BCE3] | 70:03:9f:cd:bc:e3 |
| 192.168.0.149 | Stereo Right | Stereo Right [59C9] | e8:d8:7e:51:59:c9 |
| 192.168.0.154 | Bedroom - Nano HD | Bedroom - Nano HD [6D4E] | b4:fb:e4:26:6d:4e |
| 192.168.0.160 | Hall 2 | Hall 2 [EA2E] | 38:1f:8d:72:ea:2e |
| 192.168.0.165 | wlan0 18:30 | wlan0 [1830] | 38:1f:8d:74:18:30 |
| 192.168.0.168 | Entryway Lights | Entryway Lights [33CF] | 40:f5:20:e7:33:cf |
| 192.168.0.171 | Bedroom Two Clock Dot | Bedroom Two Clock Dot [CA44] | 80:0c:f9:c9:ca:44 |
| 192.168.0.176 | ESP_3D87E5 87:e5 | ESP_3D87E5 [87E5] | f4:cf:a2:3d:87:e5 |
| 192.168.0.179 | Watch 9d:d3 | Watch [9DD3] | 3e:1e:48:44:9d:d3 |
| 192.168.0.183 | wlan0 6b:6f | wlan0 [6B6F] | 1c:90:ff:a4:6b:6f |
| 192.168.0.190 | USW Lite 8 PoE | USW Lite 8 PoE [9A50] | d0:21:f9:4d:9a:50 |
| 192.168.0.191 | Master Bath Fan | Master Bath Fan [5F2F] | 40:f5:20:eb:5f:2f |
| 192.168.0.193 | Bathroom Lights | Bathroom Lights [40A5] | 38:1f:8d:17:40:a5 |
| 192.168.0.195 | wlan0 4a:51 | wlan0 [4A51] | fc:67:1f:af:4a:51 |
| 192.168.0.201 | Kitchen Light | Kitchen Light [71D0] | 38:1f:8d:76:71:d0 |
| 192.168.0.202 | Living-Room 4f:c2 | Living-Room [4FC2] | ec:a9:07:02:4f:c2 |
| 192.168.0.209 | Bedroom 2 Lights | Bedroom 2 Lights [BC07] | 10:5a:17:f2:bc:07 |
| 192.168.0.213 | 1421home 5e:5c | 1421home [5E5C] | 9c:7b:ef:b8:5e:5c |
| 192.168.0.215 | wlan0 dd:ba | wlan0 [DDBA] | 84:e3:42:e6:dd:ba |
| 192.168.0.217 | My Bedroom Echo Plus | My Bedroom Echo Plus [D4FD] | 08:a6:bc:53:d4:fd |
| 192.168.0.219 | wlan0.localdomain 47:a0 | wlan0.localdomain [47A0] | 38:1f:8d:5b:47:a0 |
| 192.168.0.220 | Living Room  Lights | Living Room  Lights [9474] | 70:03:9f:ce:94:74 |
| 192.168.0.227 | Sink Light | Sink Light [6794] | 10:5a:17:f3:67:94 |
| 192.168.0.228 | LGwebOSTV 21:ce | LGwebOSTV [21CE] | 64:cb:e9:3c:21:ce |
| 192.168.0.229 | Epson_ET-2800 | Epson_ET-2800 [4A66] | 58:05:d9:3c:4a:66 |
| 192.168.0.232 | Master Bath Toilet Lights | Master Bath Toilet Lights [4BEB] | 40:f5:20:f1:4b:eb |
| 192.168.0.233 | Stereo Left | Stereo Left [1A75] | e8:d8:7e:2f:1a:75 |
| 192.168.0.235 | Back Porch Lights | Back Porch Lights [45F5] | 10:5a:17:f7:45:f5 |
| 192.168.0.243 | Garage Dot | Garage Dot [30B4] | 5c:41:5a:5e:30:b4 |
| 192.168.0.244 | Insignia Smart TV 08:36 | Insignia Smart TV [0836] | a8:2c:3e:9c:08:36 |
| 192.168.0.248 | roborock-vacuum-a168 0f:b7 | roborock-vacuum-a168 [0FB7] | 24:9e:7d:69:0f:b7 |
| 192.168.0.253 | Living Room Dot | Living Room Dot [122E] | cc:f7:35:96:12:2e |
| 192.168.3.10 | 1421mcp 7a:ff | 1421mcp [7AFF] | 88:a2:9e:a4:7a:ff |

## unifi-church-nvr - Protect (cameras + viewers)

All 25 cameras and 2 viewers were renamed successfully via MCP (the Protect MCP exposes an `update` action with a `name` field). No manual action needed.

Renamed:

- Admin1 - G3 Flex [A07D]
- Admin2 - G3 Flex [66E3]
- Admin3 - G3 Flex [A08B]
- EastConcourse - G3 Flex [6094]
- EastDoor - G3 Flex [A040]
- EastFP - G3 Flex [5EE2]
- FLC1H1 - G3 Flex [FA94]
- FLC1H2 - G3 Flex [FF14]
- FLC1H3 - G3 Flex [002E]
- FLC2H1 - G3 Flex [FECE]
- FLC2H2 - G3 Flex [F861]
- FLC2H3 - G3 Flex [F8BA]
- FLC201 - G3 Flex [8B31]
- FLC202 - G3 Flex [F9DA]
- FLC203 - G3 Flex [F87B]
- FLC204 - G3 Flex [FF3E]
- FLC205A - G3 Flex [008B]
- FLC205B - G3 Flex [009A]
- Foyer - G3 Flex [A0B5]
- MWS-E - G3 Flex [5D5E]
- MWS-N - G3 Flex [59D5]
- MWS-W - G3 Flex [599F]
- Nursery - G3 Flex [A039]
- WestConcourse - G3 Flex [49FC]
- WestDoor - G3 Flex [67D1]
- WestKitchen - G3 Flex [615A]
- FLCXovr - ViewPort [3658]
- Admin ViewPort [3BB6]
