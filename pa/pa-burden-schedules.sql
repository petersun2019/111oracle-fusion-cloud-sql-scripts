/*
File Name: pa-burden-schedules.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PROJECT AND RATES
-- PROJECT AND RATES AND BURDEN REVISIONS
-- COST BASE ASSIGNMENTS
-- COST BASE ASSIGNMENTS
-- LINKED TO EXPENDITURE ITEMS 1
-- LINKED TO EXPENDITURE ITEMS 2
-- COMPILED SETS

*/

-- ##############################################################
-- PROJECT AND RATES
-- ##############################################################

		select ppav.segment1 project_number
			 -- , ppav.name project_name
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , ppav.project_id
			 , pptt.project_type
			 , ppst.project_status_name 
			 , (select count(*) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) item_count
			 , pirsv.ind_rate_sch_id
			 , pirsv.ind_sch_name
			 , pirsv.task_id 
			 , pirsv.creation_date rate_created
			 , pirsv.created_by rate_created_by
		  from pjf_projects_all_vl ppav
	 left join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		 where 1 = 1
		   and 1 = 1
	  order by to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- PROJECT AND RATES AND BURDEN REVISIONS
-- ##############################################################

/*
PJF_IRS_REVISIONS PA_IND_RATE_SCH_REVISIONS stores revisions of burden schedules with different effective dates 
Each revision is a group of burden rates that are effective between the start date and end date of the revision
*/

		select ppav.segment1 project_number
			 -- , ppav.name project_name
			 , ppav.project_id
			 , pptt.project_type
			 , ppst.project_status_name
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , to_char(ppav.start_date, 'yyyy-mm-dd') start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') completion_date
			 , to_char(ppav.closed_date, 'yyyy-mm-dd') closed_date
			 , '#'
			 , pirsv.ind_sch_name
			 , pirsv.task_id 
			 , to_char(pirsv.creation_date, 'yyyy-mm-dd hh24:mi:ss') rate_created
			 , pirsv.created_by rate_created_by
			 , '##'
			 , pir.ind_rate_sch_revision
			 , to_char(pir.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(pir.end_date_active, 'yyyy-mm-dd') end_date_active
			 , pir.ind_structure_name
			 , pir.tree_structure_code
			 , pir.tree_code
			 , pir.compiled_flag
			 , pir.compiled_date
			 , to_char(pir.creation_date, 'yyyy-mm-dd hh24:mi:ss') revision_created
			 , pir.last_update_date revision_updated
			 , pir.ready_to_compile_flag
			 , '###'
			 , to_char(picm.creation_date, 'yyyy-mm-dd hh24:mi:ss') multiplier_created
			 , picm.ind_cost_code
			 , picm.multiplier_num
		  from pjf_projects_all_vl ppav
		  join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
		  join pjf_irs_revisions pir on pir.ind_rate_sch_id = pirsv.ind_rate_sch_id
		  join pjf_ind_cost_multipliers picm on picm.ind_rate_sch_revision_id = pir.ind_rate_sch_revision_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		 where 1 = 1
	  order by ppav.creation_date desc

-- ##############################################################
-- COST BASE ASSIGNMENTS
-- ##############################################################

		select proj_b.segment1 proj_num
			 , proj_b.project_id
			 , proj_b.cost_ind_rate_sch_id proj_sched
			 , proj_b.cost_ind_sch_fixed_date proj_fix_date
			 , proj_b.ovr_cost_ind_rate_sch_id proj_o_sched
			 , ele_b.proj_element_id
			 , proj_tl.name proj_name
			 , ele_b.element_number
			 , ele_b.cost_ind_rate_sch_id task_sched
			 , ele_b.cost_ind_sch_fixed_date task_fix_date
			 , ele_b.ovr_cost_ind_rate_sch_id task_o_sched
		  from pjf_projects_all_b proj_b
			 , pjf_projects_all_tl proj_tl
			 , pjf_proj_elements_b ele_b
			 , pjf_proj_elements_tl ele_tl
		 where proj_b.project_id = proj_tl.project_id
		   and proj_tl.language = userenv('lang')
		   and proj_b.project_id = ele_b.project_id
		   and ele_b.proj_element_id = ele_tl.proj_element_id
		   and ele_tl.language = proj_tl.language
		   and 1 = 1

-- ##############################################################
-- COST BASE ASSIGNMENTS
-- ##############################################################

		select petl.expenditure_type_name
			 , pcbet.ind_structure_name
			 , pcbet.cost_base 
			 , pcbet.cost_base_type
			 , pcbet.creation_date
			 , pcbet.created_by
		  from pjf_cost_base_exp_types pcbet
		  join pjf_exp_types_tl petl on pcbet.expenditure_type_id = petl.expenditure_type_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- LINKED TO EXPENDITURE ITEMS 1
-- ##############################################################

with my_data as
(select ppav.segment1 project_number
			 , pptt.project_type
			 , ppst.project_status_name
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , to_char(ppav.start_date, 'yyyy-mm-dd') start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') completion_date
			 , to_char(ppav.closed_date, 'yyyy-mm-dd') closed_date
			 , pirsv.ind_sch_name
			 , to_char(pirsv.creation_date, 'yyyy-mm-dd hh24:mi:ss') rate_created
			 , pirsv.created_by rate_created_by
			 , pir.ind_rate_sch_revision
			 , to_char(pir.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(pir.end_date_active, 'yyyy-mm-dd') end_date_active
			 , pir.ind_structure_name
			 , pir.tree_structure_code
			 , pir.tree_code
			 , pir.compiled_flag
			 , pir.compiled_date
			 , to_char(pir.creation_date, 'yyyy-mm-dd hh24:mi:ss') revision_created
			 , pir.last_update_date revision_updated
			 , pir.ready_to_compile_flag
			 , to_char(picm.creation_date, 'yyyy-mm-dd hh24:mi:ss') multiplier_created
			 , picm.ind_cost_code
			 , picm.multiplier_num
			 , peia.expenditure_item_id
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') exp_item_date
			 , case when pcdla.burden_sum_source_run_id < 0 then 'N'
					when pcdla.burden_sum_source_run_id > 0 then 'Y'
			   end burdened
		  from pjf_projects_all_vl ppav
		  join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
		  join pjf_irs_revisions pir on pir.ind_rate_sch_id = pirsv.ind_rate_sch_id
		  join pjf_ind_cost_multipliers picm on picm.ind_rate_sch_revision_id = pir.ind_rate_sch_revision_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id
		  join pjc_cost_dist_lines_all pcdla on pcdla.project_id = peia.project_id and pcdla.expenditure_item_id = peia.expenditure_item_id
		  join pjf_project_types_b pptb on pptb.project_type_id = ppav.project_type_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
		 where 1 = 1
		   and pir.compiled_flag = 'Y'
		   and pptb.burden_cost_flag = 'Y'
		   and petl.expenditure_type_name != 'Overheads')
		select my_data.project_number
			 , my_data.project_type
			 , my_data.project_status_name
			 , my_data.project_created
			 , my_data.start_date
			 , my_data.completion_date
			 , my_data.closed_date
			 , my_data.ind_sch_name
			 , my_data.rate_created
			 , my_data.rate_created_by
			 , my_data.ind_rate_sch_revision
			 , my_data.start_date_active
			 , my_data.end_date_active
			 , my_data.ind_structure_name
			 , my_data.tree_structure_code
			 , my_data.tree_code
			 , my_data.compiled_flag
			 , my_data.compiled_date
			 , my_data.revision_created
			 , my_data.revision_updated
			 , my_data.ready_to_compile_flag
			 , my_data.multiplier_created
			 , my_data.ind_cost_code
			 , my_data.multiplier_num
			 , my_data.burdened
			 , count(distinct(my_data.expenditure_item_id)) item_count
			 , max(my_data.exp_item_date) max_item_date
			 , min(my_data.exp_item_date) min_item_date
		  from my_data
	  group by my_data.project_number
			 , my_data.project_type
			 , my_data.project_status_name
			 , my_data.project_created
			 , my_data.start_date
			 , my_data.completion_date
			 , my_data.closed_date
			 , my_data.ind_sch_name
			 , my_data.rate_created
			 , my_data.rate_created_by
			 , my_data.ind_rate_sch_revision
			 , my_data.start_date_active
			 , my_data.end_date_active
			 , my_data.ind_structure_name
			 , my_data.tree_structure_code
			 , my_data.tree_code
			 , my_data.compiled_flag
			 , my_data.compiled_date
			 , my_data.revision_created
			 , my_data.revision_updated
			 , my_data.ready_to_compile_flag
			 , my_data.multiplier_created
			 , my_data.ind_cost_code
			 , my_data.multiplier_num
			 , my_data.burdened

-- ##############################################################
-- LINKED TO EXPENDITURE ITEMS 2
-- ##############################################################

/*
Removing the multipliers as that leads to duplicates where the project has > 1 burden multiplier (can be linked to different burden cost codes, like research overhead consumables, research overhead general etc.
*/

with my_data as
(select ppav.segment1 project_number
			 , pptt.project_type
			 , ppst.project_status_name
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , to_char(ppav.start_date, 'yyyy-mm-dd') start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') completion_date
			 , to_char(ppav.closed_date, 'yyyy-mm-dd') closed_date
			 , pirsv.ind_sch_name
			 , to_char(pirsv.creation_date, 'yyyy-mm-dd hh24:mi:ss') rate_created
			 , pirsv.created_by rate_created_by
			 , pir.ind_rate_sch_revision
			 , to_char(pir.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(pir.end_date_active, 'yyyy-mm-dd') end_date_active
			 , pir.ind_structure_name
			 , pir.tree_structure_code
			 , pir.tree_code
			 , pir.compiled_flag
			 , pir.compiled_date
			 , to_char(pir.creation_date, 'yyyy-mm-dd hh24:mi:ss') revision_created
			 , pir.last_update_date revision_updated
			 , pir.ready_to_compile_flag
			 , peia.expenditure_item_id
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') exp_item_date
			 , case when pcdla.burden_sum_source_run_id < 0 then 'N'
					when pcdla.burden_sum_source_run_id > 0 then 'Y'
			   end burdened
		  from pjf_projects_all_vl ppav
		  join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
		  join pjf_irs_revisions pir on pir.ind_rate_sch_id = pirsv.ind_rate_sch_id
		  join pjf_ind_cost_multipliers picm on picm.ind_rate_sch_revision_id = pir.ind_rate_sch_revision_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id
		  join pjc_cost_dist_lines_all pcdla on pcdla.project_id = peia.project_id and pcdla.expenditure_item_id = peia.expenditure_item_id
		  join pjf_project_types_b pptb on pptb.project_type_id = ppav.project_type_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
		 where 1 = 1
		   and pir.compiled_flag = 'Y'
		   and pptb.burden_cost_flag = 'Y'
		   and petl.expenditure_type_name != 'Overheads'
		   and ppav.segment1 = 'PROJ123')
		select my_data.project_number
			 , my_data.project_type
			 , my_data.project_status_name
			 , my_data.project_created
			 , my_data.start_date
			 , my_data.completion_date
			 , my_data.closed_date
			 , my_data.ind_sch_name
			 , my_data.rate_created
			 , my_data.rate_created_by
			 , my_data.ind_rate_sch_revision
			 , my_data.start_date_active
			 , my_data.end_date_active
			 , my_data.ind_structure_name
			 , my_data.tree_structure_code
			 , my_data.tree_code
			 , my_data.compiled_flag
			 , my_data.compiled_date
			 , my_data.revision_created
			 , my_data.revision_updated
			 , my_data.ready_to_compile_flag
			 , my_data.burdened
			 , count(distinct(my_data.expenditure_item_id)) item_count
			 , max(my_data.exp_item_date) max_item_date
			 , min(my_data.exp_item_date) min_item_date
		  from my_data
	  group by my_data.project_number
			 , my_data.project_type
			 , my_data.project_status_name
			 , my_data.project_created
			 , my_data.start_date
			 , my_data.completion_date
			 , my_data.closed_date
			 , my_data.ind_sch_name
			 , my_data.rate_created
			 , my_data.rate_created_by
			 , my_data.ind_rate_sch_revision
			 , my_data.start_date_active
			 , my_data.end_date_active
			 , my_data.ind_structure_name
			 , my_data.tree_structure_code
			 , my_data.tree_code
			 , my_data.compiled_flag
			 , my_data.compiled_date
			 , my_data.revision_created
			 , my_data.revision_updated
			 , my_data.ready_to_compile_flag
			 , my_data.burdened

-- ##############################################################
-- COMPILED SETS
-- ##############################################################

/*
when "Build New Organization Burden Multipliers" is run, data is loaded onto the PJF_IND_COMPILED_SETS table
*/

		select ind_compiled_set_id
			 , ind_rate_sch_revision_id
			 , organization_id
			 , cost_base
			 , status
			 , compiled_multiplier_sum
		  from pjf_ind_compiled_sets
		 where ind_rate_sch_revision_id in (123456,234567)
		   and organization_id in (987654,876543,765432)
	  order by ind_rate_sch_revision_id
			 , organization_id
			 , cost_base
			 , ind_compiled_set_id
