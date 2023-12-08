/*
File Name: xla-mapping-sets.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- XLA MAPPING SETS - DEFINITION
-- XLA MAPPING SETS - VALUES

*/

-- ##############################################################
-- XLA MAPPING SETS - DEFINITION
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

-- ##############################################################
-- XLA MAPPING SETS - VALUES
-- ##############################################################

		select app.application_name
			 , app.application_id
			 , xmsb.mapping_set_code
			 , xmsb.flexfield_assign_mode_code
			 , xmst.name
			 , xmst.description
			 , xmsb.enabled_flag
			 , to_char(xmsb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date_set
			 , xmsb.created_by created_by_set
			 , to_char(xmsb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date_set
			 , xmsb.last_updated_by last_updated_by_set
			 , '#' values_
			 , haou.name exp_org
			 , xmsv.value_constant
			 , to_char(xmsv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date_value
			 , xmsv.created_by created_by_value
			 , to_char(xmsv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date_value
			 , xmsv.last_updated_by last_updated_by_value
		  from xla_mapping_sets_b xmsb
		  join xla_mapping_sets_tl xmst on xmst.mapping_set_code = xmsb.mapping_set_code and xmst.language = userenv('lang')
		  join xla_mapping_set_values xmsv on xmsv.mapping_set_code = xmsb.mapping_set_code
		  join fnd_application_tl app on app.application_id = xmsb.application_id and app.language = userenv('lang')
		  join hr_all_organization_units haou on haou.organization_id = xmsv.input_value_constant1
		 where 1 = 1
		   and xmsb.mapping_set_code = 'XX_HR_ORG_CC'
		   and 1 = 1
