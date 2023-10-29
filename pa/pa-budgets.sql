/*
File Name: pa-budgets.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- BUDGETS 1
-- BUDGETS 2
-- BUDGETS 3
-- BUDGETS 4
-- BUDGETS 5
-- BUDGET SUMMARY ATTEMPT 1
-- BUDGET SUMMARY ATTEMPT 2
-- BUDGETS VIEW
-- PJO_PLAN_VERSIONS_B TABLE DUMP
-- PJO_PLAN_VERSIONS_VL TABLE DUMP
-- PJO_PLAN_LINES TABLE DUMP
-- PJO_PLANNING_ELEMENTS TABLE DUMP
-- PJO_PLAN_LINE_DETAILS TABLE DUMP

*/

-- ##############################################################
-- BUDGETS 1
-- ##############################################################

		select ppav.segment1 proj
			 -- , ppav.name
			 -- , ppav.description
			 , '#' || ppav.project_id project_id
			 , to_char(ppav.creation_date, 'YYYY-MM-DD HH24:MI:SS') proj_created
			 , ppav.created_by project_created_by
			 , ppav.pm_product_code
			 , ppav.pm_project_reference
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , '#################'
			 , '#' || ppvb.plan_version_id plan_version_id
			 , ppvb.object_version_number 
			 , pptl.name budget_type
			 , ppvt.version_name
			 , ppvb.plan_type_id
			 , ppvb.planned_for_code
			 , ppvb.plan_status_code
			 , ppvb.current_plan_status_flag
			 , ppvb.version_number
			 , ppvb.original_flag
			 , to_char(ppvb.last_refresh_date, 'yyyy-mm-dd hh24:mi:ss') last_refresh_date
			 , to_char(ppvb.baselined_date, 'yyyy-mm-dd hh24:mi:ss') baselined_date
			 , ppvb.pfc_raw_cost
			 , ppvb.pfc_revenue
			 , ppvb.pm_budget_reference
			 , to_char(ppvb.creation_date, 'YYYY-MM-DD HH24:MI:SS') budget_created
			 , ppvb.created_by budget_created_by
			 , to_char(ppvb.last_update_date, 'YYYY-MM-DD HH24:MI:SS') budget_update_date
			 , ppvb.last_updated_by budget_updated_by
			 , pu.username budget_locked_by
		  from pjf_projects_all_vl ppav
		  join pjo_plan_versions_b ppvb on ppvb.project_id = ppav.project_id
		  join pjo_plan_versions_tl ppvt on ppvt.plan_version_id = ppvb.plan_version_id and ppvt.language = userenv('lang')
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
		  join pjo_plan_types_tl pptl on pptl.plan_type_id = ppvb.plan_type_id and pptl.language = userenv('lang')
	 left join per_users pu on pu.user_guid = ppvb.locked_by_person_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGETS 2
-- ##############################################################

		select ppav.segment1 proj
			 , ppav.project_id
			 , ptv.task_number
			 , ppvb.creation_date budget_versioned
			 , ppvb.plan_version_id
			 , pptl.name budget_type
			 , null seg1
			 , ppvt.version_name budget_name
			 , ppvb.plan_status_code budget_status
			 , ppvb.current_plan_status_flag current_flag
			 , ppvb.creation_date budget_created
			 , ppvb.created_by budget_created_by
			 , ppvb.version_number budget_version
			 , ppvb.original_flag
			 , to_char(ppvb.baselined_date, 'yyyy-mm-dd hh24:mi:ss') baselined_date
			 , ppvb.pfc_raw_cost total_raw_cost
			 , ppvb.pfc_revenue total_revenue
			 , pecl.expenditure_category_name
			 , petl.expenditure_type_name exp_type
			 , ppl.total_tc_raw_cost
			 , ppl.total_tc_brdnd_cost
			 , ppl.total_tc_revenue
			 , ppl.total_pfc_raw_cost
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
		  join pjo_plan_versions_b ppvb on ppvb.project_id = ppav.project_id
		  join pjo_plan_versions_tl ppvt on ppvt.plan_version_id = ppvb.plan_version_id and ppvt.language = userenv('lang')
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjo_plan_types_tl pptl on pptl.plan_type_id = ppvb.plan_type_id and pptl.language = userenv('lang')
	 left join pjo_planning_elements ppe on ppe.plan_version_id = ppvb.plan_version_id and ptv.task_id = ppe.task_id
	 left join pjo_plan_lines ppl on ppvb.plan_version_id = ppl.plan_version_id and ppl.planning_element_id = ppe.planning_element_id
	 left join pjf_exp_types_tl petl on ppe.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_exp_categories_tl pecl on ppe.expenditure_category_id = pecl.expenditure_category_id and pecl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGETS 3
