/*
File Name: po-agents.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- PO AGENTS / BUYERS
-- ##############################################################

		select to_char(paa.creation_date, 'yyyy-mm-dd hh24:mi:ss') agent_created
			 , papf.person_id
			 , papf.person_number
			 , ppnf.full_name
			 , ppnf.display_name
			 , fu.username
			 , decode(fu.suspended, 'N', 'Active', 'Y', 'Inactive') status
			 , to_char(fu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(fu.end_date, 'yyyy-mm-dd') user_end
			 , nvl(pea.email_address, 'no-email') email_address
		  from po_agent_assignments paa
		  join per_all_people_f papf on paa.agent_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_users fu on fu.person_id = papf.person_id
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' -- not all users have email addresses
	  order by to_char(paa.creation_date, 'yyyy-mm-dd hh24:mi:ss')
