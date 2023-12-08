/*
File Name: iex-collectors.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- COLLECTORS
-- ROLES ASSIGNED TO COLLECTORS
-- DATA ACCESS ASSIGNED TO COLLECTORS

*/

-- ##################################################################
-- COLLECTORS
-- ##################################################################

		select ac.collector_id
			 , to_char(ac.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , ac.created_by
			 , to_char(ac.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ac.last_updated_by
			 , ac.name collector_name
			 , ac.description collector_description
			 , ac.status
			 , ac.set_id
			 , ac.resource_type
			 , '#' || papf.person_number emp_num
			 , pu.username
		  from ar_collectors ac
	 left join per_all_people_f papf on papf.person_id = ac.employee_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_users pu on pu.person_id = papf.person_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(ac.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- ROLES ASSIGNED TO COLLECTORS
-- ##############################################################

		select pu.username
			 , prdt.role_name
			 , prd.role_common_name
			 , to_char(pur.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_created
			 , pur.created_by access_created_by
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_active_status
			 , pu.active_flag user_active_flag
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and pur.active_flag = 'Y'
		   and pur.terminated_flag = 'N'
		   and 1 = 1

-- ##############################################################
-- DATA ACCESS ASSIGNED TO COLLECTORS
-- ##############################################################

with
context as (
		select gl.name, role.role_name, role.creation_date, role.created_by, pu.username, 'Data Access Set' as type from fusion.fun_user_role_data_asgnmnts role join fusion.gl_access_sets gl on role.access_set_id = gl.access_set_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select bu.bu_name, role.role_name, role.creation_date, role.created_by, pu.username, 'Business Unit' as type from fusion.fun_user_role_data_asgnmnts role join fusion.fun_all_business_units_v bu on role.org_id = bu.bu_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select led.name, role.role_name, role.creation_date, role.created_by, pu.username, 'Ledger' as type from fusion.fun_user_role_data_asgnmnts role join fusion.gl_ledgers led on role.ledger_id = led.ledger_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select book.book_type_code name, role.role_name, role.creation_date, role.created_by, pu.username, 'Asset Book' as type from fusion.fun_user_role_data_asgnmnts role join fusion.fa_book_controls book on role.book_id = book.book_control_id join fusion.per_users pu on role.user_guid = pu.user_guid union select interco.interco_org_name name, role.role_name, role.creation_date, role.created_by, pu.username, 'Intercompany Organization' as type from fusion.fun_user_role_data_asgnmnts role join fusion.fun_interco_organizations interco on role.interco_org_id = interco.interco_org_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select cost.cost_org_name name, role.role_name, role.creation_date, role.created_by, pu.username, 'Cost Organization' as type from fusion.fun_user_role_data_asgnmnts role join fusion.cst_cost_orgs_v cost on role.cst_organization_id = cost.cost_org_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select mfg.def_supply_subinv name, role.role_name, role.creation_date, role.created_by, pu.username, 'Manufacturing Plant' as type from fusion.fun_user_role_data_asgnmnts role join fusion.rcs_mfg_parameters mfg on role.mfg_organization_id = mfg.organization_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select budget.name, role.role_name, role.creation_date, role.created_by, pu.username, 'Control Budget' as type from fusion.fun_user_role_data_asgnmnts role join fusion.xcc_control_budgets budget on role.control_budget_id = budget.control_budget_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select st.set_name name, role.role_name, role.creation_date, role.created_by, pu.username, 'Reference Data Set' as type from fusion.fun_user_role_data_asgnmnts role join fusion.fnd_setid_sets_vl st on role.set_id = st.set_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select inv.organization_code name, role.role_name, role.creation_date, role.created_by, pu.username, 'Inventory Organization' as type from fusion.fun_user_role_data_asgnmnts role join fusion.inv_org_parameters inv on role.inv_organization_id = inv.organization_id join fusion.per_users pu on role.user_guid = pu.user_guid union
		select hr.name name, role.role_name, role.creation_date, role.created_by, pu.username, 'Project Organization Classification' as type from fusion.fun_user_role_data_asgnmnts role join fusion.hr_organization_units_f_tl hr on role.prj_organization_id = hr.organization_id join fusion.per_users pu on role.user_guid = pu.user_guid)
			 , context_values as (select name, role_name, username, type, creation_date , created_by from context)
		select pu.username
			 , prdv.role_name
			 , context_values.role_name as role_code
			 , context_values.type as context
			 , context_values.name as value
			 , to_char(context_values.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_created
			 , context_values.created_by access_created_by
			 , to_char(pur.start_date, 'yyyy-mm-dd') start_date
			 , to_char(pur.end_date, 'yyyy-mm-dd') end_date
		  from per_users pu
		  join fusion.per_user_roles pur on pu.user_id = pur.user_id -- and sysdate between nvl(pur.start_date, sysdate-1) and nvl(pur.end_date, sysdate+1) -- active access only
		  join fusion.per_roles_dn_vl prdv on pur.role_id = prdv.role_id
		  join context_values on (pu.username = context_values.username and prdv.role_common_name = context_values.role_name)
		 where 1 = 1
		   and pu.username in (select pu.username from ar_collectors ac join per_users pu on pu.person_id = ac.employee_id)
		   and prdv.role_name in ('Collections Agent','Collections Manager')
		   and 1 = 1