-- ##############################################################

		select ppav.segment1 proj
			 -- , ppav.name
			 -- , ppav.description
			 , ppav.creation_date proj_created
			 , ppav.created_by project_created_by
			 , ppav.pm_product_code
			 , ppav.pm_project_reference
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , '❌' "❌"
			 , ppvb.creation_date budget_versioned
			 , ppvb.plan_version_id
			 , pptl.name budget_type
			 , ppvt.version_name
			 , ppvb.plan_type_id
			 , ppvb.planned_for_code
			 , ppvb.plan_status_code
			 , ppvb.current_plan_status_flag
			 , ppvb.version_number
			 , ppvb.original_flag
			 , to_char(ppvb.baselined_date, 'yyyy-mm-dd hh24:mi:ss') baselined_date
			 , ppvb.pfc_raw_cost
			 , ppvb.pfc_revenue
			 , ppvb.pm_budget_reference
			 , ppvb.creation_date budget_created
			 , ppvb.created_by budget_created_by
			 , ppvb.last_update_date budget_update_date
			 , ppvb.last_updated_by budget_updated_by
			 , '❌❌' "❌❌"
			 , ptv.task_number
			 , ptv.task_name
			 , '❌❌❌' "❌❌❌"
			 , ppl.creation_date bud_line_created
			 , ppl.created_by bug_line_created_by
			 , ppl.last_update_date bud_line_updated
			 , ppl.last_updated_by bud_line_updated_by
			 , '❌❌❌❌' "❌❌❌❌"
			 , ppl.txn_currency_code
			 , ppl.total_act_quantity
			 , ppl.total_tc_act_raw_cost
			 , ppl.total_tc_act_brdnd_cost
			 , ppl.total_tc_act_revenue
			 , ppl.total_pc_act_raw_cost
			 , ppl.total_pc_act_brdnd_cost
			 , ppl.total_pc_act_revenue
			 , ppl.total_pfc_act_raw_cost
			 , ppl.total_pfc_act_brdnd_cost
			 , ppl.total_pfc_act_revenue
		  from pjf_projects_all_vl ppav
	 left join pjo_plan_versions_b ppvb on ppvb.project_id = ppav.project_id
	 left join pjo_plan_versions_tl ppvt on ppvt.plan_version_id = ppvb.plan_version_id and ppvt.language = userenv('lang')
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
	 left join pjo_plan_types_tl pptl on pptl.plan_type_id = ppvb.plan_type_id and pptl.language = userenv('lang')
	 left join pjo_plan_lines ppl on ppvb.plan_version_id = ppl.plan_version_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and ptv.task_id = ppl.planning_element_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGETS 4
-- ##############################################################

		select pv.project_id
			 , gps.period_name
			 , gps.period_year
			 , rbse.resource_source_id
			 , rbse.alias as resource_name
			 , pv.plan_version_id
			 , pld.quantity
			 , pld.start_date pld_start
			 , pld.end_date pld_end
			 , gps.start_date gps_start
			 , gps.end_date gps_end
			 , pe.planning_element_id
			 , pe.task_id
			 , pe.rbs_element_id
			 , pe.res_type_code
			 , pe.expenditure_type_id   
		  from pjf_rbs_elements rbse
		  join pjo_planning_elements pe on pe.rbs_element_id = rbse.rbs_element_id
		  join pjo_plan_line_details pld on pld.planning_element_id = pe.planning_element_id
		  join gl_period_statuses gps on ((gps.start_date <= pld.end_date) and (gps.end_date >= pld.start_date))
		  join pjo_plan_versions_vl pv on pv.plan_version_id = pe.plan_version_id
		  join pjo_plan_types_vl pt on pv.plan_type_id = pt.plan_type_id
		  join pjf_projects_all_vl ppav on ppav.project_id = pv.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGETS 5
