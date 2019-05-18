#!/bin/sh
tmpdir=`/usr/local/bin/getconf temp`
logdir=`/usr/local/bin/getconf logdir`

if [ $# -eq 1 ]; then
	echo "Checking for ${logdir}/wattson_log-$1.txt"
	if [ -e ${logdir}/wattson_log-$1.txt ]; then
		echo "Time Used Generated Grid_Given" > ${tmpdir}/wattsonplot.tmp
		cat ${logdir}/wattson_log-$1.txt | awk '{ split($0, arr);print arr[2] "." arr[3] " " arr[4] " " arr[5] " " arr[5]-arr[4];}' >> ${tmpdir}/wattsonplot.tmp
	fi
fi
cat ${tmpdir}/wattsonplot.tmp | awk 'BEGIN {maxgen=0;maxuse=0} {
	if (NR < 2) {next} {
	time=substr($1, 13, 2);
	#print time;
       	time=(2*time)/2;
       	gen[time]=gen[time]+$3;
       	grid[time]=grid[time]+$2;
	readings[time]++;
	surp=surp+$3-$2;
	if ($2>maxuse) {
		maxuse=$2;
		maxusetime=$1;
	}
	if ($3>maxgen) {
		maxgen=$3;
		maxgentime=$1;
	}
} }
   END {
   	print "<tr><td colspan='4'>Max Generated: " maxgen " at " maxgentime "</td></tr>";
	print "<tr><td colspan='4'>Max Used: " maxuse " at " maxusetime "</td><tr>";
       	print "<tr><td colspan='2'>Surplus: " surp "</td>";
       	print "<td colspan='2'>Avg Surp: " surp/NR "</td><tr>";
	print "<tr><td colspan='4'>Average Power (Watts)</td></tr>";
	print "<tr><td>Hour</td><td>Used Power</td><td>Generated Power</td><td>Power to Grid</td></tr>";
	for (i=0; i<24; i++) if (readings[i]>0) { print "<tr><td>"i ":00</td><td>" grid[i]/readings[i] "</td><td>" gen[i]/readings[i] "</td><td>" (gen[i]-grid[i])/readings[i] "</td></tr>"; } else { print "<tr><td>" i ":00</td><td> No readings</td><td /><td /><tr>"; }
   }' 
