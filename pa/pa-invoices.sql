/*
File Name: pa-invoices.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- INVOICE HEADERS
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS LINKED TO CONTRACT LINES AND BILL PLANS
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS - SUMMARY

*/

-- ##############################################################
-- INVOICE HEADERS
-- ##############################################################

		select distinct -- to handle the fact a contract line can be linked to > 1 project task (e.g. line 1 linked to task 1, line 3 linked to task 50)
			   okhab.contract_number
			 , okhab.major_version
			 , okhab.version_type
			 , to_char(okhab.start_date, 'yyyy-mm-dd') start_date
			 , to_char(okhab.end_date, 'yyyy-mm-dd') end_date
			 , to_char(okhab.date_approved, 'yyyy-mm-dd') date_approved
			 , to_char(okhab.date_signed, 'yyyy-mm-dd') date_signed
			 , to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') amendment_effective_date
			 , ppav.segment1 project
			 , pih.invoice_num
			 , pih.invoice_id
			 , pih.invoice_type_code
			 , pih.invoice_currency_code
			 , pih.ra_invoice_number
			 , pih.transfer_status_code
			 , to_char(pih.transferred_date, 'yyyy-mm-dd') transferred_date
			 , to_char(pih.bill_from_date, 'yyyy-mm-dd') bill_from_date
			 , to_char(pih.bill_to_date, 'yyyy-mm-dd') bill_to_date
			 , to_char(pih.invoice_date, 'yyyy-mm-dd') invoice_date
			 , to_char(pih.released_date, 'yyyy-mm-dd') released_date
			 , to_char(pih.creation_date, 'yyyy-mm-dd HH24:MI:SS') inv_created
			 , to_char(pih.gl_date, 'yyyy-mm-dd HH24:MI:SS') gl_date
			 , pih.created_by inv_created_by
			 , pih.billing_type_code
			 , pih.pa_period_name
			 , pih.gl_period_name
			 , pih.invoice_status_code
			 , hp.party_name
			 , hp.party_number
			 , hca.account_number act_no
			 , pih.generation_error_flag
			 , pih.invoice_comment
			 , haou.name org
		  from pjb_invoice_headers pih
	 left join okc_k_headers_all_b okhab on pih.contract_id = okhab.id
	 left join okc_k_lines_b oklb on okhab.id = oklb.chr_id and okhab.major_version = oklb.major_version and sysdate between nvl(oklb.start_date, sysdate-1) and nvl(oklb.end_date, sysdate+1)
	 left join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and okhab.major_version = pcpl.major_version and oklb.id = pcpl.contract_line_id
	 left join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join hz_cust_accounts hca on pih.bill_to_cust_acct_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join hr_all_organization_units haou on haou.organization_id = pih.org_id
		 where 1 = 1
		   and okhab.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and 1 = 1

-- ##############################################################
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS
-- ##############################################################

		select okhab.contract_number
			 , ppav.segment1 project
			 , pih.invoice_num
			 , pih.invoice_type_code
			 , pih.invoice_currency_code
			 , pih.ra_invoice_number
			 , pih.transfer_status_code
			 , to_char(pih.transferred_date, 'yyyy-mm-dd') transferred_date
			 , to_char(pih.bill_from_date, 'yyyy-mm-dd') bill_from_date
			 , to_char(pih.bill_to_date, 'yyyy-mm-dd') bill_to_date
			 , to_char(pih.invoice_date, 'yyyy-mm-dd') invoice_date
			 , to_char(pih.released_date, 'yyyy-mm-dd') released_date
			 , to_char(pih.creation_date, 'yyyy-mm-dd HH24:MI:SS') inv_created
			 , to_char(pih.gl_date, 'yyyy-mm-dd HH24:MI:SS') gl_date
			 , pih.created_by inv_created_by
			 , pih.billing_type_code
			 , pih.pa_period_name
			 , pih.gl_period_name
			 , pih.invoice_status_code
			 , pil.invoice_line_num inv_line
			 , pil.inv_curr_line_amt
			 , pil.invoice_line_desc
			 , pild.bill_transaction_type_code
			 , pild.transaction_id
			 , pild.trns_currency_code
			 , pild.trns_curr_billed_amt
			 , pild.invoice_discount_percentage
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_created
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , round(peia.project_raw_cost,20) project_raw_cost
			 , round(peia.project_burdened_cost,20) project_burdened_cost
			 , round(peia.quantity, 20) quantity
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , peia.burden_sum_dest_run_id
			 , peia.adjusted_expenditure_item_id
			 , peia.net_zero_adjustment_flag
			 , peia.adjustment_type
			 , peia.adjustment_status
		  from pjb_invoice_headers pih
	 left join okc_k_headers_all_b okhab on pih.contract_id = okhab.id
	 left join okc_k_lines_b oklb on okhab.id = oklb.chr_id and okhab.major_version = oklb.major_version -- and sysdate between nvl(oklb.start_date, sysdate-1) and nvl(oklb.end_date, sysdate+1)
	 left join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and okhab.major_version = pcpl.major_version and oklb.id = pcpl.contract_line_id
	 left join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join hz_cust_accounts hca on pih.bill_to_cust_acct_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join hr_all_organization_units haou on haou.organization_id = pih.org_id
	 left join pjb_invoice_lines pil on pih.invoice_id = pil.invoice_id
	 left join pjb_inv_line_dists pild on pil.invoice_line_id = pild.invoice_line_id
	 left join pjc_exp_items_all peia on peia.expenditure_item_id = pild.transaction_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id
	 left join pjb_bill_plans_b pbpb_bill on okhab.id = pbpb_bill.contract_id and oklb.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill.major_version = okhab.major_version
	 left join pjb_bill_plans_tl pbpb_bill_t on pbpb_bill_t.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill_t.major_version = okhab.major_version
	 left join pjf_billing_cycles_b pbcb on pbpb_bill.billing_cycle_id = pbcb.billing_cycle_id
	 left join pjf_billing_cycles_tl pbct on pbcb.billing_cycle_id = pbct.billing_cycle_id
	 left join pjb_billing_methods_b pbmb_bill on pbmb_bill.bill_method_id = pbpb_bill.bill_method_id
	 left join pjb_billing_methods_tl pbmt_bill on pbmt_bill.bill_method_id = pbmb_bill.bill_method_id
	 left join pjb_bill_rate_ovrrds pbro_bill on pbro_bill.bill_plan_id = pbpb_bill.bill_plan_id and pbro_bill.major_version = okhab.major_version
	 left join pjf_exp_types_tl petl_bill on pbro_bill.expenditure_type_id = petl_bill.expenditure_type_id
		 where 1 = 1
		   and okhab.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and 1 = 1

