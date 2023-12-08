/*
File Name: dba-schema-browser.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLES 1
-- TABLES 2
-- TABLE ROW COUNT PER MODULE
-- VIEWS
-- TABLES AND COLUMNS
-- OBJECTS

*/

-- ##############################################################
-- TABLES 1
-- ##############################################################

		select distinct upper(table_name)
			 , num_rows 
		  from all_tables
		 where 1 = 1
		   and upper(table_name) like '%IMPORT%'
		   -- and num_rows between 1300 and 1400
		   and num_rows > 0
	  order by num_rows desc

-- ##############################################################
-- TABLES 2
-- ##############################################################

			select distinct upper(table_name)
				 , num_rows
			  from all_tables
			 where num_rows > 0
			   and upper(table_name) like '%MAP%'

-- ##############################################################
-- TABLE ROW COUNT PER MODULE
-- ##############################################################

		select upper(regexp_substr(tbl.table_name, '[^_]+', 1, 1)) segment1
			 , sum(tbl.num_rows) row_count
			 , count(tbl.table_name) table_count
			 , fa.application_short_name
			 , fat.application_name
		  from all_tables tbl
	 left join fnd_application fa on upper(regexp_substr(tbl.table_name, '[^_]+', 1, 1)) = fa.application_short_name
	 left join fnd_application_tl fat on fa.application_id = fat.application_id
		 where tbl.num_rows > 0
		   -- and upper(tbl.table_name) like 'PJ%'
		   and tbl.table_name not like '%$%'
	  group by upper(regexp_substr(tbl.table_name, '[^_]+', 1, 1))
			 , fa.application_short_name
			 , fat.application_name

-- ##############################################################
-- VIEWS
-- ##############################################################

		select distinct upper(view_name)
		  from all_views
		 where upper(view_name) like '%HIERARCH%%'
	  order by 1

-- ##############################################################
-- TABLES AND COLUMNS
-- ##############################################################

		select distinct upper(atc.table_name)
             , att.num_rows
			 , atc.column_name
			 , atc.data_type
             -- , atc.data_length
		  from all_tab_columns atc
		  join all_tables att on upper(atc.table_name) = upper(att.table_name)
		 where 1 = 1
		   and upper(atc.column_name) = 'ACCOUNTING_EVENT_ID'
		   -- and upper(atc.column_name) = 'NOTES'
		   -- and upper(atc.table_name) like 'Z%'
		   and att.num_rows > 0
		   -- and atc.data_type = 'DATE'
		   -- and atc.data_length = 80
	  order by att.num_rows desc
			 , upper(atc.table_name)

-- ##############################################################
-- OBJECTS
-- ##############################################################

select * from all_objects
