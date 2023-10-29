/*
File Name: xla-event-types.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- EVENT TYPES DEFINITION
-- ##############################################################

		select fat.application_name appl
			 , xetb.entity_code
			 , xetb.event_class_code
			 , xetb.event_type_code
			 , xett.name event_type_name
			 -- , xetb.accounting_flag
			 -- , xetb.tax_flag
			 , xetb.enabled_flag
			 -- , xetb.transaction_reversal_flag
		  from xla_event_types_b xetb
		  join xla_event_types_tl xett on xett.event_class_code = xetb.event_class_code and xett.language = userenv('lang')
		  join fnd_application_tl fat on fat.application_id = xetb.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
