/*  openwattson  - rwwattson.c library functions
 *  This is a library of functions common to Linux and Windows
 *  
 *  Version 0.1
 *  
 *  Control Wattson power meter
 *  
 *  Copyright 2010, Kary Främling, Jan Nyman
 *  This program is published under the GNU General Public license
 */

#include "rwwattson.h"

#include <strings.h>    //bzero()

/********************************************************************/
/* get_current_power_with_retry
 * Return current power reading. Retry a maximum of MAXRETRIES times
 * if an error occurs. Negative value is returned in case of error, 
 * greater than or equal to zero if successful.  
 * 
 * Input: Handle to Wattson
 *
 * Returns: Current power consumption
 *
 ********************************************************************/
int get_current_power_with_retry(WATTSON wattson)
{
	int power;
	int i;

	for ( i=0 ; i<MAXRETRIES ; i++ ) {
		power = get_current_power(wattson);
		if ( power >= 0 )
			break;
		mySleep(500000); // Give enough time for recovering
	}

	return power;
}

/********************************************************************/
/* get_current_generated_power_with_retry
 * Return current generated power reading. Retry a maximum of MAXRETRIES times
 * if an error occurs. Negative value is returned in case of error, 
 * greater than or equal to zero if successful.  
 * 
 * Input: Handle to Wattson
 *
 * Returns: Current generated power consumption
 *
 ********************************************************************/
int get_current_generated_power_with_retry(WATTSON wattson)
{
        int genpower;
        int i;

        for ( i=0 ; i<MAXRETRIES ; i++ ) {
                genpower = get_current_generated_power(wattson);
                if ( genpower >= 0 )
                        break;
                mySleep(500000); // Give enough time for recovering
        }

        return genpower;
}

/********************************************************************/


/********************************************************************/
/* get_current_power
 * Return current power reading. Negative value is returned in case of error, 
 * greater than or equal to zero if successful. 
 * This error handling is needed because sometimes Wattson returns 
 * negative values od some other error. This is probably due to some
 * "misuse" of the protocol due to our restricted knowledge about it. 
 * 
 * Input: Handle to Wattson
 *
 * Returns: Current power consumption
 *
 ********************************************************************/
int get_current_power(WATTSON wattson)
{
	char cmd[] = "nowp";
	//char cmd[] = "nowA00009 00\n";
	char result[REPLY_BUF_SIZE];
	unsigned int power = 0;
        //unsigned int readbytes = 0;
        //unsigned int loop = 0;

	tcflush(wattson, TCIOFLUSH); // Flush everything just in case

	if (writeport(wattson, cmd) <= 0)
		return(-1);
/*
        while (readbytes == 0) {
           loop = loop + 1;
           mySleep(5000); // Give enough time for replying
           bzero(result, REPLY_BUF_SIZE);  // Clear the buffer before readport

           readbytes = readport(wattson, result);
printf("loop %d, readbytes %d\n", loop, readbytes);
           if ( result[0] == 'w' ) {
                sscanf(result+1, "%x", &power);
           }
           else {
                   power=-3;
           }
           if (( readbytes == 0 ) && (loop == 100)) {
                   power = -2;
                   readbytes = 1;
           }
        }
*/
	mySleep(50000); // Give enough time for replying
    bzero(result, REPLY_BUF_SIZE);  // Clear the buffer before readport

	if (readport(wattson, result) <= 0)
		return(-2);

	if ( result[0] == 'p' ) {
		sscanf(result+1, "%x", &power);
	}
	else {
		return(-3); // Error in power value
	}

	return power*4;  // Odd fudge needed to get the values correct on my system. Works, but don't know why.
}

/********************************************************************/
/* get_current_generated_power
 * Return current generated power reading. 
 * 
 * Input: Handle to Wattson
 *
 * Returns: Current generated power
 *
 ********************************************************************/
