#!/bin/bash

source /home/earajr/.bashrc
source /home/earajr/anaconda3/etc/profile.d/conda.sh
conda activate ncl

region=$1
strt_date=$2
strt_hour=$3

forecast_len=72

end_time=$( date -u -d "${strt_hour}:00:00 ${strt_date:0:4}-${strt_date:4:2}-${strt_date:6:2} +${forecast_len}hours" +"%Y-%m-%d_%H:%M:%S" )

script_dir="/home/earajr/ncl_plotting/scripts"
namelist_vars="${script_dir}/namelist.vars"
namelist_locs="${script_dir}/${region}.locs"
src_dir="/home/shared/nwr/${region}/data/${strt_date}${strt_hour}"
#src_dir="/home/earajr/ncl_plotting/scripts/test_src"
base_dest_dir="/home/earajr/ncl_plotting/scripts/images/${region}/${strt_date}/${strt_hour}"
log_file="${src_dir}/nwr_log"
#log_file="/home/earajr/ncl_plotting/scripts/test_log"
command_list="${script_dir}/command_list_${region}_${strt_date}_${strt_hour}"
fil_list="${script_dir}/fil_list_${region}_${strt_date}_${strt_hour}"

# Read namelist.varfile to aquire relavent information for variables to be plotted

#( tail -f -n0 ${log_file} & ) | grep -q "Starting wrf.exe:"
while true
do
   if grep -q "Starting wrf.exe:" ${log_file}
   then
      break
   fi
done

if [ -f "${command_list}" ]
then
   rm -rf ${command_list}
fi
touch ${command_list}

if [ -f "${fil_list}" ]
then
   rm -rf ${fil_list}
fi
touch ${fil_list}

