/*
File Name: sa-role-mappings.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- MANAGE ROLE PROVISIONING RULES - HEADERS
-- MANAGE ROLE PROVISIONING RULES - HEADERS - COUNT
-- MANAGE ROLE PROVISIONING RULES - DETAILS WITH ROLES
-- MANAGE DATA ACCESS PROVISIONING 1
-- MANAGE DATA ACCESS PROVISIONING 2

*/

-- ##############################################################
-- MANAGE ROLE PROVISIONING RULES - HEADERS
-- ##############################################################

/*
BASIC SUMMARY NOT LINKED TO ROLES
*/

		select prm.mapping_name
			 , to_char(prm.creation_date, 'yyyy-mm-dd hh24:mi:ss') mapping_created
			 , prm.created_by mapping_created_by
			 , to_char(prm.last_update_date, 'yyyy-mm-dd hh24:mi:ss') mapping_updated
			 , prm.last_updated_by mapping_updated_by
			 , to_char(prm.date_from, 'yyyy-mm-dd') date_from
			 , to_char(prm.date_to, 'yyyy-mm-dd') date_to
			 , (select count(*) from per_role_mapping_roles prmr where prm.role_mapping_id = prmr.role_mapping_id) roles_count
			 , (select count(*) from per_all_assignments_m paam2 where paam2.position_id = hap.position_id and sysdate between paam2.effective_start_date and paam2.effective_end_date) hr_records_linked_to_pos
			 , hap.position_id
			 , ple.name legal_employer_name
			 , pou.name business_unit
			 , pd.name as department
			 , pj.name as job
			 , pj.job_code
			 , hap.name position
			 , hap.position_code
			 , pg.name as grade
			 , hl.location_name location
			 , prm.assignment_type
			 , flv_person_type.meaning system_person_type
			 , ppt.user_person_type
			 , flv_active.meaning hr_assignment_status
			 , paam.assignment_status_type
			 , decode(prm.current_manager_flag,'N','No','Y','Yes',prm.current_manager_flag) as manager_with_reports
			 , prm.manager_type
			 , flv_resp_type.meaning resp_type
		  from per_role_mappings prm
	 left join per_jobs pj on prm.job_id = pj.job_id and sysdate between pj.effective_start_date and pj.effective_end_date
	 left join per_grades pg on prm.grade_id = pg.grade_id and sysdate between pg.effective_start_date and pg.effective_end_date
	 left join hr_locations_all hl on prm.location_id = hl.location_id and sysdate between hl.effective_start_date and hl.effective_end_date
	 left join hr_all_positions_f_vl hap on prm.position_id = hap.position_id and sysdate between hap.effective_start_date and hap.effective_end_date
	 left join per_departments pd on prm.department_id = pd.organization_id and sysdate between pd.effective_start_date and pd.effective_end_date
	 left join per_all_assignments_m paam on prm.assignment_status_type_id = paam.assignment_status_type_id and sysdate between paam.effective_start_date and paam.effective_end_date
	 left join per_person_types_vl ppt on prm.user_person_type_id = ppt.person_type_id
	 left join per_legal_employers ple on prm.legal_employer_id = ple.organization_id and sysdate between ple.effective_start_date and ple.effective_end_date
	 left join hr_organization_units_f_tl pou on prm.business_unit_id=pou.organization_id and sysdate between pou.effective_start_date and pou.effective_end_date
	 left join fnd_lookup_values_vl flv_resp_type on prm.responsibility_type = flv_resp_type.lookup_code and flv_resp_type.lookup_type = 'PER_RESPONSIBILITY_TYPES' and flv_resp_type.view_application_id = 3
	 left join fnd_lookup_values_vl flv_person_type on prm.system_person_type = flv_person_type.lookup_code and flv_person_type.lookup_type = 'SYSTEM_PERSON_TYPE' and flv_person_type.view_application_id = 3
	 left join fnd_lookup_values_vl flv_active on prm.assignment_status = flv_active.lookup_code and flv_active.lookup_type = 'ACTIVE_INACTIVE' and flv_active.view_application_id = 3
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- MANAGE ROLE PROVISIONING RULES - HEADERS - COUNT
-- ##############################################################

		select count(*)
		  from per_role_mappings prm
	 left join per_jobs pj on prm.job_id = pj.job_id and sysdate between pj.effective_start_date and pj.effective_end_date
	 left join per_grades pg on prm.grade_id = pg.grade_id and sysdate between pg.effective_start_date and pg.effective_end_date
	 left join hr_locations_all hl on prm.location_id = hl.location_id and sysdate between hl.effective_start_date and hl.effective_end_date
	 left join hr_all_positions_f_vl hap on prm.position_id = hap.position_id and sysdate between hap.effective_start_date and hap.effective_end_date
	 left join per_departments pd on prm.department_id = pd.organization_id and sysdate between pd.effective_start_date and pd.effective_end_date
	 left join per_all_assignments_m paam on prm.assignment_status_type_id = paam.assignment_status_type_id and sysdate between paam.effective_start_date and paam.effective_end_date
	 left join per_person_types_vl ppt on prm.user_person_type_id = ppt.person_type_id
	 left join per_legal_employers ple on prm.legal_employer_id = ple.organization_id and sysdate between ple.effective_start_date and ple.effective_end_date
	 left join hr_organization_units_f_tl pou on prm.business_unit_id=pou.organization_id and sysdate between pou.effective_start_date and pou.effective_end_date
	 left join fnd_lookup_values_vl flv_resp_type on prm.responsibility_type = flv_resp_type.lookup_code and flv_resp_type.lookup_type = 'PER_RESPONSIBILITY_TYPES' and flv_resp_type.view_application_id = 3
	 left join fnd_lookup_values_vl flv_person_type on prm.system_person_type = flv_person_type.lookup_code and flv_person_type.lookup_type = 'SYSTEM_PERSON_TYPE' and flv_person_type.view_application_id = 3
	 left join fnd_lookup_values_vl flv_active on prm.assignment_status = flv_active.lookup_code and flv_active.lookup_type = 'ACTIVE_INACTIVE' and flv_active.view_application_id = 3
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- MANAGE ROLE PROVISIONING RULES - DETAILS WITH ROLES
-- ##############################################################

		select prm.mapping_name
			 , to_char(prm.creation_date, 'yyyy-mm-dd hh24:mi:ss') mapping_created
			 , prm.created_by mapping_created_by
			 , to_char(prm.date_from, 'yyyy-mm-dd') date_from
			 , to_char(prm.date_to, 'yyyy-mm-dd') date_to
			 , ple.name legal_employer_name
			 , pou.name business_unit
			 , pd.name as department
			 , pj.name as job
			 , hap.name position
			 , pg.name as grade
			 , hl.location_name location
			 , prm.assignment_type
			 , flv_person_type.meaning system_person_type
			 , ppt.user_person_type
			 , flv_active.meaning hr_assignment_status
			 , paam.assignment_status_type
			 , decode(prm.current_manager_flag,'N','No','Y','Yes',prm.current_manager_flag) as manager_with_reports
			 , prm.manager_type
			 , flv_resp_type.meaning resp_type
			 , '#' roles____
			 , prdv.role_name
			 , prdv.role_common_name
			 , prdv.description role_description
			 , decode(prdv.delegation_allowed,'Y','Yes','N','No',prdv.delegation_allowed) as delegation_allowed
			 , decode(prmr.self_requestable_flag,'Y','Yes','N','No',prmr.self_requestable_flag) as self_requestable_flag
			 , decode(prmr.requestable_flag,'Y','Yes','N','No',prmr.requestable_flag) as requestable_flag
			 , decode(prmr.use_for_auto_provisioning_flag,'Y','Yes','N','No',prmr.use_for_auto_provisioning_flag) as use_for_auto_provisioning_flag
		  from per_role_mappings prm
	 left join per_jobs pj on prm.job_id = pj.job_id and sysdate between pj.effective_start_date and pj.effective_end_date
	 left join per_grades pg on prm.grade_id = pg.grade_id and sysdate between pg.effective_start_date and pg.effective_end_date
	 left join hr_locations_all hl on prm.location_id = hl.location_id and sysdate between hl.effective_start_date and hl.effective_end_date
	 left join hr_all_positions_f_vl hap on prm.position_id = hap.position_id and sysdate between hap.effective_start_date and hap.effective_end_date
	 left join per_departments pd on prm.department_id = pd.organization_id and sysdate between pd.effective_start_date and pd.effective_end_date
	 left join per_all_assignments_m paam on prm.assignment_status_type_id = paam.assignment_status_type_id and sysdate between paam.effective_start_date and paam.effective_end_date
	 left join per_person_types_vl ppt on prm.user_person_type_id = ppt.person_type_id
	 left join per_legal_employers ple on prm.legal_employer_id = ple.organization_id and sysdate between ple.effective_start_date and ple.effective_end_date
	 left join hr_organization_units_f_tl pou on prm.business_unit_id=pou.organization_id and sysdate between pou.effective_start_date and pou.effective_end_date
	 left join fnd_lookup_values_vl flv_resp_type on prm.responsibility_type = flv_resp_type.lookup_code and flv_resp_type.lookup_type = 'PER_RESPONSIBILITY_TYPES' and flv_resp_type.view_application_id = 3
	 left join fnd_lookup_values_vl flv_person_type on prm.system_person_type = flv_person_type.lookup_code and flv_person_type.lookup_type = 'SYSTEM_PERSON_TYPE' and flv_person_type.view_application_id = 3
	 left join fnd_lookup_values_vl flv_active on prm.assignment_status = flv_active.lookup_code and flv_active.lookup_type = 'ACTIVE_INACTIVE' and flv_active.view_application_id = 3
		  join per_role_mapping_roles prmr on prm.role_mapping_id = prmr.role_mapping_id
		  join per_roles_dn_vl prdv on prmr.role_id = prdv.role_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- MANAGE DATA ACCESS PROVISIONING 1
