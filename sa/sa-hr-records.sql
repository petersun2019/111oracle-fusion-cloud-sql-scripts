/*
File Name: sa-hr-records.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PER_ALL_ASSIGNMENTS_M
-- HR RECORDS - SIMPLE
-- HR RECORDS - WITHOUT LINE MANAGER
-- HR RECORDS - WITH LINE MANAGER
-- HR RECORDS - WITH LINE MANAGER (PER_MANAGER_HRCHY_DN)
-- HR RECORDS - EMPLOYEE BANK ACCOUNTS

-- ##############################################################
-- PER_ALL_ASSIGNMENTS_M
-- ##############################################################

Use PER_ALL_ASSIGNMENTS_M, because PER_ALL_ASSIGNMENTS_F is not a table on fusion.
Fusion Global HR: What is the difference between PER_ALL_ASSIGNMENTS_M and PER_ALL_ASSIGNMENTS_F (DOC ID 2096539.1)
PER_ALL_ASSIGNMENTS_M is the core table for assignments.
The definition of the PER_ALL_ASSIGNMENTS_F view is as below :

		select *
		  from PER_ALL_ASSIGNMENTS_M
		 where effective_latest_change = 'Y';

So if you want all the data use the base table: PER_ALL_ASSIGNMENTS_M
If you want the effective latest change only, please use: PER_ALL_ASSIGNMENTS_F

Assignment Type
-----------------------------

PER_ALL_ASSIGNMENTS_M.ASSIGNMENT_TYPE

E: Employee
C: Contingent Worker
O: Offer
N: Nonworker

*/

-- ##############################################################
-- HR RECORDS - SIMPLE
-- ##############################################################

		select papf.person_id
			 , '#' || papf.person_number emp_num
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.full_name
			 , pu.username
			 , hp.party_id
			 , hp.party_name
			 , nvl(pea.email_address, 'no-email') email_address
		  from per_all_people_f papf 
		  join per_person_names_f ppnf on ppnf.person_id = papf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between papf.effective_start_date and papf.effective_end_date and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_email_addresses pea on pea.person_id = papf.person_id and pea.email_type = 'W1'
	 left join per_users pu on pu.person_id = papf.person_id
	 left join hz_parties hp on '#' || hp.orig_system_reference = '#' || papf.person_id and hp.party_type ='PERSON' -- appended join fields with '#' to get around "ORA-01722: invalid number" error. Tried to_number(hp.orig_system_reference) instead but got same error
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- HR RECORDS - WITHOUT LINE MANAGER
-- ##############################################################

		select '#' || papf.person_number emp_num
			 , papf.person_id
			 , ppnf.full_name
			 , bu.bu_name business_unit
			 , bg.name bus_group
			 , hauft.name employer
			 , ppnf.display_name
			 , paam.assignment_id
			 , '#' || paam.assignment_number assg_numb
			 , paam.assignment_name assg_name
			 , paam.assignment_status_type
			 , paam.assignment_type
			 , pastt.user_status assig_status
			 , org.name assig_org
			 , gsob.name sob
			 , nvl(pea.email_address, 'no-email') email_address
			 , hla.location_code
			 , '#' || gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 code_comb
			 , hapf.position_code
			 , hapft.name position_name
			 , pjfv.name job_title
			 , pjfv.approval_authority job_level
			 , pjfv.job_code
			 , pd.name person_department
			 , to_char(paam.creation_date, 'yyyy-mm-dd hh24:mi:ss') assg_created
			 , paam.created_by assg_created_by
			 , to_char(paam.last_update_date, 'yyyy-mm-dd hh24:mi:ss') assg_updated
			 , paam.last_updated_by assg_updated_by
			 , paam.primary_flag
			 , paam.primary_assignment_flag
			 , paam.effective_latest_change
			 , to_char(papf.effective_start_date, 'yyyy-mm-dd') effective_start_date_person
			 , to_char(papf.effective_end_date, 'yyyy-mm-dd') effective_end_date_person
			 , to_char(paam.effective_start_date, 'yyyy-mm-dd') effective_start_date_assg
			 , to_char(paam.effective_end_date, 'yyyy-mm-dd') effective_end_date_assg
			 , '#' user_account_____________
			 , nvl(pu.username, 'no-user-account') username
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_status
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , to_char(pu.creation_date, 'yyyy-mm-dd hh24:mi:ss') user_created
			 , pu.created_by user_created_by
			 , to_char(pu.last_update_date, 'yyyy-mm-dd hh24:mi:ss') user_updated
			 , (select to_char(s.last_login_date, 'yyyy-mm-dd hh24:mm:ss') from ase_user_login_info s where s.user_guid = pu.user_guid) last_login_date
			 , pu.last_updated_by user_updated_by
			 -- , (select count(*) from per_manager_hrchy_dn pmhd where pmhd.person_id = papf.person_id) subordinate_count
			 -- , (select max(plu.email) from per_ldap_users plu where plu.user_guid = pu.user_guid and plu.email like '%@%') plu_email
		  from per_all_people_f papf
		  join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between paam.effective_start_date and paam.effective_end_date and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join hr_all_organization_units bg on bg.organization_id = papf.business_group_id and sysdate between bg.effective_start_date and bg.effective_end_date
	 left join hr_all_organization_units org on org.organization_id = paam.organization_id and sysdate between org.effective_start_date and org.effective_end_date
	 left join gl_code_combinations gcc on gcc.code_combination_id = paam.default_code_comb_id
	 left join hr_all_positions_f hapf on paam.position_id = hapf.position_id and sysdate between hapf.effective_start_date and hapf.effective_end_date
	 left join hr_all_positions_f_tl hapft on hapf.position_id = hapft.position_id and sysdate between hapft.effective_start_date and hapft.effective_end_date and hapf.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf.position_id)
	 left join fun_all_business_units_v bu on paam.business_unit_id = bu.bu_id
		  join per_users pu on pu.person_id = papf.person_id and pU.SUSPENDED = 'N'
	 left join hr_locations_all hla on hla.location_id = paam.location_id
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id and sysdate between pjfv.effective_start_date and pjfv.effective_end_date 
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
	 left join gl_sets_of_books gsob on gsob.set_of_books_id = paam.set_of_books_id
	 left join per_assignment_status_types past on paam.assignment_status_type_id = past.assignment_status_type_id
	 left join per_assignment_status_types_tl pastt on past.assignment_status_type_id = pastt.assignment_status_type_id
	 left join hr_organization_units_f_tl hauft on hauft.organization_id = paam.legal_entity_id and sysdate between hauft.effective_start_date and hauft.effective_end_date and hauft.language = userenv('lang')
	 left join hr_all_organization_units_f haouf on haouf.organization_id = hauft.organization_id and sysdate between haouf.effective_start_date and haouf.effective_end_date
	 left join hr_org_unit_classifications_f houcf on haouf.organization_id = houcf.organization_id and haouf.effective_start_date between houcf.effective_start_date and houcf.effective_end_date and houcf.classification_code = 'HCM_LEMP'
		 where 1 = 1
		   and paam.primary_flag = 'Y'
		   and paam.primary_assignment_flag = 'Y'
		   and paam.effective_latest_change = 'Y'
		   and 1 = 1

