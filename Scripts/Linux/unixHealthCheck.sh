# Project   : UnixHealthCheck
# Usecase   : Script to perform health-check Unix based systems
# Author    : Sounak 'St4rr3h' Roy
# Email     : mail.roy.sounak@gmail.com
# Github    : www.github.com/sounak-starreh-roy
# LinkedIn  : www.linkedin.com/in/roy-sounak
# Copyright : Free
# Licence   : GNU General Public Licence v3.0

#!/bin/bash

# Getting Today's Date
dt=`date +"%d-%m-%Y"`

# Making The Destination Folder For Output, If I Doesnot Exist

# Making The Report Output File
echo -e """
Report of the HealthCheck for Linux Based Node as of $dt
""" > /home/starreh/health_check/report/report_$dt.txt

# Making The Log Output File
echo -e """
Logs of the HealthCheck for Linux Based Node as of $dt
""" > /home/starreh/health_check/report/log_$dt.txt

# Giving Read Permissions To The Report and Log File
chmod 444 /home/starreh/health_check/report/report_$dt.txt
chmod 444 /home/starreh/health_check/report/log_$dt.txt

# Getting Node Information For Report File
echo -e """
====================================================
Health Check Automation For Linux Nodes
====================================================

Hostname : `hostname`
Operating System : `uname`
Kernel Version : `uname -r`
Last Reboot Time : `uptime | awk -F" "  '{print $3,$4}' | sed  -e 's/,//g'`
User : `whoami`

====================================================
""" >> /home/starreh/health_check/report/report_$dt.txt

# Getting Node Information For Log File
cat /home/starreh/health_check/report/report_$dt.txt >> /home/starreh/health_check/report/log_$dt.txt


# Defining methods to call the health check commands

# Commands For CPU Load 
function cpu_load {

        # mpstat
        echo -e """
        Command : mpstat
        """
        var_mpstat=`which mpstat`
        var_mpstat=$?
        if [ $var_mpstat != 0 ]
        then
                echo "mpstat : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install sysstat"
                echo "On RHEL Based Systems : yum install sysstat"
				echo "===================================================="
        else
                if [[ ` mpstat | awk -F" " '{print $13}' | tail -1` < 30 ]]
                then
                        echo "CPU Idle % is less than 30%, Please contact SysAdmin"
                        echo "===================================================="
                else
                        echo "System is running fine"
                        echo "===================================================="
                fi
        fi

        # lscpu
        echo -e """
        Command : lscpu
        """
        var_lscpu=`which lscpu`
        var_lscpu=$?
        if [ $var_lscpu != 0 ]
        then
                echo "lscpu : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install lscpu"
                echo "On RHEL Based Systems : yum install lscpu"
                echo "===================================================="
        else
                cpu_num=`lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}'`
                counter=0
                while [ $counter -lt $cpu_num ]
                do
                        cpu_use=`mpstat -P ALL | awk -v var=$cpu_num '{ if ($3 == var ) print $4 }'`
                        if [[ cpu_use > 75 ]]
                        then	
                                echo "CPU Usage is more than 75% on CPU Number $cpu_num, Please Contact SysAdmin"
                                echo "===================================================="
                        else
                                echo "CPU Usage is running within NORMAL range"
                                echo "===================================================="
                        fi
                done
        fi
		
		# iostat
		echo -e """
		Command : iostat
		"""
		var_iostat=`which iostat`
		var_iostat=$?
		if [ $var_iostat != 0 ]
		then
				echo "iostat : Command not found, Please install"
				echo "On Debian Based Systems : sudo apt-get install iostat"
				echo "On RHEL Based Systems : yum install iostat"
                echo "===================================================="
		else
				if [[ `iostat | sed '1,3d' | awk -F" " '{print $6}' | head -1` < 30 ]]
				then
						echo "CPU Idle % is less than 30%"
						echo "===================================================="
                else
                        echo "System is running fine"
                        echo "===================================================="
                fi
		fi
		
		# sar 
		echo -e """
		Command : sar
		"""
		var_sar=`which sar`
		var_sar=$?
		if [ $var_sar != 0 ]
		then
				echo "sar : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install sar"
                echo "On RHEL Based Systems : yum install sar"
                echo "===================================================="
		else
				if [[ `sar | grep -i "average" | awk -F" " '{print $8}'` < 80 ]]
				then
						echo "CPU Idle % is less than 80%"
						echo "===================================================="
                else
                        echo "System is running fine as per sar"
                        echo "===================================================="
                fi
		fi
}


