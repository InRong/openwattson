#!/bin/sh
# Shell script that gets the current power reading from the Wattson energy
# meter and creates a simple HTML file for showing it. The name of the file 
# to create is given as the first command line parameter. 
# If the name of 1-3 image files (e.g.one produced by 'wattsonplot') is given as 
# the 2nd-4th parameters, then those images are included in the page (if it exists). 
# These are in the order Used Power, Generated Power, Difference.
#
# Authors: Alan Wood (2015), Kary Främling, 2010
#

# Verify that we have a command line parameter; should be name of file to
# create.
if [ $# -lt 1 ]; then
	echo "No output file name given"
	exit 0
fi

# Get power value into variable
#pow=`getpower`
#gen=`getgen`
scriptDir=`/usr/local/bin/getconf scriptdir`

#<META HTTP-EQUIV=\"Refresh\" CONTENT=\"60\">  
# Write everything into file.
echo "<html>

<head>
<title>Alan's Wattson energy meter, Farnham, England</title>
<meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\">
<META HTTP-EQUIV=\"Expires\" CONTENT=\"Tue, 01 Jan 1980 1:00:00 GMT\">  
<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">  
</head>

<body bgcolor=\"white\" text=\"black\" link=\"blue\" vlink=\"purple\" alink=\"red\">

<h1 align=\"center\">Alan's Wattson energy meter, Farnham, England</h1>
<table border=\"1\" width=\"20%\" align=\"center\">
  <tr>

<td colspan="4" width=\"100%\" height=\"70\" valign=\"top\">
  <center>" > $1

# See if we have image file to include
if [ $# -ge 2 ]; then
	echo "<img src=\"$2\"><br>Used Power<br>" >> $1
fi

# See if we have another image file to include
if [ $# -ge 3 ]; then
	echo "<img src=\"$3\"><br>Generated Power<br>" >> $1
fi

# See if we have another image file to include
if [ $# -ge 4 ]; then
	echo "<img src=\"$4\"><br>Grid given Power<br>" >> $1
fi

echo " </center> </td></tr><tr><td>" >> $1
 $scriptDir/analysesolar_web.sh $5 >> $1
echo "</td></tr><tr><td colspan="4">" >> $1
# Continue with rest
echo "<center><b>`date`</b>
<br>
			   </center>
</td>
</tr>
</table>
<!--p align=\"center\">Power readings are updated once per minute</p-->

</body>

</html>" >> $1


