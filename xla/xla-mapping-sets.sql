/*
File Name: xla-mapping-sets.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- XLA MAPPING SETS
-- ##############################################################

		select app.application_name
			 , app.application_id
			 , xmsb.mapping_set_code
			 , xmsb.flexfield_assign_mode_code
			 , xmst.name
			 , xmst.description
			 , xmsb.enabled_flag
			 , to_char(xmsb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , xmsb.created_by
			 , to_char(xmsb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , xmsb.last_updated_by
		  from xla_mapping_sets_b xmsb
		  join xla_mapping_sets_tl xmst on xmst.mapping_set_code = xmsb.mapping_set_code and xmst.language = userenv('lang')
		  join fnd_application_tl app on app.application_id = xmsb.application_id and app.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
