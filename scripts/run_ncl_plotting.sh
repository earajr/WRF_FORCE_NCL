#!/bin/bash 

#source /home/earajr/anaconda3/etc/profile.d/conda.sh
#conda activate ncl

script_dir="/home/earajr/ncl_plotting/scripts"

region=$1

#Date for today (format YYYYMMDD)
YYYY=$( date -u --date='today' +%Y )
MM=$( date -u --date='today' +%m )
DD=$( date -u --date='today' +%d )
HH=$( date -u --date='today' +%H )
YYYYMMDD=$( date -u --date='today' +%Y%m%d )

if [ "$HH" -gt  3 ] && [ "$HH" -le  9 ]
then
   HH="00"
elif [ "$HH" -gt  9 ] && [ "$HH" -le  15 ]
then
   HH="06"
elif [ "$HH" -gt  15 ] && [ "$HH" -le  21 ]
then
   HH="12"
elif [ "$HH" -gt  21 ] && [ "$HH" -le  23 ]
then
   HH="18"
elif [ "$HH" -le  3 ]
then
   YYYYMMDD=$( date -u --date='yesterdy' +%Y%m%d )
   HH="18"
fi

if [ "${region}" == "uk" ]
then
   plot_machine="liono"
elif [ "${region}" == "iceland" ]
then
   plot_machine="liono"
elif [ "${region}" == "cape_verde" ]
then
   plot_machine="liono"
fi

if [ -d "/home/shared/nwr/${region}/data/${YYYYMMDD}${HH}" ]
then
   echo "${script_dir}/read_log.sh ${region} ${YYYYMMDD} ${HH}"
   ssh -i /home/earajr/.ssh/thundercat_id_rsa ${plot_machine} "timeout 2h /bin/bash ${script_dir}/read_log.sh ${region} ${YYYYMMDD} ${HH}"
else
   echo "There is no data directory for the ${region} domain for the date ${YYYYMMDD} at time ${HH}"
fi

