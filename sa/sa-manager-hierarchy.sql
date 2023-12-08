/*
File Name: sa-manager-hierarchy.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- MANAGER HIERARCHY 1
-- MANAGER HIERARCHY 2

*/

-- ##############################################################
-- MANAGER HIERARCHY 1
-- ##############################################################

/*
https://fusionhcmknowledgebase.com/2020/04/supervisor-direct-and-indirect-reportees-sql-query/
*/

		select ppnf_emp.full_name emp_name
			 , pmhd.person_id emp_id
			 , fu_person.username emp_uname
			 , '#' || papf_emp.person_number emp_num
			 , pd_emp.name emp_dept
			 , pjfv_emp.name emp_job
			 , pjfv_emp.approval_authority emp_job_level
			   -- ########################## manager
			 , ppnf_sup.full_name mgr_name
			 , pmhd.manager_id mgr_id
			 , fu_manager.username mgr_uname
			 , '#' || papf_sup.person_number mgr_num
			 , pd_sup.name manager_dept
			 , pjfv_sup.name mgr_job
			 , pjfv_sup.approval_authority mgr_job_level
			   -- ############# hier table
			 , pmhd.assignment_id
			 , pmhd.manager_id
			 , pmhd.manager_assignment_id
			 , pmhd.manager_level
			 , pmhd.manager_type
			 , pmhd.effective_start_date
			 , pmhd.effective_end_date
			 , decode(pmhd.manager_level, '1', 'Direct Reportee', 'Indirect Reportee') direct_indirect
		  from per_manager_hrchy_dn pmhd
		  join per_person_names_f_v ppnf_emp on pmhd.person_id = ppnf_emp.person_id
		  join per_all_people_f papf_emp on ppnf_emp.person_id = papf_emp.person_id
		  join per_all_assignments_m paam_emp on papf_emp.person_id = paam_emp.person_id and sysdate between paam_emp.effective_start_date and paam_emp.effective_end_date and paam_emp.primary_flag = 'Y'
	 left join per_jobs_f_vl pjfv_emp on paam_emp.job_id = pjfv_emp.job_id and sysdate between pjfv_emp.effective_start_date and pjfv_emp.effective_end_date 
	 left join per_departments pd_emp on paam_emp.organization_id = pd_emp.organization_id and sysdate between nvl(pd_emp.effective_start_date, sysdate - 1) and nvl(pd_emp.effective_end_date, sysdate + 1)
	 left join per_users fu_person on fu_person.person_id = papf_emp.person_id
			   -- ########################### supervisor
		  join per_all_people_f papf_sup on papf_sup.person_id = pmhd.manager_id
		  join per_person_names_f_v ppnf_sup on ppnf_sup.person_id = pmhd.manager_id
	 left join per_users fu_manager on fu_manager.person_id = papf_sup.person_id
	 left join per_all_assignments_m paam_sup on pmhd.manager_assignment_id = paam_sup.assignment_id and sysdate between paam_sup.effective_start_date and paam_sup.effective_end_date and paam_sup.primary_flag = 'Y'
	 left join per_jobs_f_vl pjfv_sup on paam_sup.job_id = pjfv_sup.job_id and sysdate between pjfv_sup.effective_start_date and pjfv_sup.effective_end_date 
	 left join per_departments pd_sup on paam_sup.organization_id = pd_sup.organization_id and sysdate between nvl(pd_sup.effective_start_date, sysdate - 1) and nvl(pd_sup.effective_end_date, sysdate + 1)
		 where 1 = 1
		   and pmhd.manager_type = 'LINE_MANAGER'
		   and ppnf_emp.name_type = 'GLOBAL'
		   and ppnf_sup.name_type = 'GLOBAL'
		   and sysdate between papf_emp.effective_start_date and papf_emp.effective_end_date
		   and sysdate between papf_sup.effective_start_date and papf_sup.effective_end_date
		   and sysdate between ppnf_emp.effective_start_date and ppnf_emp.effective_end_date
		   and sysdate between ppnf_sup.effective_start_date and ppnf_sup.effective_end_date
		   and sysdate between pmhd.effective_start_date and pmhd.effective_end_date
		   -- and pmhd.manager_level = '1' -- use 1 for direct reports, comment it for all reportees
	  order by papf_emp.person_number
			 , pmhd.manager_level

