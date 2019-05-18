openwattson
===========
A fork of Kary Framling's excellent base project. Adjusted to log Generated and used power from a Wattson Solar Plus. I beleive this will not work on a basic one with only a single power feed, although it may just give a -2 or -3 value back always.

I have also significantly changed the way that I generate HTML output for showing this, and the way that the data is logged.

I now log into daily logs, and create a daily HTML file with 3 graphs - Used power, Generated power and a difference betwee them. I also create some analysis of this data for the day, and hourly in a table. I think this analysis is accurate, but welcome any feedback.

I am running this on a Raspberry Pi, so have had to make some additional changes to the read method as it seemed to keep locking the FTDI driver. It seems to have helped.

From Kary's description :
My version of Openwattson, I needed to add collection of stats for generated power (`noww` command) as I have a Wattson Solar Plus.  This code is originally from http://dialog.hut.fi/openwattson/

SQL logging
===========
I have moved away from the locally generated and stored graph images to an SQL based version. There is now a single command to retrieve the gernerated and used power, and to store this in a mySQL database.

I have created an additional project, SolarPower_Display that can be used to display the results via a webserver.