-- ##############################################################

		select ppab.segment1 project
			 , ppab.project_id
			 , t.name plan_type_name
			 , t.description plan_type_desc
			 , b.budgetary_controls_flag
			 , b.plan_type_code
			 , b.plan_class_code
			 , b.plan_option_code
			 , b.approved_cost_plan_type_flag
			 , b.enable_wf_flag
			 , plan_tl.version_name plan_version
			 , plan_tl.description plan_desc
			 , plan_b.plan_version_id
			 , b.plan_type_id
			 , plan_b.planned_for_code
			 , plan_b.plan_status_code
			 , plan_b.current_plan_status_flag
			 , plan_b.version_number
			 , plan_b.locked_by_person_id
			 , plan_b.original_flag
			 , plan_b.baselined_by_person_id
			 , plan_b.baselined_date
			 , plan_b.pfc_raw_cost
			 , plan_b.pfc_brdnd_cost
			 , plan_b.pfc_revenue
			 , plan_b.total_pc_raw_cost
			 , plan_b.total_pc_brdnd_cost
			 , plan_b.total_pc_revenue
		  from pjo_plan_types_b b
		  join pjo_plan_types_tl t on b.plan_type_id = t.plan_type_id and t.language = userenv('lang')
		  join pjo_plan_versions_b plan_b on b.plan_type_id = plan_b.plan_type_id
		  join pjo_plan_versions_tl plan_tl on plan_tl.plan_version_id = plan_b.plan_version_id and plan_tl.language = userenv('lang')
		  join pjf_projects_all_b ppab on plan_b.project_id = ppab.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGET SUMMARY ATTEMPT 1