# Commands For Memory Management
function mem_mgmt {
		
		# top
		echo -e """
		Command : top
		"""
		var_top=`which top`
		var_top=$?
		if [ $var_top != 0 ]
		then
				echo "top : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install top"
                echo "On RHEL Based Systems : yum install top"
                echo "===================================================="
		else
				if [ `top | head -1 | awk -F 'load average: ' '{print $2}' | tr ', ' '\n'| sed '/^$/d'| awk -F ' ' '$1>3{print $1}'| wc -l` != 0 ]
				then
						echo "Load Average > 3"
				else
						echo "Load Average < 3"
				fi
				
				if [ `top b -n1 | head -17 | tail -11 | awk -F ' ' '$9>80{print $0}'| wc -l` != 0 ]
				then
						echo "CPU Usage is > 80%"
				else
						echo "CPU Usage is < 80%"
				fi
				
				if [ `top b -n1 | head -17 | tail -11 | awk -F ' ' '$10>80{print $0}'| wc -l` != 0 ]
				then
						echo "MEMORY Usage > 80%"
				else
						echo "MEMORY Usage < 80%"
						echo "===================================================="
				fi
		fi
		
		# free -m
		echo -e """
		Command : free -m
		"""
		var_free=`free`
		var_free=$?
		if [  $var_free != 0 ]
		then
				echo "free : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install free"
                echo "On RHEL Based Systems : yum install free"
                echo "===================================================="
		else
				mem=`free -m | grep -vi "total" | grep -i "Mem"`
				swap=`free -m | grep -vi "total" | grep -i "Swap"`
				
				if [[ `echo $mem | awk -F" " '{print $4}' | sed 's/G//g'` -lt 2 ]]
				then
						echo "MEMORY Usage is more than Threshould"
				else
						echo "MEMORY Usage is under the Threshould"
				fi

				if [[ `echo $swap | awk -F" " '{print $4}' | sed 's/G//g'` -lt 2 ]]
				then
					echo "SWAP MEMORY Usage is more than Threshould"
				else
					echo "SWAP MEMORY Usage is less than Threshould"
					echo "===================================================="
				fi
		fi
		
		# vmstat
		echo -e """
		Command : vmstat
		"""
		var_vmstat=`which vmstat`
		var_vmstat=$?
		if [ $var_vmstat != 0 ]
		then
				echo "vmstat : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install vmstat"
                echo "On RHEL Based Systems : yum install vmstat"
                echo "===================================================="
		else
				if [[ `vmstat -S M | egrep -vi "system|free" | awk -F" " '{print $4}'` < 2048 ]]
				then
						echo "FREE MEMORY below Threshould"
						echo "===================================================="
				else
						echo "FREE MEMORY above Threshould"
						echo "===================================================="
				fi
		fi
		
		# cat /proc/meminfo
		echo -e """
		Command : cat /proc/meminfo
		"""
		cat /proc/meminfo
		echo "===================================================="
}


# Commands For Disk Usage Management
function disk_usage {

		# df
		echo """
		Command : df 
		"""
		var_df=`which df`
		var_df=$?
		if [ $var_df != 0 ]
		then
				echo "df : Command not found, Please install"
                echo "On Debian Based Systems : sudo apt-get install df"
                echo "On RHEL Based Systems : yum install df"
                echo "===================================================="
		else
				df -Pkh | grep -vi "filesystem" > /home/starreh/health_check/output/temp.txt
				IFS=$'\n';
				for i in `cat /home/starreh/health_check/output/temp.txt`;
				do
						mem_use=`echo $i | awk -F" " '{print $5}' | sed 's/%//g'`
						if [[ $mem_use -gt  75 ]]
						then
								deviation=`echo -e "$i" | awk -F" " '{print $1}'`
								echo "Disk Usage > 75% on $deviation"
						else
								echo "Disk Usage on $deviation is NORMAL"
						fi
				done
				echo "===================================================="
				
				rm /home/starreh/health_check/output/temp.txt
		fi							
}	


