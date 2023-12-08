/*
File Name: gl-periods.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- GL PERIODS DEFINITIONS
-- GL PERIODS - STATUS

*/

-- ##############################################################
-- GL PERIODS DEFINITIONS
-- ##############################################################

		select *
		  from gl_periods
		 where 1 = 1
		   -- and sysdate between start_date and end_date -- list period for current date
		   and 1 = 1

-- ##############################################################
-- GL PERIODS - STATUS
-- ##############################################################

/*
Lists Accounting Periods per module, and whether they are open or closed
*/

		select gps.period_name
			 , gsob.name set_of_books
			 , gsob.set_of_books_id
			 , flv_status.meaning || ' - ' || gps.closing_status period_status
			 , to_char(gps.start_date, 'yyyy-mm-dd') start_date
			 , to_char(gps.end_date, 'yyyy-mm-dd') end_date
			 , to_char(gps.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gps.last_updated_by
			 , gps.application_id
			 , fa.application_short_name appl
			 , fat.application_name
		  from gl_period_statuses gps
	 left join gl_sets_of_books gsob on gps.set_of_books_id = gsob.set_of_books_id
	 left join fnd_application fa on gps.application_id = fa.application_id
	 left join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_lookup_values_vl flv_status on gps.closing_status = flv_status.lookup_code and flv_status.view_application_id = 101 and flv_status.lookup_type = 'CLOSING_STATUS'
		 where 1 = 1
		   -- and (sysdate) between gps.start_date and gps.end_date -- list periods for current date
		   and 1 = 1
	  order by gps.last_update_date desc