-- ##############################################################

		select ppav.segment1 proj
			 , ppvt.version_name
			 , ppvb.object_version_number
			 , ppvb.plan_status_code
			 , to_char(ppvb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ppvb.last_updated_by
			 , ppvb.pm_budget_reference
			 , ppvb.request_id
			 , ppvb.lines_processed
			 , nvl(sum(ppvb.pfc_raw_cost), 0) pfc_raw_cost
			 , nvl(sum(ppvb.pfc_brdnd_cost), 0) pfc_brdnd_cost
			 , nvl(sum(pbl.total_tc_act_raw_cost), 0) total_tc_act_raw_cost
			 , nvl(sum(pbl.total_tc_act_brdnd_cost), 0) total_tc_act_brdnd_cost
			 , nvl(sum(pbl.total_pc_act_raw_cost), 0) total_pc_act_raw_cost
			 , nvl(sum(pbl.total_pc_act_brdnd_cost), 0) total_pc_act_brdnd_cost
			 , nvl(sum(pbl.total_pfc_act_raw_cost), 0) total_pfc_act_raw_cost
			 , nvl(sum(pbl.total_pfc_act_brdnd_cost), 0) total_pfc_act_brdnd_cost
			 , count(*)
		  from pjf_projects_all_vl ppav
		  join pjo_plan_versions_b ppvb on ppvb.project_id = ppav.project_id
		  join pjo_plan_versions_tl ppvt on ppvt.plan_version_id = ppvb.plan_version_id and ppvt.language = userenv('lang')
		  join pjo_plan_lines pbl on pbl.plan_version_id = ppvb.plan_version_id
		 where 1 = 1
		   and ppvb.plan_status_code = 'W'
		   and 1 = 1
	  group by ppav.segment1
			 , ppvt.version_name
			 , ppvb.object_version_number
			 , ppvb.plan_status_code
			 , to_char(ppvb.last_update_date, 'yyyy-mm-dd hh24:mi:ss')
			 , ppvb.last_updated_by
			 , ppvb.pm_budget_reference
			 , ppvb.request_id
			 , ppvb.lines_processed
	  order by to_char(ppvb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- BUDGET SUMMARY ATTEMPT 2
-- ##############################################################

		select ppav.segment1 proj
			 , ppvt.version_name
			 , ppvb.object_version_number
			 , ppvb.plan_status_code
			 , ppvb.lines_processed
			 , to_char(ppvb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ppvb.last_updated_by
			 , nvl(sum(ppld.tc_raw_cost), 0) raw_cost
			 -- , nvl(sum(ppld.tc_revenue), 0) revenue
			 , nvl(nvl(sum(ppld.tc_raw_cost), 0) - nvl(sum(ppld.tc_revenue), 0), 0) total_budget
			 , count(*)
		  from pjf_projects_all_vl ppav
		  join pjo_plan_versions_b ppvb on ppvb.project_id = ppav.project_id
		  join pjo_plan_versions_tl ppvt on ppvt.plan_version_id = ppvb.plan_version_id and ppvt.language = userenv('lang')
		  join pjo_plan_line_details ppld on ppvb.plan_version_id = ppld.plan_version_id
		 where 1 = 1
		   -- and ppvb.object_version_number = (select max(object_version_number) from pjo_plan_versions_b max_version where max_version.project_id = ppav.project_id)
		   and ppvb.plan_status_code = 'W'
		   and 1 = 1
	  group by ppav.segment1
			 , ppvt.version_name
			 , ppvb.object_version_number
			 , ppvb.plan_status_code
			 , ppvb.lines_processed
			 , to_char(ppvb.last_update_date, 'yyyy-mm-dd hh24:mi:ss')
			 , ppvb.last_updated_by
	  order by to_char(ppvb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- BUDGETS VIEW
-- ##############################################################

			select ppav.segment1 proj
				 , '#' || ppav.project_id project_id
				 , ppvv.version_name
				 , ppvv.object_version_number
				 , ppvv.pfc_raw_cost
				 , ppvv.pfc_brdnd_cost
				 , to_char(ppvv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
				 , ppvv.created_by
				 , to_char(ppvv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
				 , ppvv.last_updated_by
			  from pjf_projects_all_vl ppav
			  join pjo_plan_versions_vl ppvv on ppvv.project_id = ppav.project_id
			 where 1 = 1
			   and ppvv.plan_status_code = 'W'
			   and ppvv.current_plan_status_flag = 'Y'
			   and ppvv.budgetary_controls_flag = 'Y'
			   and 1 = 1
		  order by to_char(ppvv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- PJO_PLAN_VERSIONS_B TABLE DUMP
-- ##############################################################

/*
Header table that contains basic information for project plans and financial plan versions.
*/

		select ppav.segment1 proj
			 , ppvb.*
		  from pjf_projects_all_vl ppav
		  join pjo_plan_versions_b ppvb on ppvb.project_id = ppav.project_id
		  join pjo_plan_versions_tl ppvt on ppvt.plan_version_id = ppvb.plan_version_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PJO_PLAN_VERSIONS_VL TABLE DUMP
-- ##############################################################

		select ppav.segment1 proj
			 , ppvv.*
		  from pjf_projects_all_vl ppav
		  join pjo_plan_versions_vl ppvv on ppvv.project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PJO_PLAN_LINES TABLE DUMP
-- ##############################################################

		select ppab.segment1 project
			 , ppl.* 
		  from pjo_plan_lines ppl
		  join pjo_plan_versions_b plan_b on plan_b.plan_version_id = ppl.plan_version_id
		  join pjf_projects_all_b ppab on ppab.project_id = plan_b.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PJO_PLANNING_ELEMENTS TABLE DUMP
-- ##############################################################

		select ppab.segment1 project
			 , ppl.* 
		  from pjo_planning_elements ppl
		  join pjo_plan_versions_b plan_b on plan_b.plan_version_id = ppl.plan_version_id
		  join pjf_projects_all_b ppab on ppab.project_id = plan_b.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PJO_PLAN_LINE_DETAILS TABLE DUMP
-- ##############################################################

		select ppab.segment1 project
			 , ppl.* 
		  from pjo_plan_line_details ppl
		  join pjo_plan_versions_b plan_b on plan_b.plan_version_id = ppl.plan_version_id
		  join pjf_projects_all_b ppab on ppab.project_id = plan_b.project_id
		 where 1 = 1
		   and 1 = 1
