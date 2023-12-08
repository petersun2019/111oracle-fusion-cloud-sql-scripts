/*
File Name: sa-roles.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- ROLES ASSIGNED - SIMPLE
-- COMPARE ROLES BETWEEN USERS
-- ROLES ASSIGNED - DETAILED (NO HR RECORD INFO)
-- ROLES ASSIGNED - DETAILED (WITH HR RECORD INFO)
-- ROLES ASSIGNED - DETAILED (WITH MORE DETAILED HR RECORD INFO)
-- COUNT ROLES ASSIGNED TO USER
-- COUNT ASSIGNMENTS PER ROLE
-- ROLE SETUP
-- SUMMARY INFO

*/

-- ##############################################################
-- ROLES ASSIGNED - SIMPLE
-- ##############################################################

		select pu.username
			 , prdt.role_name
			 , prd.role_common_name
			 , to_char(pur.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_created
			 , pur.created_by access_created_by
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_active_status
			 -- , pu.active_flag user_active_flag
			 -- , (replace(replace(prdt.description,chr(10),''),chr(13),' ')) role_description
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and pur.active_flag = 'Y'
		   and pur.terminated_flag = 'N'
		   and 1 = 1
	  order by to_char(pur.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- COMPARE ROLES BETWEEN USERS
-- ##############################################################

		select prdt.role_name
			 , prd.role_common_name
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where nvl(pu.end_date, sysdate + 1) > sysdate
		   and upper(pu.username) = 'USER123'
		   and pur.active_flag = 'Y'
		   and pur.terminated_flag = 'N'
		 minus
		select prdt.role_name
			 , prd.role_common_name
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ROLES ASSIGNED - DETAILED (NO HR RECORD INFO)
-- ##############################################################

		select pu.username
			 -- , (select to_char(s.last_login_date, 'mm/dd/yyyy hh24:mm') from ase_user_login_info s where s.user_guid = pu.user_guid) last_login_date
			 , prdt.role_name
			 , (replace(replace(prdt.description,chr(10),''),chr(13),' ')) role_description
			 , prd.role_common_name
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_active_status
			 , pu.active_flag user_active_flag
			 , pu.suspended user_suspended
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , to_char(pur.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_created
			 , pur.created_by access_created_by
			 , to_char(pur.start_date, 'yyyy-mm-dd') access_start
			 , to_char(pur.end_date, 'yyyy-mm-dd') access_end
			 , pur.active_flag access_active
			 , pur.terminated_flag access_terminated
			 , regexp_substr(prd.role_common_name, '[^_]+', 1, 1) segment1
			 , regexp_substr(prd.role_common_name, '[^_]+', 1, 2) segment2
			 , regexp_substr(prd.role_common_name, '[^_]+', 1, 3) segment3
			 , regexp_substr(prd.role_common_name, '[^_]+', 1, 4) segment4
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id -- and sysdate between nvl(pur.start_date, sysdate - 1) and nvl(pur.end_date, sysdate + 1) -- active access only
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ROLES ASSIGNED - DETAILED (WITH HR RECORD INFO)
-- ##############################################################

		select pu.username
			 , prdt.role_name
			 , prd.role_common_name
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_active_status
			 , pu.active_flag user_active_flag
			 , pu.suspended user_suspended
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , to_char(pur.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_created
			 , pur.created_by access_created_by
			 , to_char(pur.start_date, 'yyyy-mm-dd') access_start
			 , to_char(pur.end_date, 'yyyy-mm-dd') access_end
			 , pur.active_flag access_active
			 , pur.terminated_flag access_terminated
			 , '#' || papf.person_number person_number
			 -- , papf.person_id
			 -- , to_char(papf.effective_start_date, 'yyyy-mm-dd') papf_start
			 -- , to_char(papf.effective_end_date, 'yyyy-mm-dd') papf_end
			 , ppnf.full_name
			 -- , ppnf.display_name
			 -- , to_char(ppnf.effective_start_date, 'yyyy-mm-dd') ppnf_start
			 -- , to_char(ppnf.effective_end_date, 'yyyy-mm-dd') ppnf_end
			 -- , pea.email_address
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
	 left join per_all_people_f papf on pu.person_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' -- not all users have email addresses
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ROLES ASSIGNED - DETAILED (WITH MORE DETAILED HR RECORD INFO)
-- ##############################################################

		select pu.username
			 , prdt.role_name
			 , prd.role_common_name
			 , decode(pu.suspended, 'N', 'Active', 'Y', 'Inactive') user_active_status
			 , pu.active_flag user_active_flag
			 , pu.suspended user_suspended
			 , to_char(pu.start_date, 'yyyy-mm-dd') user_start
			 , to_char(pu.end_date, 'yyyy-mm-dd') user_end
			 , to_char(pur.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_created
			 , pur.created_by access_created_by
			 , to_char(pur.start_date, 'yyyy-mm-dd') access_start
			 , to_char(pur.end_date, 'yyyy-mm-dd') access_end
			 , pur.active_flag access_active
			 , pur.terminated_flag access_terminated
			 -- , '#' hr_______________
			 , '#' || papf.person_number emp_num
			 -- , papf.person_id
			 , ppnf.full_name
			 , bg.name bus_group
			 , hauft.name employer
			 , ppnf.display_name
			 , '#' || paam.assignment_id assg_id
			 , '#' || paam.assignment_number assg_numb
			 , paam.assignment_name assg_name
			 , paam.assignment_status_type
			 , pastt.user_status assig_status
			 , org.name assig_org
			 , gsob.name sob
			 , nvl(pea.email_address, 'no-email') email_address
			 , hla.location_code
			 -- , '#' || gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 code_comb
			 , hapf.position_code
			 , hapft.name position_name
			 , pjfv.name job_title
			 , pjfv.approval_authority job_level
			 , pd.name person_department
			 -- , to_char(paam.creation_date, 'yyyy-mm-dd hh24:mi:ss') assg_created
			 -- , paam.created_by assg_created_by
			 -- , to_char(paam.last_update_date, 'yyyy-mm-dd hh24:mi:ss') assg_updated
			 -- , paam.last_updated_by assg_updated_by
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
	 left join per_all_people_f papf on pu.person_id = papf.person_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1' and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between paam.effective_start_date and paam.effective_end_date and paam.primary_flag = 'Y' and paam.effective_latest_change = 'Y'
	 left join hr_all_organization_units bg on bg.organization_id = papf.business_group_id and sysdate between bg.effective_start_date and bg.effective_end_date
	 left join hr_all_organization_units org on org.organization_id = paam.organization_id and sysdate between org.effective_start_date and org.effective_end_date
	 left join gl_code_combinations gcc on gcc.code_combination_id = paam.default_code_comb_id
	 left join hr_all_positions_f hapf on paam.position_id = hapf.position_id and sysdate between hapf.effective_start_date and hapf.effective_end_date
	 left join hr_all_positions_f_tl hapft on hapf.position_id = hapft.position_id and sysdate between hapft.effective_start_date and hapft.effective_end_date and hapf.object_version_number = (select max(object_version_number) from hr_all_positions_f max_pos where max_pos.position_id = hapf.position_id)
	 left join fun_all_business_units_v fabuv on hapf.business_unit_id = fabuv.bu_id
	 left join per_users fu on fu.person_id = papf.person_id
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
		   and 1 = 1

-- ##############################################################
-- COUNT ROLES ASSIGNED TO USER
-- ##############################################################

		select pu.username
			 , count(*)
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and sysdate between nvl(pur.start_date, sysdate - 1) and nvl(pur.end_date, sysdate + 1) -- active access only
	  group by pu.username

-- ##############################################################
-- COUNT ASSIGNMENTS PER ROLE
-- ##############################################################

		select prdt.role_name
			 , prd.role_common_name
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 1) segment1
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 2) segment2
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 3) segment3
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 4) segment4
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 5) segment5
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 6) segment6
			 , count(*)
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and sysdate between nvl(pur.start_date, sysdate-1) and nvl(pur.end_date, sysdate+1) -- active access only
	  group by prdt.role_name
			 , prd.role_common_name
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 1)
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 2)
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 3)
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 4)
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 5)
			 -- , regexp_substr(prd.role_common_name, '[^_]+', 1, 6)

