/*
File Name: pa-projects.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- PROJECT HEADERS
-- PROJECT HEADERS AND TASKS
-- TASK HIERARCHY
-- PROJECT BURDENS
-- COUNT BY PROJECT AND TASK
-- COUNT BY PROJECT TYPE
-- COUNT BY STATUS
-- COUNT BY TEMPLATE

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from pjf_projects_all_vl where segment1 in ('123456')
select * from pjf_projects_all_b where segment1 = '123456'
select * from pjf_tasks_v where project_id = 123456

-- ##############################################################
-- PROJECT HEADERS
-- ##############################################################

		select ppav.project_id
			 , ppav.segment1
			 , ppav.name
			 , ppav.description
			 , ppav.creation_date
			 , ppav.created_by
			 , ppav.pm_product_code
			 , ppav.pm_project_reference
			 , ppav.template_flag
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , (select count(*) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) expenditure_item_count
			 , (select min(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) expenditure_min
			 , (select max(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) expenditure_max
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , ppav.created_by project_created_by
			 , to_char(ppav.start_date, 'yyyy-mm-dd') start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') completion_date
			 , to_char(ppav.closed_date, 'yyyy-mm-dd') closed_date
		  from pjf_projects_all_vl ppav
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join pjf_projects_all_vl ppav_templ on ppav_templ.project_id = ppav.created_from_project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PROJECT HEADERS AND TASKS
-- ##############################################################

		select ppav.segment1 proj_number
			 , ppav.project_id
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , ppst.project_status_name project_status
			 , haou.name org
			 , pptt.project_type
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , ppav.created_by project_created_by
			 , to_char(ppav.last_update_date, 'yyyy-mm-dd hh24:mi:ss') project_updated
			 , ppav.last_updated_by project_updated_by
			 , to_char(ppav.start_date, 'yyyy-mm-dd') project_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') project_completion_date
			 , ptv.task_number
			 , ptv.task_id
			 , ptv.task_name
			 , flv_service_type.meaning task_service_type
			 , to_char(ptv.creation_date, 'yyyy-mm-dd hh24:mi:ss') task_created
			 , ptv.created_by task_created_by
			 , to_char(ptv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') task_updated
			 , ptv.last_updated_by task_updated_by
			 , to_char(ptv.start_date, 'yyyy-mm-dd') task_start_date
			 , to_char(ptv.completion_date, 'yyyy-mm-dd') task_completion_date
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join fnd_lookup_values_vl flv_service_type on flv_service_type.lookup_code = ptv.service_type_code and flv_service_type.lookup_type = 'PJF_SERVICE_TYPE'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- TASK HIERARCHY
-- ##############################################################

/*
https://community.oracle.com/message/15591664
*/

		select ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.project_id
			 , ppav.project_status_code
			 , ppst.project_status_name project_status
			 , haou.name org
			 , pptt.project_type
			 , ptv.task_number
			 , ptv.task_name
			 , ptv.task_id
			 , flv_service_type.meaning task_service_type
			 , lpad ('_', (level - 1) * 3, '_') || ptv.task_number hier
			 , level
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join fnd_lookup_values_vl flv_service_type on flv_service_type.lookup_code = ptv.service_type_code and flv_service_type.lookup_type = 'PJF_SERVICE_TYPE'
		 where 1 = 1
	start with ppav.segment1 = '123456' --  and ptv.parent_task_id not in (select task_id from pjf_tasks_v where project_id = ppav.project_id)
	connect by prior ptv.task_id = ptv.parent_task_id
		 order siblings by ptv.task_number

-- ##############################################################
-- PROJECT BURDENS
-- ##############################################################

		select ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , haou.name org
			 , pptt.project_type
			 , ppeb.cost_ind_rate_sch_id
		  from pjf_projects_all_vl ppav
		  join pjf_proj_elements_b ppeb on ppav.project_id = ppeb.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		 where 1 = 1
		   and ppeb.ovr_cost_ind_rate_sch_id is not null
		   and ppeb.cost_ind_rate_sch_id is not null
		   and 1 = 1

-- ##############################################################
-- COUNT BY PROJECT AND TASK
-- ##############################################################

		select ppav.segment1 proj_number
			 , ppav.project_id
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , ppst.project_status_name project_status
			 , haou.name org
			 , pptt.project_type
			 , count(*) task_count
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		 where 1 = 1
		   and 1 = 1
	  group by ppav.segment1
			 , ppav.project_id
			 , ppav.name
			 , ppav.project_status_code
			 , ppst.project_status_name
			 , haou.name
			 , pptt.project_type
	  order by 8 desc

-- ##############################################################
-- COUNT BY PROJECT TYPE
-- ##############################################################

		select pptt.project_type
			 , pptb.burden_cost_flag
			 , count(*)
		  from pjf_projects_all_vl ppav
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
	 left join pjf_project_types_b pptb on pptb.project_type_id = ppav.project_type_id
	  group by pptt.project_type, pptb.burden_cost_flag
	  order by pptt.project_type

-- ##############################################################
-- COUNT BY STATUS
-- ##############################################################

		select ppst.project_status_name project_template
			 , min(ppav.segment1)
			 , max(ppav.segment1)
			 , min(to_char(ppav.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(ppav.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , count(*) project_count
		  from pjf_projects_all_vl ppav
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		 where 1 = 1
		   and 1 = 1
	  group by ppst.project_status_name
	  order by ppst.project_status_name

-- ##############################################################
-- COUNT BY TEMPLATE
-- ##############################################################

		select ppav_templ.name project_template
			 , min(ppav.segment1)
			 , max(ppav.segment1)
			 , min(to_char(ppav.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(ppav.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , count(*) project_count
		  from pjf_projects_all_vl ppav
		  join pjf_projects_all_vl ppav_templ on ppav_templ.project_id = ppav.created_from_project_id
		 where 1 = 1
		   and 1 = 1
	  group by ppav_templ.name
	  order by ppav_templ.name
