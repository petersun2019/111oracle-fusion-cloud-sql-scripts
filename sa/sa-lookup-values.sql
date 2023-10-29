/*
File Name: sa-lookup-values.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- LOOKUP VALUES
-- LOOKUP VALUES - COUNT SUMMARY
-- TABLE DUMPS

*/

-- ##############################################################
-- LOOKUP VALUES
-- ##############################################################

		select flv.lookup_type
			 , '#' || flv.lookup_code
			 , flv.set_id reference_data_set
			 , flvb.display_sequence display_seq
			 , flv.enabled_flag
			 , to_char(flv.start_date_active, 'yyyy-mm-dd') start_date
			 , to_char(flv.end_date_active, 'yyyy-mm-dd') end_date
			 , flv.meaning
			 , flv.description
			 , '########'
			 , flv.creation_date
			 , flv.created_by
			 , flv.view_application_id
			 -- , fa.application_short_name appl
			 -- , fat.application_name
		  from fnd_lookup_values_vl flv
		  join fnd_lookup_values_b flvb on flvb.lookup_type = flv.lookup_type and flvb.lookup_code = flv.lookup_code and flv.view_application_id = flvb.view_application_id
	 left join fnd_application fa on fa.application_id = flv.view_application_id
	 left join fnd_application_tl fat on fat.application_id = fa.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- LOOKUP VALUES - COUNT SUMMARY
-- ##############################################################

		select flv.lookup_type
			 , flv.view_application_id
			 , fat.application_name
			 , count(*)
		  from fnd_lookup_values_vl flv
		  join fnd_application_tl fat on fat.application_id = flv.view_application_id
		 where 1 = 1
		   and 1 = 1
		having count(*) = 10
	  group by flv.lookup_type
			 , flv.view_application_id
			 , fat.application_name
	  order by flv.lookup_type
			 , flv.view_application_id

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from fnd_lookup_values_vl where lookup_type in ('POSTED PAID STATUS','POSTING STATUS','INVOICE PAYMENT STATUS');
select * from fnd_lookup_types_tl where lookup_type like 'VEND%TYP%';
select * from ar_lookups where lookup_code in ('A1','A2','A3','A4','A5')