count=0 
while true;
do
   date_time=$( date -u '+%Y%m%d%H%M%S' )
   touch ${command_list}_${date_time}

   if compgen -G "${src_dir}/wrfout*" > /dev/null;
   then
      for fil in ${src_dir}/wrfout*;
      do
         if grep -q ${fil} ${fil_list};
         then
   	    echo "############################################################################################################################"
            echo "File \"${fil}\" already processed."
	    echo "############################################################################################################################"
         else
            base_fil=$( basename ${fil} ) 
            dom=$( echo ${base_fil} | awk -F "_" '{print $2}' )

            while IFS= read -r var_line; do
               var_line_head=$( echo ${var_line} | awk -F ":" '{print $1}' )
               if [ "${var_line_head}" == "s_lev_vars" ]
               then
                  for var in $( echo ${var_line} | awk -F ":" '{print $2}' )
                  do
                     var1=$( echo ${var} | tr -d , )
	             dest_dir="${base_dest_dir}/${dom}/${var1}/"
	             if [ ! -d ${dest_dir} ]
                     then
                        mkdir -p ${dest_dir}
	             fi
	             echo "ncl 'dom=\"${dom}\"' 'dest=\"${dest_dir}\"' 'a=addfile(\"${fil}\", \"r\")' ${script_dir}/ncl/${var1}.ncl" >> ${script_dir}/command_list_${region}_${strt_date}_${strt_hour}_${date_time}
                  done
               elif [ "${var_line_head}" == "m_lev_vars" ]
               then
                  IFS=',' read -ra vars_plevs  <<< "$( echo ${var_line} | awk -F ":" '{print $2}' )"
                  for var_plevs in "${vars_plevs[@]}"; do
                     var=$( echo ${var_plevs} | awk '{print $1}' )
	             IFS=' ' read -ra plevs  <<< "$( echo ${var_plevs} | awk '{$1 = ""; print $0}' )"
	             for plev in "${plevs[@]}"; do
	                dest_dir="${base_dest_dir}/${dom}/${var}/${plev}/"
	                if [ ! -d ${dest_dir} ]
                        then
                           mkdir -p ${dest_dir}
                        fi
                        echo "ncl 'dom=\"${dom}\"' 'dest=\"${dest_dir}\"' 'plevs=${plev}' 'a=addfile(\"${fil}\", \"r\")' ${script_dir}/ncl/${var}.ncl" >> ${script_dir}/command_list_${region}_${strt_date}_${strt_hour}_${date_time}
	             done
   	          done
               elif [ "${var_line_head}" == "loc_vars" ]
               then
                  for var in $( echo ${var_line} | awk -F ":" '{print $2}' )
                  do
                     var1=$( echo ${var} | tr -d , )
                     while IFS= read -r loc_line; do
                        loc_name=$( echo ${loc_line} | awk -F "," '{print $1}' )
     	                loc_stat=$( echo ${loc_line} | awk -F "," '{print $2}' )
	                loc_lat=$( echo ${loc_line} | awk -F "," '{print $3}' )
	                loc_lon=$( echo ${loc_line} | awk -F "," '{print $4}' )

   		        if [ "${region}" == "iceland" ]
		        then

                           loc_name2=$( echo ${loc_name//??/A~H-15V6F35~A~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/a~H-13V2F35~A~FV-2H3~})
                           loc_name2=$( echo ${loc_name2//??/A~H-15V6F35~B~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/a~H-13V2F35~B~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/A~H-15V6F35~C~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/a~H-13V2F35~C~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/A~H-15V6F35~D~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/a~H-13V2F35~D~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/A~H-15V6F35~H~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/a~H-13V2F35~H~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/E~H-15V6F35~A~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/e~H-13V2F35~A~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/E~H-15V6F35~B~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/e~H-13V2F35~B~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/E~H-15V6F35~C~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/e~H-13V2F35~C~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/E~H-15V6F35~H~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/e~H-13V2F35~H~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/I~H-10V6F35~A~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/i~H-10V2F35~A~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/I~H-08V6F35~B~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/i~H-08V2F35~B~FV-2~})
	                   loc_name2=$( echo ${loc_name2//??/I~H-09V6F35~C~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/i~H-09V2F35~C~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/I~H-09V6F35~H~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/i~H-09V2F35~H~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/O~H-15V6F35~A~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/o~H-13V2F35~A~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/O~H-15V6F35~B~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/o~H-13V2F35~B~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/O~H-16V6F35~C~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/o~H-14V2F35~C~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/O~H-15V6F35~D~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/o~H-13V2F35~D~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/O~H-16V6F35~H~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/o~H-14V2F35~H~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/U~H-15V6F35~A~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/u~H-13V2F35~A~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/U~H-13V6F35~B~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/u~H-13V2F35~B~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/U~H-15V6F35~C~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/u~H-13V2F35~C~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/U~H-15V6F35~H~FV-6H3~})
	                   loc_name2=$( echo ${loc_name2//??/u~H-13V2F35~H~FV-2H3~})
	                   loc_name2=$( echo ${loc_name2//??/D~H-22V-8F35~E~FV8H10~})
	                   loc_name2=$( echo ${loc_name2//??/d~H-10F35~E~FH5~~H-4~})
                           loc_name2=$( echo ${loc_name2//??/A~H-10~E})
	                   loc_name2=$( echo ${loc_name2//??/a~H-6~e})
                        fi

	                if [ "${loc_stat}" == " " ]
                        then
                           loc_stat=${loc_name}
                        fi

                        dest_dir="${base_dest_dir}/${dom}/${var1}/${loc_name}/"
	                if [ ! -d ${dest_dir} ]
                        then
                           mkdir -p ${dest_dir}
                        fi
                        echo "ncl 'dom=\"${dom}\"' 'dest=\"${dest_dir}\"' 'ids=\"${loc_name}\"' 'stat=\"${loc_stat}\"' 'name=\"${loc_name2}\"' 'lats=${loc_lat}' 'lons=\"${loc_lon}\"' 'a=addfile(\"${fil}\", \"r\")' ${script_dir}/ncl/${var1}.ncl" >> ${script_dir}/command_list_${region}_${strt_date}_${strt_hour}_${date_time}
                     done < ${namelist_locs}
	          echo "ncl ${var1}"
	          done
	       fi
            done < ${namelist_vars}
            echo ${fil} >> ${fil_list}
         fi
      done
      parallel -j 10 < ${command_list}_${date_time}
      cat ${command_list}_${date_time} >> ${command_list}
   fi
   rm -rf ${command_list}_${date_time}
   sleep 30s

   if grep -q ${end_time} ${fil_list}
   then
      ((count+=1))
      echo ${count}
      if (( ${count} > 2 ))
      then
         break
      fi
   fi
done

rm -rf ${fil_list}
rm -rf ${command_list}