-- ##############################################################
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS LINKED TO CONTRACT LINES AND BILL PLANS
-- ##############################################################

		select okhab.contract_number
			 , okhab.created_by contract_created_by
			 , okhab.major_version contract_ver
			 , okhab.version_type
			 , okhab.contribution_percent
			 , to_char(okhab.date_approved, 'yyyy-mm-dd') date_approved
			 , to_char(okhab.date_signed, 'yyyy-mm-dd') date_signed
			 , to_char(okhab.amendment_effective_date, 'yyyy-mm-dd') amendment_effective_date
			 , pbpb_bill_t.bill_plan_name
			 , pbmt_bill.bill_method_name invoice_method_name
			 , pbpb_bill_t.created_by bill_plan_created_by
			 , decode(pbpb_bill.bill_type_class_code, 'PERCENT_COMPLETE', 'Percent Complete', 'AS_INCURRED', 'As Incurred', 'AS_BILLED', 'As Billed', 'AMOUNT_BASED', 'Amount Based', 'RATE_BASED', 'Rate Based', 'PERCENT_SPENT', 'Percent Spent') inv_method_classification
			 , pbpb_bill.labor_discount_percentage labor_discount
			 , pbpb_bill.nl_discount_percentage non_labor_discount
			 , to_char(pbpb_bill.creation_date, 'yyyy-mm-dd HH24:MI:SS') bill_plan_created
			 , to_char(pbpb_bill.last_update_date, 'yyyy-mm-dd HH24:MI:SS') bill_plan_updated
			 , ppav.segment1 project
			 , pih.invoice_num
			 , pih.invoice_type_code
			 , pih.invoice_currency_code
			 , pih.ra_invoice_number
			 , pih.transfer_status_code
			 , to_char(pih.transferred_date, 'yyyy-mm-dd') transferred_date
			 , to_char(pih.bill_from_date, 'yyyy-mm-dd') bill_from_date
			 , to_char(pih.bill_to_date, 'yyyy-mm-dd') bill_to_date
			 , to_char(pih.invoice_date, 'yyyy-mm-dd') invoice_date
			 , to_char(pih.released_date, 'yyyy-mm-dd') released_date
			 , to_char(pih.creation_date, 'yyyy-mm-dd HH24:MI:SS') inv_created
			 , to_char(pih.gl_date, 'yyyy-mm-dd HH24:MI:SS') gl_date
			 , pih.created_by inv_created_by
			 , pih.billing_type_code
			 , pih.pa_period_name
			 , pih.gl_period_name
			 , pih.invoice_status_code
			 , pil.invoice_line_num inv_line
			 , pil.inv_curr_line_amt
			 , pil.invoice_line_desc
			 , pild.inv_line_dist_num
			 , pild.bill_transaction_type_code
			 , pild.transaction_id
			 , pild.trns_currency_code
			 , pild.trns_curr_billed_amt
			 , pild.invoice_discount_percentage
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , ptdet.doc_entry_name exp_document_entry
			 , ptdt.document_name exp_document
			 , to_char(peia.creation_date, 'yyyy-mm-dd hh24:mi:ss') exp_item_created
			 , to_char(peia.expenditure_item_date, 'yyyy-mm-dd') cost_item_date
			 , round(peia.project_raw_cost,20) project_raw_cost
			 , round(peia.project_burdened_cost,20) project_burdened_cost
			 , round(peia.quantity, 20) quantity
			 , peia.billable_flag
			 , peia.revenue_hold_flag
			 , peia.revenue_recognized_flag
			 , peia.denom_currency_code
			 , peia.acct_currency_code
			 , peia.burden_sum_dest_run_id
			 , peia.adjusted_expenditure_item_id
			 , peia.net_zero_adjustment_flag
			 , peia.adjustment_type
			 , peia.adjustment_status
			 , '-- bill plan override --'
			 , pbro_bill.discount_percentage
			 , pbro_bill.contract_line_id override_contr_line_id
			 , pbro_bill.rate_override_type_code
			 , pbro_bill.creation_date pbro_created
			 , pbro_bill.created_by pbro_created_by
			 , to_char(pbro_bill.start_date_active, 'yyyy-mm-dd') pbro_start
			 , to_char(pbro_bill.end_date_active, 'yyyy-mm-dd') pbro_end
			 , petl_bill.expenditure_type_name override_exp_type
		  from pjb_invoice_headers pih
	 left join okc_k_headers_all_b okhab on pih.contract_id = okhab.id
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and oklb.major_version = okhab.major_version
	 left join pjb_bill_plans_b pbpb_bill on okhab.id = pbpb_bill.contract_id and oklb.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill.major_version = okhab.major_version
	 left join pjb_bill_plans_tl pbpb_bill_t on pbpb_bill_t.bill_plan_id = pbpb_bill.bill_plan_id and pbpb_bill_t.major_version = okhab.major_version
	 left join pjb_billing_methods_b pbmb_bill on pbmb_bill.bill_method_id = pbpb_bill.bill_method_id
	 left join pjb_billing_methods_tl pbmt_bill on pbmt_bill.bill_method_id = pbmb_bill.bill_method_id
	 left join pjb_bill_rate_ovrrds pbro_bill on pbro_bill.bill_plan_id = pbpb_bill.bill_plan_id and pbro_bill.major_version = okhab.major_version
	 left join pjf_exp_types_tl petl_bill on pbro_bill.expenditure_type_id = petl_bill.expenditure_type_id
	 left join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and okhab.major_version = pcpl.major_version and oklb.id = pcpl.contract_line_id
	 left join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join hz_cust_accounts hca on pih.bill_to_cust_acct_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join hr_all_organization_units haou on haou.organization_id = pih.org_id
	 left join pjb_invoice_lines pil on pih.invoice_id = pil.invoice_id
	 left join pjb_inv_line_dists pild on pil.invoice_line_id = pild.invoice_line_id
	 left join pjc_exp_items_all peia on peia.expenditure_item_id = pild.transaction_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id

		 where 1 = 1
		   and okhab.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and 1 = 1

