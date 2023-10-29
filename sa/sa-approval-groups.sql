/*
File Name: sa-approval-groups.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- APPROVAL GROUP MEMBERS - BASIC
-- APPROVAL GROUP MEMBERS - LINKED TO USERS AND STAFF

*/

-- ##############################################################
-- APPROVAL GROUP MEMBERS - BASIC
-- ##############################################################

		select grp.approvalgroupname approvalgroup
			 , mem.member member
		  from fa_fusion_soainfra.wfapprovalgroups grp
		  join fa_fusion_soainfra.wfapprovalgroupmembers mem on grp.approvalgroupid = mem.approvalgroupid

-- ##############################################################
-- APPROVAL GROUP MEMBERS - LINKED TO USERS AND STAFF
-- ##############################################################

		select grp.approvalgroupname approvalgroup
			 , mem.member member
			 , fu.username
			 , decode(fu.suspended, 'N', 'Active', 'Y', 'Inactive') user_status
			 , to_char(fu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(fu.end_date, 'yyyy-mm-dd') user_end
			 , papf.person_number
			 , nvl(pea.email_address, 'no-email') email_address
			 , papf.person_id
			 , ppnf.full_name
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.display_name
		  from fa_fusion_soainfra.wfapprovalgroups grp
		  join fa_fusion_soainfra.wfapprovalgroupmembers mem on grp.approvalgroupid = mem.approvalgroupid
	 left join per_users fu on fu.username = mem.member
	 left join per_all_people_f papf on fu.person_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' -- not all users have email addresses
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
		 where 1 = 1
		   and 1 = 1

