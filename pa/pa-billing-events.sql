/*
File Name: pa-billing-events.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- BILLING EVENTS 1
-- BILLING EVENTS 2 - LINKED TO REVENUE PLAN
-- SUMMARY

*/

-- ##############################################################
-- BILLING EVENTS 1
-- ##############################################################

		select okhab.contract_number
			 , pbe.event_num event_number
			 , ppav.segment1 project
			 , ptv2.task_number associated_task_num
			 , ptv1.task_number trx_task_num
			 , to_char(pbe.creation_date, 'yyyy-mm-dd hh24:mi:ss') event_created
			 , to_char(pbe.completion_date, 'yyyy-mm-dd') completion_date
			 , pbe.event_id
			 , pbe.adjust_desc
			 , pbe.bill_trns_amount
			 , pbe.bill_trns_currency_code
			 , pbe.bill_hold_flag
			 , pbe.revenue_hold_flag
			 , pbe.contract_curr_amt
			 , pbe.contract_curr_code
			 , pbe.invoiced_flag
			 , pbe.invoice_currency_code
			 , pbe.invoiced_amt
			 , pbe.invoiced_percentage
			 , pbe.revenue_recognzd_flag
			 , pbe.revenue_currency_code
			 , pbe.revenue_amt
			 , pbe.ledger_currency_code
			 , pbe.ledger_revenue_amt
			 , pbe.ledger_invoice_amt
			 , pbe.request_id
			 , petl.event_type_name event_type
			 , petl.description event_type_description
			 , '############'
			 , to_char(peaa.activity_date, 'yyyy-mm-dd') adj_activity_date
			 , peaa.adjustment_type
			 , peaa.module_code
			 , peaa.adj_origin
			 , peaa.request_id adj_request_id
			 , peaa.job_definition_name
			 , peaa.job_definition_package
			 , to_char(peaa.creation_date, 'yyyy-mm-dd hh24:mi:ss') adj_created
			 , peaa.created_by adj_created_by
		  from okc_k_headers_all_b okhab
		  join pjb_billing_events pbe on pbe.contract_id = okhab.contract_id
		  join pjf_projects_all_vl ppav on pbe.project_id = ppav.project_id
		  join pjf_tasks_v ptv1 on pbe.task_id = ptv1.task_id
		  join pjf_tasks_v ptv2 on pbe.linked_task_id = ptv2.task_id
		  join pjf_event_types_tl petl on petl.event_type_id = pbe.event_type_id and petl.language = userenv('lang')
	 left join pjb_event_adj_activities peaa on peaa.event_id = pbe.event_id
		 where 1 = 1
		   and okhab.version_type = 'C'
	  order by pbe.creation_date desc

