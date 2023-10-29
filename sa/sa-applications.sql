/*
File Name: sa-applications.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- APPLICATIONS
-- ##############################################################

		select fa.application_id
			 , fa.application_short_name
			 , fat.application_name 
		  from fnd_application fa
		  join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  order by 1
