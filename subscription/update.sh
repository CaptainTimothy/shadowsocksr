#! /bin/sh

CURRENT_DIR=$(cd "$(dirname "$0")";pwd)

echo -e "\033[32m\033[01mget-link.sh\033[0m"
echo '--------------------------------------------------------------'
/bin/sh $CURRENT_DIR/get-link.sh
if [ "$?" != 0 ]
then
        exit 99
fi
echo -e "\033[32m\033[01mtest-delay.sh\033[0m"
echo '--------------------------------------------------------------'
/bin/sh $CURRENT_DIR/test-delay.sh
echo -e "\033[32m\033[01mcreate-conig.sh\033[0m"
echo '--------------------------------------------------------------'
/bin/sh $CURRENT_DIR/create-config.sh
echo -e "\033[32m\033[01mreplace-config.sh\033[0m"
echo '--------------------------------------------------------------'
/bin/sh $CURRENT_DIR/replace-config.sh
