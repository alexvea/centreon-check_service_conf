# FOR TESTS ONLY

## Description :

Check command that will check if configuration files has been modified compared to the service last restart.

## Prerequisites :

* Only work with service managed by systemctl.

## How to use : 

## Help :
```
./check_service.sh --help
This script will help to check if a service needs to be restarted because conf files where modified
Syntax: --service SYSTEMCTL_SERVICE_NAME (--file PATH_FILE|--folder PATH_FOLDER) [--help|--nagios-output|--verbose]

Options:
--help                  Print this help.
--service               Specify a service managed by systemctl.
                        ie: --service centengine
--file                  Specify the service conf file path.
                        ie: --file /etc/centreon-engine/centengine.cfg
--folder                Specify the service confs folder path.
                        ie: --folder /etc/centreon-engine
--verbose               Display more informations.
--nagios        Display the nagios output.

```

## Functionnalities :


* Work with one configuration file (--file) or configuration files from a folder (--folder).
* Compare timestamp of last service restart and configuration file modification.
* Provide verbose output (--verbose).
* Provide nagios output (--output).
* 3 types of output : OK, WARNING, CRITITAL.

  1. OK when no file has been modified after the last service restart.
  2. WARNING when one or more files has been modified after the last service restart.
  3. CRITICAL when no files has been checked.

## Example :
Restart the centengine via systemctl and check the conf files from /etc/centreon-engine/ : 
```
# systemctl restart centengine
# ./check_service.sh   --service centengine --folder /etc/centreon-engine/
No need to restart the service 'centengine'. All files are older than the last restart.
```
Export centengine configuration from CLAPI : 
```
# centreon -u admin -p 'Centreon$321' -a CFGMOVE -v 1
OK: All configuration files copied with success.
Return code end : 0
```
Normal check : 
```
# ./check_service.sh   --service centengine --folder /etc/centreon-engine/
The service 'centengine' needs to be restarted because some files were modified after the last restart.
```
Using --verbose option :
```
# ./check_service.sh   --service centengine --folder /etc/centreon-engine/ --verbose
/etc/centreon-engine//centengine.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-command.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-contactgroups.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-contacts.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-dependencies.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-escalations.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-host.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-services.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//centreon-bam-timeperiod.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//commands.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//conf.d is older than the service restart (modified: 2024-09-13 11:59:31)
/etc/centreon-engine//connectors.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//contactgroups.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//contacts.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//dependencies.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//escalations.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//hostgroups.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//hosts.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//hostTemplates.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//meta_commands.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//meta_host.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//meta_services.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//meta_timeperiod.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//plugins.json was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//resource.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//servicegroups.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//services.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//serviceTemplates.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//severities.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//tags.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
/etc/centreon-engine//timeperiods.cfg was modified after the service restart (modified: 2024-11-21 13:22:53)
Service centengine last restarted at: 2024-11-21 13:22:18
```
Using --nagios option : 
```
# ./check_service.sh   --service centengine --folder /etc/centreon-engine/ --nagios
WARNING - Some configuration files have been modified after the service restart. | files_checked=31 files_modified=30
```
Restart centengine via CLAPI : 
```
# centreon -u admin -p 'Centreon$321' -a POLLERRESTART -v 1
OK: A restart signal has been sent to 'Central'
Return code end : 0
```
Check again using --nagios option : 
```
# ./check_service.sh   --service centengine --folder /etc/centreon-engine/ --nagios
OK - All configuration files are older than the service restart. | files_checked=31 files_modified=0
```
