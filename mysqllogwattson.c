/*  openwattson - logwattson.c
 *  
 *  Version 0.1
 *  
 *  Log data from Wattson energy monitor
 *  
 *  Copyright 2010, Kary Främling, Jan Nyman
 *  This program is published under the GNU General Public license
 */

#include "rwwattson.h"
//#include <my_global.h>
#include <mysql.h>


/********************************************************************
 * print_usage prints a short user guide
 *
 * Input:   none
 * 
 * Output:  prints to stdout
 * 
 * Returns: exits program
 *
 ********************************************************************/
void print_usage(void)
{
	printf("\n");
	printf("mysqllogwattson - Read and interpret data from Wattson energy monitor\n");
	printf("and write it to a mysql database. Perfect for a cron driven task.\n");
	printf("Version %s (C)2017 Alan Wood.\n", VERSION);
	printf("Based on logwattson (C)2010 Kary Främling, Jan Nyman.\n");
	printf("This program is released under the GNU General Public License (GPL)\n\n");
	printf("Usage:\n");
	printf("Save current data to logfile: logwattson config_filename\n");
	exit(0);
}

/***********************************************************************
 *
 * An exit statement that gives the mysql error and returns an exit
 * code of 1
 *
 **********************************************************************/
void finish_with_error(MYSQL *con)
{
	  fprintf(stderr, "%s\n", mysql_error(con));
	    mysql_close(con);
	      exit(1);        
}

 
/********** MAIN PROGRAM ************************************************
 *
 * This program reads current weather data from a Wattson energy monitor
 * and inserts the data into an mysql database
 *
 * It takes one parameter. 
 * This is the config file name with path
 * If this parameter is omitted the program will look at the default paths
 * See the openwattson.conf-dist file for info
 *
 ***********************************************************************/
int main(int argc, char *argv[])
{
	WATTSON wattson;
	//FILE *fileptr;
	char logline[3000] = "";
	char datestring[50];        //used to hold the date stamp for the log file
	int current_power; 
	int current_generated_power;
	struct config_type config;
	time_t basictime;
  	MYSQL *con = mysql_init(NULL);
    
    	if (con == NULL) 
	{
		fprintf(stderr, "%s\n", mysql_error(con));
		exit(1);
	}

	get_configuration(&config, argv[1]);

	wattson = open_wattson(config.serial_device_name);

	/* check for excess parameters */
	if (argc > 1)
	{
		print_usage();
	}			


	/* Read power value */
	current_power = get_current_power_with_retry(wattson);
	current_generated_power = get_current_generated_power_with_retry(wattson);

	/* Get date and time */
	time(&basictime);
	strftime(datestring, sizeof(datestring), "%Y-%m-%d %H:%M:%S",
	         localtime(&basictime));

	/* Create the SQL statement */
	sprintf(logline, "INSERT INTO powerReadings (LogTime, GeneratedPower, UsedPower) VALUES ('%s',%d,%d)",datestring,current_generated_power, current_power);
	/* For debugging.. Not good for a cron job.... */
	//printf("INSERT INTO powerReadings (LogTime, GeneratedPower, UsedPower) VALUES ('%s',%d,%d)\n",datestring,current_generated_power, current_power);
	//printf("Connection : h=%s db=%s user=%s pwd=%s\n",config.dbhost,config.dbname, config.dbusername, config.dbpwd);

	/* Connect to the database ... */
  	if (mysql_real_connect(con, config.dbhost, config.dbusername, config.dbpwd, config.dbname, 0, NULL, 0) == NULL) 
	{
		finish_with_error(con);
	}    
    
	/* .. and place the entry therein. */
	if (mysql_query(con, logline))
	{
		finish_with_error(con);
	}


	close_wattson(wattson);
	
	//fclose(fileptr);
	mysql_close (con);

	exit(0);
}