-- ##############################################################
-- HR RECORDS - WITH LINE MANAGER
-- ##############################################################

		select '#' || papf.person_number emp_num
			 , papf.person_id
			 , ppnf.full_name
			 , bu.bu_name business_unit
			 , bg.name bus_group
			 , hauft.name employer
			 , ppnf.display_name
			 , paam.assignment_id
			 , '#' || paam.assignment_number assg_numb
			 , paam.assignment_name assg_name
			 , paam.effective_latest_change
			 , paam.primary_flag
			 , paam.primary_assignment_flag
			 , paam.assignment_type
			 , pastt.user_status assig_status
			 , org.name assig_org
			 , gsob.name sob
			 , nvl(pea.email_address, 'no-email') email_address
			 , hla.location_code
			 , '#' || gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 code_comb
			 , hapf.position_code
			 , hapft.name position_name
			 , pjfv.name job_title
			 , pjfv.approval_authority job_level
			 , pd.name person_department
			 , pu.username
			 , to_char(paam.creation_date, 'yyyy-mm-dd hh24:mi:ss') assg_created
			 , paam.created_by assg_created_by
			 , to_char(paam.last_update_date, 'yyyy-mm-dd hh24:mi:ss') assg_updated
			 , paam.last_updated_by assg_updated_by
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') status
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , to_char(papf.effective_start_date, 'yyyy-mm-dd') effective_start_date_person
			 , to_char(papf.effective_end_date, 'yyyy-mm-dd') effective_end_date_person
			 , to_char(paam.effective_start_date, 'yyyy-mm-dd') effective_start_date_assg
			 , to_char(paam.effective_end_date, 'yyyy-mm-dd') effective_end_date_assg
			 -- , (select count(*) from per_manager_hrchy_dn pmhd where pmhd.person_id = papf.person_id) subordinate_count
			 -- , (select max(plu.email) from per_ldap_users plu where plu.user_guid = pu.user_guid and plu.email like '%@%') plu_email
			 , '####' mgr
			 , ppnf_mgr.full_name mgr_name
			 , bg_mgr.name mgr_bus_group
			 , hauft_mgr.name mgr_employer
			 , pd.name mgr_department
			 , papf_mgr.person_id mgr_person_id
			 , '#' || papf_mgr.person_number mgr_emp_num
			 , paam_mgr.assignment_id mgr_assignment_id
			 , '#' || paam_mgr.assignment_number mgr_assg_numb
			 , org_mgr.name mgr_assig_org
			 , nvl(pea_mgr.email_address, 'no-email') mgr_email_address
			 , hla.location_code mgr_location
			 , hapf_mgr.position_code mgr_position
			 , hapft_mgr.name mgr_position_name
			 , pjfv_mgr.name mgr_job_title
			 , pjfv_mgr.approval_authority mgr_job_level
			 , fu_mgr.username mgr_username
		  from per_all_people_f papf
		  join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between paam.effective_start_date and paam.effective_end_date and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join hr_all_organization_units bg on bg.organization_id = papf.business_group_id and sysdate between bg.effective_start_date and bg.effective_end_date
	 left join hr_all_organization_units org on org.organization_id = paam.organization_id and sysdate between org.effective_start_date and org.effective_end_date
	 left join gl_code_combinations gcc on gcc.code_combination_id = paam.default_code_comb_id
	 left join hr_all_positions_f hapf on paam.position_id = hapf.position_id and sysdate between hapf.effective_start_date and hapf.effective_end_date
	 left join hr_all_positions_f_tl hapft on hapf.position_id = hapft.position_id and sysdate between hapft.effective_start_date and hapft.effective_end_date and hapf.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf.position_id)
	 left join per_users pu on pu.person_id = papf.person_id
	 left join hr_locations_all hla on hla.location_id = paam.location_id
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id and sysdate between pjfv.effective_start_date and pjfv.effective_end_date 
	 left join per_departments pd on paam.organization_id = pd.organization_id and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
	 left join gl_sets_of_books gsob on gsob.set_of_books_id = paam.set_of_books_id
	 left join per_assignment_status_types past on paam.assignment_status_type_id = past.assignment_status_type_id
	 left join per_assignment_status_types_tl pastt on past.assignment_status_type_id = pastt.assignment_status_type_id
	 left join hr_organization_units_f_tl hauft on hauft.organization_id = paam.legal_entity_id and sysdate between hauft.effective_start_date and hauft.effective_end_date and hauft.language = userenv('lang')
	 left join hr_all_organization_units_f haouf on haouf.organization_id = hauft.organization_id and sysdate between haouf.effective_start_date and haouf.effective_end_date
	 left join hr_org_unit_classifications_f houcf on haouf.organization_id = houcf.organization_id and haouf.effective_start_date between houcf.effective_start_date and houcf.effective_end_date and houcf.classification_code = 'HCM_LEMP'
	 left join fun_all_business_units_v bu on paam.business_unit_id = bu.bu_id
	 -- ################## manager info
	 left join per_assignment_supervisors_f pasf on pasf.person_id = papf.person_id and pasf.assignment_id = paam.assignment_id and sysdate between pasf.effective_start_date and pasf.effective_end_date
	 left join per_all_people_f papf_mgr on papf_mgr.person_id = pasf.manager_id and sysdate between papf_mgr.effective_start_date and papf_mgr.effective_end_date
	 left join per_all_assignments_m paam_mgr on paam_mgr.assignment_id = pasf.manager_assignment_id and paam_mgr.person_id = papf_mgr.person_id and sysdate between paam_mgr.effective_start_date and paam_mgr.effective_end_date and paam_mgr.primary_flag = 'Y'
	 left join per_jobs_f_vl pjfv_mgr on paam_mgr.job_id = pjfv_mgr.job_id and sysdate between pjfv_mgr.effective_start_date and pjfv_mgr.effective_end_date
	 left join per_person_names_f ppnf_mgr on papf_mgr.person_id = ppnf_mgr.person_id and ppnf_mgr.name_type = 'GLOBAL' and sysdate between ppnf_mgr.effective_start_date and ppnf_mgr.effective_end_date
	 left join per_departments pd_mgr on paam_mgr.organization_id = pd_mgr.organization_id and sysdate between nvl(pd_mgr.effective_start_date, sysdate - 1) and nvl(pd_mgr.effective_end_date, sysdate + 1)
	 left join per_email_addresses pea_mgr on papf_mgr.person_id = pea_mgr.person_id and pea_mgr.email_type = 'W1' -- not all users have email addresses
	 left join hr_all_positions_f hapf_mgr on paam_mgr.position_id = hapf_mgr.position_id and sysdate between hapf_mgr.effective_start_date and hapf_mgr.effective_end_date
	 left join hr_all_positions_f_tl hapft_mgr on hapf_mgr.position_id = hapft_mgr.position_id and hapf_mgr.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf_mgr.position_id) and sysdate between hapft_mgr.effective_start_date and hapft_mgr.effective_end_date
	 left join per_users fu_mgr on fu_mgr.person_id = papf_mgr.person_id
	 left join hr_locations_all hla_mgr on hla_mgr.location_id = paam_mgr.location_id
	 left join hr_all_organization_units bg_mgr on bg_mgr.organization_id = papf.business_group_id and sysdate between bg_mgr.effective_start_date and bg_mgr.effective_end_date
	 left join hr_all_organization_units org_mgr on org_mgr.organization_id = paam_mgr.organization_id and sysdate between org_mgr.effective_start_date and org_mgr.effective_end_date
	 left join hr_organization_units_f_tl hauft_mgr on hauft_mgr.organization_id = paam_mgr.legal_entity_id and sysdate between hauft_mgr.effective_start_date and hauft_mgr.effective_end_date and hauft_mgr.language = userenv('lang')
	 left join hr_all_organization_units_f haouf_mgr on haouf_mgr.organization_id = hauft_mgr.organization_id and sysdate between haouf_mgr.effective_start_date and haouf_mgr.effective_end_date
	 left join hr_org_unit_classifications_f houcf_mgr on haouf_mgr.organization_id = houcf_mgr.organization_id and haouf_mgr.effective_start_date between houcf_mgr.effective_start_date and houcf_mgr.effective_end_date and houcf_mgr.classification_code = 'HCM_LEMP'
		 where 1 = 1
		   and paam.primary_flag = 'Y'
		   and paam.primary_assignment_flag = 'Y'
		   and paam.effective_latest_change = 'Y'
		   and 1 = 1
	  order by paam.last_update_date desc

