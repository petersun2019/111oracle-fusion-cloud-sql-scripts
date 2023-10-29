/*
File Name: sa-profiles.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

I used this when trying to link up a payroll transaction number appearing in a Payroll Create Accounting report's output With the SLA data

Queries:

-- PROFILE VALUES
-- COUNTING
-- PROFILE DEFINITION

*/

-- ##############################################################
-- PROFILE VALUES
-- ##############################################################

		select fpo.profile_option_name profile_name
			 , fpot.user_profile_option_name profile 
			 , fpov.level_name
			 , fpov.profile_option_value value
			 , to_char(fpov.last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
			 , fpov.last_updated_by updated_by
			 , fat.application_name appl
			 , fa.application_short_name app
			 , case when fpov.level_name = 'USER' then (select username from per_users where user_guid = fpov.level_value) else 'N' end set_against_user
		  from fnd_profile_option_values fpov
		  join fnd_profile_options fpo on fpov.profile_option_id = fpo.profile_option_id
		  join fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
		  join fnd_application_tl fat on fat.application_id = fpov.application_id and fat.language = userenv('lang')
		  join fnd_application fa on fat.application_id = fa.application_id
		 where 1 = 1
		   -- and fpo.profile_option_name in ('ORA_PJS_ONLINE_SUM_ACTUAL_COST','ORA_PJS_ONLINE_SUM_BUDGET','ORA_PJS_ONLINE_PUSH_ACT','ORA_PJS_ONLINE_SUM_REV_INV','ORA_PJS_CLEAN_ALL')
		   -- and (select username from per_users where user_guid = fpov.level_value) in ('USER123') -- Set at User level for specific user
		   -- and fpov.level_name = 'USER'
		   -- and fpo.profile_option_name like 'AFLOG%'
		   and fpov.profile_option_value like '%@%'
		   -- and fpov.last_updated_by = 'USER123'
		   and 1 = 1
	  order by fpov.last_update_date desc

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
-- PROFILE DEFINITION
-- ##############################################################

		select fpo.profile_option_name
			 , fpot.user_profile_option_name
			 , to_char(fpov.last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
			 , fpov.last_updated_by
			 , fpov.level_name
			 , fpov.level_value
			 , fpov.profile_option_value value
		  from fnd_profile_option_values fpov 
		  join fnd_profile_options fpo on fpov.profile_option_id = fpo.profile_option_id
		  join fnd_profile_options_tl fpot on fpot.profile_option_name = fpo.profile_option_name and fpot.language = userenv('lang')
		 where 1 = 1
		   -- and fpov.profile_option_value like '%@%'
		   -- and fpot.user_profile_option_name = 'Number of Parallel Summarization Extraction Programs'
		   and lower(fpot.user_profile_option_name) like '%cross%'
		   and 1 = 1