# Commands For Network Management
function nw_mgmt {

	# netstat
	echo -e """
	Command : netstat
	"""
	var_netstat=`which netstat`
	var_netstat=$?
	if [ var_netstat != 0 ]
	then
			echo "netstat : Command not found, Please install"
			echo "On Debian Based Systems : sudo apt-get install netstat"
			echo "On RHEL Based Systems : yum install netstat"
			echo "===================================================="
	else
			if [[ `netstat -nr | wc -l` -ge 2 ]]
			then
					echo "ROUTING TABLE is running Healthy"
					echo "===================================================="
			else
					echo "ROUTING TABLE is unhealthy"
					echo "===================================================="
			fi
	fi
	
	# ifconfig
	echo -e """
	Command : ifconfig
	"""
	var_ifconfig=`which ifconfig`
	var_ifconfig=$?
	if [ var_ifconfig != 0 ]
	then
			echo "ifconfig : Command not found, Please install"
			echo "On Debian Based Systems : sudo apt-get install ifconfig"
			echo "On RHEL Based Systems : yum install ifconfig"
			echo "===================================================="
	else
			ifconfig
			echo "===================================================="
	fi
}


# Commands For Process Management
function proc_mgmt {

	# ps
	echo -e """
	Command : ps aux
	"""
	var_ps=`which ps`
	var_ps=$?
	if [ $var_ps != 0 ]
	then
			echo "ps : Command not found, Please install"
			echo "On Debian Based Systems : sudo apt-get install ps"
			echo "On RHEL Based Systems : yum install ps"
			echo "===================================================="
	else
			ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10
			echo "===================================================="
	fi
}


# Commands For System Messages Management
function sys_messages {
	
	# /var/log/messages
	if [[ `tail -n 50 '/var/log/messages' |egrep 'ERROR|WARNING|FATAL'| wc -l` > 0 ]]
	then
			echo "Please Check /var/log/messages. System Unhealthy"
			echo "===================================================="
	else
			echo "System Healthy"
			echo "===================================================="
}

# Logger
function logger {

	echo -e """
	CPU Load Command Log
	====================================================
	"
	echo "`mpstat`"
	echo "`lscpu`"
	echo "`iostat`"
	echo "`sar 5 5`"
	
	echo -e """
	Memory Management Command Log
	====================================================
	"""
	echo "`top b -n1 | head -17 | tail -11`"
	echo "`free -m`"
	echo "`vmstat -S M`"
	echo "`cat /proc/meminfo`"
	
	echo -e """
	Disk Usage Management Command Log
	====================================================
	"""
	echo "`df -Pkh`"
	
	echo -e """
	Network Management Command Log
	====================================================
	"""
	echo "`netstat -nr`"
	echo "`ifconfig`"
	
	echo -e """
	Process Management Command Log
	====================================================
	"""
	echo "`ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10`"
	
	echo -e """
	System Log Management Command Log
	====================================================
	"""
	echo "`tail -n 50 '/var/log/messages'`"
}

# Calling The Methods

cpu_load >> /home/starreh/health_check/report/report_$dt.txt
mem_mgmt >> /home/starreh/health_check/report/report_$dt.txt
disk_usage >> /home/starreh/health_check/report/report_$dt.txt
nw_mgmt >> /home/starreh/health_check/report/report_$dt.txt
proc_mgmt >> /home/starreh/health_check/report/report_$dt.txt
sys_messages >> /home/starreh/health_check/report/report_$dt.txt
logger >> /home/starreh/health_check/report/log_$dt.txt

# Deleting All Files That Are Older Than 14 Days
find /home/starreh/health_check/report/* -type f -mtime +14 -exec rm -rf {} \;

# Exiting The Script
exit
