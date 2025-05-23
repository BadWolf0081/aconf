#!/system/bin/sh
# version 1.9.1

source /data/local/aconf_versions
logfile="/sdcard/aconf.log"

#Configs
aegis_conf="/data/local/tmp/aegis_config.json"
aegis_log="/data/local/tmp/aegis.log"
aconf_log="/sdcard/aconf.log"
monitor_log="/sdcard/aegis_monitor.log"
android_version=`getprop ro.build.version.release | sed -e 's/\..*//'`

# initial sleep for reboot
sleep 120

while true
  do
    if [ "$useSender" != true ] ;then
      echo "`date +%Y-%m-%d_%T` ATVdetailsSender: sender stopped" >> $logfile && exit 1
    fi

# remove windows line ending
    dos2unix $aegis_conf

# generic
    MITM="Aegis"
    RPL=$(($atvdetails_interval/60))
    deviceName=$(cat $aegis_conf | tr , '\n' | grep -w 'deviceName' | awk -F ":" '{ print $2 }' | tr -d \"})
    arch=$(uname -m)
    productmodel=$(getprop ro.product.model)
    MITMSh=$(head -2 /data/bin/aegis.sh | grep '# version' | awk '{ print $NF }')
    MITM55=$([ -f /data/etc/init.d/55aegis ] && head -2 /data/etc/init.d/55aegis | grep '# version' | awk '{ print $NF }' || echo 'na')
    MITM42=$([ -f /data/etc/init.d/42aegis ] && head -2 /data/etc/init.d/42aegis | grep '# version' | awk '{ print $NF }' || echo 'na')
    monitor=$([ -f /data/bin/aegis_monitor.sh ] && head -2 /data/bin/aegis_monitor.sh | grep '# version' | awk '{ print $NF }' || echo 'na')
    whversion=$([ -f /data/bin/AegisDetailsSender.sh ] && head -2 /data/bin/AegisDetailsSender.sh | grep '# version' | awk '{ print $NF }' || echo 'na')
    pogo=$(dumpsys package com.nianticlabs.pokemongo | grep versionName | head -n1 | sed 's/ *versionName=//')
    MITMv=$(dumpsys package com.pokemod.aegis | grep versionName | head -n1 | sed 's/ *versionName=//')
    temperature=$(cat /sys/class/thermal/thermal_zone0/temp | cut -c -2)
    magisk=$(magisk -c | sed 's/:.*//')
    macw=$([ -d /sys/class/net/wlan0 ] && ifconfig wlan0 |grep 'HWaddr' |awk '{ print ($NF) }' || echo 'na')
    ip=$(ifconfig wlan0 |grep 'inet addr' |cut -d ':' -f2 |cut -d ' ' -f1 && ifconfig eth0 |grep 'inet addr' |cut -d ':' -f2 |cut -d ' ' -f1)
    ext_ip=$(curl -k -s https://ifconfig.me/)
    #mac=$(ifconfig wlan0 2>/dev/null | grep 'HWaddr' | awk '{print $5}' | cut -d ' ' -f1 && ifconfig eth0 2>/dev/null | grep 'HWaddr' | awk '{print $5}')
    hostname=$(getprop net.hostname)
    playstore=$(dumpsys package com.android.vending | grep versionName | head -n 1 | cut -d "=" -f 2 | cut -d " " -f 1)
    proxyinfo=$(proxy=$(settings list global | grep "http_proxy=" | awk -F= '{ print $NF }'); [ -z "$proxy" ] || [ "$proxy" = ":0" ] && echo "none" || echo "$proxy")
# atv performance
    memTot=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    memFree=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
    memAv=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}')
    memPogo=$(dumpsys meminfo 'com.nianticlabs.pokemongo' | grep -m 1 "TOTAL" | awk '{print $2}')
    memMITM=$(dumpsys meminfo 'com.pokemod.aegis:mapping' | grep -m 1 "TOTAL" | awk '{print $2}')
    cpuL5=$(dumpsys cpuinfo | grep "Load" | awk '{ print $2 }')
    cpuL10=$(dumpsys cpuinfo | grep "Load" | awk '{ print $4 }')
    cpuL15=$(dumpsys cpuinfo | grep "Load" | awk '{ print $6 }')
    numPogo=$(ls -l /sbin/.magisk/mirror/data/app/ | grep com.nianticlabs.pokemongo | wc -l)
# aconf.log
    reboot=$(grep 'Device rebooted' $aconf_log | wc -l)
# aegis config
    authBearer=$(cat $aegis_conf | tr , '\n' | grep -w 'authBearer' | awk -F ":" '{ print $2 }' | tr -d \"})
    token=$(cat $aegis_conf | tr , '\n' | grep -w 'deviceAuthToken' | awk -F ":" '{ print $2 }' | tr -d \"})
    email=$(cat $aegis_conf | tr , '\n' | grep -w 'email' | awk -F ":" '{ print $2 }' | tr -d \"})
    rdmUrl=$(cat $aegis_conf | tr , '\n' | grep -w 'rdmUrl' | awk -F "\"" '{ print $4 }')
    onBoot=$(cat $aegis_conf | tr , '\n' | grep -w 'runOnBoot' | awk -F ":" '{ print $2 }' | tr -d \"})
# aegis.log
    a_pogoStarted=$(grep 'Launched Pokemon Go' $aegis_log | wc -l)
    a_injection=$(grep 'Injected successfully' $aegis_log | wc -l)
    a_ptcLogin=$(grep 'Logged in using ptc' $aegis_log | wc -l)
    a_MITMCrash=$(grep 'Agent has crashed or stopped responding' $aegis_log | wc -l)
    a_rdmError=$(grep 'Could not send heartbeat' $aegis_log | wc -l)

# monitor.log
    m_noInternet=$(grep 'No internet' $monitor_log | wc -l)
    m_noConfig=$(grep 'aegis_config.json does not exist or is empty' $monitor_log | wc -l)
    m_noLicense=$(grep 'Device Lost Aegis License' $monitor_log | wc -l)
    m_MITMDied=$(grep 'Aegis must be dead, rebooting device' $monitor_log | wc -l)
    m_pogoDied=$(grep 'Pogo must be dead, rebooting device' $monitor_log | wc -l)
    m_deviceOffline=$(grep 'Device must be offline. Running a stop mapping service of Aegis, killing pogo and clearing junk' $monitor_log | wc -l)
    m_noRDM=$(grep 'something wrong with RDM' $monitor_log | wc -l)
    m_noFocus=$(grep 'Something is not right! Pogo is not in focus. Killing pogo and clearing junk' $monitor_log | wc -l)
    m_unknown=$(grep 'Something happened! Some kind of error' $monitor_log | wc -l)

# version specific metrics
if [ $android_version -ge 9 ]; then
    cpuSys=$(top -n 1 | grep %sys | awk 'NR == 1 {sub(/%sys/, "", $4); print $4}')
    cpuUser=$(top -n 1 | grep %user | awk 'NR == 1 {sub(/%user/, "", $2); print $2}')
    cpuPogoPct=$(dumpsys cpuinfo | grep 'com.nianticlabs.pokemongo' | awk '{print substr($1, 1, length($1)-1)}')
    cpuApct=$(dumpsys cpuinfo | grep 'com.pokemod.aegis' | awk 'NR == 1 {sub(/%/, "", $1); print $1}')
    #Still not sure about these
    diskSysPct=$(df -h | grep /dev/root | awk 'NR == 1 {sub("%", "", $5); print $5}')
    diskDataPct=$(df -h | grep /data/media | awk 'NR == 1 {sub("%", "", $5); print $5}')
    magisk_modules=$(ls -1 /sbin/.magisk/modules/ | xargs | sed -e 's/ /, /g')
    mace=$(ifconfig eth0 |grep 'HWaddr' |awk '{ print ($5) }')
else
    cpuSys=$(top -n 1 | grep -m 1 "System" | awk '{print substr($2, 1, length($2)-2)}')
    cpuUser=$(top -n 1 | grep -m 1 "User" | awk '{print substr($2, 1, length($2)-2)}')
    cpuPogoPct=$(dumpsys cpuinfo | grep 'com.nianticlabs.pokemongo' | awk '{print substr($1, 1, length($1)-1)}')
    cpuApct=$(dumpsys cpuinfo | grep 'com.pokemod.aegis' | awk '{print substr($1, 1, length($1)-1)}')
    diskSysPct=$(df -h | grep /sbin/.magisk/mirror/system | awk '{print substr($5, 1, length($5)-1)}')
    diskDataPct=$(df -h | grep /sbin/.magisk/mirror/data | awk '{print substr($5, 1, length($5)-1)}')
    magisk_modules=$(ls -1 /sbin/.magisk/img | xargs | sed -e 's/ /, /g' 2>/dev/null)
    mace=$(ifconfig eth0 |grep 'HWaddr' |awk '{ print ($NF) }')
fi

# corrections
[[ -z $temperature ]] && temperature=0
[[ -z $cpuPogoPct ]] && cpuPogoPct=0
[[ -z $cpuApct ]] && cpuApct=0

#send data
    curl -k -X POST ${atvdetails_receiver_user:+-u $atvdetails_receiver_user:$atvdetails_receiver_pass} ${atvdetails_receiver_host}${atvdetails_receiver_port:+:$atvdetails_receiver_port}/webhook -H "Accept: application/json" -H "Content-Type: application/json" --data-binary @- <<DATA
{
    "WHType": "ATVDetails",

    "MITM": "${MITM}",
    "RPL": "${RPL}",
    "deviceName": "${deviceName}",
    "arch": "${arch}",
    "productmodel": "${productmodel}",
    "MITMSh": "${MITMSh}",
    "MITM55": "${MITM55}",
    "MITM42": "${MITM42}",
    "monitor": "${monitor}",
    "whversion": "${whversion}",
    "pogo": "${pogo}",
    "MITMv": "${MITMv}",
    "temperature": "${temperature}",
    "magisk": "${magisk}",
    "magisk_modules": "${magisk_modules}",
    "macw": "${macw}",
    "mace": "${mace}",
    "ip": "${ip}",
    "ext_ip": "${ext_ip}",
    "hostname": "${hostname}",
    "playstore": "${playstore}",
    "proxyinfo": "${proxyinfo}",

    "memTot": "${memTot}",
    "memFree": "${memFree}",
    "memAv": "${memAv}",
    "memPogo": "${memPogo}",
    "memMITM": "${memMITM}",
    "cpuSys": "${cpuSys}",
    "cpuUser": "${cpuUser}",
    "cpuL5": "${cpuL5}",
    "cpuL10": "${cpuL10}",
    "cpuL15": "${cpuL15}",
    "cpuPogoPct": "${cpuPogoPct}",
    "cpuApct": "${cpuApct}",
    "diskSysPct": "${diskSysPct}",
    "diskDataPct": "${diskDataPct}",
    "numPogo": "${numPogo}",

    "reboot": "${reboot}",

    "authBearer": "${authBearer}",
    "token": "${token}",
    "email": "${email}",
    "rdmUrl": "${rdmUrl}",
    "onBoot": "${onBoot}",

    "a_pogoStarted": "${a_pogoStarted}",
    "a_injection": "${a_injection}",
    "a_ptcLogin": "${a_ptcLogin}",
    "a_MITMCrash": "${a_MITMCrash}",
    "a_rdmError": "${a_rdmError}",

    "m_noInternet": "${m_noInternet}",
    "m_noConfig": "${m_noConfig}",
    "m_noLicense": "${m_noLicense}",
    "m_MITMDied": "${m_MITMDied}",
    "m_pogoDied": "${m_pogoDied}",
    "m_deviceOffline": "${m_deviceOffline}",
    "m_noRDM": "${m_noRDM}",
    "m_noFocus": "${m_noFocus}",
    "m_unknown": "${m_unknown}"
}
DATA

    sleep $atvdetails_interval
  done;