-- ##############################################################
-- BILLING EVENTS 2 - LINKED TO REVENUE PLAN
-- ##############################################################

		select okhab.contract_number
			 , octt.name agreement_type
			 , oklb.line_number contract_line_number
			 , pbe.event_num event_number
			 , ppav.segment1 project
			 , ptv2.task_number associated_task_num
			 , ptv1.task_number trx_task_num
			 , to_char(pbe.creation_date, 'yyyy-mm-dd hh24:mi:ss') event_created
			 , to_char(pbe.completion_date, 'yyyy-mm-dd') completion_date
			 , pbe.event_id
			 -- , pbe.event_desc
			 , pbe.adjust_desc
			 , pbe.bill_trns_amount
			 , pbe.bill_trns_currency_code
			 , pbe.bill_hold_flag
			 , pbe.revenue_hold_flag
			 , pbe.contract_curr_amt
			 , pbe.contract_curr_code
			 , pbe.invoiced_flag
			 , pbe.invoice_currency_code
			 , pbe.invoiced_amt
			 , pbe.invoiced_percentage
			 , pbe.revenue_recognzd_flag
			 , pbe.revenue_currency_code
			 , pbe.revenue_amt
			 , pbe.ledger_currency_code
			 , pbe.ledger_revenue_amt
			 , pbe.ledger_invoice_amt
			 , pbe.request_id
			 , petl.event_type_name event_type
			 , petl.description event_type_description
			 , '-- revenue plan --'
			 , pbpb_rev_t.bill_plan_name revenue_plan
			 , pbmt_rev.bill_method_name revenue_method_name
			 , pbmt_rev.created_by rev_plan_created_by
			 , decode(pbpb_rev.bill_type_class_code, 'PERCENT_COMPLETE', 'Percent Complete', 'AS_INCURRED', 'As Incurred', 'AS_BILLED', 'As Billed', 'AMOUNT_BASED', 'Amount Based', 'RATE_BASED', 'Rate Based', 'PERCENT_SPENT', 'Percent Spent') rev_method_classification
		  from okc_k_headers_all_b okhab
		  join pjb_billing_events pbe on pbe.contract_id = okhab.contract_id
		  join pjf_projects_all_vl ppav on pbe.project_id = ppav.project_id
		  join pjf_tasks_v ptv1 on pbe.task_id = ptv1.task_id
		  join pjf_tasks_v ptv2 on pbe.linked_task_id = ptv2.task_id
		  join pjf_event_types_tl petl on petl.event_type_id = pbe.event_type_id and petl.language = userenv('lang')
		  join okc_contract_types_tl octt on pbe.contract_type_id = octt.contract_type_id and octt.language = userenv('lang')
		  join okc_k_lines_b oklb on okhab.id = oklb.chr_id and okhab.major_version = oklb.major_version -- and sysdate between nvl(oklb.start_date, sysdate-1) and nvl(oklb.end_date, sysdate+1)
		  join okc_k_lines_tl oklt on oklb.id = oklt.id and oklb.line_id = pbe.contract_line_id and oklt.language = userenv('lang')
	 left join pjb_bill_plans_b pbpb_rev on okhab.id = pbpb_rev.contract_id and oklb.revenue_plan_id = pbpb_rev.bill_plan_id
	 left join pjb_bill_plans_tl pbpb_rev_t on pbpb_rev_t.bill_plan_id = pbpb_rev.bill_plan_id and pbpb_rev_t.major_version = pbpb_rev.major_version and pbpb_rev_t.language = userenv('lang')
	 left join pjb_billing_methods_b pbmb_rev on pbmb_rev.bill_method_id = pbpb_rev.bill_method_id
	 left join pjb_billing_methods_tl pbmt_rev on pbmt_rev.bill_method_id = pbmb_rev.bill_method_id and pbmt_rev.language = userenv('lang')
		 where 1 = 1
		   and okhab.version_type = 'C'
		   and oklb.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and oklt.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
		   and pbpb_rev.version_type = 'C' -- current (can be (c)urrent, (a)mendment or (h)istory
	  order by pbe.creation_date desc

-- ##############################################################
-- SUMMARY
-- ##############################################################

		select petl.event_type_name
			 , petl.description
			 , petb.revenue_flag
			 , petb.invoice_flag
			 , flv_cat.meaning revenue_category
			 , count(pbe.event_id)
			 , sum(invoiced_amt)
			 , sum(revenue_amt)
		  from pjf_event_types_tl petl
		  join pjf_event_types_b petb on petl.event_type_id = petb.event_type_id and petl.language = userenv('lang')
		  join fnd_lookup_values_vl flv_cat on flv_cat.lookup_code = petb.revenue_category_code and flv_cat.lookup_type = 'PJF_REVENUE_CATEGORY' and flv_cat.view_application_id = 0
	 left join pjb_billing_events pbe on petl.event_type_id = pbe.event_type_id
		 where sysdate between nvl(petb.start_date_active, sysdate-1) and nvl(petb.end_date_active, sysdate+1)
	  group by petl.event_type_name
			 , petl.description
			 , petb.revenue_flag
			 , petb.invoice_flag
			 , flv_cat.meaning
	  order by petl.event_type_name
