#!/bin/bash
# get the list of DST files for specified dataset
# - this script may take a while to run
# - use the output for integrityCheck.sh

if [ -z "$CLASQA" ]; then
  echo "ERROR: please source env.sh first"
  exit
fi

if [ $# -ne 1 ];then echo "USAGE: $0 [dataset]"; exit; fi
dataset=$1

datadir=$(grep $dataset datasetList.txt | awk '{print $4}')
if [ -z "$datadir" ]; then
  echo "ERROR: dataset not foundin datasetList.txt"
  exit
fi
datadir=$(echo $datadir | sed 's/^\/cache/\/mss/g')
echo "datadir=$datadir"
ls $datadir


find $datadir -name "*.hipo" -print | sed 's/^.*\/rec_clas_//g' > dstfilelist.tmp

> dstlist.tmp
while read dst; do
  run=$(echo $dst | sed 's/\..*$//g' | sed 's/^0*//')
  file=$(echo $dst | awk -F. '{print $3}' | sed 's/-.*$//g' | sed 's/^0*//')
  if [ -z "$file" ]; then file=0; fi
  #echo "dst=$dst run=$run file=$file"
  echo "$run $file" | tee -a dstlist.tmp
done < dstfilelist.tmp
rm dstfilelist.tmp

cat dstlist.tmp | sort -n > dstlist.${dataset}.dat
rm dstlist.tmp
