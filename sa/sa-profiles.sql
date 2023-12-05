/*
File Name: sa-profiles.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PROFILE DEFINITION AND VALUES
-- COUNTING
-- PROFILE DEFINITION ONLY

*/

-- ##############################################################
-- PROFILE DEFINITION AND VALUES
-- ##############################################################

		select fpo.profile_option_name
			 , fpot.user_profile_option_name
			 , fpot.description
			 , to_char(fpo.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , fpo.created_by
			 , to_char(fpo.last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
			 , fpo.last_updated_by
			 , fat.application_name appl
			 , fa.application_short_name app
			 , fpo.user_enabled_flag
			 , fpo.user_updateable_flag
			 , fpo.sql_validation
			 , to_char(fpo.start_date_active, 'yyyy-mm-dd') start_date
			 , to_char(fpo.end_date_active, 'yyyy-mm-dd') end_date
			 , '#' values___
			 , fpov.level_name
			 , fpov.profile_option_value value_
			 , to_char(fpov.last_update_date, 'yyyy-mm-dd hh24:mi:ss') value_updated
			 , fpov.last_updated_by value_updated_by
			 , case when fpov.level_name = 'USER' then (select username from per_users where user_guid = fpov.level_value) else 'N' end value_set_against_user
		  from fnd_profile_options fpo
		  join fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
		  join fnd_application_tl fat on fat.application_id = fpo.application_id and fat.language = userenv('lang')
		  join fnd_application fa on fat.application_id = fa.application_id
		  join fnd_profile_option_values fpov on fpov.profile_option_id = fpo.profile_option_id
		 where 1 = 1
		   -- and fpo.profile_option_name in ('ORA_PJS_ONLINE_SUM_ACTUAL_COST','ORA_PJS_ONLINE_SUM_BUDGET','ORA_PJS_ONLINE_PUSH_ACT','ORA_PJS_ONLINE_SUM_REV_INV','ORA_PJS_CLEAN_ALL')
		   -- and (select username from per_users where user_guid = fpov.level_value) in ('USER123') -- Set at User level for specific user
		   -- and fpov.level_name = 'USER'
		   -- and fpo.profile_option_name like 'AFLOG%'
		   -- and fpov.profile_option_value like '%@%'
		   -- and fpov.last_updated_by = 'USER123'
		   -- and substr(fpov.profile_option_value,1,1) = ' ' or substr(fpov.profile_option_value,-1,1) = ' ' -- trailing spaces
		   and 1 = 1
		   order by to_char(fpo.last_update_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- COUNTING
-- ##############################################################

		select set_against_user
			 , count(*)
		  from (select case when fpov.level_name = 'USER' then (select username from per_users where user_guid = fpov.level_value) else 'N' end set_against_user
				  from fnd_profile_option_values fpov
				  join fnd_profile_options fpo on fpov.profile_option_id = fpo.profile_option_id
				  join fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
				  join fnd_application_tl fat on fat.application_id = fpov.application_id and fat.language = userenv('lang')
				  join fnd_application fa on fat.application_id = fa.application_id
				 where fpov.level_name = 'USER'
				   and case when fpov.level_name = 'USER' then (select username from per_users where user_guid = fpov.level_value) else 'N' end is not null)
	  group by set_against_user
	  order by 2 desc

-- ##############################################################
-- PROFILE DEFINITION ONLY
-- ##############################################################

		select fpo.profile_option_name
			 , fpot.user_profile_option_name
			 , fpot.description
			 , to_char(fpo.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , fpo.created_by
			 , to_char(fpo.last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
			 , fpo.last_updated_by
			 , fat.application_name appl
			 , fa.application_short_name app
			 , fpo.user_enabled_flag
			 , fpo.user_updateable_flag
			 , fpo.sql_validation
			 , to_char(fpo.start_date_active, 'yyyy-mm-dd') start_date
			 , to_char(fpo.end_date_active, 'yyyy-mm-dd') end_date
		  from fnd_profile_options fpo
		  join fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
		  join fnd_application_tl fat on fat.application_id = fpo.application_id and fat.language = userenv('lang')
		  join fnd_application fa on fat.application_id = fa.application_id
		 where 1 = 1
		   and 1 = 1
		   order by to_char(fpo.last_update_date, 'yyyy-mm-dd hh24:mi:ss') desc