-- ##############################################################
-- MANAGER HIERARCHY 2
-- ##############################################################

/*
https://fusionhcmknowledgebase.com/2020/04/supervisor-direct-and-indirect-reportees-sql-query/
*/

		select ppnf_emp.full_name
			 , pmhd.person_id
			 , fu_person.username person_username
			 , '#' || papf_emp.person_number person_number
			 , pd_emp.name person_dept
			 , pmhd.assignment_id
			 , pmhd.manager_id
			 , '#' || papf_sup.person_number manager_number
			 , ppnf_sup.full_name manager_full_name
			 , fu_manager.username manager_username
			 , pmhd.manager_assignment_id
			 , pjfv_sup.name mgr_job
			 , pjfv_sup.approval_authority mgr_job_level
			 , pmhd.manager_level
			 , pmhd.manager_type
			 , pmhd.effective_start_date
			 , pmhd.effective_end_date
			 , decode(pmhd.manager_level, '1', 'Direct Reportee', 'Indirect Reportee') direct_indirect
			 , pd_sup.name mgr_dept
		  from per_manager_hrchy_dn pmhd
		  join per_person_names_f_v ppnf_emp on pmhd.person_id = ppnf_emp.person_id
		  join per_all_people_f papf_emp on ppnf_emp.person_id = papf_emp.person_id
		  join per_all_people_f papf_sup on papf_sup.person_id = pmhd.manager_id
		  join per_person_names_f_v ppnf_sup on ppnf_sup.person_id = pmhd.manager_id
	 left join per_all_assignments_m paam_emp on paam_emp.person_id = papf_emp.person_id and sysdate between paam_emp.effective_start_date and paam_emp.effective_end_date and paam_emp.primary_flag = 'Y'
	 left join per_departments pd_emp on paam_emp.organization_id = pd_emp.organization_id and sysdate between nvl(pd_emp.effective_start_date, sysdate - 1) and nvl(pd_emp.effective_end_date, sysdate + 1)
	 left join per_users fu_person on fu_person.person_id = papf_emp.person_id
	 left join per_users fu_manager on fu_manager.person_id = papf_sup.person_id
	 left join per_all_assignments_m paam_sup on pmhd.manager_assignment_id = paam_sup.assignment_id and sysdate between paam_sup.effective_start_date and paam_sup.effective_end_date and paam_sup.primary_flag = 'Y'
	 left join per_departments pd_sup on paam_sup.organization_id = pd_sup.organization_id and sysdate between nvl(pd_sup.effective_start_date, sysdate - 1) and nvl(pd_sup.effective_end_date, sysdate + 1)
	 left join per_jobs_f_vl pjfv_sup on paam_sup.job_id = pjfv_sup.job_id and sysdate between pjfv_sup.effective_start_date and pjfv_sup.effective_end_date 
		 where 1 = 1
		   and pmhd.manager_type = 'LINE_MANAGER'
		   and ppnf_emp.name_type = 'GLOBAL'
		   and ppnf_sup.name_type = 'GLOBAL'
		   and sysdate between papf_emp.effective_start_date and papf_emp.effective_end_date
		   and sysdate between papf_sup.effective_start_date and papf_sup.effective_end_date
		   and sysdate between ppnf_emp.effective_start_date and ppnf_emp.effective_end_date
		   and sysdate between ppnf_sup.effective_start_date and ppnf_sup.effective_end_date
		   and sysdate between pmhd.effective_start_date and pmhd.effective_end_date
		   -- and pmhd.manager_level = '1' -- use 1 for direct reports, comment it for all reportees
	  order by papf_emp.person_number
			 , pmhd.manager_level
