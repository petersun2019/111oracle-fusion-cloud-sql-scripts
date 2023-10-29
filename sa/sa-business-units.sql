/*
File Name: sa-business-units.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- BUSINESS UNITS - BASIC DEFINITION
-- BUSINESS UNITS - RELATED FUNCTIONS

See also: gl/gl-ledgers-legal-entities.sql

*/

-- ##############################################################
-- BUSINESS UNITS - BASIC DEFINITION
-- ##############################################################

		select '#' || fabuv.bu_id business_unit_id
			 , fabuv.bu_name bu_name
			 , fabuv.short_code short_code
			 , fabuv.status status
			 , to_char(fabuv.date_from, 'yyyy-mm-dd') date_from
			 , to_char(fabuv.date_to, 'yyyy-mm-dd') date_to
			 , to_char(fabuv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , fabuv.created_by
			 , to_char(fabuv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , fabuv.last_updated_by
		  from fun_all_business_units_v fabuv
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUSINESS UNITS - RELATED FUNCTIONS
-- ##############################################################

		select '#' || fbu.business_unit_id business_unit_id
			 , fabuv.bu_name bu_name
			 , fabuv.short_code short_code
			 , fabuv.status status
			 , fbu.module_id module_id
			 , fbfv.business_function_code module_key
			 , fbfv.business_function_name module_name
			 , fbu.configuration_status configuration_status
			 , fabuv.creation_date
			 , fabuv.created_by
			 , fabuv.last_update_date
			 , fabuv.last_updated_by
		  from fun_bu_usages fbu
		  join fun_all_business_units_v fabuv on fbu.business_unit_id = fabuv.bu_id
		  join fun_business_functions_vl fbfv on fbu.module_id = fbfv.business_function_id
		 where 1 = 1
		   and 1 = 1
