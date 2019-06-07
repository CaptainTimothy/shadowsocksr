# SSR Subscription updater and "ssr://" link importer for Linux

## Dependencies
        - python modules
            - wcwidth
            - tabulate

        - linux package
            - bc

## Usage

### Import "ssr://" link
Use `import.sh` to import your link with following command:

    /bin/sh ./import.sh 'ssr://exampleSsrLink=='

Then, your config file will be updated, and the old config file will rename to `user-config.json.bak`.

### Update Subscription
Decompress `updateSubscription.tar.gz` and put updateSubscription directory into your `shadoesocksr` directory, it should look like this:

	shadowsocksr
	├── subscription
	│   ├── create─config.sh
	│   ├── exclude.lst
	│   ├── get─link.sh
	│   ├── import.sh
	│   ├── print-delay.py
	│   ├── print-nodes.py
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

    # this is a commit
	https://link1.com/link
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
|import.sh      |Import single "ssr://" link, should use with your link as a parameter. It should looks like: `./import.sh 'ssr://*'`|

## Change Log
#### 04.21.2019
> - Forked project
> - Add this tool for update subscription

#### 04.27.2019
> - Node sort Bug fixed

#### 05.20.2019
> - README.md error fixed
> - Add commit support for link list (with "#")

#### 06.03.2019
> - Add Change Log
> - User interface got update
> - Fixed link with `_` and `-` could not be correctly decode
> - Fixed "ssr://" link import issue

#### 06.05.2019
> - Fatal logic error fixed
> - "ssr://" link import issue fixed
> - Python script get wrong path issue fixed
> - Rename `importLink.sh` to `import.sh`
> - Update user interface

#### 06.05.2019
> - Add ignore server list, filter by server address
> - Removed some sensetive data

#### 06.08.2019
> - Fix commit issue
