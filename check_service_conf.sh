#!/bin/bash

verbose=0
exit_status=0
files_checked=0
files_modified=0
nagios_output_flag=0

# Function to display the script help
help_output()
{
   # Display Help
   echo "This script will help to check if a service needs to be restarted because conf files where modified"
   echo "Syntax: --service SYSTEMCTL_SERVICE_NAME (--file PATH_FILE|--folder PATH_FOLDER) [--help|--nagios-output|--verbose]"
   echo
   echo "Options:"
   echo "--help                 Print this help."
   echo "--service              Specify a service managed by systemctl."
   echo "                       ie: --service SYSTEMCTL_SERVICE_NAME"
   echo "--file                 Specify the service conf file path."
   echo "                       ie: --file PATH_FILE"
   echo "--folder               Specify the service confs folder path."
   echo "                       ie: --folder PATH_FOLDER"
   echo "--verbose              Display more informations."
   echo "--nagios-output        Display the nagios output."
   echo
   exit
}

# Function to check the last modification time of file(s)
check_modification_time() {
  local path="$1"
  local service_restart_time="$2"

  # Check if it's a folder or a single file
  if [ -d "$path" ]; then
    # For folders, check all files inside
    for file in "$path"/*; do
      file_mod_time=$(stat -c %Y "$file")
      compare_time "$file" "$file_mod_time" "$service_restart_time"
    done
  elif [ -f "$path" ]; then
    # For single file
    file_mod_time=$(stat -c %Y "$path")
    compare_time "$path" "$file_mod_time" "$service_restart_time"
  else
    echo "Invalid file or directory: $path"
    exit_status=2
  fi
}

# Function to compare file modification time with service restart time
compare_time() {
  local file="$1"
  local file_mod_time="$2"
  local service_restart_time="$3"
  local file_mod_time_human

  # Convert the modification time to a human-readable format
  file_mod_time_human=$(date -d @"$file_mod_time" '+%Y-%m-%d %H:%M:%S')

  files_checked=$((files_checked+1))

  if [ "$file_mod_time" -gt "$service_restart_time" ]; then
    files_modified=$((files_modified+1))
    [ "$verbose" -eq 1 ] && echo "$file was modified after the service restart (modified: $file_mod_time_human)"
    exit_status=1
  else
    [ "$verbose" -eq 1 ] && echo "$file is older than the service restart (modified: $file_mod_time_human)"
  fi
}

# Function to format the Nagios output
nagios_output() {
  local exit_status="$1"
 
  case $exit_status in
    0)
      echo "OK - All configuration files are older than the service restart. | files_checked=$files_checked files_modified=$files_modified"
      ;;
    1)
      echo "WARNING - Some configuration files have been modified after the service restart. | files_checked=$files_checked files_modified=$files_modified"
      ;;
    2)
      echo "CRITICAL - Service or files are not valid. | files_checked=$files_checked files_modified=$files_modified"
      ;;
    *)
      echo "UNKNOWN - An error occurred. | files_checked=$files_checked files_modified=$files_modified"
      ;;
  esac
}

[[ "$#" -eq 0 ]] && help_output
# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --service) service="$2"; shift ;;
    --file) file="$2"; shift ;;
    --folder) folder="$2"; shift ;;
    --nagios-output) nagios_output_flag=1 ;;
    --verbose) verbose=1 ;;
    --help) help_output ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Get the service restart time
service_restart_time=$(systemctl show -p ExecMainStartTimestamp --value "$service")
service_restart_time=$(date --date="$service_restart_time" +%s)
service_restart_time_human=$(date -d @"$service_restart_time" '+%Y-%m-%d %H:%M:%S')


# Check files or folders
if [ -n "$file" ]; then
  check_modification_time "$file" "$service_restart_time"
elif [ -n "$folder" ]; then
  check_modification_time "$folder" "$service_restart_time"
else
  echo "No file or folder provided."
  exit 1
fi

  # Output for Nagios if requested
  if [ "$nagios_output_flag" -eq 1 ]; then
    nagios_output "$exit_status"
  fi

# If not using --verbose or --nagios-output, provide a simple summary
if [ "$nagios_output_flag" -ne 1 ] && [ "$verbose" -ne 1 ]; then
  if [ "$exit_status" -eq 1 ]; then
    echo "The service '$service' needs to be restarted because some files were modified after the last restart."
  elif [ "$exit_status" -eq 0 ]; then
    echo "No need to restart the service '$service'. All files are older than the last restart."
  fi
fi
# Show the service restart time in verbose mode
[ "$verbose" -eq 1 ] && echo "Service '$service' last restarted at: $service_restart_time_human"
