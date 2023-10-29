/*
File Name: pa-key-members.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- KEY MEMBER DETAILS
-- COUNT BY KEY MEMBER
-- COUNT BY KEY MEMBER ROLE

*/

-- ##############################################################
-- KEY MEMBER DETAILS
-- ##############################################################

		select ppav.segment1 proj_number
			 , ppav.name
			 , ppav.description
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') proj_created
			 , ppav.created_by proj_created_by
			 , pptt.project_type
			 , ppst.project_status_name proj_status
			 , '#'
			 , ppnf.full_name
			 , '#' || papf.person_number person_number
			 , pprtt.project_role_name role
			 , nvl(pea.email_address, 'no-email') email_address
			 , '##'
			 , fu.username
			 , fu.active_flag
			 , fu.suspended
			 , to_char(fu.start_date, 'yyyy-mm-dd') user_start
			 , nvl(to_char(fu.end_date, 'yyyy-mm-dd'), '31-DEC-4712') user_end
			 , to_char(ppp.creation_date, 'yyyy-mm-dd hh24:mi:ss') km_assigned
			 , to_char(ppp.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(ppp.end_date_active, 'yyyy-mm-dd') end_date_active
			 , ppp.created_by km_assig_created
		  from pjf_proj_role_types_b pptb
		  join pjf_project_parties ppp on ppp.project_role_id = pptb.project_role_id and sysdate between ppp.start_date_active and nvl(ppp.end_date_active, sysdate + 1)
		  join pjf_projects_all_vl ppav on ppp.object_id = ppav.project_id 
		  join per_all_people_f papf on papf.person_id = ppp.resource_source_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between paam.effective_start_date and paam.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_users fu on papf.person_id = fu.person_id
		  join pjf_proj_role_types_tl pprtt on ppp.project_role_id = pprtt.project_role_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1'
		 where 1 = 1
		   and paam.assignment_status_type = 'ACTIVE'
		   and paam.primary_assignment_flag = 'Y'
		   and 1 = 1

-- ##############################################################
-- COUNT BY KEY MEMBER
-- ##############################################################

		select ppnf.full_name
			 , '#' || papf.person_number person_number
			 , min(ppav.segment1) min_project
			 , max(ppav.segment1) max_project
			 , count(*)
		  from pjf_proj_role_types_b pptb
		  join pjf_project_parties ppp on ppp.project_role_id = pptb.project_role_id and sysdate between ppp.start_date_active and nvl(ppp.end_date_active, sysdate + 1)
		  join pjf_projects_all_vl ppav on ppp.object_id = ppav.project_id
		  join per_all_people_f papf on papf.person_id = ppp.resource_source_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between paam.effective_start_date and paam.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL'
	 left join per_users fu on papf.person_id = fu.person_id
		  join pjf_proj_role_types_tl pprtt on ppp.project_role_id = pprtt.project_role_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1'
		 where 1 = 1
		   and paam.primary_assignment_flag = 'Y'
	  group by ppnf.full_name
			 , '#' || papf.person_number

-- ##############################################################
-- COUNT BY KEY MEMBER ROLE
-- ##############################################################

		select pprtt.project_role_name role
			 , min(ppav.segment1) min_project
			 , max(ppav.segment1) max_project
			 , count(*)
		  from pjf_proj_role_types_b pptb
		  join pjf_project_parties ppp on ppp.project_role_id = pptb.project_role_id and sysdate between ppp.start_date_active and nvl(ppp.end_date_active, sysdate + 1)
		  join pjf_projects_all_vl ppav on ppp.object_id = ppav.project_id
		  join per_all_people_f papf on papf.person_id = ppp.resource_source_id and sysdate between papf.effective_start_date and papf.effective_end_date
		  join per_all_assignments_m paam on paam.person_id = papf.person_id and sysdate between paam.effective_start_date and paam.effective_end_date
		  join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL'
	 left join per_users fu on papf.person_id = fu.person_id
		  join pjf_proj_role_types_tl pprtt on ppp.project_role_id = pprtt.project_role_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join per_email_addresses pea on papf.person_id = pea.person_id and pea.email_type = 'W1'
		 where 1 = 1
		   and paam.primary_assignment_flag = 'Y'
	  group by pprtt.project_role_name
