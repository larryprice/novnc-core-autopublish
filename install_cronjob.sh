#!/bin/bash

if [ ! -f $PWD/autopublish.sh ]; then
  echo "This script must be run from the directory containing autopublish.sh"
  exit 1
fi

echo "Installing as local daily cron job in ${HOME}/.anacron/cron.daily"
if [ ! -d $HOME/.anacron/cron.daily ]; then
  echo "This may require some additional setup on your end to run anacron as ${USER}, see README.md"
  mkdir -p $HOME/.anacron/cron.daily/
fi

# Create a new script which redirects all output to a logfile
INSTALLED_SCRIPT="${HOME}/.anacron/cron.daily/noVNC-core-autopublish"
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
