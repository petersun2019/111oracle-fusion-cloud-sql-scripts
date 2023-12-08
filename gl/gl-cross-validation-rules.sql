/*
File Name: gl-cross-validation-rules.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

*/

-- ##############################################################
-- CROSS VALIDATION RULES
-- ##############################################################

		select to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , created_by
			 , enabled_flag
			 , enterprise_id
			 , structure_instance_id
			 , rule_code
			 , description
			 , error_msg_application_id
			 , error_msg_name
			 , start_date_active
			 , end_date_active
			 , last_update_date
			 , to_char(last_update_date, 'yyyy-mm-dd hh24:mi:ss')
			 , last_updated_by
			 , seed_data_source
			 , ora_seed_set1
			 , ora_seed_set2
		  from fnd_kf_cross_val_rules
