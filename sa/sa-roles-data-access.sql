/*
File Name: sa-roles-data-access.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- DATA ACCESS REPORT 1
-- DATA ACCESS REPORT 2
-- DATA ACCESS REPORT 3
-- COMPARE DATA ACCESS BETWEEN TWO USERS
-- COUNT BY USER AND ROLE AND DATA ASSIGNMENT

*/

-- ##############################################################
-- DATA ACCESS REPORT 1
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
		   and 1 = 1

-- ##############################################################
-- DATA ACCESS REPORT 2
-- ##############################################################

/*
when add data access to a role and user, a record is added to FUN_USER_ROLE_DATA_ASGNMNTS
That links role and user
Also the field in FUN_USER_ROLE_DATA_ASGNMNTS changes depending on the data access being added.
e.g. for Business Unit - field is FUN_USER_ROLE_DATA_ASGNMNTS.ORG_ID, for data access set = FUN_USER_ROLE_DATA_ASGNMNTS.ACCESS_SET_ID
Found that can remove a role access via it Security Manager, but the corresponding data access record for the role is not removed, unless you go and remove it manually.
If you remove a data access, then the record remains in FUN_USER_ROLE_DATA_ASGNMNTS but the active_flag changes to N.
Changes back to Y if you set it up again.
*/

		select prdt.role_name
			 , prd.role_common_name
			 , pu.username
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_status
			 , fbc.book_type_name asset_book
			 , fabuv.bu_name business_unit
			 , furda.datasec_context_type_code award_org_hierarchy
			 , fssv.set_name reference_data_set
			 , gas.name data_access_set
			 , fio.interco_org_name intercompany_org_name
			 , iop.organization_code inventory_org
			 , gl.name ledger
			 , houft.name project_org_classification
			 , xcb.name control_budget
			 , rmp.def_supply_subinv manufacturing_plant
			 , ccov.cost_org_name cost_organization
			 -- , '###################'
			 -- , furda.active_flag
			 , furda.creation_date
			 , furda.created_by 
			 -- , furda.last_update_date
			 -- , furda.last_updated_by
			 , nvl2(pur.active_flag, 'Y','N') user_has_access_to_role
			 , pur.creation_date role_access_created
			 , pur.created_by role_access_created_by
		  from per_roles_dn_tl prdt
	 left join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
	 left join fun_user_role_data_asgnmnts furda on furda.role_name = prd.role_common_name
	 left join per_users pu on furda.user_guid = pu.user_guid
	 left join fa_book_controls fbc on fbc.book_control_id = furda.book_id
	 left join fun_all_business_units_v fabuv on fabuv.bu_id = furda.org_id
	 left join fnd_setid_sets_vl fssv on fssv.set_id = furda.set_id
	 left join gl_access_sets gas on gas.access_set_id = furda.access_set_id
	 left join fun_interco_organizations fio on fio.interco_org_id = furda.interco_org_id
	 left join inv_org_parameters iop on iop.organization_id = furda.inv_organization_id
	 left join gl_ledgers gl on gl.ledger_id = furda.ledger_id
	 left join hr_organization_units_f_tl houft on houft.organization_id = furda.prj_organization_id
	 left join per_user_roles pur on pur.role_id = prd.role_id and pur.user_id = pu.user_id
	 left join xcc_control_budgets xcb on xcb.control_budget_id = furda.control_budget_id
	 left join rcs_mfg_parameters rmp on rmp.organization_id = furda.mfg_organization_id
	 left join cst_cost_orgs_v ccov on ccov.cost_org_id = furda.cst_organization_id
		 where 1 = 1
		   -- and nvl2(pur.active_flag, 'Y','N') = 'Y' -- user has data access and the role the data access is linked to
		   -- and nvl2(pur.active_flag, 'Y','N') = 'N' -- user has data access but no longer has the role the data access is linked to
		   and 1 = 1

