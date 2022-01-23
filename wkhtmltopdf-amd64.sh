#!/bin/bash
# Script to call wkhtmltopdf binary with arguments from scriptcase production in wkhtmltopdf docker container
# If in /pdf_ini dir a [report]_pdf.ini (eg grid_customers_pdf.ini) file exist these settings prefail 
# Author: Stephan Tiebosch
#exec 19>>wk.debugfile
#BASH_XTRACEFD=19
#set -v -x -e
argc=$#
argv=("$@")
infile="${argv[(($argc - 2))]}"
outfile="${argv[(($argc - 1))]}"
report_pdf=$(awk -F'sc_|_html' '{print $2}' <<< "$infile")
wkpdfinidir=../../../../../pdf_ini   # or use an absolute path
wkpdfinifile=${wkpdfinidir}/${report_pdf}_pdf.ini   # or use an absolute path
debugfile=${wkpdfinidir}/${report_pdf}_pdf.debug


echo "$@" >> wk.debugfile

if [ ! -d ${wkpdfinidir} ]; then
  mkdir -p ${wkpdfinidir}
  if [ $? -ne 0 ] ; then
    echo "no /pdf_ini created"
  else
    echo "pdf_ini created"
  fi
fi 



if [ -f ${wkpdfinidir}/.project.env ]; then
  source ${wkpdfinidir}/.project.env
else  
  wkhtmltopdf_server="wkhtmltopdf1"
  wkhtmltopdf_port=4000
  wkhtmltopdf_exec_time=2
fi

data=""
# if exists ini file pdf_ini directory
if [ -f "${wkpdfinifile}" ]; then
  # file found
  for word in $(<$wkpdfinifile);
  do
     data=$(printf '%s"%s"' "$data",  "${word//[$'\t\r\n']}");
  done
else
  # file not found
  for i in $(seq 0 $((${argc} - 3)));
  do
     data=$(printf '%s"%s"' "${data}", "${argv[($i)]}");
  done
fi

# Add last 2 arguments

data=$(printf '%s"%s"' "$data",  "${infile}");
data=$(printf '%s"%s"' "$data",  "${outfile}");


data=${data#,}
data=$(printf '{"args":[%s]}' "${data}");
echo $(date) "$@" >> wk.debugfile
echo $data >> wk.debugfile
echo "Execute curl -v -X POST -H 'Content-Type: application/json' -d '$data' http://${wkhtmltopdf_server}:${wkhtmltopdf_port}/commands/wkhtmltopdf?wait=true&force_unique_key=true" >> wk.debugfile 
echo "Execute curl -v -X POST -H 'Content-Type: application/json' -d '$data' http://${wkhtmltopdf_server}:${wkhtmltopdf_port}/commands/wkhtmltopdf?wait=true&force_unique_key=true" >> $debugfile 

bash -c "curl -v -X POST -H 'Content-Type: application/json' -d '$data' http://${wkhtmltopdf_server}:${wkhtmltopdf_port}/commands/wkhtmltopdf?wait=true&force_unique_key=true" 2>> $debugfile >> $debugfile
sleep $wkhtmltopdf_exec_time
exit 0
