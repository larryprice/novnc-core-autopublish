# novnc-core-autopublish
Autopublisher for [novnc-core](https://github.com/larryprice/novnc-core)

### Usage ###

You'll want an `anacron` that runs as your user (with Github creds, npm creds). The setup for this (as adapted from [grinux.wordpress.com](https://grinux.wordpress.com/2012/04/18/run-anacron-as-user/):

``` bash
$ cd ~
$ mkdir .anacron
$ cd .anacron/
$ mkdir cron.daily cron.weekly cron.monthly spool etc
$ vim etc/anacrontab
```

Inside the `$HOME/.anacron/etc/anacrontab`:

```
# See anacron(8) and anacrontab(5) for details.
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# These replace cron's entries
1 5 daily-cron nice run-parts --report $HOME/.anacron/cron.daily
7 10 weekly-cron nice run-parts --report $HOME/.anacron/cron.weekly
@monthly 15 monthly-cron nice run-parts --report $HOME/.anacron/cron.monthly
```

Run `crontab -e` from a terminal and add the following to the bottom to run your local anacron hourly:

``` bash
0 *   * * * anacron -t $HOME/.anacron/etc/anacrontab -S $HOME/.anacron/spool &> $HOME/.anacron/anacron.log
```

Finally, to install autopublish as a cronjob:

``` bash
$ install_cronjob.sh
```

By default, this will install a weekly cronjob. If you want the job to run daily, use the `--daily` flag. If you want it to run monthly, use `--monthly`.