-- ##############################################################

/*
https://community.oracle.com/customerconnect/discussion/614539/query-for-manage-data-provisioning-rules
*/

		select prm.mapping_name
			 , prm.date_from
			 , prm.date_to
			 , to_char(pda.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , pda.created_by
			 , (select name
				  from hr_organization_units_f_tl
				 where organization_id = prm.business_unit_id
				   and language = userenv('lang')
				   and object_version_number = (select max(object_version_number)
												  from hr_organization_units_f_tl
												 where organization_id = prm.business_unit_id)) "business_unit_name"
			 , (select role_name
				  from per_roles_dn_vl prdv
				 where role_common_name = pda.role_code
				   and object_version_number = (select max(object_version_number)
												  from per_roles_dn_vl
												 where role_id = prdv.role_id)
				   and rownum = 1) role_name
			 , case when pda.datasec_context_type_code = 'ORA_BU_ID' then 'Business Unit'
					when pda.datasec_context_type_code = 'ORA_BOOK_CONTROL_ID' then 'Asset Book'
					when pda.datasec_context_type_code = 'ORA_COST_ORG_ID' then 'Cost Organization'
					when pda.datasec_context_type_code = 'ORA_ACCESS_SET_ID' then 'Data Access Set'
					when pda.datasec_context_type_code = 'ORA_ORGANIZATION_ID' then 'Inventory Organization'
					when pda.datasec_context_type_code = 'ORA_LEDGER_ID' then 'Ledger'
					when pda.datasec_context_type_code = 'ORA_SET_ID' then 'Reference Data Set'
			   end context_name
			 , case when pda.datasec_context_type_code = 'ORA_BU_ID' then (select bu_name from fun_all_business_units_v bu where bu.bu_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_BOOK_CONTROL_ID' then (select book_type_name from fusion.fa_book_controls where book_control_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_COST_ORG_ID' then (select cost_org_name from cst_cost_orgs_v where cost_org_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_ACCESS_SET_ID' then (select name from gl_access_sets where access_set_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_ORGANIZATION_ID' then (select organization_code from inv_org_parameters where organization_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_LEDGER_ID' then (select led.name from gl_ledgers led where ledger_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_SET_ID' then (select set_name from fusion.fnd_setid_sets_vl where set_id = pda.datasec_context_value1 and rownum = 1)
			   end context_value
		  from per_role_mappings prm, per_data_asgnmnts_rule_dtl pda
		 where pda.rule_id = prm.role_mapping_id
		   and prm.object_version_number = (select max(object_version_number) from per_role_mappings where role_mapping_id = prm.role_mapping_id)
		   and pda.object_version_number = (select max(object_version_number) from per_data_asgnmnts_rule_dtl where rule_id = pda.rule_id and rule_dtl_id = pda.rule_dtl_id) 
		   and pda.role_code = 'XX_FINANCE_MANAGER'

-- ##############################################################
-- MANAGE DATA ACCESS PROVISIONING 2
-- ##############################################################

/*
https://community.oracle.com/customerconnect/discussion/614539/query-for-manage-data-provisioning-rules
*/

		select prm.mapping_name
			 , prm.date_from
			 , prm.date_to
			 , to_char(pda.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , pda.created_by
			 , (select name 
				  from hr_organization_units_f_tl 
				 where organization_id = prm.business_unit_id 
				   and language = userenv('lang')
				   and object_version_number =  (select max(object_version_number)
												   from hr_organization_units_f_tl
												  where organization_id = prm.business_unit_id)) "business_unit_name"
			 , (select name
				  from hr_organization_units_f_tl
				 where organization_id = prm.department_id
				   and language = userenv('lang')
				   and object_version_number = (select max(object_version_number)
												  from hr_organization_units_f_tl
												 where organization_id = prm.department_id)) "department"
			 , (select location_name
				  from hr_locations
				 where location_id = prm.location_id
				   and object_version_number = (select max(object_version_number)
												  from hr_locations
												 where location_id = prm.location_id)) "location"
			 , (select name
				  from per_jobs_f_tl
				 where job_id = prm.job_id
				   and language = userenv('lang')
				   and object_version_number = (select max(object_version_number)
												  from per_jobs_f_tl
												 where job_id = prm.job_id)) "job"
			 , (select name
				  from hr_all_positions_f_tl
				 where position_id = prm.position_id
				   and language = userenv('lang')
				   and object_version_number = (select max(object_version_number)
												  from hr_all_positions_f_tl
												 where position_id = prm.position_id)) "position"
			 , (select name
				  from per_grades_f_tl
				 where grade_id = prm.grade_id
				   and language = userenv('lang')
				   and object_version_number = (select max(object_version_number)
												  from per_grades_f_tl
												 where grade_id = prm.grade_id)) "grade"
			 , prm.assignment_status "hr_assignment_status"
			 , prm.system_person_type
			 , (select role_name
				  from per_roles_dn_vl prdv
				 where role_common_name = pda.role_code
				   and object_version_number = (select max(object_version_number)
												  from per_roles_dn_vl
												 where role_id = prdv.role_id)
				   and rownum = 1) role_name
			 , case when pda.datasec_context_type_code = 'ORA_BU_ID' then 'Business Unit'
					when pda.datasec_context_type_code = 'ORA_BOOK_CONTROL_ID' then 'Asset Book'
					when pda.datasec_context_type_code = 'ORA_COST_ORG_ID' then 'Cost Organization'
					when pda.datasec_context_type_code = 'ORA_ACCESS_SET_ID' then 'Data Access Set'
					when pda.datasec_context_type_code = 'ORA_ORGANIZATION_ID' then 'Inventory Organization'
					when pda.datasec_context_type_code = 'ORA_LEDGER_ID' then 'Ledger'
					when pda.datasec_context_type_code = 'ORA_SET_ID' then 'Reference Data Set'
			   end context_name
			 , case when pda.datasec_context_type_code = 'ORA_BU_ID' then (select bu_name from fun_all_business_units_v bu where bu.bu_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_BOOK_CONTROL_ID' then (select book_type_name from fusion.fa_book_controls where book_control_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_COST_ORG_ID' then (select cost_org_name from cst_cost_orgs_v where cost_org_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_ACCESS_SET_ID' then (select name from gl_access_sets where access_set_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_ORGANIZATION_ID' then (select organization_code from inv_org_parameters where organization_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_LEDGER_ID' then (select led.name from gl_ledgers led where ledger_id = pda.datasec_context_value1 and rownum = 1)
					when pda.datasec_context_type_code = 'ORA_SET_ID' then (select set_name from fusion.fnd_setid_sets_vl where set_id = pda.datasec_context_value1 and rownum = 1)
			   end context_value
		  from per_role_mappings prm
		  join per_data_asgnmnts_rule_dtl pda on pda.rule_id = prm.role_mapping_id
		 where 1 = 1
		   and prm.object_version_number = (select max(object_version_number)
											  from per_role_mappings
											 where role_mapping_id = prm.role_mapping_id)
											   and pda.object_version_number = (select max(object_version_number)
																				  from per_data_asgnmnts_rule_dtl
																				 where rule_id = pda.rule_id 
																				   and rule_dtl_id = pda.rule_dtl_id)
		   and pda.role_code = 'XX_FINANCE_MANAGER'
		   and 1 = 1