-- ##############################################################
-- HR RECORDS - WITH LINE MANAGER (PER_MANAGER_HRCHY_DN)
-- ##############################################################

/*
http://chinnasahebshaik.blogspot.com/2018/06/fusion-manager-hierarchy-quires.html
https://docs.oracle.com/en/cloud/saas/global-human-resources/18b/oedmh/per_manager_hrchy_cf-tbl.html
https://docs.oracle.com/en/cloud/saas/global-human-resources/18b/oedmh/per_manager_hrchy_dn-tbl.html
*/

		select ppnfv.full_name person_name
			 , papf.person_number
			 , bu.bu_name business_unit
			 , pu.username person_username
			 , nvl(pea.email_address, 'no-email') person_email
			 , pjfv.name person_job_title
			 , pjfv.approval_authority person_job_level
			 , hla_m.location_code person_location
			 , pd.name person_department
			 , ppnfv_m.full_name manager_name
			 , papf_m.person_number manager_number
			 , fu_m.username manager_username
			 , nvl(pea_m.email_address, 'no-email') manager_email
			 , pjfv_m.name manager_job_title
			 , pjfv_m.approval_authority manager_job_level
			 , hla_m.location_code manager_location
			 , pd_m.name manager_department
			 , pmhd.manager_level
			 , decode(pmhd.manager_level, '1', 'Direct Reportee', 'Indirect Reportee') direct_indirect
		  from per_manager_hrchy_dn pmhd
		  join per_person_names_f_v ppnfv on pmhd.person_id = ppnfv.person_id
		  join per_all_people_f papf on ppnfv.person_id = papf.person_id
		  join per_person_names_f_v ppnfv_m on pmhd.manager_id = ppnfv_m.person_id
		  join per_all_people_f papf_m on ppnfv_m.person_id = papf_m.person_id
	 left join per_users pu on pu.person_id = papf.person_id
	 left join per_users fu_m on fu_m.person_id = papf_m.person_id
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1'
	 left join per_email_addresses pea_m on papf_m.person_id = pea_m.person_id and pea_m.email_type = 'W1'
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and paam.assignment_status_type = 'ACTIVE' and paam.primary_flag = 'Y'
	 left join per_all_assignments_m paam_m on paam_m.person_id = papf_m.person_id and paam_m.assignment_status_type = 'ACTIVE' and paam_m.primary_flag = 'Y'
	 left join per_jobs_f_vl pjfv on paam.job_id = pjfv.job_id
	 left join per_jobs_f_vl pjfv_m on paam_m.job_id = pjfv_m.job_id
	 left join hr_locations_all hla on hla.location_id = paam.location_id
	 left join hr_locations_all hla_m on hla_m.location_id = paam_m.location_id
	 left join per_departments pd on paam.organization_id = pd.organization_id
	 left join per_departments pd_m on paam_m.organization_id = pd_m.organization_id
	 left join fun_all_business_units_v bu on paam.business_unit_id = bu.bu_id
		 where 1 = 1
		   and sysdate between nvl(pmhd.effective_start_date, sysdate - 1) and nvl(pmhd.effective_end_date, sysdate + 1)
		   and sysdate between nvl(ppnfv.effective_start_date, sysdate - 1) and nvl(ppnfv.effective_end_date, sysdate + 1)
		   and sysdate between nvl(ppnfv_m.effective_start_date, sysdate - 1) and nvl(ppnfv_m.effective_end_date, sysdate + 1)
		   and sysdate between nvl(papf.effective_start_date, sysdate - 1) and nvl(papf.effective_end_date, sysdate + 1)
		   and sysdate between nvl(papf_m.effective_start_date, sysdate - 1) and nvl(papf_m.effective_end_date, sysdate + 1)
		   and sysdate between nvl(paam.effective_start_date, sysdate - 1) and nvl(paam.effective_end_date, sysdate + 1)
		   and sysdate between nvl(paam_m.effective_start_date, sysdate - 1) and nvl(paam_m.effective_end_date, sysdate + 1)
		   and sysdate between nvl(pjfv.effective_start_date, sysdate - 1) and nvl(pjfv.effective_end_date, sysdate + 1)
		   and sysdate between nvl(pjfv_m.effective_start_date, sysdate - 1) and nvl(pjfv_m.effective_end_date, sysdate + 1)
		   and sysdate between nvl(pea.date_from, sysdate - 1) and nvl(pea.date_to, sysdate + 1)
		   and sysdate between nvl(pea_m.date_from, sysdate - 1) and nvl(pea_m.date_to, sysdate + 1)
		   and sysdate between nvl(pd.effective_start_date, sysdate - 1) and nvl(pd.effective_end_date, sysdate + 1)
		   and sysdate between nvl(pd_m.effective_start_date, sysdate - 1) and nvl(pd_m.effective_end_date, sysdate + 1)
		   and 1 = 1
	  order by pmhd.manager_level

