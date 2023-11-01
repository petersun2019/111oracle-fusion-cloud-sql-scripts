/*
File Name: pa-expenditure-types.sql

Queries:

-- EXPENDITURE TYPES
-- EXPENDITURE TYPES LINKED TO EXPENDITURE ITEMS
-- EXPENDITURE TYPE CLASSES

*/

-- ##############################################################
-- EXPENDITURE TYPES
-- ##############################################################

		select petb.expenditure_type_id
			 , petl.expenditure_type_name
			 , petb.unit_of_measure
			 , to_char(petb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , petb.created_by
			 , to_char(petb.creation_date, 'yyyy-mm-dd') start_date_active
			 , to_char(petb.creation_date, 'yyyy-mm-dd') end_date_active
			 , petb.revenue_category_code
			 , pect.expenditure_category_name
		  from pjf_exp_types_b petb
		  join pjf_exp_types_tl petl on petb.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_exp_categories_tl pect on petb.expenditure_category_id = pect.expenditure_category_id and pect.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- EXPENDITURE TYPES LINKED TO EXPENDITURE ITEMS
-- ##############################################################

		select petb.expenditure_type_id
			 , petl.expenditure_type_name
			 , petb.unit_of_measure
			 , to_char(petb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , petb.created_by
			 , to_char(petb.start_date_active, 'yyyy-mm-dd') start_date_active
			 , to_char(petb.end_date_active, 'yyyy-mm-dd') end_date_active
			 , petb.revenue_category_code
			 , pect.expenditure_category_name
			 , count(peia.expenditure_item_id) item_count
			 , sum(round(peia.project_raw_cost,20)) project_raw_cost
			 , min(round(peia.project_raw_cost,20)) project_raw_cost_min
			 , max(round(peia.project_raw_cost,20)) project_raw_cost_max
			 , sum(round(peia.project_burdened_cost,20)) project_burdened_cost
			 , sum(round(peia.quantity, 20)) quantity
			 , to_char(min(peia.creation_date),'yyyy-mm-dd') min_item_created
			 , to_char(max(peia.creation_date),'yyyy-mm-dd') max_item_created
			 , to_char(min(peia.expenditure_item_date),'yyyy-mm-dd') min_item_date
			 , to_char(max(peia.expenditure_item_date),'yyyy-mm-dd') max_item_date
			 , min(ppav.segment1) min_proj_number
			 , max(ppav.segment1) max_proj_number
		  from pjf_exp_types_b petb
		  join pjf_exp_types_tl petl on petb.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_exp_categories_tl pect on petb.expenditure_category_id = pect.expenditure_category_id and pect.language = userenv('lang')
		  join pjc_exp_items_all peia on peia.expenditure_type_id = petb.expenditure_type_id
		  join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1
	  group by petb.expenditure_type_id
			 , petl.expenditure_type_name
			 , petb.unit_of_measure
			 , to_char(petb.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , petb.created_by
			 , to_char(petb.start_date_active, 'yyyy-mm-dd')
			 , to_char(petb.end_date_active, 'yyyy-mm-dd')
			 , petb.revenue_category_code
			 , pect.expenditure_category_name

-- ##############################################################
-- EXPENDITURE TYPE CLASSES
-- ##############################################################

		select petb.expenditure_type_id
			 , petl.expenditure_type_name
			 , petb.unit_of_measure
			 , to_char(petb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , petb.created_by
			 , to_char(petb.creation_date, 'yyyy-mm-dd') start_date_active
			 , to_char(petb.creation_date, 'yyyy-mm-dd') end_date_active
			 , petb.revenue_category_code
			 , pect.expenditure_category_name
			 , pslt.meaning exp_type_class
			 , pslt.description exp_type_class_description
		  from pjf_exp_types_b petb
		  join pjf_exp_types_tl petl on petb.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_exp_categories_tl pect on petb.expenditure_category_id = pect.expenditure_category_id and pect.language = userenv('lang')
		  join pjf_expend_typ_sys_links petsl on petsl.expenditure_type_id = petb.expenditure_type_id
		  join pjf_system_linkages_tl pslt on pslt.function = petsl.system_linkage_function and pslt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
