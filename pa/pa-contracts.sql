/*
File Name: pa-contracts.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- CONTRACT HEADERS
-- CONTRACT HEADERS SUMMARY
-- SIMPLE CONTRACT TO PROJECT
-- CONTRACT BILLING CONTROLS
-- CONTRACT HEADERS AND LINES 1
-- CONTRACT HEADERS AND LINES 2
-- CONTRACT HEADERS AND LINES 3
-- CONTRACT HEADERS AND LINES 4
-- CONTRACT HEADERS AND LINES 5
-- CONTRACT HEADERS AND LINES 6
-- CONTRACT HEADERS AND LINES 7
-- CONTRACT HEADERS AND LINES 8
-- COUNT SHOWING VOLUMES SPLIT BY MARKUP OR NO MARKUP
-- CONTRACT HEADERS CHECKING AMENDMENT_START_DATE

*/

-- ##############################################################
-- CONTRACT HEADERS
-- ##############################################################

		select okhab.contract_id
			 , okhab.id
			 , okhab.contract_number
			 , okhab.version_type
			 , flv_status.meaning contract_status
			 , octt.name agreement_type
			 , okhab.major_version
			 , to_char(okhab.creation_date, 'yyyy-mm-dd HH24:MI:SS') contract_created
			 , okhab.created_by contract_created_by
			 , to_char(okhab.last_update_date, 'yyyy-mm-dd HH24:MI:SS') contract_updated
			 , okhab.last_updated_by contract_updated_by
			 , to_char(okhab.start_date, 'yyyy-mm-dd') start_date
			 , to_char(okhab.end_date, 'yyyy-mm-dd') end_date
			 , to_char(okhab.date_approved, 'yyyy-mm-dd') date_approved
			 , to_char(okhab.date_signed, 'yyyy-mm-dd') date_signed
			 , to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') amendment_effective_date
			 , '💲💲💲' "💲💲💲"
			 , okhab.curcy_conv_rate_type
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , okhab.inv_conv_rate_date_type -- currency rate date type used for converting amounts to contract currency during invoicing process.
			 , okhab.inv_conv_rate_type -- currency conversion rate type used for converting amounts to contract currency during invoicing process.
		  from okc_k_headers_all_b okhab
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		 where 1 = 1
	  order by okhab.major_version