int get_current_generated_power(WATTSON wattson)
{
        char cmd[] = "noww";
        //char cmd[] = "nowA00009 00\n";
        char genresult[REPLY_BUF_SIZE];
        int genpower = -2;
	//unsigned int readbytes = 0;
	//unsigned int loop = 0;

        tcflush(wattson, TCIOFLUSH); // Flush everything just in case

        if (writeport(wattson, cmd) <= 0)
                return(-1);

        /* bzero(genresult, REPLY_BUF_SIZE);  // Clear the buffer before readport
	while (readbytes == 0) {
	   loop++; // = loop + 1;
           mySleep(50000); // Give enough time for replying

           //if (readport(wattson, genresult) <= 0)
           //     return(-2);
	   readbytes = readport(wattson, genresult);
printf("loop %u, readbytes %u genresult %c\n", loop, readbytes,genresult[0]);
           if ( genresult[0] == 'w' ) {
                sscanf(genresult+1, "%x", &genpower);
           }
           else {
           //        return(-3); // Error in power value
	           genpower=-3;
           }
	   if (( readbytes == 0 ) && (loop == 10)) {
		   genpower = -2;
		   readbytes = 1;
	   }
	}
        return genpower;
} */
        mySleep(50000); // Give enough time for replying
    bzero(genresult, REPLY_BUF_SIZE);  // Clear the buffer before readport

        if (readport(wattson, genresult) <= 0)
                return(-2);
        if ( genresult[0] == 'w' ) {
                sscanf(genresult+1, "%x", &genpower);
        }
        else {
                return(-3); // Error in power value
        }

        return genpower;
}


/********************************************************************
 * get_configuration()
 *
 * read setup parameters from openwattson.conf
 * It searches in this sequence:
 * 1. Path to config file including filename given as parameter
 * 2. ./openwattson.conf
 * 3. /usr/local/etc/openwattson.conf
 * 4. /etc/openwattson.conf
 *
 * See file openwattson.conf-dist for the format and option names/values
 *
 * input:    config file name with full path - pointer to string
 *
 * output:   struct config populated with valid settings either
 *           from config file or defaults
 *
 * returns:  0 = OK
 *          -1 = no config file or file open error
 *
 ********************************************************************/
int get_configuration(struct config_type *config, char *path)
{
	FILE *fptr;
	char inputline[1000] = "";
	char token[100] = "";
	char val[100] = "";
	char val2[100] = "";

	// First we set everything to defaults - faster than many if statements
	strcpy(config->serial_device_name, DEFAULT_SERIAL_DEVICE);  // Name of serial device

	// open the config file

	fptr = NULL;
	if (path != NULL)
		fptr = fopen(path, "r");   //first try the parameter given
	if (fptr == NULL)                  //then try default search
	{
		if ((fptr = fopen("openwattson.conf", "r")) == NULL)
		{
			if ((fptr = fopen("/usr/local/etc/openwattson.conf", "r")) == NULL)
			{
				if ((fptr = fopen("/etc/openwattson.conf", "r")) == NULL)
				{
					//Give up and use defaults
					return(-1);
				}
			}
		}
	}

	while (fscanf(fptr, "%[^\n]\n", inputline) != EOF)
	{
		sscanf(inputline, "%[^= \t]%*[ \t=]%s%*[, \t]%s%*[^\n]", token, val, val2);

		if (token[0] == '#')	// comment
			continue;

		if ((strcmp(token,"SERIAL_DEVICE")==0) && (strlen(val) != 0))
		{
			strncpy(config->serial_device_name,val, DEV_NAME_SIZE);
			config->serial_device_name[DEV_NAME_SIZE-1]='\0';
			continue;
		}		

		if ((strcmp(token,"LOG_DIR")==0) && (strlen(val) != 0))
		{
			strncpy(config->logfile_dir,val, PATH_SIZE);
			config->logfile_dir[PATH_SIZE-1]='\0';
			continue;
		}		

		if ((strcmp(token,"HTML_DIR")==0) && (strlen(val) != 0))
		{
			strncpy(config->HTMLfile_dir,val, PATH_SIZE);
			config->HTMLfile_dir[PATH_SIZE-1]='\0';
			continue;
		}		

		if ((strcmp(token,"TEMP_DIR")==0) && (strlen(val) != 0))
		{
			strncpy(config->temp_dir,val, PATH_SIZE);
			config->temp_dir[PATH_SIZE-1]='\0';
			continue;
		}		
	}
	return (0);
}


/********************************************************************
 * initialize resets Wattson to cold start (rewind and start over)
 * 
 * Input:   device number of the already open serial port
 *           
 * Returns: 0 if fail, 1 if success
 *
 ********************************************************************/
int initialize(WATTSON wattson)
{
	return 1;
}


