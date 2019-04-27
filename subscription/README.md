# SSR Subscription updater and "ssr://" link importer for Linux

## Usage

### Import "ssr://" link
Use `update.sh` to import your link with following command:

    /bin/sh ./update.sh 'ssr://exAmpLeSSrLink=='

Then, your config file will be updated, and the old config file will rename to `user-config.json.bak`.

### Update Subscription
First, ensure you have `bc` installed on your system. Use `whereis bc` to find out if you're not sure.
Then, decompress "updateSubscription.tar.gz" and put updateSubscription directory into your "shadoesocksr" directory, it should look like this:

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
	└── user-config.json

Put your subscription link in "updateSubscription.lst" line-by-line. *(Doesn't support comment or other things... for now.)*\
Remember to remove the example link, it won't work at all. \
It should look like this:

	https;//link1.com/link
	https://link2.com/link
	https://link3.com/link
	...

Now, you are ready to use those scripts to update your subscriptions :)

## Note

**For most users, just use "update.sh" to update and replace your config.**

## Purpose of those files

|File             |Uses|
|:------------------|:----------------------------------------------------------------------------------------------------------------------------|
|get-link.sh        |Read updateSubscription.lst file and get all subscriptioned "ssr://" link(s).|
|create-config.sh   |Decode those "ssr://" links and process them to shadowsocksr's json file(s).|
|test-delay.sh      |Test all your subscriptioned nodes' latency and keep the one which has the minimum latency.|
|replace-config.sh  |Replace your original "user-config.json" with "test-delay.sh" given json, and backup your original json as "user-config.bak".|
|importLink.sh      |Import single "ssr://" link, should use with your link as a parameter. It should looks like: **./importLink.sh 'ssr://*'**|