-- ##############################################################
-- HR RECORDS - EMPLOYEE BANK ACCOUNTS
-- ##############################################################

/*
FUSION PAYROLL: What Table and Field References the "Selected Account" (Green Check Mark) for an Employee's Bank Account Information. (Doc ID 2204431.1)
*/

		select papf.person_number
			 , ppnf.full_name
			 , ppnf.display_name
			 , pppmf.name pay_methods_name
			 , pppmf.effective_start_date
			 , pppmf.effective_end_date
			 , pppmf.payment_amount_type
			 , pppmf.amount
			 , pppmf.percentage
			 , pppmf.priority
			 , pba.bank_account_name
			 , pba.bank_account_num
			 , pba.bank_name
			 , pba.bank_number
			 , pba.bank_branch_name
			 , pba.bank_account_type
		  from pay_payroll_assignments ppa
		  join per_all_assignments_f paaf on ppa.hr_assignment_id = paaf.assignment_id
		  join per_all_people_f papf on paaf.person_id = papf.person_id
		  join pay_person_pay_methods_f pppmf on pppmf.payroll_relationship_id = ppa.payroll_relationship_id
		  join pay_bank_accounts pba on pppmf.bank_account_id=pba.bank_account_id
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL'
		 where 1 = 1 
		   and paaf.assignment_type = 'E'
		   and trunc(sysdate) between pppmf.effective_start_date and pppmf.effective_end_date
		   and trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
		   and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
		   and trunc(sysdate) between ppnf.effective_start_date and ppnf.effective_end_date
		   and 1 = 1
