/*
File Name: po-procurement-agents.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- REQ ACTION HISTORY
-- PO ACTION HISTORY

*/

-- ##############################################################
-- PROCUREMENT AGENTS
-- ##############################################################

/*
https://www.oracleappsdna.com/2020/05/sql-query-to-get-list-of-procurement-agents-in-oracle-erp-coud/
*/

		select ppf.display_name
			 , pu.username
			 , hou.name bu_name
			 , paa.access_action_code
			 , paa.active_flag
			 , paa.access_others_level_code
		  from po_agent_accesses paa
		  join per_person_names_f_v ppf on paa.agent_id = ppf.person_id
		  join per_users pu on pu.person_id = ppf.person_id
		  join hr_organization_units hou on hou.organization_id = paa.prc_bu_id
		 where 1 = 1
		   -- and lower(pu.username) like '%fire%'
		   and paa.access_action_code = 'MANAGE_PURCHASE_ORDERS'
		   and paa.access_others_level_code = 'FULL'
		   and 1 = 1
