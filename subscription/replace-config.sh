#! /bin/sh

WORK_PATH=$(cd "$(dirname "$0")";pwd)/ssrSubUpd
SSR_PATH=$(cd "$(dirname "$0")/../";pwd)

# Replace old config
if [ -f "$SSR_PATH/user-config.json.old" ]
then
	rm $SSR_PATH/user-config.json.old
fi
mv $SSR_PATH/user-config.json $SSR_PATH/user-config.json.old
cp $WORK_PATH/json/*.json $SSR_PATH/user-config.json

# Remove temporary files.
rm -rf $WORK_PATH