-- ##############################################################
-- CONTRACT HEADERS SUMMARY
-- ##############################################################

		select octt.name agreement_type
			 , min(to_char(octt.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_min
			 , max(to_char(octt.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_max
			 , min(okhab.contract_number) min_contract_num
			 , max(okhab.contract_number) max_contract_num
			 , count(*)
		  from okc_k_headers_all_b okhab
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		 where 1 = 1
		   and 1 = 1
	  group by octt.name

-- ##############################################################
-- SIMPLE CONTRACT TO PROJECT
-- ##############################################################

		select distinct okhab.contract_number
			 , ppav.segment1 project
		  from okc_k_headers_all_b okhab
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and oklb.major_version = okhab.major_version
		  join okc_k_lines_tl oklt on oklb.id = oklt.id and oklt.major_version = okhab.major_version
		  join okc_line_types_tl oltt on oklb.line_type_id = oltt.line_type_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id and pcpl.major_version = okhab.major_version
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CONTRACT BILLING CONTROLS
-- ##############################################################

		select okhab.contract_id
			 , okhab.contract_number
			 , okhab.creation_date contract_created
			 , okhab.id
			 , okhab.version_type
			 , to_char(pbc.start_date, 'yyyy-mm-dd') start_date
			 , to_char(pbc.end_date, 'yyyy-mm-dd') end_date
			 , pbc.soft_limit_amount
			 , pbc.hard_limit_amount
			 , pbc.itd_invoice_amount
			 , pbc.itd_revenue_amount
		  from okc_k_headers_all_b okhab
		  join pjb_billing_controls pbc on pbc.contract_id = okhab.id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CONTRACT HEADERS AND LINES 1
-- ##############################################################

		select okhab.contract_number
			 , okhab.contract_id
			 , octt.name agreement_type
			 , flv_status.meaning contract_status
			 , to_char(okhab.creation_date, 'yyyy-mm-dd hh24:mi:ss') contract_created
			 , okhab.created_by contract_created_by
			 , okhab.major_version
			 , '💲💲💲'
			 , okhab.curcy_conv_rate_type
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , okhab.inv_conv_rate_date_type -- Currency conversion rate date type used for converting amounts to contract currency during Invoicing process.
			 , okhab.inv_conv_rate_type -- Currency conversion rate type used for converting amounts to contract currency during Invoicing process.
			 , '#################'
			 , oklb.line_number
			 , oklb.line_amount
			 , oklb.cust_po_number
			 , oklt.line_name
			 , oklt.line_description
			 , '##################'
			 , ppav.segment1 project
			 , ppav.name proj_name
			 , pptt.project_type
			 , ppst.project_status_name project_status
			 , haou.name project_org
			 , to_char(ppav.creation_date, 'yyyy-mm-dd hh24:mi:ss') project_created
			 , ppav.project_currency_code
			 , to_char(ppav.start_date, 'yyyy-mm-dd') project_start
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') project_completion
			 , to_char(ppav.closed_date, 'yyyy-mm-dd') project_closed_date
			 , ppav.pm_product_code
			 , ppav.pm_project_reference
			 , ptv.task_number
			 , ptv.task_name
			 , pcpl.funding_amount funded_amount
			 , (select sum(pbt.inv_curr_billed_amt)
		  from pjb_bill_trxs pbt
		 where pbt.contract_id = okhab.id
		   and pbt.contract_line_id = oklb.id
		   and pbt.linked_project_id = ppav.project_id
		   and pbt.linked_task_id = ptv.task_id
		   and pbt.contract_project_linkage_id = pcpl.link_id) invoiced_amount
			 , (select sum(prd.revenue_curr_amt)
		  from pjb_rev_distributions prd
		 where prd.contract_id = okhab.id
		   and prd.contract_line_id = oklb.id
		   and prd.linked_project_id = ppav.project_id
		   and prd.linked_task_id = ptv.task_id
		   and prd.contract_project_linkage_id = pcpl.link_id) recognised_revenue
			 , pcpl.active_flag
			 , '###################'
			 , (select distinct count(pda.po_header_id) from po_distributions_all pda where pda.pjc_project_id = ppav.project_id) po_count
			 , (select distinct count(aida.invoice_id) from ap_invoice_distributions_all aida where aida.pjc_project_id = ppav.project_id) invoice_count
		  from okc_k_headers_all_b okhab
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang') and okhab.version_type = 'C' -- current (can be (C)urrent, (A)mendment or (H)istory
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and sysdate between nvl(oklb.start_date, sysdate-1) and nvl(oklb.end_date, sysdate+1) and oklb.version_type = 'C' -- current (can be (C)urrent, (A)mendment or (H)istory
		  join okc_k_lines_tl oklt on oklb.id = oklt.id and oklt.version_type = 'C' -- current (can be (C)urrent, (A)mendment or (H)istory
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id and pcpl.version_type = 'C' -- current (can be (C)urrent, (A)mendment or (H)istory
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
		  join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id
		  join pjf_project_types_tl pptt on pptt.project_type_id = ppav.project_type_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(okhab.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- CONTRACT HEADERS AND LINES 2
-- ##############################################################

/*
With associated Bill and Revenue Plans
*/

		select okhab.contract_number
			 , octt.name agreement_type
			 , flv_status.meaning contract_status
			 , to_char(okhab.creation_date, 'yyyy-mm-dd HH24:MI:SS') contract_created
			 , okhab.created_by contract_created_by
			 , okhab.major_version contract_ver
			 , okhab.version_type
			 , okhab.contribution_percent
			 , to_char(okhab.date_approved, 'yyyy-mm-dd') date_approved
			 , to_char(okhab.date_signed, 'yyyy-mm-dd') date_signed
			 , to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') amendment_effective_date
			 , '-- contract line --' contract_line
			 , oklb.line_number
			 , oklb.id contract_line_id_id
			 , oltt.name line_type
			 , oklt.line_name
			 , oklt.line_description
			 , oklt.item_name
			 , to_char(oklb.start_date, 'yyyy-mm-dd') line_start_date
			 , to_char(oklb.end_date, 'yyyy-mm-dd') line_end_date
			 , oklb.line_amount
			 , oklb.cust_po_number
			 , oklb.revenue_recog_amt line_revenue_amount
			 , oklb.sts_code line_status
			 , to_char(oklb.creation_date, 'yyyy-mm-dd HH24:MI:SS') contract_line_created
			 , to_char(oklb.last_update_date, 'yyyy-mm-dd HH24:MI:SS') contract_line_updatwed
			 , '-- line billing control -- '
			 , pbc.soft_limit_amount amount_soft_limit
			 , pbc.hard_limit_amount amount_hard_limit
			 , pbc.itd_invoice_amount amount_invoice
			 , pbc.itd_revenue_amount amount_revenue
			 , '-- associated projects -- '
			 , ppav.segment1 project
			 , ppst.project_status_name project_status
			 , ptv.task_number task
			 , ptv.task_id
			 , pcpl.funding_amount funded_amount
			 , pcpl.active_flag
			 , '-- bill plan --'
			 , pbpb_bill_t.bill_plan_name
			 , pbmt_bill.bill_method_name invoice_method_name
			 , pbct.billing_cycle_name
			 , pbcb.billing_cycle_type
			 , pbcb.billing_value1
			 , pbpb_bill_t.created_by bill_plan_created_by
			 , decode(pbpb_bill.bill_type_class_code, 'PERCENT_COMPLETE', 'Percent Complete', 'AS_INCURRED', 'As Incurred', 'AS_BILLED', 'As Billed', 'AMOUNT_BASED', 'Amount Based', 'RATE_BASED', 'Rate Based', 'PERCENT_SPENT', 'Percent Spent') inv_method_classification
			 , pbpb_bill.labor_discount_percentage labor_discount
			 , pbpb_bill.nl_discount_percentage non_labor_discount
			 , to_char(pbpb_bill.creation_date, 'yyyy-mm-dd HH24:MI:SS') bill_plan_created
			 , to_char(pbpb_bill.last_update_date, 'yyyy-mm-dd HH24:MI:SS') bill_plan_updated
			 , '-- bill plan override --'
			 , pbro_bill.discount_percentage
			 , pbro_bill.contract_line_id override_contr_line_id
			 , pbro_bill.rate_override_type_code
			 , to_char(pbro_bill.creation_date, 'yyyy-mm-dd HH24:MI:SS') pbro_created
			 , pbro_bill.created_by pbro_created_by
			 , petl_bill.expenditure_type_name override_exp_type
			 , to_char(pbro_bill.start_date_active, 'yyyy-mm-dd') pbro_start
			 , to_char(pbro_bill.end_date_active, 'yyyy-mm-dd') pbro_end
			 , '-- revenue plan --'
			 , pbpb_rev_t.bill_plan_name revenue_plan
			 , pbmt_rev.bill_method_name revenue_method_name
			 , pbmt_rev.created_by rev_plan_created_by
			 , decode(pbpb_rev.bill_type_class_code, 'PERCENT_COMPLETE', 'Percent Complete', 'AS_INCURRED', 'As Incurred', 'AS_BILLED', 'As Billed', 'AMOUNT_BASED', 'Amount Based', 'RATE_BASED', 'Rate Based', 'PERCENT_SPENT', 'Percent Spent') rev_method_classification 
		  from okc_k_headers_all_b okhab
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and oklb.major_version = okhab.major_version
		  join okc_k_lines_tl oklt on oklb.id = oklt.id and oklt.major_version = okhab.major_version
		  join okc_line_types_tl oltt on oklb.line_type_id = oltt.line_type_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id and pcpl.major_version = okhab.major_version
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
		  join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id and ptv.project_id = ppav.project_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		  join pjb_billing_controls pbc on pbc.contract_id = okhab.id and pbc.contract_line_id = oklb.id and pbc.major_version = okhab.major_version
	 left join pjb_bill_plans_b pbpb_bill on okhab.id = pbpb_bill.contract_id and oklb.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill.major_version = okhab.major_version
	 left join pjb_bill_plans_tl pbpb_bill_t on pbpb_bill_t.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill_t.major_version = okhab.major_version
	 left join pjf_billing_cycles_b pbcb on pbpb_bill.billing_cycle_id = pbcb.billing_cycle_id
	 left join pjf_billing_cycles_tl pbct on pbcb.billing_cycle_id = pbct.billing_cycle_id
	 left join pjb_billing_methods_b pbmb_bill on pbmb_bill.bill_method_id = pbpb_bill.bill_method_id
	 left join pjb_billing_methods_tl pbmt_bill on pbmt_bill.bill_method_id = pbmb_bill.bill_method_id
	 left join pjb_bill_rate_ovrrds pbro_bill on pbro_bill.bill_plan_id = pbpb_bill.bill_plan_id and pbro_bill.major_version = okhab.major_version
	 left join pjf_exp_types_tl petl_bill on pbro_bill.expenditure_type_id = petl_bill.expenditure_type_id
	 left join pjb_bill_plans_b pbpb_rev on okhab.id = pbpb_rev.contract_id and oklb.revenue_plan_id = pbpb_rev.bill_plan_id and pbpb_rev.major_version = okhab.major_version
	 left join pjb_bill_plans_tl pbpb_rev_t on pbpb_rev_t.bill_plan_id = pbpb_rev.bill_plan_id and pbpb_rev_t.major_version = okhab.major_version
	 left join pjb_billing_methods_b pbmb_rev on pbmb_rev.bill_method_id = pbpb_rev.bill_method_id
	 left join pjb_billing_methods_tl pbmt_rev on pbmt_rev.bill_method_id = pbmb_rev.bill_method_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(okhab.creation_date, 'yyyy-mm-dd HH24:MI:SS') desc

-- ##############################################################
-- CONTRACT HEADERS AND LINES 3
-- ##############################################################

		select okhab.contract_number
			 , octt.name agreement_type
			 , flv_status.meaning contract_status
			 , to_char(okhab.creation_date, 'yyyy-mm-dd HH24:MI:SS') contract_created
			 , '-- contract line --' contract_line
			 , okhab.created_by contract_created_by
			 , okhab.major_version contract_ver
			 , oklb.line_number
			 , oltt.name line_type
			 , oklt.line_name
			 , oklt.line_description
			 , to_char(oklb.start_date, 'yyyy-mm-dd') line_start_date
			 , to_char(oklb.end_date, 'yyyy-mm-dd') line_end_date
			 , oklb.line_amount
			 , oklb.cust_po_number
			 , oklb.revenue_recog_amt line_revenue_amount
			 , oklb.sts_code line_status
			 , '-- line billing control -- '
			 , pbc.soft_limit_amount amount_soft_limit
			 , pbc.hard_limit_amount amount_hard_limit
			 , pbc.itd_invoice_amount amount_invoice
			 , pbc.itd_revenue_amount amount_revenue
			 , '-- ship -- '
			 , hcsua_ship.location ship_to_site
			 , hca_ship.account_number ship_to_acct
			 , hca_ship.account_name ship_to_acct_name
			 , hp_ship.party_name ship_to_party
			 , '-- bill -- '
			 , hcsua_bill.location bill_to_site
			 , hca_bill.account_number bill_to_acct
			 , hca_bill.account_name bill_to_acct_name
			 , hp_bill.party_name bill_to_party
			 , '-- associated projects -- '
			 , ppav.segment1 project
			 , ppst.project_status_name project_status
			 , ptv.task_number
			 , ptv.task_id
			 , pcpl.funding_amount funded_amount
			 , pcpl.active_flag
			 , '-- bill plan --'
			 , pbpb_bill_t.bill_plan_name
			 , pbmt_bill.bill_method_name invoice_method_name
			 , pbct.billing_cycle_name
			 , pbcb.billing_cycle_type
			 , pbcb.billing_value1
			 , decode(pbpb_bill.bill_type_class_code, 'PERCENT_COMPLETE', 'Percent Complete', 'AS_INCURRED', 'As Incurred', 'AS_BILLED', 'As Billed', 'AMOUNT_BASED', 'Amount Based', 'RATE_BASED', 'Rate Based', 'PERCENT_SPENT', 'Percent Spent') inv_method_classification
			 , '-- revenue plan --'
			 , pbpb_rev_t.bill_plan_name revenue_plan
			 , pbmt_rev.bill_method_name revenue_method_name
			 , decode(pbpb_rev.bill_type_class_code, 'PERCENT_COMPLETE', 'Percent Complete', 'AS_INCURRED', 'As Incurred', 'AS_BILLED', 'As Billed', 'AMOUNT_BASED', 'Amount Based', 'RATE_BASED', 'Rate Based', 'PERCENT_SPENT', 'Percent Spent') rev_method_classification 
			 , ' -- stats -- ' -- cannot link counts below to task that the contract is linked to, because contract is linked to top task, exp items are at lower task levels
			 , (select count(*) from pjc_exp_items_all peia where peia.project_id = ppav.project_id and peia.revenue_recognized_flag = 'F') exp_items_recog
			 , (select count(*) from pjc_exp_items_all peia where peia.project_id = ppav.project_id) exp_items_all
			 , (select count(*) from pjb_rev_distributions prd where okhab.id = prd.contract_id and oklb.id = prd.contract_line_id and ppav.project_id = prd.linked_project_id) rev_dists_count
			 , (select count(*) from pjb_billing_events pbe where okhab.id = pbe.contract_id and oklb.id = pbe.contract_line_id and ppav.project_id = pbe.project_id) events_count
			 , (select count(*) from pjb_bill_trxs pbt where okhab.id = pbt.contract_id and oklb.id = pbt.contract_line_id and ppav.project_id = pbt.linked_project_id) bill_trxns_count
			 -- , ' -- stats -- ' -- used to link to same task that contract linked to, but commented out 
			 -- , (select count(*) from pjc_exp_items_all peia where peia.project_id = ppav.project_id and peia.task_id = ptv.task_id) exp_items
			 -- , (select count(*) from pjb_rev_distributions prd where okhab.id = prd.contract_id and oklb.id = prd.contract_line_id and ppav.project_id = prd.linked_project_id and ptv.task_id = prd.linked_task_id) rev_dists_count
			 -- , (select count(*) from pjb_billing_events pbe where okhab.id = pbe.contract_id and oklb.id = pbe.contract_line_id and ppav.project_id = pbe.project_id and ptv.task_id = pbe.linked_task_id) events_count
			 -- , (select count(*) from pjb_bill_trxs pbt where okhab.id = pbt.contract_id and oklb.id = pbt.contract_line_id and ppav.project_id = pbt.linked_project_id and ptv.task_id = pbt.linked_task_id) bill_trxns_count
		  from okc_k_headers_all_b okhab
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and okhab.major_version = oklb.major_version and sysdate between nvl(oklb.start_date, sysdate - 1) and nvl(oklb.end_date, sysdate + 1)
		  join okc_k_lines_tl oklt on oklb.id = oklt.id
		  join okc_line_types_tl oltt on oklb.line_type_id = oltt.line_type_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and okhab.major_version = pcpl.major_version and oklb.id = pcpl.contract_line_id
		  -- 
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
		  join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id and ptv.project_id = ppav.project_id
		  join pjf_project_statuses_tl ppst on ppst.project_status_code = ppav.project_status_code
		  -- 
		  join pjb_billing_controls pbc on pbc.contract_id = okhab.id and pbc.major_version = okhab.major_version and pbc.contract_line_id = oklb.id
		  -- 
	 left join pjb_bill_plans_b pbpb_bill on okhab.id = pbpb_bill.contract_id and oklb.bill_plan_id = pbpb_bill.bill_plan_id
	 left join pjb_bill_plans_tl pbpb_bill_t on pbpb_bill_t.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill_t.major_version = pbpb_bill.major_version
	 left join pjf_billing_cycles_b pbcb on pbpb_bill.billing_cycle_id = pbcb.billing_cycle_id
	 left join pjf_billing_cycles_tl pbct on pbcb.billing_cycle_id = pbct.billing_cycle_id
	 left join pjb_billing_methods_b pbmb_bill on pbmb_bill.bill_method_id = pbpb_bill.bill_method_id
	 left join pjb_billing_methods_tl pbmt_bill on pbmt_bill.bill_method_id = pbmb_bill.bill_method_id
		  -- 
	 left join pjb_bill_plans_b pbpb_rev on okhab.id = pbpb_rev.contract_id and oklb.revenue_plan_id = pbpb_rev.bill_plan_id
	 left join pjb_bill_plans_tl pbpb_rev_t on pbpb_rev_t.bill_plan_id = pbpb_rev.bill_plan_id and pbpb_rev_t.major_version = pbpb_rev.major_version
	 left join pjb_billing_methods_b pbmb_rev on pbmb_rev.bill_method_id = pbpb_rev.bill_method_id
	 left join pjb_billing_methods_tl pbmt_rev on pbmt_rev.bill_method_id = pbmb_rev.bill_method_id
		  -- 
	 left join hz_cust_site_uses_all hcsua_ship on hcsua_ship.site_use_id = oklb.ship_to_site_use_id and hcsua_ship.site_use_code = 'SHIP_TO'
	 left join hz_cust_acct_sites_all hcasa_ship on hcsua_ship.cust_acct_site_id = hcasa_ship.cust_acct_site_id
	 left join hz_cust_accounts hca_ship on hca_ship.cust_account_id = hcasa_ship.cust_account_id and oklb.ship_to_acct_id = hca_ship.cust_account_id
	 left join hz_parties hp_ship on hp_ship.party_id = hca_ship.party_id
		  -- 
	 left join hz_cust_site_uses_all hcsua_bill on hcsua_bill.site_use_id = oklb.bill_to_site_use_id and hcsua_bill.site_use_code = 'BILL_TO'
	 left join hz_cust_acct_sites_all hcasa_bill on hcsua_bill.cust_acct_site_id = hcasa_bill.cust_acct_site_id
	 left join hz_cust_accounts hca_bill on hca_bill.cust_account_id = hcasa_bill.cust_account_id and oklb.bill_to_acct_id = hca_bill.cust_account_id
	 left join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  -- 
		 where 1 = 1
		  -- 
		   and okhab.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and oklb.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and oklt.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and pcpl.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and pbc.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and pbpb_bill.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and pbpb_rev.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
	  order by to_char(okhab.creation_date, 'yyyy-mm-dd HH24:MI:SS') desc

-- ##############################################################
-- CONTRACT HEADERS AND LINES 4
-- ##############################################################

		select okhab.contract_number
			 , okhab.sts_code contract_status
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , okhab.creation_date contract_created
			 , octt.name agreement_type
			 , ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , to_char(ppav.start_date, 'yyyy-mm-dd') project_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') project_completion_date
			 , ptv.task_number
			 , ptv.task_name
			 , haou.name org
			 , oklb.line_number
			 , to_char(oklb.start_date, 'yyyy-mm-dd') line_start_date
			 , to_char(oklb.end_date, 'yyyy-mm-dd') line_end_date
			 , oklb.currency_code line_currency
			 , oklb.sts_code line_status
			 , oklb.revenue_recog_amt
			 , '###############'
			 , nvl(okhab.curcy_conv_rate_type, 'n/a') curcy_conv_rate_type
			 , nvl(okhab.inv_conv_rate_date_type, 'n/a') inv_conv_rate_date_type
			 , nvl(okhab.inv_conv_rate_type, 'n/a') inv_conv_rate_type
			 , nvl(okhab.rev_conv_rate_type, 'n/a') rev_conv_rate_type
			 , '@@@@@@@@@@@@@@@'
			 , (select ledger_currency_code from pjb_rev_distributions where linked_project_id = ppav.project_id and rownum < 2) func_currency
			 , (select nvl(sum(nvl(prd.ledger_curr_revenue_amt, 0)), 0) from pjb_rev_distributions prd where 1 = 1 and prd.contract_id = okhab.id and prd.contract_line_id = oklb.id) actual_rev_itd_func_curr
			 , (select nvl(sum(nvl(prd.project_curr_revenue_amt, 0)),0) project_curr_revenue_amt from pjb_rev_distributions prd where 1 = 1 and prd.contract_id = okhab.id and prd.contract_line_id = oklb.id) actual_rev_itd_prj_curr
			 , (select nvl (sum (projectcostdistributionpeo.quantity), 0) from pjc_cost_dist_lines_all projectcostdistributionpeo, pjc_exp_items_all expenditureitempeo, pjf_exp_types_vl pet where (projectcostdistributionpeo.expenditure_item_id = expenditureitempeo.expenditure_item_id and expenditureitempeo.expenditure_type_id = pet.expenditure_type_id and projectcostdistributionpeo.task_id = nvl(pcpl.proj_element_id, projectcostdistributionpeo.task_id) and pet.expenditure_type_name in ('Professional Labor', 'Contract Professional Labor') and projectcostdistributionpeo.billable_flag = 'Y') and expenditureitempeo.project_id = ppav.project_id) billable_hours_actual_itd
		  from okc_k_headers_all_b okhab
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and sysdate between nvl(oklb.start_date, sysdate - 1) and nvl(oklb.end_date, sysdate + 1)
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C'
		   and pcpl.version_type = 'C'
	  order by okhab.creation_date

-- ##############################################################
-- CONTRACT HEADERS AND LINES 5
-- ##############################################################

		select okhab.contract_number
			 , okhab.sts_code contract_status
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , okhab.creation_date contract_created
			 , octt.name agreement_type
			 , ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , to_char(ppav.start_date, 'yyyy-mm-dd') project_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') project_completion_date
			 , ptv.task_number
			 , ptv.task_name
			 , haou.name org
			 , oklb.line_number
			 , to_char(oklb.start_date, 'yyyy-mm-dd') line_start_date
			 , to_char(oklb.end_date, 'yyyy-mm-dd') line_end_date
			 , oklb.currency_code line_currency
			 , oklb.sts_code line_status
			 , oklb.revenue_recog_amt
			 , '###############'
			 , nvl(okhab.curcy_conv_rate_type, 'n/a') curcy_conv_rate_type
			 , nvl(okhab.inv_conv_rate_date_type, 'n/a') inv_conv_rate_date_type
			 , nvl(okhab.inv_conv_rate_type, 'n/a') inv_conv_rate_type
			 , nvl(okhab.rev_conv_rate_type, 'n/a') rev_conv_rate_type
			 , '@@@@@@@@@@@@@@@'
			 , (select ledger_currency_code from pjb_rev_distributions where linked_project_id = ppav.project_id and rownum < 2) func_currency
			 , (select nvl(sum(nvl(prd.ledger_curr_revenue_amt, 0)), 0) from pjb_rev_distributions prd where 1 = 1 and prd.contract_id = okhab.id and prd.contract_line_id = oklb.id) actual_rev_itd_func_curr
			 , (select nvl(sum(nvl(prd.project_curr_revenue_amt, 0)),0) project_curr_revenue_amt from pjb_rev_distributions prd where 1 = 1 and prd.contract_id = okhab.id and prd.contract_line_id = oklb.id) actual_rev_itd_prj_curr
			 , (select nvl (sum (projectcostdistributionpeo.quantity), 0) from pjc_cost_dist_lines_all projectcostdistributionpeo, pjc_exp_items_all expenditureitempeo, pjf_exp_types_vl pet where (projectcostdistributionpeo.expenditure_item_id = expenditureitempeo.expenditure_item_id and expenditureitempeo.expenditure_type_id = pet.expenditure_type_id and projectcostdistributionpeo.task_id = nvl(pcpl.proj_element_id, projectcostdistributionpeo.task_id) and pet.expenditure_type_name in ('Professional Labor', 'Contract Professional Labor') and projectcostdistributionpeo.billable_flag = 'Y') and expenditureitempeo.project_id = ppav.project_id) billable_hours_actual_itd
		  from okc_k_headers_all_b okhab
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C'
		   and pcpl.version_type = 'C'
	  order by okhab.creation_date

-- ##############################################################
-- CONTRACT HEADERS AND LINES 6
-- ##############################################################

/*
Including billing events and revenues
*/

		select okhab.contract_number
			 , okhab.sts_code contract_status
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , octt.name agreement_type
			 , ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , to_char(ppav.start_date, 'yyyy-mm-dd') project_start_date
			 , to_char(ppav.completion_date, 'yyyy-mm-dd') project_completion_date
			 , ptv.task_number
			 , ptv.task_name
			 , haou.name org
			 , oklb.line_number
			 , to_char(oklb.start_date, 'yyyy-mm-dd') line_start_date
			 , to_char(oklb.end_date, 'yyyy-mm-dd') line_end_date
			 , oklb.currency_code line_currency
			 , oklb.sts_code line_status
			 , oklb.revenue_recog_amt
			 , '😀'
			 , nvl(okhab.curcy_conv_rate_type, 'n/a') curcy_conv_rate_type
			 , nvl(okhab.inv_conv_rate_date_type, 'n/a') inv_conv_rate_date_type
			 , nvl(okhab.inv_conv_rate_type, 'n/a') inv_conv_rate_type
			 , nvl(okhab.rev_conv_rate_type, 'n/a') rev_conv_rate_type
			 , '😀😀'
			 , prd.creation_date prd_created
			 , prd.created_by
			 , prd.bill_transaction_type_code
			 , prd.revenue_category_code
			 , prd.revenue_recognized_flag
			 , prd.trns_currency_code
			 , prd.trns_curr_revenue_amt "Transaction currency"
			 , prd.contract_currency_code
			 , prd.cont_curr_rev_rate_type
			 , prd.cont_curr_rev_exchg_rate
			 , prd.cont_curr_rev_exchg_date
			 , prd.cont_curr_revenue_amt "Amount in contract currency"
			 , prd.revenue_curr_amt "Revenue Currency Amount"
			 , prd.revenue_currency_code
			 , prd.project_currency_code
			 -- , prd.project_curr_rate_type
			 -- , prd.project_curr_exchg_rate
			 -- , prd.project_currency_exchg_date
			 , prd.project_curr_revenue_amt "Amount in Project Currency"
			 , prd.ledger_currency_code
			 -- , prd.ledger_curr_rev_rate_type
			 -- , prd.ledger_curr_rev_exchg_date
			 -- , prd.ledger_curr_rev_exchg_rate
			 , prd.ledger_curr_revenue_amt "Ledger currency billed amount"
			 , prd.gl_period_name
			 , prd.pa_period_name
			 , '😀😀😀'
			 , pbt.transaction_id
			 , pbt.transaction_type_id
			 , pbt.transaction_date
			 , pbt.transaction_project_id
			 , pbt.transaction_task_id
			 , '😀😀😀😀'
			 , pbpt.bill_plan_name
			 , '😀😀😀😀😀'
			 , pbpt2.bill_plan_name revenue_plan
			 , '😀😀😀😀😀😀'
			 , peia.cc_rejection_code
			 , peia.expenditure_item_id
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') expenditure_item_date
			 , round(peia.projfunc_raw_cost, 2) "Raw cost in project Func Curr"
			 , peia.raw_cost_rate "Raw cost rate to cost the item"
			 , peia.denom_raw_cost "Total raw cost in TRX CURR"
			 , round(peia.acct_raw_cost, 2) "Raw cost in Func CURR"
			 , round(peia.project_raw_cost, 2) "Raw cost in PROD CURR"
			 , peia.denom_currency_code "TRX CURR code of the TRX"
			 , petl.expenditure_type_name
			 , ptst.user_transaction_source trx_source
			 -- , pega.EXPENDITURE_GROUP
			 , '😀😀😀😀😀😀😀'
			 , round(peia.acct_raw_cost, 2) cost
			 , round(prd.project_curr_revenue_amt,2) revenue
			 , 100 - (round(round(peia.acct_raw_cost, 2) / round(prd.project_curr_revenue_amt,2),2)*100) markup_percentage
		  from okc_k_headers_all_b okhab
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjb_rev_distributions prd on okhab.id = prd.contract_id and oklb.id = prd.contract_line_id and ppav.project_id = prd.linked_project_id and ptv.task_id = prd.linked_task_id
		  join pjb_bill_trxs pbt on pbt.transaction_id = prd.transaction_id
	 left join pjb_bill_plans_b pbpb on pbt.bill_plan_id = pbpb.bill_plan_id and pbpb.version_type = 'C'
	 left join pjb_bill_plans_tl pbpt on pbpt.bill_plan_id = pbpb.bill_plan_id and pbpt.major_version = pbpb.major_version
	 left join pjb_bill_plans_b pbpb2 on pbt.revenue_plan_id = pbpb2.bill_plan_id and pbpb2.version_type = 'C'
	 left join pjb_bill_plans_tl pbpt2 on pbpt2.bill_plan_id = pbpb2.bill_plan_id and pbpt2.major_version = pbpb2.major_version
	 left join pjc_exp_items_all peia on pbt.transaction_id = peia.expenditure_item_id and pbt.bill_transaction_type_code = 'EI'
	 left join pjb_billing_events pbe on pbt.transaction_id = pbe.event_id and pbt.bill_transaction_type_code = 'evt'
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id
	 left join PJC_EXP_GROUPS_ALL pega on peia.EXP_GROUP_ID = pega.exp_group_id
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C'
		   and pcpl.version_type = 'C'
		   and 1 = 1
	  order by prd.creation_date

-- ##############################################################
-- CONTRACT HEADERS AND LINES 7
-- ##############################################################

/*
Including billing events and revenues
*/

		select okhab.contract_number
			 , okhab.sts_code Contract_Status
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , octt.name agreement_type
			 , ppav.segment1 proj_number
			 , ppav.name proj_name
			 , ppav.project_status_code
			 , TO_CHAR(ppav.start_date, 'yyyy-mm-dd') project_start_date
			 , TO_CHAR(ppav.completion_date, 'yyyy-mm-dd') project_completion_date
			 , ptv.task_number
			 , ptv.task_name
			 , haou.name org
			 , oklb.line_number
			 , to_char(oklb.start_date, 'yyyy-mm-dd') line_start_date
			 , to_char(oklb.end_date, 'yyyy-mm-dd') line_end_date
			 , oklb.currency_code line_currency
			 , oklb.sts_code line_status
			 , oklb.revenue_recog_amt
			 , '###############'
			 , nvl(okhab.CURCY_CONV_RATE_TYPE, 'n/a') CURCY_CONV_RATE_TYPE
			 , nvl(okhab.INV_CONV_RATE_DATE_TYPE, 'n/a') INV_CONV_RATE_DATE_TYPE
			 , nvl(okhab.INV_CONV_RATE_TYPE, 'n/a') INV_CONV_RATE_TYPE
			 , nvl(okhab.REV_CONV_RATE_TYPE, 'n/a') REV_CONV_RATE_TYPE
			 , '@@@@@@@@@@@@@@@'
			 , prd.creation_date prd_created
			 , prd.created_by
			 , prd.bill_transaction_type_code
			 , prd.revenue_category_code
			 , prd.revenue_recognized_flag
			 , prd.trns_currency_code
			 , prd.trns_curr_revenue_amt
			 , prd.contract_currency_code
			 , prd.cont_curr_rev_rate_type
			 , prd.cont_curr_rev_exchg_rate
			 , prd.cont_curr_rev_exchg_date
			 , prd.cont_curr_revenue_amt
			 , prd.revenue_curr_amt
			 , prd.revenue_currency_code
			 , prd.project_currency_code
			 , prd.project_curr_rate_type
			 , prd.project_curr_exchg_rate
			 , prd.project_currency_exchg_date
			 , prd.project_curr_revenue_amt
			 , prd.ledger_currency_code
			 , prd.ledger_curr_rev_rate_type
			 , prd.ledger_curr_rev_exchg_date
			 , prd.ledger_curr_rev_exchg_rate
			 , prd.ledger_curr_revenue_amt
			 , prd.gl_period_name
			 , prd.pa_period_name
			 , '~~~~~~~~~~~~~~~'
			 , pbt.transaction_id
			 , pbt.transaction_type_id
			 , pbt.transaction_date
			 , pbt.transaction_project_id
			 , pbt.transaction_task_id
			 , '😀'
			 , pbpt.bill_plan_name
			 , '😀😀'
			 , pbpt2.bill_plan_name revenue_plan
		  from okc_k_headers_all_b okhab
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjb_rev_distributions prd on okhab.id = prd.contract_id and oklb.id = prd.contract_line_id and ppav.project_id = prd.linked_project_id and ptv.task_id = prd.linked_task_id
		  join pjb_bill_trxs pbt on pbt.transaction_id = prd.transaction_id
	 left join pjb_bill_plans_b pbpb on pbt.bill_plan_id = pbpb.bill_plan_id and pbpb.version_type = 'C'
	 left join pjb_bill_plans_tl pbpt on pbpt.bill_plan_id = pbpb.bill_plan_id and pbpt.major_version = pbpb.major_version
	 left join pjb_bill_plans_b pbpb2 on pbt.revenue_plan_id = pbpb2.bill_plan_id and pbpb2.version_type = 'C'
	 left join pjb_bill_plans_tl pbpt2 on pbpt2.bill_plan_id = pbpb2.bill_plan_id and pbpt2.major_version = pbpb2.major_version
case when pbt.bill_transaction_type_code = 'EI' then join pjc_exp_items_all peia on pbt.transaction_id = pei.expenditure_item_id end
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C'
		   and pcpl.version_type = 'C'
		   and 1 = 1
	  order by prd.creation_date

-- ##############################################################
-- CONTRACT HEADERS AND LINES 8
-- ##############################################################

/*
Contract headers, lines, projects, billing events, revenues, expenditure items
*/

		select okhab.contract_number
			 , okhab.currency_code project_currency
			 , okhab.corp_currency_code
			 , ppav.segment1 proj_number
			 , '😀'
			 , nvl(okhab.curcy_conv_rate_type, 'n/a') curcy_conv_rate_type
			 , nvl(okhab.inv_conv_rate_date_type, 'n/a') inv_conv_rate_date_type
			 , nvl(okhab.inv_conv_rate_type, 'n/a') inv_conv_rate_type
			 , nvl(okhab.rev_conv_rate_type, 'n/a') rev_conv_rate_type
			 , '😀😀'
			 , prd.creation_date prd_created
			 , prd.bill_transaction_type_code
			 , prd.revenue_category_code
			 , prd.revenue_recognized_flag
			 , prd.trns_currency_code
			 , prd.trns_curr_revenue_amt "Transaction currency"
			 , prd.contract_currency_code
			 , prd.cont_curr_rev_rate_type
			 , prd.cont_curr_rev_exchg_rate
			 , to_char(prd.cont_curr_rev_exchg_date, 'yyyy-mm-dd') cont_curr_rev_exchg_date
			 , prd.cont_curr_revenue_amt "Amount in contract currency"
			 , prd.revenue_curr_amt "Revenue Currency Amount"
			 , prd.revenue_currency_code
			 , prd.project_currency_code
			 , prd.project_curr_rate_type
			 , prd.project_curr_exchg_rate
			 , to_char(prd.project_currency_exchg_date, 'yyyy-mm-dd') project_currency_exchg_date
			 , prd.project_curr_revenue_amt "Amount in Project Currency"
			 , prd.ledger_currency_code
			 , prd.ledger_curr_rev_rate_type
			 , to_char(prd.ledger_curr_rev_exchg_date, 'yyyy-mm-dd') ledger_curr_rev_exchg_date
			 , prd.ledger_curr_rev_exchg_rate
			 , prd.ledger_curr_revenue_amt "Ledger currency billed amount"
			 , prd.gl_period_name
			 , prd.pa_period_name
			 , '😀😀😀'
			 , peia.expenditure_item_id item_id
			 , peia.creation_date exp_created
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') exp_item_date
			 , to_char(peia.expenditure_ending_date, 'yyyy-mm-dd') expenditure_ending_date
			 , '😀😀😀😀'
			 , peia.orig_transaction_reference
			 , peia.acct_currency_code
			 , to_char(peia.acct_rate_date, 'yyyy-mm-dd') acct_rate_date
			 , peia.acct_rate_type
			 , peia.acct_rate_date_type
			 , peia.acct_exchange_rate
			 , peia.acct_raw_cost
			 , peia.acct_burdened_cost
			 , to_char(peia.project_rate_date, 'yyyy-mm-dd') project_rate_date
			 , peia.project_rate_type
			 , peia.project_rate_date_type
			 , peia.project_exchange_rate
			 , to_char(peia.project_tp_rate_date, 'yyyy-mm-dd') project_tp_rate_date
			 , to_char(peia.projfunc_tp_rate_date, 'yyyy-mm-dd') projfunc_tp_rate_date
			 , to_char(peia.projfunc_cost_rate_date, 'yyyy-mm-dd') projfunc_cost_rate_date
			 , to_char(peia.recvr_accrual_date, 'yyyy-mm-dd') recvr_accrual_date
			 , to_char(peia.prvdr_accrual_date, 'yyyy-mm-dd') prvdr_accrual_date
			 , to_char(peia.prvdr_accrual_date, 'dd-mmm-yyyy hh24:mi:ss')
			 , '😀😀😀😀😀'
			 , round(peia.acct_raw_cost, 2) cost
			 , round(prd.project_curr_revenue_amt,2) revenue
			 , 100 - (round(round(peia.acct_raw_cost, 2) / round(prd.project_curr_revenue_amt,2),2)*100) markup_percentage
		  from okc_k_headers_all_b okhab
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id
		  join okc_contract_types_tl octt on okhab.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join pjf_tasks_v ptv on pcpl.proj_element_id = ptv.task_id
		  join fun_all_business_units_v fabuv on okhab.org_id = fabuv.bu_id
		  join hr_all_organization_units haou on ppav.carrying_out_organization_id = haou.organization_id
		  join pjb_rev_distributions prd on okhab.id = prd.contract_id and oklb.id = prd.contract_line_id and ppav.project_id = prd.linked_project_id and ptv.task_id = prd.linked_task_id
		  join pjb_bill_trxs pbt on pbt.transaction_id = prd.transaction_id
	 left join pjb_bill_plans_b pbpb on pbt.bill_plan_id = pbpb.bill_plan_id and pbpb.version_type = 'C'
	 left join pjb_bill_plans_tl pbpt on pbpt.bill_plan_id = pbpb.bill_plan_id and pbpt.major_version = pbpb.major_version
	 left join pjb_bill_plans_b pbpb2 on pbt.revenue_plan_id = pbpb2.bill_plan_id and pbpb2.version_type = 'C'
	 left join pjb_bill_plans_tl pbpt2 on pbpt2.bill_plan_id = pbpb2.bill_plan_id and pbpt2.major_version = pbpb2.major_version
	 left join pjc_exp_items_all peia on pbt.transaction_id = peia.expenditure_item_id and pbt.bill_transaction_type_code = 'EI'
	 left join pjb_billing_events pbe on pbt.transaction_id = pbe.event_id and pbt.bill_transaction_type_code = 'EVT'
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id
	 left join pjc_exp_groups_all pega on peia.exp_group_id = pega.exp_group_id
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C'
		   and pcpl.version_type = 'C'
		   and 1 = 1
	  order by prd.creation_date
	  
-- ##############################################################
-- COUNT SHOWING VOLUMES SPLIT BY MARKUP OR NO MARKUP
-- ##############################################################

		select to_char(peia.creation_date, 'yyyy-mm') yyyy_mm
			 , CASE WHEN 100 - (round(round(peia.acct_raw_cost, 2) / round(prd.project_curr_revenue_amt,2),2)*100) <> 0 then 'markup' ELSE 'no markup' end mark
			 , count(*)
		  from okc_k_headers_all_b okhab
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id
		  join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and oklb.id = pcpl.contract_line_id
		  join pjb_rev_distributions prd on okhab.id = prd.contract_id and oklb.id = prd.contract_line_id
		  join pjb_bill_trxs pbt on pbt.transaction_id = prd.transaction_id
	 left join pjc_exp_items_all peia on pbt.transaction_id = peia.expenditure_item_id and pbt.bill_transaction_type_code = 'EI'
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C'
		   and pcpl.version_type = 'C'
		   and 1 = 1
	  group by to_char(peia.creation_date, 'yyyy-mm')
			 , CASE WHEN 100 - (round(round(peia.acct_raw_cost, 2) / round(prd.project_curr_revenue_amt,2),2)*100) <> 0 then 'markup' ELSE 'no markup' end
	  order by 1, 2

-- ##############################################################
-- CONTRACT HEADERS CHECKING AMENDMENT_START_DATE
-- ##############################################################

		select case when to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') < to_char(okhab.start_date, 'yyyy-mm-dd') then 'amendment_before_start'
					when to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') = to_char(okhab.start_date, 'yyyy-mm-dd') then 'amendment_matches_start'
					when to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') > to_char(okhab.start_date, 'yyyy-mm-dd') then 'amendment_after_start'
					when okhab.amendment_effective_date is null then 'no_amendment_date'
					else 'something_else'
			   end amendment_check
			 , count(*) contract_count
			 , min(okhab.contract_number)
			 , max(okhab.contract_number)
			 , min(okhab.major_version)
			 , max(okhab.major_version)
			 , to_char(MIN(okhab.amendment_effective_date),'yyyy-mm-dd') min_amendment_date
			 , to_char(MAX(okhab.amendment_effective_date),'yyyy-mm-dd') max_amendment_date
		  from okc_k_headers_all_b okhab
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = okhab.sts_code and flv_status.lookup_type = 'OKC_STATUS' and flv_status.view_application_id = 0
		 where 1 = 1
		   and flv_status.meaning = 'Active'
		   and okhab.version_type = 'C'
	  group by case when to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') < to_char(okhab.start_date, 'yyyy-mm-dd') then 'amendment_before_start'
					when to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') = to_char(okhab.start_date, 'yyyy-mm-dd') then 'amendment_matches_start'
					when to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') > to_char(okhab.start_date, 'yyyy-mm-dd') then 'amendment_after_start'
					when okhab.amendment_effective_date is null then 'no_amendment_date'
					else 'something_else'
			   end
