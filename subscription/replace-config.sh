#! /bin/sh

WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrSubUpd
SSR_PATH=$(cd "$(dirname "$0")/../";pwd)

# Replace old config
if [ -f "$SSR_PATH/user-config.json.old" ]
then
	rm $SSR_PATH/user-config.json.old
fi
mv $SSR_PATH/user-config.json $SSR_PATH/user-config.json.old

if [ "$1" = '' ]
then
    cp $WORK_PATH/json/$(ls $WORK_PATH/json/) $SSR_PATH/user-config.json
else
	cp $WORK_PATH/json/$1.json $SSR_PATH/user-config.json
	exit 0
fi

# Remove temporary files.
rm -rf $WORK_PATH
