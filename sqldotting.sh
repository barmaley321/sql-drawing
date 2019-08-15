#!/bin/bash

echo "Using: $0 input.sql outpic.png "

header=header.dat
input=$1
input=${input:=input_example.sql}
output=output.dot
outpic=$2
outpic=${outpic:="$(date +%s).png"}

###
echo input= $input
echo output= $output
echo outpic= $outpic

# fill header
cat $header > $output

#make pairs table:column from input
for tbl in $(cat $input | awk -F "," '{print $1","$2}' | sort | uniq)
do
  echo $tbl >> tbls
done

for tbl in $(cat $input | awk -F "," '{print $3","$4}' | sort | uniq)
do
  echo $tbl >> tbls
done

#to be sure that the list is uniq
for tbl in $(cat tbls | sort | uniq)
do
  echo $tbl >> tbl_list
done

echo 'tbl_list prepared'


# create labels (table names and their columns):
for tbl in $(cat tbl_list | awk -F "," '{print $1}' | sort | uniq)
do
  fld=$(cat tbl_list | awk -F "," -v tbl="$tbl" '{ if ($1 == tbl) print $2}')
  echo $fld >> all_fld
  echo $tbl >> all_tbl
  echo $tbl ' [label=<'>> $output
  echo '<table border="0" cellborder="1" cellspacing="0">' >> $output
  echo '   <tr><td><i>'$tbl'</i></td></tr>' >> $output
  for clmns in $fld
  do
    echo $clmns >> all_clmns
    echo '  <tr><td port="'$clmns'">'$clmns'</td></tr>' >> $output
  done
  echo '</table>>];' >> $output
done

echo 'table definition ready'

# create relations:
for tbl in $(cat $input) # | awk -F "," '{print $1}' | sort | uniq)
do
  f1=$(echo $tbl |awk -F "," '{print$1}')
  f2=$(echo $tbl |awk -F "," '{print$2}')
  f3=$(echo $tbl |awk -F "," '{print$3}')
  f4=$(echo $tbl |awk -F "," '{print$4}')
  echo $f1':'$f2' -> '$f3':'$f4';' >>$output
done

echo '}' >> $output

rm -f all_fld all_tbl all_clmns tbl_list tbls

dot -o$outpic -Tpng $output
rm output.dot

echo 'done'

