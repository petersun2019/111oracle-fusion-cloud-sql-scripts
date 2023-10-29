/*
File Name: sa-users.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Some users have no hr record but still have a first name and last name on their user account record on IT Security Manager
There is a table called PER_LDAP_USERS which joins to per_users via PER_LDAP_USERS.USER_GUID = PER_USERS.USER_GUID
PER_LDAP_USERS has first_name, last_name, email

Oracle Docs:
https://docs.oracle.com/en/cloud/saas/human-resources/22d/oedmh/perldapusers-8317.html
PER_LDAP_USERS
Table for storing one record for each user to be processed in OIM when creating new users or maintaining user details (including username and preferred language)

Login Audit History table: ASE_USER_LOGIN_INFO
Does not get populated until "Import User Login History" job runs.

Queries:

-- USER ACCOUNTS 1
-- USER ACCOUNTS 2
-- USER ACCOUNTS 3
-- USER ACCOUNTS - FIND USERNAMES WITH LEADING OR TRAILING SPACES

*/

-- ##############################################################
-- USER ACCOUNTS 1
-- ##############################################################

		select pu.username
			 , pu.user_guid
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') status
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , to_char(pu.creation_date, 'yyyy-mm-dd hh24:mi:ss') user_created
			 , pu.created_by user_created_by
			 , to_char(pu.last_update_date, 'yyyy-mm-dd hh24:mi:ss') user_updated
			 , (select to_char(s.last_login_date, 'yyyy-mm-dd hh24:mi:ss') from ase_user_login_info s where s.user_guid = pu.user_guid) last_login_date
			 , pu.last_updated_by user_updated_by
			 , papf.person_number
			 , nvl(pea.email_address, 'no-email') email_address
			 , '#' || papf.person_id person_id
			 , ppnf.full_name
			 , ppnf.display_name
			 , paaf.assignment_number assignment
			 , paaf.assignment_id
			 , paaf.last_update_date
			 , paaf.last_updated_by
			 , paaf.primary_flag
			 -- , plu.first_name
			 -- , plu.last_name
			 -- , plu.email
		  from per_users pu
		  -- join per_ldap_users plu on plu.user_guid = pu.user_guid
	 left join per_all_people_f papf on pu.person_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' -- not all users have email addresses
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_assignments_m paaf on paaf.person_id = papf.person_id and sysdate between paaf.effective_start_date and paaf.effective_end_date and paaf.primary_flag = 'Y' and paaf.assignment_type = 'E'
		 where 1 = 1
		   and 1 = 1
	  order by pu.last_update_date desc

-- ##############################################################
-- USER ACCOUNTS 2
-- ##############################################################

/*
https://community.oracle.com/customerconnect/discussion/comment/616402#comment_616402
*/

		select pu.username
			 , papf.person_number
			 , nvl(ppnf.first_name, ldap.first_name) first_name
			 , nvl(ppnf.last_name, ldap.last_name) last_name
			 , nvl(pea.email_address, ldap.email) email
			 , (select to_char(s.last_login_date, 'mm/dd/yyyy hh24:mm') from ase_user_login_info s where s.user_guid = pu.user_guid) last_login_date
			 , pu.active_flag
			 , pu.created_by
			 , to_char(pu.creation_date, 'mm/dd/yyyy hh24:mm') as creation_dt
			 , pu.last_updated_by
			 , to_char(pu.last_update_date, 'mm/dd/yyyy hh24:mm') as last_update_dt
			 , pu.suspended
			 , pu.credentials_email_sent
			 , pu.user_guid
			 , paam.assignment_status_type
			 , paam.system_person_type
			 , to_char(ppos.actual_termination_date,'mm/dd/yyyy') as termination_date
			 , auv.user_display_name
		  from per_users pu
	 left join per_person_names_f ppnf on ppnf.person_id = pu.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_email_addresses pea on pea.person_id = pu.person_id and pea.email_type = 'W1'
	 left join per_all_assignments_m paam on paam.person_id = pu.person_id and paam.assignment_type in ('E','C','N','P') and paam.effective_latest_change = 'Y' and sysdate between paam.effective_start_date and paam.effective_end_date
	 left join per_periods_of_service ppos on ppos.person_id = paam.person_id and ppos.period_of_service_id = paam.period_of_service_id
	 left join per_all_people_f papf on papf.person_id = pu.person_id
	 left join ase_user_vl auv on auv.user_id = pu.user_id
	 left join (select distinct
					   l.first_name
					 , l.last_name
					 , l.email
					 , l.username
					 , l.user_guid
				  from per_ldap_users l 
				 where l.first_name is not null
				   and l.creation_date = (select max(l1.creation_date) from per_ldap_users l1 where l1.username = l.username and l1.user_guid = l.user_guid)) ldap on ldap.user_guid = pu.user_guid and ldap.username = pu.username
		 where 1 = 1
		   and paam.effective_latest_change = 'Y'
		   and paam.primary_flag = 'Y'
		   and 1 = 1

-- ##############################################################
-- USER ACCOUNTS 3
-- ##############################################################

		select pu.username
			 , papf.person_id
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') status
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , papf.person_number
			 , nvl(pea.email_address, 'no-email') email_address
			 , papf.person_id
			 , papf.creation_date
			 , papf.created_by
			 , papf.last_update_date
			 , papf.last_updated_by
			 , ppnf.full_name
			 , ppnf.display_name
			 , plu.first_name
			 , plu.last_name
			 , plu.email
		  from per_users pu
	 left join per_ldap_users plu on plu.user_guid = pu.user_guid
	 left join per_all_people_f papf on pu.person_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' -- not all users have email addresses
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- USER ACCOUNTS - FIND USERNAMES WITH LEADING OR TRAILING SPACES
-- ##############################################################

		select pu.username
			 , replace(pu.username,' ','___') username_space
			 , case when substr(username,1,1) = ' ' then '<-- leading'
					when substr(username,-1,1) = ' ' then 'trailing -->'
			   end space_issue
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') status
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.creation_date, 'yyyy-mm-dd hh24:mi:ss') user_created
			 , pu.created_by user_created_by
			 , '#' || papf.person_number person_number
			 , nvl(pea.email_address, 'no-email') email_address
			 , '#' || papf.person_id person_id
			 , ppnf.full_name
			 , ppnf.display_name
		  from per_users pu
	 left join per_all_people_f papf on pu.person_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' -- not all users have email addresses
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
		 where 1 = 1
		   and substr(username,1,1) = ' ' or substr(username,-1,1) = ' '
		   and 1 = 1
