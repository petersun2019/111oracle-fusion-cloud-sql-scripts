/*
File Name: po-categories.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- PO CATEGORIES
-- ##############################################################

		select catt.category_name
			 , catt.category_id 
			 , catb.created_by
			 , catb.category_code
			 , to_char(catb.creation_date, 'yyyy-mm-dd HH24:MI:SS') cat_created
			 , catb.enabled_flag
			 , catb.end_date_active
		  from egp_categories_b catb
		  join egp_categories_tl catt on catb.category_id = catt.category_id
		 where 1 = 1
		   and 1 = 1
