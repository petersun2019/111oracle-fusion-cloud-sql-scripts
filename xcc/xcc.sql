/*
File Name: xcc.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

XCC: Control Budgets

Queries:

-- CONTROL BUDGETS
-- CONTROL BUDGET PERIODS
-- TRANSACTION HEADER ATTRIBUTES CALLING THE BUDGETARY CONTROL ENGINE
-- BUDGET BALANCES - SUM PER PERIOD PER SEGMENT 2
-- BUDGET BALANCES - SUM PER YEAR PER SEGMENT 2
-- BUDGET BALANCES - DETAILS FROM BALANCE TABLE
-- BUDGET BALANCES - TABLE DUMPS

*/

-- ##############################################################
-- CONTROL BUDGETS
-- ##############################################################

		select xcb.name budget_name
			 -- , '#' || xcb.control_budget_id control_budget_id
			 , to_char(xcb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , xcb.created_by
			 , to_char(xcb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , xcb.last_updated_by
			 -- , xcb.description budget_desc
			 -- , glv.name ledger
			 -- , xcb.period_set_name
			 -- , xcb.period_type
			 -- , xcb.start_period_name
			 -- , xcb.end_period_name
			 -- , xcb.start_eff_period_num
			 -- , xcb.end_eff_period_num
			 -- , xcb.source_budget_system_code
			 -- , xcb.source_budget
			 , xcb.control_level_code
			 -- , xcb.currency_code
			 -- , xcb.default_rate_type
			 , to_char(xcb.start_date, 'yyyy-mm-dd') xcc_start_date
			 , to_char(xcb.end_date, 'yyyy-mm-dd') xcc_end_date
			 , xcb.status_code
			 -- , '#' || xcb.project_id project_id
			 , ppnf.full_name budget_manager
			 , pu.username budget_manager_username
			 , '#' project____
			 , ppav.segment1 proj_number
			 , ppav.name project_name
			 , ppst.project_status_name project_status
			 , to_char(ppav.start_date, 'yyyy-mm-dd') proj_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') proj_finish_date
			 , (select count(*) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) expenditure_item_count
		  from xcc_control_budgets xcb
	 left join per_users pu on pu.user_id = xcb.budget_manager_id
	 left join per_person_names_f ppnf on ppnf.person_id = pu.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join gl_ledgers glv on xcb.ledger_id = glv.ledger_id
	 left join pjf_projects_all_vl ppav on ppav.project_id = xcb.project_id
	 left join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		 where 1 = 1
		   and 1 = 1
	  order by to_char(xcb.end_date, 'yyyy-mm-dd')

-- ##############################################################
-- CONTROL BUDGET PERIODS
-- ##############################################################

		select '#' || xcb.control_budget_id
			 , xcb.name budget_name
			 , glv.name ledger
			 , xcps.period_name
			 , xcps.status_code
			 , xcps.effective_period_num
			 , xcps.quarter_num
			 , xcps.period_year
			 , xcps.period_num
			 , xcps.fiscal_year
			 , xcps.budget_effective_period_num
			 , xcps.budget_period_num
			 , to_char(xcps.start_date, 'yyyy-mm-dd') period_start_date
			 , to_char(xcps.end_date, 'yyyy-mm-dd') period_end_date
			 , to_char(xcps.last_update_date, 'yyyy-mm-dd hh24:mi:ss') period_last_update
			 , xcps.last_updated_by period_updated_by
		  from xcc_control_budgets xcb
		  join gl_ledgers glv on xcb.ledger_id = glv.ledger_id
		  join xcc_cb_period_statuses xcps on xcps.control_budget_id = xcb.control_budget_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- TRANSACTION HEADER ATTRIBUTES CALLING THE BUDGETARY CONTROL ENGINE
-- ##############################################################

/*
https://docs.oracle.com/en/cloud/saas/financials/22b/oedmf/xcctrheaders-19222.html#xcctrheaders-19222
https://docs.oracle.com/en/cloud/saas/financials/22b/oedmf/xcctrlines-9358.html#xcctrlines-9358
*/

		select xth.header_num hdr_num
			 , xth.transaction_type_code hdr_trx_type
			 , xth.source_header_id_1 hdr_src_id_1
			 , xth.transaction_number hdr_trx_num
			 , xth.source_action_code hdr_src_action
			 , flv_source_action.meaning hdr_src_action_1
			 , flv_source_action.description hdr_src_action_2
			 , xth.result_code hdr_result
			 , to_char(xth.creation_date, 'yyyy-mm-dd hh24:mi:ss') hdr_created
			 , xth.created_by hdr_created_by
			 , xth.success_reason_code hdr_success_code
			 , '##########'
			 , xtl.*
		  from xcc_tr_headers xth
		  join xcc_tr_lines xtl on xth.header_num = xtl.header_num
	 left join fnd_lookup_values_vl flv_source_action on flv_source_action.lookup_code = xth.source_action_code and flv_source_action.lookup_type = 'XCC_TRANSACTION_TYPE_ACTION' and flv_source_action.view_application_id = 0
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGET BALANCES - SUM PER PERIOD PER SEGMENT 2
-- ##############################################################

		select xcb.name budget_name
			 , glv.name ledger
			 , xba.segment_value2
			 , xb.period_name
			 , xcps.effective_period_num
			 , to_char(xcps.start_date, 'yyyy-mm-dd') period_start
			 , to_char(xcps.end_date, 'yyyy-mm-dd') period_end
			 , xcps.period_year
			 , sum(xb.budget_amount) budget_amount
			 -- , sum(xb.budget_adjustment_amount) budget_adjustment_amount
			 -- , sum(xb.commitment_amount) commitment_amount
			 -- , sum(xb.obligation_amount) obligation_amount
			 -- , sum(xb.other_amount) other_amount
			 -- , sum(xb.actual_amount) actual_amount
			 -- , sum(xb.misc_expenditures_amount) misc_expenditures_amount
			 -- , sum(xb.funds_available_amount) funds_available_amount
			 -- , sum(xb.accounted_payables_amount) accounted_payables_amount
			 -- , sum(xb.accounted_receipts_amount) accounted_receipts_amount
			 -- , sum(xb.accounted_project_amount) accounted_project_amount
		  from xcc_budget_accounts xba
		  join xcc_balances xb on xb.budget_ccid = xba.budget_code_combination_id
		  join xcc_control_budgets xcb on xcb.control_budget_id = xb.control_budget_id
		  join xcc_cb_period_statuses xcps on xcps.control_budget_id = xcb.control_budget_id and xcps.period_name = xb.period_name
		  join gl_ledgers glv on xcb.ledger_id = glv.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by xcb.name
			 , glv.name
			 , xba.segment_value2
			 , xb.period_name
			 , xcps.effective_period_num
			 , to_char(xcps.start_date, 'yyyy-mm-dd')
			 , to_char(xcps.end_date, 'yyyy-mm-dd')
			 , xcps.period_year

-- ##############################################################
-- BUDGET BALANCES - SUM PER YEAR PER SEGMENT 2
-- ##############################################################

		select xcb.name budget_name
			 , xcb.description budget_desc
			 , glv.name ledger
			 , xcb.period_set_name
			 -- , xba.segment_value2
			 , xcps.period_year
			 , min(xcps.effective_period_num) min_period
			 , max(xcps.effective_period_num) maxperiod
			 , sum(xb.budget_amount) budget_amount
			 , sum(xb.budget_adjustment_amount) budget_adjustment_amount
			 , sum(xb.commitment_amount) commitment_amount
			 , sum(xb.obligation_amount) obligation_amount
			 , sum(xb.other_amount) other_amount
			 , sum(xb.actual_amount) actual_amount
			 , sum(xb.misc_expenditures_amount) misc_expenditures_amount
			 , sum(xb.funds_available_amount) funds_available_amount
			 , sum(xb.accounted_payables_amount) accounted_payables_amount
			 , sum(xb.accounted_receipts_amount) accounted_receipts_amount
			 , sum(xb.accounted_project_amount) accounted_project_amount
		  from xcc_budget_accounts xba
		  join xcc_balances xb on xb.budget_ccid = xba.budget_code_combination_id
		  join xcc_control_budgets xcb on xcb.control_budget_id = xb.control_budget_id
		  join xcc_cb_period_statuses xcps on xcps.control_budget_id = xcb.control_budget_id and xcps.period_name = xb.period_name
		  join gl_ledgers glv on xcb.ledger_id = glv.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by xcb.name
			 , xcb.description
			 , glv.name
			 , xcb.period_set_name
			 -- , xba.segment_value2
			 , xcps.period_year

-- ##############################################################
-- BUDGET BALANCES - DETAILS FROM BALANCE TABLE
-- ##############################################################

		select xba.segment_value2
			 , xb.*
		  from xcc_budget_accounts xba
		  join xcc_balances xb on xb.budget_ccid = xba.budget_code_combination_id
		  join xcc_control_budgets xcb on xcb.control_budget_id = xb.control_budget_id
		  join gl_ledgers glv on xcb.ledger_id = glv.ledger_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGET BALANCES - TABLE DUMPS
-- ##############################################################

select * from xcc_balance_activities where budget_ccid = 1234
select * from xcc_balances
select * from xcc_balances where budget_ccid = 1234
select * from xcc_balances where budget_ccid in (select budget_code_combination_id from xcc_budget_accounts where segment_value2 in ('xx123','ab765'))
select * from xcc_budget_accounts -- budget balances
select * from xcc_budget_accounts where segment_value2 in ('xx123','ab765')
select * from xcc_budget_dist_accts
select * from xcc_budget_dist_headers
select * from xcc_budget_dist_lines
select * from xcc_control_budgets -- budget combinations
select * from xcc_tr_headers where source_header_id_1 = 1234
select * from xcc_tr_lines where budget_ccid = 1234
select * from xcc_tr_lines where code_combination_id = 1234
select * from xcc_tr_lines where header_num in ('1234++1','4321++1')

-- ##############################################################
-- XCC_TR_HEADERS
-- ##############################################################

		select xth.header_num
			 , prha.requisition_number req
			 , '#' || prha.requisition_header_id requisition_header_id
			 , prha.document_status
			 , xth.transaction_number
			 , xth.source_action_code
			 , xth.result_code
			 , xth.draft_flag
			 , xth.budget_flag
			 , to_char(xth.creation_date, 'yyyy-mm-dd hh24:mi:ss') xth_created
			 , xth.created_by xth_created_by
		  from xcc_tr_headers xth
		  join por_requisition_headers_all prha on xth.source_header_id_1 = prha.requisition_header_id
		 where 1 = 1
		   and 1 = 1
	  order by xth.creation_date desc

-- ##############################################################
-- XCC_TR_HEADERS and XCC_TR_LINES
-- ##############################################################

		select xth.header_num
			 , prha.requisition_number req
			 , '#' || prha.requisition_header_id requisition_header_id
			 , prha.document_status
			 , xth.transaction_number
			 , xth.source_action_code
			 , xth.result_code
			 , xth.draft_flag
			 , xth.budget_flag
			 , to_char(xth.creation_date, 'yyyy-mm-dd hh24:mi:ss') xth_created
			 , xth.created_by xth_created_by
			 , '########################'
			 , xtl.quantity
			 , xtl.price
			 , xtl.entered_amount
			 , ppav.segment1 proj_number
			 , ptv.task_number
			 , petl.expenditure_type_name
			 , to_char(xtl.pjc_expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , to_char(xtl.budget_date, 'yyyy-mm-dd') budget_date
			 , to_char(xtl.budget_date, 'yyyy-mm-dd') accounting_date
		  from xcc_tr_headers xth
		  join xcc_tr_lines xtl on xth.header_num = xtl.header_num
	 left join pjf_projects_all_vl ppav on xtl.pjc_project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and xtl.pjc_task_id = ptv.task_id
	 left join pjf_exp_types_tl petl on xtl.pjc_expenditure_type_id = petl.expenditure_type_id
		  join por_requisition_headers_all prha on xth.source_header_id_1 = prha.requisition_header_id
		 where 1 = 1
		   and 1 = 1
	  order by xth.creation_date desc

-- ##############################################################
-- XCC_TR_HEADERS, XCC_TR_LINES and XCC_BALANCE_ACTIVITIES
-- ##############################################################

		select xth.header_num
			 , prha.requisition_number req
			 , '#' || prha.requisition_header_id requisition_header_id
			 , prha.document_status
			 , xth.transaction_number
			 , xth.source_action_code
			 , xth.result_code
			 , xth.draft_flag
			 , xth.budget_flag
			 , to_char(xth.creation_date, 'yyyy-mm-dd hh24:mi:ss') xth_created
			 , xth.created_by xth_created_by
			 , '#' lines________
			 , xtl.quantity
			 , xtl.price
			 , xtl.entered_amount
			 , ppav.segment1 proj_number
			 , ptv.task_number
			 , petl.expenditure_type_name
			 , to_char(xtl.pjc_expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , to_char(xtl.budget_date, 'yyyy-mm-dd') budget_date
			 , to_char(xtl.budget_date, 'yyyy-mm-dd') accounting_date
			 , '#' balances________
			 , xcb.name control_budget_name
			 , xba.result_code bal_result_code
			 , xba.control_level_code
			 , xba.amount bal_amount
			 , xba.period_name
			 , xba.balance_type_code
			 , xba.sub_balance_type_code
			 , xba.budget_amount
			 , xba.budget_adjustment_amount
			 , xba.commitment_amount
			 , xba.obligation_amount
			 , xba.actual_amount
			 , xba.funds_available_amount
			 , xba.entered_amount bal_entered_amount
			 , xba.balances_updated_flag
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.full_name budget_manager_name
		  from xcc_tr_headers xth
		  join xcc_tr_lines xtl on xth.header_num = xtl.header_num
		  join xcc_balance_activities xba on xba.header_num = xth.header_num
	 left join pjf_projects_all_vl ppav on xtl.pjc_project_id = ppav.project_id
	 left join pjf_tasks_v ptv on ppav.project_id = ptv.project_id and xtl.pjc_task_id = ptv.task_id
	 left join pjf_exp_types_tl petl on xtl.pjc_expenditure_type_id = petl.expenditure_type_id
	 left join por_requisition_headers_all prha on xth.source_header_id_1 = prha.requisition_header_id
		  join xcc_control_budgets xcb on xcb.control_budget_id = xba.control_budget_id
	 left join per_person_names_f ppnf on ppnf.person_id = xcb.budget_manager_id and ppnf.name_type = 'GLOBAL'
		 where 1 = 1
		   and 1 = 1
	  order by xth.creation_date desc