-- ##############################################################
-- DATA ACCESS REPORT 3
-- ##############################################################

  SELECT u.person_id,
         u.username,
         s.start_date_active,
         s.end_date_active,
         s.active_flag,
         r.role_name,
         r.role_common_name,
         (SELECT bu.bu_name
            FROM fun_all_business_units_v bu
           WHERE s.org_id = bu.bu_id)
            business_unit,
         s.org_id bu_id,
         (SELECT ic.interco_org_name
            FROM fun_interco_organizations ic
           WHERE s.interco_org_id = ic.interco_org_id)
            ic_org_name,
         (SELECT a.book_type_name
            FROM fa_book_controls a
           WHERE s.book_id = a.book_control_id)
            asset_book,
         (SELECT g.name
            FROM gl_ledgers g
           WHERE s.ledger_id = g.ledger_id)
            ledger_name,
         (SELECT b.name
            FROM xcc_control_budgets b
           WHERE s.control_budget_id = b.control_budget_id)
            budget_name,
         (SELECT gs.name
            FROM gl_access_sets gs
           WHERE s.access_set_id = gs.access_set_id)
            data_access_set,
         (SELECT rs.set_name
            FROM fnd_setid_sets_vl rs
           WHERE s.set_id = rs.set_id)
            reference_set_name,
	-- (select username from per_users where person_id =  (select manager_id from per_assignment_supervisors_f where person_Id = :PersonId and sysdate between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE )) manager_username,
	-- (select manager_id from per_assignment_supervisors_f where person_Id = :PersonId and sysdate between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE) manager_id,
	-- (select EMAIL_ADDRESS from PER_EMAIL_ADDRESSES where  EMAIL_TYPE='W1' And person_Id= (select manager_id from per_assignment_supervisors_f where person_Id = :PersonId and sysdate between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE )) manager_email_address,
	-- (select EMAIL_ADDRESS from PER_EMAIL_ADDRESSES where person_Id=u.person_id and EMAIL_TYPE='W1' ) user_email_address,
	g.LEGAL_ENTITY_NAME,g.legal_entity_id,u.suspended
	/*(SELECT g.LEGAL_ENTITY_NAME
            FROM GL_LEDGER_LE_V g
           WHERE s.ledger_id = g.ledger_id)
            LEGAL_ENTITY_NAME,
	(SELECT g.legal_entity_id
            FROM GL_LEDGER_LE_V g
           WHERE s.ledger_id = g.ledger_id)
            legal_entity_id	*/ --26-aug-2021 issue has been identified for multiple ledger 	
    from fun_user_role_data_asgnmnts s, per_users u, per_roles_dn_vl r ,GL_LEDGER_LE_V g, PER_USER_ROLES PUR
   WHERE s.user_guid = u.user_guid AND s.role_name = r.role_common_name
   and  s.ledger_id  = g.ledger_id(+)
AND s.active_flag <> 'N' 
AND u.USER_ID = PUR.USER_ID
AND PUR.ROLE_ID = r.ROLE_ID
AND PUR.active_flag = 'Y'
ORDER BY u.username, r.role_name

-- ##############################################################
-- COMPARE DATA ACCESS BETWEEN TWO USERS
-- ##############################################################

/*
Useful to see which Data Access one user might have compared to another
*/

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
			 , context_values as (select name , role_name , username , type , creation_date , created_by from context)
		select prdv.role_name
			 , context_values.role_name as role_code
			 , context_values.type as context
			 , context_values.name as value
		  from per_users pu
	 left join fusion.per_user_roles pur on pu.user_id = pur.user_id -- and sysdate between nvl(pur.start_date, sysdate-1) and nvl(pur.end_date, sysdate+1) -- active access only
	 left join fusion.per_roles_dn_vl prdv on pur.role_id = prdv.role_id
	 left join context_values on (pu.username = context_values.username and prdv.role_common_name = context_values.role_name)
		 where 1 = 1
		   and 1 = 1
		 minus
		select prdv.role_name
			 , context_values.role_name as role_code
			 , context_values.type as context
			 , context_values.name as value
		  from per_users pu
	 left join fusion.per_user_roles pur on pu.user_id = pur.user_id -- and sysdate between nvl(pur.start_date, sysdate-1) and nvl(pur.end_date, sysdate+1) -- active access only
	 left join fusion.per_roles_dn_vl prdv on pur.role_id = prdv.role_id
	 left join context_values on (pu.username = context_values.username and prdv.role_common_name = context_values.role_name)
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- COUNT BY USER AND ROLE AND DATA ASSIGNMENT
-- ##############################################################

		select prdt.role_name
			 , prd.role_common_name
			 , pu.username
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_status
			 , count(*) ct
		  from per_roles_dn_tl prdt
	 left join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
	 left join fun_user_role_data_asgnmnts furda on furda.role_name = prd.role_common_name
	 left join per_users pu on furda.user_guid = pu.user_guid
		 where 1 = 1
		   and 1 = 1
	  group by prdt.role_name
			 , prd.role_common_name
			 , pu.username
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive')