-- ##############################################################
-- INVOICE HEADERS, LINES AND DISTRIBUTIONS - SUMMARY
-- ##############################################################

		select okhab.contract_number
			 , ppav.segment1 project
			 , pih.invoice_num
			 , ptst.user_transaction_source trx_source
			 , petl.expenditure_type_name exp_type
			 , count(*)
		  from pjb_invoice_headers pih
	 left join okc_k_headers_all_b okhab on pih.contract_id = okhab.id
	 left join okc_k_lines_b oklb on okhab.id = oklb.chr_id and okhab.major_version = oklb.major_version -- and sysdate between nvl(oklb.start_date, sysdate-1) and nvl(oklb.end_date, sysdate+1)
	 left join pjb_cntrct_proj_links pcpl on okhab.id = pcpl.contract_id and okhab.major_version = pcpl.major_version and oklb.id = pcpl.contract_line_id
	 left join pjf_projects_all_vl ppav on pcpl.project_id = ppav.project_id
	 left join hz_cust_accounts hca on pih.bill_to_cust_acct_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join hr_all_organization_units haou on haou.organization_id = pih.org_id
	 left join pjb_invoice_lines pil on pih.invoice_id = pil.invoice_id
	 left join pjb_inv_line_dists pild on pil.invoice_line_id = pild.invoice_line_id
	 left join pjc_exp_items_all peia on peia.expenditure_item_id = pild.transaction_id
	 left join pjf_exp_types_tl petl on peia.expenditure_type_id = petl.expenditure_type_id
	 left join pjf_txn_sources_tl ptst on peia.transaction_source_id = ptst.transaction_source_id
	 left join pjf_txn_doc_entry_tl ptdet on ptdet.doc_entry_id = peia.doc_entry_id
	 left join pjf_txn_document_tl ptdt on ptdt.document_id = peia.document_id
		 where 1 = 1
		   and okhab.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and 1 = 1
	  group by okhab.contract_number
			 , ppav.segment1
			 , pih.invoice_num
			 , ptst.user_transaction_source
			 , petl.expenditure_type_name
