/*
File Name: pa-expenditures.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- EXPENDITURE ITEMS 1 -- INC COST LINES
-- EXPENDITURE BATCHES
-- EXPENDITURE ITEMS 2 - WITH ERRORS AND COMMENTS AND PERIODS
-- EXPENDITURE ITEMS 3
-- EXPENDITURE ITEMS 4 - WITH REVENUE DISTRIBUTIONS
-- EXPENDITURE ITEMS 5 - LINKED TO POS AND RECEIPTS
-- EXPENDITURE ITEMS 6 - COST LINES SUMMARY
-- EXPENDITURE ITEMS 7 - CONTRACTS 
-- EXPENDITURE ITEMS 8 - AP INVOICES 
-- LINKING AP INVOICES BACK TO PROJECTS
-- DOCUMENT ENTRIES
-- ADJUSTMENTS
-- COUNT BY CREATION DATE
-- COUNT BY CREATED BY
-- COUNT BY EXPENDITURE TYPE
-- COUNT BY TRANSACTION SOURCE
-- COUNT OF PA EXP ITEMS SENT TO GL
-- COUNT PER PROJECT
-- COUNT BY REVENUE STATUS 1
-- COUNT BY REVENUE STATUS 2
-- COUNT PER PROJECT TYPE AND EXPENDITURE TYPE
-- COUNT AND SUM BY PROJECT, PROJECT TYPE, TASK, ORG, TRX SOURCE, EXP TYPE, DOC ENTRY, BILLABLE FLAG, REVENUE HOLD FLAG
-- COUNT AND SUM BY PROJECT, PROJECT TYPE, TASK, ORG, TRX SOURCE, EXP TYPE
-- COUNT AND SUM BY PROJECT, EXP TYPE
-- COUNT AND SUM BY PROJECT
-- COUNTING AND SUMMING LINKED TO BURDEN STRUCTURES
-- COUNT OF EXP ITEMS PER BURDEN STRUCTURE
-- ACCT SUMMARY

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from pjc_exp_items_all where expenditure_item_id in (1868848,1868862,1868869,1868917,1868938,1868948,1869060,1869074,1869202,2231673,2231675,2231674,2231672)
select * from pjc_cost_dist_lines_all where expenditure_item_id in (1868848,1868862,1868869,1868917,1868938,1868948,1869060,1869074,1869202,2231673,2231675,2231674,2231672)
select * from pjc_expend_item_adj_acts

-- ##############################################################
-- EXPENDITURE ITEMS 1 -- INC COST LINES
-- ##############################################################

/*
BURDENING NOTES

PJC_EXP_ITEMS_ALL.BURDEN_SUM_DEST_RUN_ID
Burden summarization run id. Id will identify all the expenditure items created by burden component summarization process.
This is used to identify all the Cost distribution lines summarized together to create expenditure item

PJC_COST_DIST_LINES_ALL.IND_COMPILED_SET_ID
The identifier of the compiled set which is used to calculate the burden cost

PJC_COST_DIST_LINES_ALL.BURDEN_SUM_SOURCE_RUN_ID
This will identify group of Cost Distribution Lines that were summarized to create summarized burden component expenditure items(EI).
The same run_id will be populated in EI table to identify all EI's created during a run.

If have a number of Expenditure Items where BURDEN_SUM_SOURCE_RUN_ID is populated, that means those Exp Items have been burdened.
To see which Exp Items are the Exp Items for the Burden Costs generated against those Exp Items, they can be found where
BURDEN_SUM_DEST_RUN_ID is the number of the BURDEN_SUM_SOURCE_RUN_ID for the Burdened Exp Items.

Costs are generated against the project
Costs accumulate against the project.
Then when the generate burden costs runs, a new expenditure item is created.
The expenditure item type against that exp item type = overheads.
A new exp item appears on the pjc_exp_items_all table.
The burden_sum_dest_run_id column is populated with an id for the overheads exp item.
Then in the pjc_cost_dist_lines_all table, the burden_sum_source_run_id field is populated for any costs for existing exp item ids which have been burdened.

e.g. there are two exp items created via webadi, exp item ids 1449000 and 1449001
Generate burden costs runs, with exp item id 1450000 for exp item type: overheads.
For exp item id 1450000, burden_sum_dest_run_id = 23001

If we do this:

		select *
		  from pjc_cost_dist_lines_all
		 where burden_sum_source_run_id = 23001

		select *
		  from pjc_cost_dist_lines_all
		 where burden_sum_source_run_id in (28490, 26003, 26001)

That returns 2 exp items - ids 1449000 and 1449001, which have a value of 23001 in the burden_sum_source_run_id field, which ties them back with the overheads exp item
That is how oracle knows which exp items have been burdened, and why they cannot be burdened again.

When Transfer is done, transferring Raw Cost from 1 Project to another - this happens:

1. Original Item ID 1869074 remains, with same value of 126.00	
2. When transfer done, new Exp Item 2265928 created against Project 10418, with value to reverse value of original item ID 1869074	
3. New Exp Item 2265929 created against Project 10950 for the new cost of 126.00 to reflect cost moving from Project 10418 to Project 10950	
4. When "Generate Burden Costs" ran, it created Exp Item 2266858 against Project 10418, reversing out value of original Burden value of (126 * 1.55 = 195.30)	
5. "Generate Burden Costs" created Exp Item 1166859 with value of (126 * 1.55 = 195.30) against transferred Project 10950	

*/

		select '#' || peia.expenditure_item_id item_id
			 , pptt.project_type
			 , pptb.burden_cost_flag -- burdening only happens for project types where the burden cost flag = Y
			 , ppav.segment1 proj
			 , peia.system_linkage_function cost_fcn
			 , pslt_fcn.meaning cost_fcn_meaning
			 , peia.src_system_linkage_function src_fcn
			 , pslt_src.meaning src_fcn_meaning
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') exp_item_date
			 , replace(replace(pec.expenditure_comment,chr(10),' '),chr(13),' ') expenditure_comment
			 , to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_created
			 , peia.created_by exp_item_created_by
			 , to_char(peia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_updated
			 , peia.last_updated_by exp_item_updated_by
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , peia.orig_transaction_reference
			 , peia.request_id
			 , ptv.task_id
			 , ptv.top_task_id
			 , ptv.parent_task_id
			 , flv_rev.meaning revenue_status
			 , haou.name project_org
			 , haou_exp.name expenditure_org
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , pect.expenditure_category_name
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , pega.expenditure_group
			 , pega.user_batch_name
			 , '#' exp_item_costs____
			 , peia.projfunc_raw_cost -- Raw cost in project Functional Currency *****
			 , peia.projfunc_burdened_cost -- The burden cost in project functional currency *****
			 , peia.denom_raw_cost -- The total raw cost of the expenditure item in transaction currency Raw cost = (quantity * cost rate) This value should always equal the sum of the items raw cost distribution lines	
			 , peia.denom_burdened_cost -- Total burdened cost of the expenditure item in transaction currency Burdened cost = (raw cost * (1 + burden cost multiplier)) This must equal the sum of the items burden debit cost distribution lines For non-burdened items, burdened cost
			 , peia.acct_raw_cost -- Raw cost in Functional Currency
			 , peia.acct_burdened_cost -- Burdened Cost in Functional Currency
			 , peia.project_raw_cost -- Raw cost in project currency
			 , peia.project_burdened_cost -- Burdened cost in project currency
			 , peia.quantity
			 , peia.unit_of_measure uom
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.invoiced_flag
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , peia.net_zero_adjustment_flag -- if y revenue will never be recognised
			 , peia.revenue_exception_flag
			 , peia.original_header_id
			 , peia.original_line_number
			 , peia.user_batch_name peia_user_batch
			 , peia.creation_source
			 , pha.segment1 po
			 , psv.vendor_name supplier
			 , pcdla.line_num line
			 , pcdla.accounting_status_code
			 , '#' cost_line_costs____
			 , pcdla.projfunc_raw_cost projfunc_raw_cost_
			 , pcdla.projfunc_burdened_cost projfunc_burdened_cost_
			 , pcdla.project_burdened_cost project_burdened_cost_
			 , pcdla.denom_raw_cost denom_raw_cost_
			 , pcdla.denom_burdened_cost denom_burdened_cost_
			 , pcdla.acct_raw_cost acct_raw_cost_
			 , pcdla.acct_burdened_cost acct_burdened_cost_
			 , pcdla.quantity cost_item_line_qty
			 , pcdla.billable_flag cost_item_billable_flag
			 , to_char(pcdla.prvdr_pa_date, 'yyyy-mm-dd') pa_date
			 , to_char(pcdla.prvdr_gl_date, 'yyyy-mm-dd') gl_date
			 , pcdla.prvdr_gl_period_name
			 , pcdla.transfer_status_code
			 , pcdla.acct_source_code
			 , '#' id_info___
			 , '#' || peia.adjusted_expenditure_item_id adjusted_expenditure_item_id -- The identifier of the expenditure item adjusted by this expenditure item. Adjustment items are entered by users with negative amounts to fully reverse an item, or are system created to reverse a transferred item.	
			 , '#' || peia.transferred_from_exp_item_id transferred_from_exp_item_id -- The identifier of the expenditure item from which this expenditure item originated. This expenditure item is the new item that is system created when an item is transferred and is charged to the new project/task	
			 , '#' || peia.source_expenditure_item_id source_expenditure_item_id -- Stores the transaction number of the raw cost for which the separate burden cost was created. This is populated for burden cost transactions only if burden grouping is configured in the Project Process Configurator to group burden costs by transaction number.	
			 , '#' || peia.burden_sum_dest_run_id burden_sum_dest_run_id -- Burden summarization run id. If populated, means Exp Item is created via Generate Burden Costs. Id will identify all the expenditure items created by burden component summarization process. This is used to identify all the Cost distribution lines summarized together to create expenditure item	
			 , '#' || pcdla.ind_compiled_set_id ind_compiled_set_id -- The identifier of the compiled set which is used to calculate the burden cost
			 , '#' || pcdla.burden_sum_source_run_id burden_sum_source_run_id -- If populated, means this is a Raw Cost Exp Item which has been Burdened. The same ID appears in the burden_sum_dest_run_id field on the exp item table for the Exp Item for the Burden Cost. This will identify group of Cost Distribution Lines that were summarized to create summarized burden component expenditure items(EI). The same run_id will be populated in EI table to identify all EI's created during a run.
			 , '#' || pcdla.acct_event_id acct_event_id
			 , '#' || pcdla.request_id cost_item_request_id
			 , '#' || pcdla.interface_id interface_id
		  from pjc_exp_items_all peia
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_project_types_b pptb on pptb.project_type_id = ppav.project_type_id
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join hr_all_organization_units haou_exp on peia.expenditure_organization_id = haou_exp.organization_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_exp_types_b petb on petb.expenditure_type_id = petl.expenditure_type_id
	 left join pjf_exp_categories_tl pect on pect.expenditure_category_id = petb.expenditure_category_id and pect.language = userenv('lang')
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join po_headers_all pha on pha.po_header_id = peia.parent_header_id and pha.segment1 = peia.doc_ref_id2
	 left join poz_suppliers_v psv on psv.vendor_id = peia.vendor_id
	 left join pjc_exp_comments pec on pec.expenditure_item_id = peia.expenditure_item_id
	 left join pjf_system_linkages_tl pslt_fcn on pslt_fcn.function = peia.system_linkage_function and pslt_fcn.language = userenv('lang')
	 left join pjf_system_linkages_tl pslt_src on pslt_src.function = peia.src_system_linkage_function and pslt_src.language = userenv('lang')
		  join pjc_cost_dist_lines_all pcdla on pcdla.project_id = peia.project_id and pcdla.expenditure_item_id = peia.expenditure_item_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(peia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- EXPENDITURE BATCHES
-- ##############################################################

		select pega.expenditure_group
			 , pega.user_batch_name
			 , to_char(pega.batch_ending_date, 'yyyy-mm-dd') batch_ending_date
			 , ptst.user_transaction_source trx_source
			 , pega.request_id
			 , pega.creation_date
			 , to_char(pega.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , pega.created_by batch_created_by
			 , count(*) exp_item_count
		  from pjc_exp_groups_all pega
		  join pjf_txn_sources_tl ptst on pega.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjc_exp_items_all peia on peia.exp_group_id = pega.exp_group_id
		 where 1 = 1
		   and 1 = 1
	  group by pega.expenditure_group
			 , pega.user_batch_name
			 , to_char(pega.batch_ending_date, 'yyyy-mm-dd')
			 , ptst.user_transaction_source
			 , pega.request_id
			 , pega.creation_date
			 , to_char(pega.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , pega.created_by
	  order by pega.creation_date desc

-- ##############################################################
-- EXPENDITURE ITEMS 2 - WITH ERRORS AND COMMENTS AND PERIODS
-- ##############################################################

		select '#' || peia.expenditure_item_id item_id
			 -- , pptt.project_type
			 , ppav.segment1 proj_number
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') exp_item_date
			 , pha.segment1 po
			 , psv.vendor_name supplier
			 , to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_created
			 , peia.created_by exp_item_created_by
			 , peia.request_id
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 -- , ptv.task_id
			 -- , ptv.top_task_id
			 -- , ptv.parent_task_id
			 , flv_rev.meaning revenue_status
			 , haou.name project_org
			 , haou_exp.name expenditure_org
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , pega.expenditure_group
			 , pega.user_batch_name
			 , replace(replace(pec.expenditure_comment,chr(10),' '),chr(13),' ') expenditure_comment
			 , pe.error_code x_error_code
			 , fm.message_user_details error_details
			 , fm.context error_context
			 , to_char(pe.creation_date, 'yyyy-mm-dd hh24:mi:ss') error_created
			 , gps_created.period_name period_created
			 , gps_item_date.period_name period_item_date
			 , peia.project_raw_cost
			 , peia.project_burdened_cost
			 , peia.quantity
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.invoiced_flag
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , peia.unit_of_measure uom
			 , '#' || peia.burden_sum_dest_run_id burden_sum_dest_run_id
			 , '#' || peia.adjusted_expenditure_item_id adjusted_expenditure_item_id
			 , peia.net_zero_adjustment_flag -- if y revenue will never be recognised
			 , '#' || peia.transferred_from_exp_item_id transferred_from_exp_item_id
		  from pjc_exp_items_all peia
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join hr_all_organization_units haou_exp on peia.expenditure_organization_id = haou_exp.organization_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join pjb_errors pe on pe.expenditure_item_id = peia.expenditure_item_id and pe.request_id in (select max (pe1.request_id) from pjb_errors pe1 where pe1.expenditure_item_id = pe.expenditure_item_id and pe1.erroring_process = 'REVENUE_GEN')
	 left join fnd_messages fm on fm.message_name = pe.error_code
	 left join pjc_exp_comments pec on pec.expenditure_item_id = peia.expenditure_item_id
	 left join po_headers_all pha on pha.po_header_id = peia.parent_header_id and pha.segment1 = peia.doc_ref_id2
	 left join poz_suppliers_v psv on psv.vendor_id = peia.vendor_id
	 left join gl_period_statuses gps_created on ((gps_created.start_date <= peia.creation_date) and (gps_created.end_date >= peia.creation_date)) and gps_created.application_id = 10037 and gps_created.set_of_books_id = 300000001654002
	 left join gl_period_statuses gps_item_date on ((gps_item_date.start_date <= peia.creation_date) and (gps_item_date.end_date >= peia.creation_date)) and gps_item_date.application_id = 10037 and gps_item_date.set_of_books_id = 300000001654002
		 where 1 = 1
		   and 1 = 1
	  order by peia.creation_date desc

-- ##############################################################
-- EXPENDITURE ITEMS 3
-- ##############################################################

		select ppav.segment1 project
			 , peia.task_id xx_task_id
			 , flv_rev.meaning
			 , peia.expenditure_item_id
			 , peia.expenditure_item_date
			 , peia.expenditure_comment
		  from pjc_exp_items_all peia
		  join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
		  join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- EXPENDITURE ITEMS 4 - WITH REVENUE DISTRIBUTIONS
-- ##############################################################

		select ppav.segment1 proj_number
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , pptt.project_type
			 , peia.expenditure_item_id item_id
			 , pha.segment1 po
			 , psv.vendor_name supplier
			 , ptv.task_number task
			 , flv_rev.meaning revenue_status
			 , to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_created
			 , to_char(pe.creation_date, 'yyyy-mm-dd hh24:mi:ss') error_created
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , to_char(prd.transaction_date, 'yyyy-mm-dd') dist_trx_date
			 , to_char(prd.gl_date, 'yyyy-mm-dd') dist_gl_date
			 , to_char(prd.pa_date, 'yyyy-mm-dd') dist_pa_date
			 , prd.gl_period_name dist_gl_period
			 , prd.pa_period_name dist_pa_period
		  from pjc_exp_items_all peia
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_co and ppst.language = userenv('lang')de
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join hr_all_organization_units haou_exp on peia.expenditure_organization_id = haou_exp.organization_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join pjb_errors pe on pe.expenditure_item_id = peia.expenditure_item_id and pe.request_id in (select max (pe1.request_id) from pjb_errors pe1 where pe1.expenditure_item_id = pe.expenditure_item_id and pe1.erroring_process = 'REVENUE_GEN')
	 left join fnd_messages fm on fm.message_name = pe.error_code
	 left join pjc_exp_comments pec on pec.expenditure_item_id = peia.expenditure_item_id
	 left join po_headers_all pha on pha.po_header_id = peia.parent_header_id and pha.segment1 = peia.doc_ref_id2
	 left join poz_suppliers_v psv on psv.vendor_id = peia.vendor_id
	 left join gl_period_statuses gps_created on ((gps_created.start_date <= peia.creation_date) and (gps_created.end_date >= peia.creation_date)) and gps_created.application_id = 10037 and gps_created.set_of_books_id = 300000001654002
	 left join gl_period_statuses gps_item_date on ((gps_item_date.start_date <= peia.creation_date) and (gps_item_date.end_date >= peia.creation_date)) and gps_item_date.application_id = 10037 and gps_item_date.set_of_books_id = 300000001654002
	 left join pjb_rev_distributions prd on prd.transaction_id = peia.expenditure_item_id
		 where 1 = 1
		   and 1 = 1
	  order by peia.creation_date desc

-- ##############################################################
-- EXPENDITURE ITEMS 5 - LINKED TO POS AND RECEIPTS
-- ##############################################################

		select ppav.segment1 proj_number
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , pptt.project_type
			 , peia.expenditure_item_id item_id
			 , to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_created
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , flv_rev.meaning revenue_status
			 , haou.name project_org
			 , haou_exp.name expenditure_org
			 , petl.expenditure_type_name exp_type
			 , ptst.user_transaction_source trx_source
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , pe.error_code x_error_code
			 , to_char(pe.creation_date, 'yyyy-mm-dd hh24:mi:ss') error_created
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , peia.project_raw_cost
			 , peia.project_burdened_cost
			 , peia.quantity
			 , '#################'
			 , pha.segment1 po
			 , pha.document_creation_method
			 , pha.created_by po_created_by
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_created
			 , pha.interface_source_code
			 , pha.currency_code po_currency
			 , pla.list_price
			 , pla.quantity po_line_qty
			 , pla.amount po_line_amount
			 , pla.unit_price po_line_unit_price
			 , pla.line_num
			 , pla.uom_code uom
			 , pla.order_type_lookup_code
			 , pla.purchase_basis
			 , pla.matching_basis
			 , replace(replace(replace(pla.item_description, chr(10), ''), chr(13), ''), chr(09), '') item_description
			 , replace(replace(replace(pla.note_to_vendor, chr(10), ''), chr(13), ''), chr(09), '') note_to_vendor
			 , psv.vendor_name
			 , pssam.vendor_site_code site
			 , cat.category_name
			 , rsh.receipt_num
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , rsh.created_by receipt_created_by
			 , '#' || rt.quantity receipt_qty
			 , rt.amount receipt_amount
			 , rt.transaction_type receipt_type
			 , rt.destination_type_code receipt_destination
			 , rt.currency_code receipt_currency
			 , rt.currency_conversion_type receipt_curr_conv_type
			 , '#' || rt.currency_conversion_rate receipt_conv_rate
			 , rt.currency_conversion_date receipt_conv_date
		  from pjf_projects_all_vl ppav
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join hr_all_organization_units haou_exp on peia.expenditure_organization_id = haou_exp.organization_id
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id and peia.task_id = ptv.task_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
		  join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
		  join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
		  join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
		  join po_headers_all pha on pha.po_header_id = peia.parent_header_id and pha.segment1 = peia.doc_ref_id2
		  join po_lines_all pla on pla.po_line_id = peia.parent_line_number
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on pha.vendor_site_id = pssam.vendor_site_id and pssam.vendor_id = psv.vendor_id
	 left join rcv_transactions rt on rt.transaction_id = peia.original_header_id and rt.po_line_id = pla.po_line_id and rt.po_header_id = pha.po_header_id
	 left join rcv_shipment_headers rsh on rt.shipment_header_id = rsh.shipment_header_id
		  join egp_categories_tl cat on pla.category_id = cat.category_id and cat.language = userenv('lang')
	 left join pjb_errors pe on pe.expenditure_item_id = peia.expenditure_item_id and pe.request_id in (select max (pe1.request_id) from pjb_errors pe1 where pe1.expenditure_item_id = pe.expenditure_item_id and pe1.erroring_process = 'REVENUE_GEN')
		 where 1 = 1
		   and 1 = 1
	  order by pe.creation_date desc

-- ##############################################################
-- EXPENDITURE ITEMS 6 - COST LINES SUMMARY
-- ##############################################################

		select haou.name exp_org
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , pcdla.prvdr_gl_period_name
			 , peia.created_by
			 , count(peia.expenditure_item_id) item_count
			 , sum(peia.project_raw_cost) project_raw_cost
			 , min(peia.project_raw_cost) project_raw_cost_min
			 , max(peia.project_raw_cost) project_raw_cost_max
			 , sum(peia.project_burdened_cost) project_burdened_cost
			 , sum(peia.quantity) quantity
			 , to_char(min(peia.creation_date),'yyyy-mm-dd') min_item_created
			 , to_char(max(peia.creation_date),'yyyy-mm-dd') max_item_created
			 , to_char(min(peia.expenditure_item_date),'yyyy-mm-dd') min_item_date
			 , to_char(max(peia.expenditure_item_date),'yyyy-mm-dd') max_item_date
			 , min(peia.expenditure_item_id) min_item_id
			 , max(peia.expenditure_item_id) max_item_id
			 , min(peia.request_id) min_request_id
			 , max(peia.request_id) max_request_id
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id and peia.task_id = ptv.task_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
		  join pjc_cost_dist_lines_all pcdla on pcdla.project_id = peia.project_id and pcdla.expenditure_item_id = peia.expenditure_item_id
		 where 1 = 1
		   and 1 = 1
	  group by haou.name
			 , ptst.user_transaction_source
			 , petl.expenditure_type_name
			 , pcdla.prvdr_gl_period_name
			 , peia.created_by
			 
-- ##############################################################
-- EXPENDITURE ITEMS 7 - CONTRACTS 
-- ##############################################################

		select peia.expenditure_item_id transaction
			 , ppav.segment1 proj_number
			 , ppav.creation_date project_created
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , peia.creation_date cost_created
			 , peia.bill_hold_flag
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.invoiced_flag
			 , peia.unit_of_measure uom
			 , peia.cc_rejection_code rej_code
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , flv_rev.meaning revenue_status
			 , haou.name expenditure_org
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , peia.project_raw_cost
			 , peia.project_burdened_cost
			 , peia.quantity
			 , peia.denom_currency_code trx_currency
			 , petl.expenditure_type_name exp_type
			 , ptst.user_transaction_source trx_source
			 , tbl_contract.contract_number
			 , tbl_contract.amendment_effective_date
			 , peia.revenue_exception_flag
			 , pe.error_code
			 , pe.creation_date error_created
			 , pe.request_id
		  from pjf_projects_all_vl ppav
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id and peia.task_id = ptv.task_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
		  join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join pjb_errors pe on pe.expenditure_item_id = peia.expenditure_item_id and pe.request_id in (select max (pe1.request_id) from pjb_errors pe1 where pe1.expenditure_item_id = pe.expenditure_item_id and pe1.erroring_process = 'REVENUE_GEN')
		  join (select okhab.contract_number
					 , to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') amendment_effective_date
					 , pcpl.project_id
					 , pcpl.proj_element_id
					 , okhab.major_version
				  from okc_k_headers_all_b okhab
				  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and pcpl.major_version = okhab.major_version
				 where 1 = 1
				   and okhab.version_type = 'C'
				   -- and okhab.contract_number in (123456)
				   and 1 = 1) tbl_contract on tbl_contract.project_id = ppav.project_id and tbl_contract.proj_element_id = ptv.task_id
		 where 1 = 1
		   and 1 = 1
	  order by peia.creation_date desc

-- ##############################################################
-- EXPENDITURE ITEMS 8 - AP INVOICES 
-- ##############################################################

		select peia.expenditure_item_id transaction_number
			 , ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.creation_date project_created
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , peia.creation_date cost_created
			 , peia.last_update_date cost_updated
			 , peia.bill_hold_flag
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.unit_of_measure uom
			 , peia.cc_rejection_code rej_code
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , flv_rev.meaning revenue_status
			 , haou.name expenditure_org
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , round(peia.projfunc_raw_cost,2) projfunc_raw_cost -- shows as "raw cost in transaction currency" on front-end
			 , round(peia.ledger_curr_rev_amt, 2) ledger_curr_rev_amt
			 , round(peia.project_curr_rev_amt, 2) project_curr_rev_amt
			 , round(peia.quantity, 2) quantity
			 , peia.denom_currency_code trx_currency
			 , petl.expenditure_type_name exp_type
			 , ptst.user_transaction_source trx_source
			 , peia.revenue_exception_flag
			 , aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , psv.vendor_name supplier
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , aia.invoice_amount
			 , aia.amount_paid
			 , aia.approval_status
			 , aia.cancelled_date
			 , aia.cancelled_by
			 , aia.cancelled_amount
			 , aia.source
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
		  from pjf_projects_all_vl ppav
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join pjc_exp_items_all peia on peia.project_id = ppav.project_id and peia.task_id = ptv.task_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join ap_invoices_all aia on aia.invoice_id = peia.original_header_id
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- LINKING AP INVOICES BACK TO PROJECTS
-- ##############################################################

		select aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , psv.vendor_name supplier
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , aia.invoice_amount
			 , aia.amount_paid
			 , aia.approval_status
			 , aia.cancelled_date
			 , aia.cancelled_by
			 , aia.cancelled_amount
			 , aia.source
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
			 , aida.pa_addition_flag
			 , aida.invoice_distribution_id
			 , aida.accounting_event_id -- if populated means sla accounting events were created for the invoice
			 , aida.po_distribution_id
			 , aida.pjc_project_id
			 , aida.pjc_task_id
			 , aida.pjc_expenditure_type_id
			 , aida.pjc_expenditure_item_date
			 , aida.pjc_organization_id
			 , aida.pjc_billable_flag
			 , ' ##############################'
			 , peia.expenditure_item_id transaction_number
			 , ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.creation_date project_created
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , peia.creation_date cost_created
			 , peia.last_update_date cost_updated
			 , peia.bill_hold_flag
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.unit_of_measure uom
			 , peia.cc_rejection_code rej_code
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , flv_rev.meaning revenue_status
			 , haou.name expenditure_org
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , round(peia.projfunc_raw_cost,2) projfunc_raw_cost -- shows as "raw cost in transaction currency" on front-end
			 , round(peia.ledger_curr_rev_amt, 2) ledger_curr_rev_amt
			 , round(peia.project_curr_rev_amt, 2) project_curr_rev_amt
			 , round(peia.quantity, 2) quantity
			 , peia.denom_currency_code trx_currency
			 , petl.expenditure_type_name exp_type
			 , ptst.user_transaction_source trx_source
			 , peia.revenue_exception_flag
		  from ap_invoices_all aia
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join pjc_exp_items_all peia on aia.invoice_id = peia.original_header_id
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id 
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- DOCUMENT ENTRIES
-- ##############################################################

		select '#' || doc_entry_id doc_entry_id
			 , doc_entry_name
			 , description
			 , source_lang
			 , language
			 , to_char(last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , last_updated_by
			 , to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , created_by
			 , object_version_number
			 , seed_data_source
			 , ora_seed_set1
			 , ora_seed_set2
		  from pjf_txn_doc_entry_tl

-- ##############################################################
-- ADJUSTMENTS
-- ##############################################################

		select peiaa.*
		  from pjc_expend_item_adj_acts peiaa
		  join pjf_projects_all_vl ppav on peiaa.project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- COUNT BY CREATION DATE
-- ##############################################################

		select to_char(peia.creation_date, 'yyyy-mm-dd') creation_date
			 , count(*) ct
		  from pjc_exp_items_all peia
		 where peia.creation_date > sysdate - 50
	  group by to_char(peia.creation_date, 'yyyy-mm-dd')
	  order by 1 desc

-- ##############################################################
-- COUNT BY CREATED BY
-- ##############################################################

		select peia.created_by
			 , ptst.user_transaction_source trx_source
			 -- , ptdet.doc_entry_name exp_document_entry
			 -- , ptdt.document_name exp_document
			 -- , petl.expenditure_type_name exp_type
			 -- , petl.description
			 , round(sum(peia.acct_raw_cost),2) sum_project_raw_cost
			 , round(sum(peia.acct_burdened_cost),2) sum_burdened_cost
			 , min(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date 
			 , min(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) min_item_date
			 , max(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) max_item_date
			 , min('#' || peia.expenditure_item_id) min_item_id
			 , max('#' || peia.expenditure_item_id) max_item_id
			 , min(peia.request_id) min_request_id
			 , max(peia.request_id) max_request_id
			 , count(*) ct
		  from pjc_exp_items_all peia
		  join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  -- join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
		  -- join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
		  -- join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by peia.created_by
			 , ptst.user_transaction_source 
			 -- , ptdet.doc_entry_name
			 -- , ptdt.document_name
			 -- , petl.expenditure_type_name
			 -- , petl.description

-- ##############################################################
-- COUNT BY EXPENDITURE TYPE
-- ##############################################################

		select petl.expenditure_type_name exp_type
			 , petl.description
			 , count(*)
			 , round(sum(peia.acct_raw_cost),2) sum_project_raw_cost
			 , round(sum(peia.acct_burdened_cost),2) sum_burdened_cost
			 , min(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date 
			 , min(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) min_item_date
			 , max(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) max_item_date
			 , min(peia.request_id) min_request_id
			 , max(peia.request_id) max_request_id
		  from pjc_exp_items_all peia
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by petl.expenditure_type_name
			 , petl.description
	  order by petl.expenditure_type_name
			 , petl.description

-- ##############################################################
-- COUNT BY TRANSACTION SOURCE
-- ##############################################################

		select ptst.user_transaction_source trx_source
			 , count(*)
			 , round(sum(peia.acct_raw_cost),2) sum_project_raw_cost
			 , round(sum(peia.acct_burdened_cost),2) sum_burdened_cost
			 , min(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date 
			 , min(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) min_item_date
			 , max(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) max_item_date
			 , min(peia.request_id) min_request_id
			 , max(peia.request_id) max_request_id
			 , min(peia.expenditure_item_id) min_item_id
			 , max(peia.expenditure_item_id) max_item_id
		  from pjc_exp_items_all peia
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by ptst.user_transaction_source
	  order by ptst.user_transaction_source

-- ##############################################################
-- COUNT OF PA EXP ITEMS SENT TO GL
-- ##############################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , ptst.user_transaction_source trx_source
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , count(distinct gjb.je_batch_id) batch_count
			 , count(distinct gjh.je_header_id) journal_count
			 , count(gjl.je_line_num) line_count
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join pjc_exp_items_all peia on peia.expenditure_item_id = xte.source_id_int_1
		  join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
		  join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , ptst.user_transaction_source
			 , ptdet.doc_entry_name
			 , ptdt.document_name

-- ##############################################################
-- COUNT PER PROJECT
-- ##############################################################

		select ppav.segment1 project
			 , (select count(peia.expenditure_item_id) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) item_count
			 , (select sum(round(peia.project_raw_cost,2)) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) total_cost
		  from pjf_projects_all_vl ppav
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- COUNT BY REVENUE STATUS 1
-- ##############################################################

		select flv_rev.meaning revenue_status
			 , ppav.segment1 proj
			 , ptv.task_number task
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
			 , min(peia.expenditure_item_id) min_item_id
			 , max(peia.expenditure_item_id) max_item_id
		  from pjc_exp_items_all peia
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
		  join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
		 where 1 = 1
		   and 1 = 1
	  group by flv_rev.meaning
			 , ppav.segment1
			 , ptv.task_number
			 , peia.revenue_recognized_flag
	  order by flv_rev.meaning
			 , peia.revenue_recognized_flag

-- ##############################################################
-- COUNT BY REVENUE STATUS 2
-- ##############################################################

		select flv_rev.meaning revenue_status
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
			 , min(peia.expenditure_item_id) min_item_id
			 , max(peia.expenditure_item_id) max_item_id
			 , min(ppav.segment1) min_proj_number
			 , max(ppav.segment1) max_proj_number
		  from pjc_exp_items_all peia
		  join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1
	  group by flv_rev.meaning
	  order by flv_rev.meaning

-- ##############################################################
-- COUNT PER PROJECT TYPE AND EXPENDITURE TYPE
-- ##############################################################

		select ppav.segment1
			 , ptv.task_number
			 , pptt.project_type
			 , petl.expenditure_type_name
			 , haou.name project_org
			 , haou_exp.name exp_org
			 , round(sum(peia.project_raw_cost),2) sum_project_raw_cost
			 , round(sum(peia.projfunc_burdened_cost),2) sum_burdened_cost
			 , count(*)
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id and peia.task_id = ptv.task_id
	 left join hr_all_organization_units haou_exp on peia.org_id = haou.organization_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_project_types_b pptb on pptb.project_type_id = ppav.project_type_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
	 left join pjf_cost_base_exp_types pcbet on peia.expenditure_type_id = pcbet.expenditure_type_id and pcbet.ind_structure_name = pirsv.ind_structure_name
		 where 1 = 1
		   and 1 = 1
	  group by ppav.segment1
			 , ptv.task_number
			 , haou.name
			 , haou_exp.name
			 , pptt.project_type
			 , petl.expenditure_type_name
	  order by ppav.segment1
			 , ptv.task_number
			 , haou.name
			 , haou_exp.name
			 , pptt.project_type
			 , petl.expenditure_type_name

-- ##############################################################
-- COUNT AND SUM BY PROJECT, PROJECT TYPE, TASK, ORG, TRX SOURCE, EXP TYPE, DOC ENTRY, BILLABLE FLAG, REVENUE HOLD FLAG
-- ##############################################################

		select ppav.segment1 proj_number
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , flv_rev.meaning revenue_status
			 , haou.name project_org
			 , haou_exp.name expenditure_org
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , ptdet.doc_entry_name
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , count(peia.expenditure_item_id) item_count
			 , sum(round(peia.project_raw_cost,20)) project_raw_cost
			 , min(round(peia.project_raw_cost,20)) project_raw_cost_min
			 , max(round(peia.project_raw_cost,20)) project_raw_cost_max
			 , sum(round(peia.project_burdened_cost,20)) project_burdened_cost
			 , sum(round(peia.quantity, 20)) quantity
			 , min(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date 
			 , min(to_char(peia.expenditure_item_date, 'yyyy-mm-dd hh24:mi:ss')) min_item_date
			 , max(to_char(peia.expenditure_item_date, 'yyyy-mm-dd hh24:mi:ss')) max_item_date
		  from pjc_exp_items_all peia
	 left join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
	 left join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code and ppst.language = userenv('lang')
	 left join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
	 left join hr_all_organization_units haou_exp on peia.expenditure_organization_id = haou_exp.organization_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
	 left join pjb_errors pe on pe.expenditure_item_id = peia.expenditure_item_id and pe.request_id in (select max (pe1.request_id) from pjb_errors pe1 where pe1.expenditure_item_id = pe.expenditure_item_id and pe1.erroring_process = 'REVENUE_GEN')
		 where 1 = 1
		   and 1 = 1
	  group by ppav.segment1
			 , pptt.project_type
			 , ppst.project_status_name
			 , ptv.task_number
			 , flv_rev.meaning
			 , haou.name
			 , haou_exp.name
			 , ptst.user_transaction_source
			 , petl.expenditure_type_name
			 , ptdet.doc_entry_name
			 , peia.billable_flag
			 , peia.revenue_hold_flag
	  order by ppav.segment1
			 , pptt.project_type
			 , ppst.project_status_name
			 , ptv.task_number
			 , haou.name
			 , ptst.user_transaction_source
			 , petl.expenditure_type_name
			 , ptdet.doc_entry_name
			 , flv_rev.meaning
			 , peia.billable_flag
			 , peia.revenue_hold_flag

-- ##############################################################
-- COUNT AND SUM BY PROJECT, PROJECT TYPE, TASK, ORG, TRX SOURCE, EXP TYPE
-- ##############################################################

		select ppav.segment1 proj_number
			 , pptt.project_type
			 , pptb.burden_cost_flag
			 , petl.expenditure_type_name
			 , pcbet.cost_base burden_cost_base
			 , round(sum(peia.projfunc_raw_cost),2) sum_projfunc_raw_cost
			 , round(sum(peia.acct_raw_cost),2) sum_acct_raw_cost
			 , round(sum(peia.project_raw_cost),2) sum_project_raw_cost
			 , round(sum(peia.projfunc_burdened_cost),2) sum_burdened_cost
			 , count(*)
		  from pjf_projects_all_vl ppav
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id and peia.task_id = ptv.task_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id and pptt.language = userenv('lang')
		  join pjf_project_types_b pptb on pptb.project_type_id = ppav.project_type_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
	 left join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
	 left join pjf_cost_base_exp_types pcbet on peia.expenditure_type_id = pcbet.expenditure_type_id and pcbet.ind_structure_name = pirsv.ind_structure_name
		 where 1 = 1
		   and 1 = 1
	  group by ppav.segment1
			 , pptt.project_type
			 , pptb.burden_cost_flag
			 , petl.expenditure_type_name
			 , pcbet.cost_base
	  order by ppav.segment1
			 , pptt.project_type
			 , pptb.burden_cost_flag
			 , petl.expenditure_type_name
			 , pcbet.cost_base

-- ##############################################################
-- COUNT AND SUM BY PROJECT, EXP TYPE
-- ##############################################################

		select ppav.segment1 proj_number
			 , petl.expenditure_type_name exp_type
			 , count(peia.expenditure_item_id) item_count
			 , sum(round(peia.acct_raw_cost,20)) acct_raw_cost
			 , sum(round(peia.acct_burdened_cost,20)) acct_burdened_cost
			 , sum(round(peia.quantity, 20)) quantity
			 , to_char(min(peia.creation_date),'yyyy-mm-dd') min_item_created
			 , to_char(max(peia.creation_date),'yyyy-mm-dd') max_item_created
			 , to_char(min(peia.expenditure_item_date),'yyyy-mm-dd') min_item_date
			 , to_char(max(peia.expenditure_item_date),'yyyy-mm-dd') max_item_date
		  from pjc_exp_items_all peia
		  join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by ppav.segment1
			 , petl.expenditure_type_name
	  order by ppav.segment1
			 , petl.expenditure_type_name

-- ##############################################################
-- COUNT AND SUM BY PROJECT
-- ##############################################################

		select ppav.segment1 proj_number
			 -- , peia.revenue_recognized_flag
			 -- , flv_rev.meaning
			 , count(peia.expenditure_item_id) item_count
			 , sum(round(peia.project_raw_cost,20)) project_raw_cost
			 , sum(round(peia.project_burdened_cost,20)) project_burdened_cost
			 , sum(round(peia.quantity, 20)) quantity
			 , to_char(min(peia.creation_date),'yyyy-mm-dd') min_item_created
			 , to_char(max(peia.creation_date),'yyyy-mm-dd') max_item_created
			 , to_char(min(peia.expenditure_item_date),'yyyy-mm-dd') min_item_date
			 , to_char(max(peia.expenditure_item_date),'yyyy-mm-dd') max_item_date
		  from pjc_exp_items_all peia
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
	 left join fnd_lookup_values_vl flv_rev on flv_rev.lookup_code = peia.revenue_recognized_flag and flv_rev.lookup_type = 'PJB_EVT_REVENUE_RECOGNZD'
		 where 1 = 1
		   and 1 = 1
	  group by ppav.segment1
			 -- , peia.revenue_recognized_flag
			 -- , flv_rev.meaning
	  order by ppav.segment1
			 -- , peia.revenue_recognized_flag
			 -- , flv_rev.meaning

-- ##############################################################
-- COUNTING AND SUMMING LINKED TO BURDEN STRUCTURES
-- ##############################################################

/*
Summary of overheads vs non overheads
*/

with overheads as
	   (select ppav.segment1 project
			 , ppav.project_id
			 , round(sum(peia.project_burdened_cost),2) total_value
			 , count(*) item_count
		  from pjf_projects_all_vl ppav
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id
		 where 1 = 1
		   and ppav.segment1 = '123'
		   and peia.burden_sum_dest_run_id is not null -- overheads burden_sum_dest_run_id id is populated...
	  group by ppav.segment1
			 , ppav.project_id)
, non_overheads as
	   (select ppav.segment1 project
			 , ppav.project_id
			 , round(sum(peia.project_raw_cost),2) total_value
			 , count(*) item_count
		  from pjf_projects_all_vl ppav
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id
		  join pjc_cost_dist_lines_all pcdla on pcdla.project_id = peia.project_id and pcdla.expenditure_item_id = peia.expenditure_item_id and pcdla.burden_sum_source_run_id is not null -- exp item cost dist line burden_sum_source_run_id is populated with id for overheads burden_sum_dest_run_id id
		 where ppav.segment1 = '123'
	  group by ppav.segment1
			 , ppav.project_id)
		select overheads.project
			 , overheads.total_value overheads_value
			 , overheads.item_count overheads_item_count
			 , non_overheads.total_value non_overheads_value
			 , non_overheads.item_count non_overheads_item_count
			 , (round((overheads.total_value / non_overheads.total_value), 2)*100) overheads_percent
		  from overheads
		  join non_overheads on overheads.project_id = non_overheads.project_id
	  group by overheads.project
			 , overheads.total_value
			 , overheads.item_count
			 , non_overheads.total_value
			 , non_overheads.item_count
			 
with overheads as
	   (select ppav.segment1 project
			 , ppav.project_id
			 , round(sum(peia.project_burdened_cost),2) total_value
			 , count(*) item_count
		  from pjf_projects_all_vl ppav
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id
		 where 1 = 1
		   and ppav.segment1 = '123'
		   and peia.burden_sum_dest_run_id is not null -- overheads burden_sum_dest_run_id id is populated...
	  group by ppav.segment1
			 , ppav.project_id)
, non_overheads as
	   (select ppav.segment1 project
			 , ppav.project_id
			 , round(sum(peia.project_raw_cost),2) total_value
			 , count(*) item_count
		  from pjf_projects_all_vl ppav
		  join pjc_exp_items_all peia on peia.project_id = ppav.project_id
		  join pjf_ind_rate_sch_vl pirsv on ppav.project_id = pirsv.project_id
		  join pjf_cost_base_exp_types pcbet on peia.expenditure_type_id = pcbet.expenditure_type_id and pcbet.ind_structure_name = pirsv.ind_structure_name
		  join pjc_cost_dist_lines_all pcdla on pcdla.project_id = peia.project_id and pcdla.expenditure_item_id = peia.expenditure_item_id and pcdla.burden_sum_source_run_id is not null -- exp item cost dist line burden_sum_source_run_id is populated with id for overheads burden_sum_dest_run_id id
		 where ppav.segment1 = '123'
	  group by ppav.segment1
			 , ppav.project_id)
, multipliers as
	   (select pirsv.project_id
			 , picm.multiplier_num
		  from pjf_ind_rate_sch_vl pirsv
		  join pjf_irs_revisions pir on pir.ind_rate_sch_id = pirsv.ind_rate_sch_id
		  join pjf_ind_cost_multipliers picm on picm.ind_rate_sch_revision_id = pir.ind_rate_sch_revision_id)
		select overheads.project
			 , overheads.total_value overheads_value
			 , overheads.item_count overheads_item_count
			 , non_overheads.total_value non_overheads_value
			 , non_overheads.item_count non_overheads_item_count
			 , (round((overheads.total_value / non_overheads.total_value), 2)*100) overheads_percent
			 , multipliers.multiplier_num
		  from overheads
		  join non_overheads on overheads.project_id = non_overheads.project_id
		  join multipliers on multipliers.project_id = overheads.project_id
	  group by overheads.project
			 , overheads.total_value
			 , overheads.item_count
			 , non_overheads.total_value
			 , non_overheads.item_count
			 , multipliers.multiplier_num

-- ##############################################################
-- COUNT OF EXP ITEMS PER BURDEN STRUCTURE
-- ##############################################################

		select pcbet.ind_structure_name
			 , pcbet.cost_base
			 , pcbet.cost_base_type
			 , count(*)
		  from pjf_cost_base_exp_types pcbet
	  group by pcbet.ind_structure_name
			 , pcbet.cost_base
			 , pcbet.cost_base_type
	  order by pcbet.ind_structure_name
			 , pcbet.cost_base
			 , pcbet.cost_base_type 

-- ##############################################################
-- ACCT SUMMARY
-- ##############################################################

		select haou.name project_org
			 , haou_exp.name expenditure_org
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , ptdb.import_cost_acc_flag
			 , ptdb.cost_acc_journal_flag
			 , ptdb.adjust_acc_journal_flag
			 -- , ptdb.acct_during_import
			 , ptdb.acct_source_code
			 -- , ptdb.purgeable_flag
			 , ptdb.allow_burden_flag
			 -- , xte.application_id
			 , xte.entity_code
			 , nvl2(xte.source_id_int_1, 'Y', 'N') xla_link
			 , round(sum(peia.acct_raw_cost),2) sum_project_raw_cost
			 , round(sum(peia.acct_burdened_cost),2) sum_burdened_cost
			 , min(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date 
			 , min(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) min_item_date
			 , max(to_char(peia.expenditure_item_date, 'yyyy-mm-dd')) max_item_date
			 , min('#' || peia.expenditure_item_id) min_item_id
			 , max('#' || peia.expenditure_item_id) max_item_id
			 , min(peia.request_id) min_request_id
			 , max(peia.request_id) max_request_id
			 , count(*) ct
		  from pjc_exp_items_all peia
		  join pjf_projects_all_vl ppav on peia.project_id = ppav.project_id
		  join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and peia.task_id = ptv.task_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join hr_all_organization_units haou_exp on peia.expenditure_organization_id = haou_exp.organization_id
		  join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id and petl.language = userenv('lang')
		  join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id and ptst.language = userenv('lang')
		  join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id and ptdet.language = userenv('lang')
		  join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id and ptdt.language = userenv('lang')
		  join pjf_txn_document_b ptdb on ptdb.document_id = ptdt.document_id
	 left join xla_transaction_entities xte on xte.source_id_int_1 = peia.expenditure_item_id and xte.application_id = 10036 -- Project Costing
		 where 1 = 1
		   and 1 = 1
	  group by haou.name
			 , ptst.user_transaction_source
			 , petl.expenditure_type_name
			 , ptdet.doc_entry_name
			 , ptdt.document_name
			 , ptdb.import_cost_acc_flag
			 , ptdb.cost_acc_journal_flag
			 , ptdb.adjust_acc_journal_flag
			 -- , ptdb.acct_during_import
			 , ptdb.acct_source_code
			 -- , ptdb.purgeable_flag
			 , ptdb.allow_burden_flag
			 , nvl2(xte.source_id_int_1, 'Y', 'N')
			 -- , xte.application_id
			 , xte.entity_code