-- ##############################################################
-- ROLE SETUP
-- ##############################################################

		select prdt.role_id
			 , prdt.creation_date
			 , prdt.created_by
			 , prdt.role_name
			 , prd.role_common_name
			 , case 
					when ( prd.abstract_role = 'Y' and prd.job_role = 'N' and prd.data_role = 'N' ) then 'Abstract Role' 
					when ( prd.abstract_role = 'N' and prd.job_role = 'Y' and prd.data_role = 'N' ) then 'Job Role' 
					when ( prd.abstract_role = 'N' and prd.job_role = 'N' and prd.data_role = 'Y' ) then 'Data Role' 
					when ( prd.abstract_role is null and prd.job_role is null and prd.data_role is null ) then '--NA--' 
			   end user_role_type 
			 , (select count(distinct pur.user_id) from per_user_roles pur where pur.role_id = prdt.role_id and trunc(sysdate) between nvl(trunc(pur.start_date), trunc(sysdate) - 1) and nvl(trunc(pur.end_date), trunc(sysdate) + 1)) user_count
			 , (replace(replace(prdt.description,chr(10),''),chr(13),' ')) role_description
		  from per_roles_dn_tl prdt
		  join per_roles_dn prd on prdt.role_id = prd.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ROLE SETUP - COUNT BY CREATED BY
