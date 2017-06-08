#!/bin/bash

CRON_DIR="cron.weekly"
for i in "$@"; do
  case $i in
    -d|--daily)
      CRON_DIR="cron.daily"
      ;;
    -m|--monthly)
      CRON_DIR="cron.monthly"
      ;;
    --debug)
      AUTOPUBLISH_DEBUG="1"
      ;;
  esac
done

if [ -n "$AUTOPUBLISH_DEBUG" ]; then
  set -x
fi

if [ ! -f $PWD/autopublish.sh ]; then
  echo "This script must be run from the directory containing autopublish.sh"
  exit 1
fi

FULL_CRON_PATH="${HOME}/.anacron/${CRON_DIR}"
echo "Installing as local weekly cron job in ${FULL_CRON_PATH}"
if [ ! -d $FULL_CRON_PATH ]; then
  echo "This may require some additional setup on your end to run anacron as ${USER}, see README.md"
  mkdir -p $FULL_CRON_PATH
fi

echo "Removing old installed autopublish jobs"
find ${HOME}/.anacron/ -name noVNC-core-autopublish | xargs rm

# Create a new script which redirects all output to a logfile
INSTALLED_SCRIPT="${FULL_CRON_PATH}/noVNC-core-autopublish"
echo "#!/bin/bash" > $INSTALLED_SCRIPT
echo >> $INSTALLED_SCRIPT
# Use nvm if installed
echo "export NVM_DIR=${HOME}/.nvm" >> $INSTALLED_SCRIPT
echo "[ -s ${NVM_DIR}/nvm.sh ] && . $NVM_DIR/nvm.sh" >> $INSTALLED_SCRIPT
# Run script from this directory
echo "${PWD}/autopublish.sh &> /tmp/noVNC-core-autopublish.log" >> $INSTALLED_SCRIPT
chmod 755 $INSTALLED_SCRIPT

echo
echo "Installation complete"
echo "Autopublish logs will be found at /tmp/noVNC-core-autopublish.log"

