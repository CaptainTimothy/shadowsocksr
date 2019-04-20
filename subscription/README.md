# SSR Subscription updater and "ssr://" link importer for Linux

##usage

First, decompress "updateSubscription.tar.gz" and put updateSubscription directory into your "shadoesocksr" directory, it should look like this:

	shadowsocksr
	├── updateSubscription
	│   ├── create─config.sh
	│   ├── get─link.sh
	│   ├── importLink.sh
	│   ├── README.md
	│   ├── replace─config.sh
	│   ├── subscription.lst
	│   ├── test─delay.sh
	│   └── update.sh
	├── ...
	├── user-config.json
	└── user-config.json.bak

Then, put your subscription link in "updateSubscription.lst" line-by-line.
It should look like this:

	https;//link1.com/link
	https://link2.com/link
	https://link3.com/link
	...

Now, you are ready to use those scripts to update your subscriptions :)

## Note

**For most users, just use "update.sh" to update and replace your config automatically.**

> You may find a lot of "base64: invalid input", just ignore them because most subscription links don't have "=" at the end.

## Purpose of those files

|File             |Uses|
|:------------------|:----------------------------------------------------------------------------------------------------------------------------|
|get-link.sh        |Read updateSubscription.lst file and get all subscriptioned "ssr://" link(s).|
|create-config.sh   |Decode those "ssr://" links and process them to shadowsocksr's json file(s).|
|test-delay.sh      |Test all your subscriptioned nodes' latency and keep the one which has the minimum latency.|
|replace-config.sh  |Replace your original "user-config.json" with "test-delay.sh" given json, and backup your original json as "user-config.bak".|
|importLink.sh      |Import single "ssr://" link, should use with your link as a parameter. It should looks like: **./importLink.sh 'ssr://*'**|