-- ##############################################################

		select prdt.created_by
			 , count(*)
		  from per_roles_dn_tl prdt
		  join per_roles_dn prd on prdt.role_id = prd.role_id and prdt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by prdt.created_by

-- ##############################################################
-- SUMMARY INFO
-- ##############################################################

/*
Count GL roles assigned to users
Count AR roles other than those included in the main query
Include only certain AR roles in the main query
Then can see if the user has any AR roles assigned from the list of 3 in the main query, and if they also have GL roles assigned
Query done because users with only the 3 roles in the main query could not see AR Transactions.
I wanted to see if they had access to GL roles, or any other AR roles apart from the main 3 which might have given then access to view transactions.
*/

with gl_access as
	   (select pu.user_id
			 , count(pu.user_id) ct
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn prd on pur.role_id = prd.role_id
		 where 1 = 1
		   and regexp_substr(prd.role_common_name, '[^_]+', 1, 1) = 'XXCUST'
		   and regexp_substr(prd.role_common_name, '[^_]+', 1, 3) = 'GL'
	  group by pu.user_id)
, ar_access as
	   (select pu.user_id
			 , prd.role_id
			 , count(pu.user_id) ct
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn prd on pur.role_id = prd.role_id
		 where 1 = 1
		   and regexp_substr(prd.role_common_name, '[^_]+', 1, 1) = 'XXCUST'
		   and regexp_substr(prd.role_common_name, '[^_]+', 1, 3) = 'AR'
	  group by pu.user_id
			 , prd.role_id)
		select pu.username
			 , gl_acc.ct gl_count
			 , ar_acc.ct ar_count_other
			 , count(*)
		  from per_users pu
		  join per_user_roles pur on pu.user_id = pur.user_id
		  join per_roles_dn_tl prdt on pur.role_id = prdt.role_id
		  join per_roles_dn prd on prd.role_id = prdt.role_id and prdt.language = userenv('lang')
	 left join gl_access gl_acc on gl_acc.user_id = pu.user_id
	 left join ar_access ar_acc on ar_acc.user_id = pu.user_id
		 where 1 = 1
		   and regexp_substr(prd.role_common_name, '[^_]+', 1, 1) = 'XXCUST'
		   and prdt.role_name in ('XXCUST_AR_Inquiry_Manage_Transactions','XXCUST_AR_Inquiry_Receivables','XXCUST_AR_OPS_Finance')
		   and ar_acc.role_id != prd.role_id -- only want count of roles for AR other than those restricted below
	  group by pu.username
			 , gl_acc.ct
			 , ar_acc.ct
