/*
File Name: iex.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- STRATEGY ATTEMPT 1
-- STRATEGY ATTEMPT 2
-- STRATEGY ATTEMPT 3
-- STRATEGY ATTEMPT 4
-- STRATEGY ATTEMPT 5
-- DELINQUENCY SUMMARIES ALL
-- COUNT IEX_STRATEGY_WORK_ITEMS BY CREATION DATE
-- COUNT IEX_STRATEGY_WORK_ITEMS BY CREATED BY
-- COUNT IEX_STRATEGY_WORK_ITEMS BY STATUS
-- DUNNINGS ATTEMPT
-- COUNT DUNNINGS BY CREATION DATA
-- STRATEGY SUMMARY COUNT 1
-- STRATEGY SUMMARY COUNT 2
-- STRATEGY SUMMARY COUNT 3 - BY DATE
-- STRATEGY SUMMARY COUNT 4 - BY STATUS
-- STRATEGIES ASSIGNED TO CUSTOMER 1
-- STRATEGIES ASSIGNED TO CUSTOMER 2
-- COMPARE PROFILE IN AR AGAINST CUSTOMER WITH PROFILE IN COLLECTIONS AGAINST CUSTOMER
-- SQL TO REPORT ON TO BE CREATED STRATEGY TASKS FOR TRANSACTION
-- DUNNING SETUP TABLE

*/

-- ##################################################################
-- STRATEGY ATTEMPT 1
-- ##################################################################

			select '#' || iswi.work_item_id work_item_id
				 , '#' || iswi.strategy_id strategy_id 
				 , '#' || iswi.work_item_template_id work_item_template_id 
				 , '#' || iswi.resource_id resource_id 
				 , '#' || iswi.payment_schedule_id payment_schedule_id 
				 , istwit.name template_name
				 , iswi.status_code
				 , to_char(iswi.execute_start, 'yyyy-mm-dd hh24:mi:ss') execute_start
				 , to_char(iswi.execute_end, 'yyyy-mm-dd hh24:mi:ss') execute_end
				 , to_char(iswi.schedule_start, 'yyyy-mm-dd hh24:mi:ss') schedule_start
				 , to_char(iswi.schedule_end, 'yyyy-mm-dd hh24:mi:ss') schedule_end
				 , to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
				 , iswi.created_by
				 , iswi.request_id
				 , iswi.work_item_order
				 , iswi.uwq_status
				 , iswi.pre_execution_wait
				 , iswi.pre_execution_time_uom
				 , iswi.execution_time_uom
				 , iswi.post_execution_wait
				 , iswi.xdo_temp_id
				 , iswi.optional_yn
				 , iswi.optional_wait_time
				 , iswi.optional_wait_time_uom
				 , iswi.escalate_yn
				 , iswi.escalate_wait_time
				 , iswi.escalate_wait_time_uom
				 , iswi.custom_workflow_type
				 , rcta.trx_number
				 , '#' || rcta.customer_trx_id trx_id
				 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_created
				 , rcta.created_by trx_created_by
				 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
				 , rcta.complete_flag complete
				 , rbsa.name trx_source
				 , rctta.name trx_type
				 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
				 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
				 , hp_bill.party_name bill_cust
				 , hca_bill.account_number bill_acct
			  from iex_strategy_work_items iswi
		 left join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		 left join ar_payment_schedules_all apsa on iswi.payment_schedule_id = apsa.payment_schedule_id
		 left join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		 left join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		 left join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		 left join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id
			 where 1 = 1
			   and 1 = 1
	  order by to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##################################################################
-- STRATEGY ATTEMPT 2
-- ##################################################################

		select rcta.trx_number
			 , '#' || rcta.customer_trx_id trx_id
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_created
			 , rcta.created_by trx_created_by
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , rcta.complete_flag complete
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 , hp_bill.party_name bill_cust
			 , hca_bill.account_number bill_acct
			 , istwit.name template_name
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.payment_schedule_id = apsa.payment_schedule_id
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		 where 1 = 1
		   and 1 = 1
	  order by to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##################################################################
-- STRATEGY ATTEMPT 3
-- ##################################################################

		select '#' || iswi.work_item_id work_item_id
			 , '#' || iswi.strategy_id strategy_id 
			 , '#' || iswi.work_item_template_id work_item_template_id 
			 , '#' || iswi.resource_id resource_id 
			 , istwit.name template_name
			 , iswi.status_code
			 , to_char(iswi.execute_start, 'yyyy-mm-dd hh24:mi:ss') execute_start
			 , to_char(iswi.execute_end, 'yyyy-mm-dd hh24:mi:ss') execute_end
			 , to_char(iswi.schedule_start, 'yyyy-mm-dd hh24:mi:ss') schedule_start
			 , to_char(iswi.schedule_end, 'yyyy-mm-dd hh24:mi:ss') schedule_end
			 , to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , iswi.created_by
			 , iswi.request_id
			 , iswi.work_item_order
			 , iswi.uwq_status
			 , iswi.pre_execution_wait
			 , iswi.pre_execution_time_uom
			 , iswi.execution_time_uom
			 , iswi.post_execution_wait
			 , iswi.xdo_temp_id
			 , iswi.optional_yn
			 , iswi.optional_wait_time
			 , iswi.optional_wait_time_uom
			 , iswi.escalate_yn
			 , iswi.escalate_wait_time
			 , iswi.escalate_wait_time_uom
			 , iswi.custom_workflow_type
		  from iex_strategy_work_items iswi
		  join istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##################################################################
-- STRATEGY ATTEMPT 4
-- ##################################################################

		select rcta.trx_number
			 , '#' || rcta.customer_trx_id trx_id
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') trx_created
			 , rcta.created_by trx_created_by
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , rcta.complete_flag complete
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 , hp_bill.party_name bill_cust
			 , hca_bill.account_number bill_acct
			 , istwit.name template_name
			 , '#' || iswi.work_item_id work_item_id
		  from IEX_STRATEGY_WORK_ITEMS iswi
		  join IEX_STRY_TEMP_WORK_ITEMS_TL istwit on istwit.WORK_ITEM_TEMP_ID = iswi.WORK_ITEM_TEMPLATE_ID and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		 where 1 = 1
		   and 1 = 1

-- ##################################################################
-- STRATEGY ATTEMPT 5
-- ##################################################################

/*
Does not include Strategy Tasks which have a To Be Completed status as they don't seem to appear in the IEX_STRATEGY_WORK_ITEMS table
*/

		select rcta.trx_number trx
			 , hca_bill.account_number acct
			 , hp_bill.party_name cust
			 , idsa.display_name
			 , hps.party_site_number site_num
			 , hcsua.location bill_to_site_num
			 , haou.name org
			 , idsa.number_delinquencies delinq_sum_num_del_trxns
			 , idsa.total_amount_due delinq_sum_total_amt_due_cust
			 , istwit.name template
			 , to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss') task_created
			 , iswi.created_by task_created_by
			 , iswi.status_code task_status
			 , to_char(iswi.execute_start, 'yyyy-mm-dd hh24:mi:ss') execute_start
			 , to_char(iswi.execute_end, 'yyyy-mm-dd hh24:mi:ss') execute_end
			 , to_char(iswi.schedule_start, 'yyyy-mm-dd hh24:mi:ss') schedule_start
			 , to_char(iswi.schedule_end, 'yyyy-mm-dd hh24:mi:ss') schedule_end
			 , iswi.request_id
			 , apsa.amount_due_remaining pay_sched_amt_remaining
			 , '#' || hca_bill.cust_account_id cust_id
			 , '#' || rcta.customer_trx_id trx_id
			 , '#' || apsa.payment_schedule_id apsa_id
			 , '#' || ida.delinquency_id delq_id
			 , '#' || iswi.work_item_id item_id
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join iex_delinquencies_all ida on ida.payment_schedule_id = apsa.payment_schedule_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca_bill.cust_account_id = hcasa.cust_account_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca_bill.cust_account_id and idsa.SITE_USE_ID = hcsua.site_use_id
		 where 1 = 1
		   and 1 = 1

-- ##################################################################
-- DELINQUENCY SUMMARIES ALL
-- ##################################################################

/*
Does not include Strategy Tasks which have a To Be Completed status as they don't seem to appear in the IEX_STRATEGY_WORK_ITEMS table
*/

		select rcta.trx_number trx
			 , hca_bill.account_number acct
			 , hp_bill.party_name cust
			 , idsa.display_name
			 , hps.party_site_number site_num
			 , hcsua.location bill_to_site_num
			 , haou.name org
			 , idsa.number_delinquencies delinq_sum_num_del_trxns
			 , idsa.total_amount_due delinq_sum_total_amt_due_cust
		  from iex_delinq_summaries_all idsa
		  join hz_cust_accounts hca_bill on idsa.cust_account_id = hca_bill.cust_account_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = idsa.site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca_bill.cust_account_id = hcasa.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		 where 1 = 1
		   and 1 = 1

-- ##################################################################
-- COUNT IEX_STRATEGY_WORK_ITEMS BY CREATION DATE
-- ##################################################################

		select to_char(iswi.creation_date, 'yyyy-mm-dd') creation_date
			 , count(*)
		  from iex_strategy_work_items iswi
		 where 1 = 1
		   and 1 = 1
	  group by to_char(iswi.creation_date, 'yyyy-mm-dd')
	  order by to_char(iswi.creation_date, 'yyyy-mm-dd') desc

-- ##################################################################
-- COUNT IEX_STRATEGY_WORK_ITEMS BY CREATED BY
-- ##################################################################

		select iswi.created_by
			 , min(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_date
			 , max(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_data
			 , count(*)
		  from iex_strategy_work_items iswi
		 where 1 = 1
		   and 1 = 1
	  group by iswi.created_by

-- ##################################################################
-- COUNT IEX_STRATEGY_WORK_ITEMS BY STATUS
-- ##################################################################

		select iswi.status_code
			 , min(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_date
			 , max(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_data
			 , count(*)
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by iswi.status_code

-- ##################################################################
-- DUNNINGS ATTEMPT
-- ##################################################################

		select hp.party_name party_name___
			 , hca.account_number account_number___
			 , hps.party_site_number
			 , hcsua.status site_use_status
			 , hcsua.site_use_code
			 , hcsua.location
			 , hcsua.primary_flag
			 , fabuv.bu_name bu
			 , rcta.trx_number
			 , rctta.name trx_type
			 , rbsa.name trx_source
			 , to_char(dunn.creation_date, 'yyyy-mm-dd hh24:mi:ss') dunning_created
			 , dunn.created_by dunning_created_by
			 , dunn.request_id dunning_request_id
			 , dunn.xml_request_id
			 , dunn.letter_name
			 , dunn.status
			 , dunn.dunning_method
			 , dunn.amount_due_remaining dunn_remaining
			 , apsa.amount_due_remaining apsa_remaining
			 , dunn.dunning_level
			 , dunn.delivery_status
			 , dunn.contact_destination
			 , dunn.contact_party_id
			 , dunn.party_location_id
			 , hca.cust_account_id
			 , '#' || dunn.dunning_id dunning_id
			 , '#' || idt.dunning_trx_id dunning_trx_id
		  from fusion.iex_dunnings dunn
		  join fusion.iex_dunning_transactions idt on dunn.dunning_id = idt.dunning_id
		  join fun_all_business_units_v fabuv on dunn.bu_id = fabuv.bu_id
		  join hz_cust_accounts hca on dunn.cust_account_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = idt.cust_trx_id
		  join ar_payment_schedules_all apsa on idt.payment_schedule_id = apsa.payment_schedule_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join hz_party_sites hps on hp.party_id = hps.party_id
		  join hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id and hca.cust_account_id = hcasa.cust_account_id
		  join hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id and dunn.site_use_id = hcsua.site_use_id
		 where 1 = 1
		   and 1 = 1
	  order by dunn.creation_date desc

-- ##################################################################
-- COUNT DUNNINGS BY CREATION DATA
-- ##################################################################

		select to_char(dunn.creation_date, 'yyyy-mm') dunning_created
			 , count(*) ct
		  from fusion.iex_dunnings dunn
	 left join fusion.iex_dunning_transactions idt on dunn.dunning_id = idt.dunning_id
	 left join fun_all_business_units_v fabuv on dunn.bu_id = fabuv.bu_id
		  join hz_cust_accounts hca on dunn.cust_account_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = idt.CUST_TRX_ID
		  join ar_payment_schedules_all apsa on idt.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		 where 1 = 1
		   and 1 = 1
	  group by to_char(dunn.creation_date, 'yyyy-mm')

-- ##################################################################
-- STRATEGY SUMMARY COUNT 1
-- ##################################################################

/*
Does not include Strategy Tasks which have a To Be Completed status as they don't seem to appear in the IEX_STRATEGY_WORK_ITEMS table
*/

		select rcta.trx_number trx
			 , hca_bill.account_number acct
			 , hp_bill.party_name cust
			 , idsa.display_name
			 , hps.party_site_number site_num
			 , hcsua.location
			 , count(distinct iswi.work_item_id) tasks
			 , haou.name org
			 , idsa.number_delinquencies num_del
			 , '#' || hca_bill.cust_account_id cust_id
			 , '#' || rcta.customer_trx_id trx_id
			 , sum(apsa.amount_due_remaining) amt_due
			 , min(istwit.name) min_templ
			 , max(istwit.name) max_templ
			 , min('#' || apsa.payment_schedule_id) min_apsa_id
			 , max('#' || apsa.payment_schedule_id) max_apsa_id
			 , min('#' || ida.delinquency_id) min_del_id
			 , max('#' || ida.delinquency_id) max_del_id
			 , min('#' || iswi.work_item_id) min_item_id
			 , max('#' || iswi.work_item_id) max_item_id
			 , min('#' || iswi.strategy_id) min_strat_id
			 , max('#' || iswi.strategy_id) max_strat_id
			 , min(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_task_created
			 , max(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_task_created
			 , min(iswi.created_by) min_task_created_by
			 , max(iswi.created_by) max_task_created_by
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join iex_delinquencies_all ida on ida.payment_schedule_id = apsa.payment_schedule_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca_bill.cust_account_id = hcasa.cust_account_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca_bill.cust_account_id and idsa.SITE_USE_ID = hcsua.site_use_id
		 where 1 = 1
		   and ida.status = 'DELINQUENT'
		   and apsa.amount_due_remaining > 0
		   and iswi.status_code not in ('CANCELLED')
		   and 1 = 1
	  group by rcta.trx_number
			 , hp_bill.party_name
			 , hca_bill.account_number
			 , haou.name
			 , idsa.number_delinquencies
			 , idsa.display_name
			 , '#' || hca_bill.cust_account_id
			 , '#' || rcta.customer_trx_id
			 , hps.party_site_number
			 , hcsua.location
		-- having count(distinct iswi.work_item_id) > 1
  order by 21 desc

-- ##################################################################
-- STRATEGY SUMMARY COUNT 2
-- ##################################################################

/*
Does not include Strategy Tasks which have a To Be Completed status as they don't seem to appear in the IEX_STRATEGY_WORK_ITEMS table
*/

		select istwit.name template
			 , min(rcta.trx_number) min_trx
			 , max(rcta.trx_number) max_trx
			 , min(hca_bill.account_number) min_acct
			 , max(hca_bill.account_number) max_acct
			 , min(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_task_created
			 , max(to_char(iswi.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_task_created
			 , min(iswi.created_by) min_task_created_by
			 , max(iswi.created_by) max_task_created_by
			 , min(iswi.status_code) min_task_status
			 , max(iswi.status_code) max_task_status
			 , min(to_char(iswi.execute_start, 'yyyy-mm-dd hh24:mi:ss')) min_execute_start
			 , to_char(iswi.execute_end, 'yyyy-mm-dd hh24:mi:ss')) max_execute_end
			 , to_char(iswi.schedule_start, 'yyyy-mm-dd hh24:mi:ss')) min_schedule_start
			 , to_char(iswi.schedule_end, 'yyyy-mm-dd hh24:mi:ss')) max_schedule_end
			 , min(iswi.request_id) min_request_id
			 , max(iswi.request_id) max_request_id
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join iex_delinquencies_all ida on ida.payment_schedule_id = apsa.payment_schedule_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca_bill.cust_account_id = hcasa.cust_account_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca_bill.cust_account_id and idsa.SITE_USE_ID = hcsua.site_use_id
		 where 1 = 1
		   and ida.status = 'DELINQUENT'
		   and apsa.amount_due_remaining > 0
		   and iswi.status_code not in ('CANCELLED')
		   and 1 = 1
	  group by istwit.name
			 , iswi.status_code

-- ##################################################################
-- STRATEGY SUMMARY COUNT 3 - BY DATE
-- ##################################################################

/*
Does not include Strategy Tasks which have a To Be Completed status as they don't seem to appear in the IEX_STRATEGY_WORK_ITEMS table
*/

		select to_char(iswi.creation_date, 'yyyy-mm-dd') creation_date 
			 , istwit.name template
			 , iswi.status_code task_status
			 , min(rcta.trx_number) min_trx
			 , max(rcta.trx_number) max_trx
			 , min(hca_bill.account_number) min_acct
			 , max(hca_bill.account_number) max_acct
			 , min(iswi.created_by) min_task_created_by
			 , max(iswi.created_by) max_task_created_by
			 , min(iswi.status_code) min_task_status
			 , max(iswi.status_code) max_task_status
			 , min(iswi.request_id) min_request_id
			 , max(iswi.request_id) max_request_id
			 , count(*) ct
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join iex_delinquencies_all ida on ida.payment_schedule_id = apsa.payment_schedule_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca_bill.cust_account_id = hcasa.cust_account_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca_bill.cust_account_id and idsa.SITE_USE_ID = hcsua.site_use_id
		 where 1 = 1
		   and ida.status = 'DELINQUENT'
		   and apsa.amount_due_remaining > 0
		   and iswi.status_code not in ('CANCELLED')
		   and 1 = 1
	  group by to_char(iswi.creation_date, 'yyyy-mm-dd') 
			 , istwit.name
			 , iswi.status_code
	  order by to_char(iswi.creation_date, 'yyyy-mm-dd') desc

-- ##################################################################
-- STRATEGY SUMMARY COUNT 4 - BY STATUS
-- ##################################################################

/*
Does not include Strategy Tasks which have a To Be Completed status as they don't seem to appear in the IEX_STRATEGY_WORK_ITEMS table
*/

		select istwit.name template
			 , iswi.status_code task_status
			 , min(rcta.trx_number) min_trx
			 , max(rcta.trx_number) max_trx
			 , min(hca_bill.account_number) min_acct
			 , max(hca_bill.account_number) max_acct
			 , min(iswi.created_by) min_task_created_by
			 , max(iswi.created_by) max_task_created_by
			 , min(iswi.status_code) min_task_status
			 , max(iswi.status_code) max_task_status
			 , min(iswi.request_id) min_request_id
			 , max(iswi.request_id) max_request_id
			 , min(to_char(iswi.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(iswi.creation_date, 'yyyy-mm-dd')) max_created
			 , count(*) ct
		  from iex_strategy_work_items iswi
		  join iex_stry_temp_work_items_tl istwit on istwit.work_item_temp_id = iswi.work_item_template_id and istwit.language = userenv('lang')
		  join ar_payment_schedules_all apsa on iswi.PAYMENT_SCHEDULE_ID = apsa.PAYMENT_SCHEDULE_ID
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = apsa.customer_trx_id
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca_bill on rcta.bill_to_customer_id = hca_bill.cust_account_id
		  join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join iex_delinquencies_all ida on ida.payment_schedule_id = apsa.payment_schedule_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca_bill.cust_account_id = hcasa.cust_account_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca_bill.cust_account_id and idsa.SITE_USE_ID = hcsua.site_use_id
		 where 1 = 1
		   and ida.status = 'DELINQUENT'
		   and apsa.amount_due_remaining > 0
		   and iswi.status_code not in ('CANCELLED')
		   and 1 = 1
	  group by istwit.name
			 , iswi.status_code

-- ##################################################################
-- STRATEGIES ASSIGNED TO CUSTOMER 1
-- ##################################################################

		select '#' || ixs.strategy_id strategy_id
			 , '#' || ixs.strategy_assignment_matrix_id strategy_assignment_matrix_id
			 , ixs.status_code
			 , '#' || ixs.strategy_template_id strategy_template_id
			 , '#' || ixs.delinquency_id delinquency_id
			 , ixs.object_type
			 , '#' || ixs.cust_account_id cust_account_id
			 , '#' || ixs.party_id party_id
			 , ixs.score_value
			 , '#' || ixs.next_work_item_id next_work_item_id
			 , ixs.request_id
			 , '#' || ixs.checklist_strategy_id checklist_strategy_id
			 , ixs.jtf_object_type
			 , '#' || ixs.customer_site_use_id customer_site_use_id
			 , to_char(ixs.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , ixs.created_by
			 , to_char(ixs.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ixs.last_updated_by
			 , hca.account_number
			 , hp.party_name
			 , hps.party_site_number site_num
			 , hcsua.location bill_to_site_num
		  from iex_strategies ixs
		  join hz_cust_accounts hca on ixs.cust_account_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = ixs.customer_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca.cust_account_id = hcasa.cust_account_id
		 where 1 = 1
		   and 1 = 1

/*
table dumps
*/

select *
  from IEX_STRATEGIES
 where cust_account_id = 100000043756218

select iswi.*
  from IEX_STRATEGY_WORK_ITEMS iswi
  join ar_payment_schedules_all apsa on iswi.payment_schedule_id = apsa.payment_schedule_id
 where apsa.customer_id = 100000043756218

select iswi.*
  from IEX_STRATEGY_USER_ITEMS iswi
  join ar_payment_schedules_all apsa on iswi.payment_schedule_id = apsa.payment_schedule_id
 where apsa.customer_id = 100000043756218

/*
Manually added Strategy Tasks appear in the IEX_STRATEGY_USER_ITEMS table.
Completed Strategy Tasks appear in the IEX_STRATEGY_WORK_ITEMS table.
Which table stores the Strategy Tasks of type "Automatic" and status of "To Be Created"?
*/

-- ##################################################################
-- STRATEGIES ASSIGNED TO CUSTOMER 2
-- ##################################################################

		select hca.account_number
			 , hp.party_name
			 , hps.party_site_number site_num
			 , hcsua.location bill_to_site_num
			 , isam.strategy_assign_matrix_name
			 , isam.business_level_code
			 , ixs.status_code
			 , ixs.object_type
			 , ixs.score_value
			 , '#' || ixs.next_work_item_id next_work_item_id
			 , ixs.request_id -- Request ID for "Collections Scoring and Strategy Assignment" job
			 , to_char(ixs.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , ixs.created_by
			 , to_char(ixs.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ixs.last_updated_by
		  from iex_strategies ixs
		  join hz_cust_accounts hca on ixs.cust_account_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = ixs.customer_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca.cust_account_id = hcasa.cust_account_id
		  join iex_strategy_assignment_matrix isam on isam.strategy_assignment_matrix_id = ixs.strategy_assignment_matrix_id
		 where 1 = 1
		   and ixs.status_code = 'OPEN'
		   and 1 = 1

-- ##################################################################
-- COMPARE PROFILE IN AR AGAINST CUSTOMER WITH PROFILE IN COLLECTIONS AGAINST CUSTOMER
-- ##################################################################

		select haou.name org
			 , hp.party_name customer_name
			 , hca.account_number
			 , hcsua.site_use_code
			 , hcsua.location bill_to_site_num
			 , ac.name collector_name
			 , hps.party_site_number
			 , hcpc.name profile_class
			 , to_char(hcpf.effective_start_date, 'yyyy-mm-dd') class_start_date
			 , to_char(hcpf.effective_end_date, 'yyyy-mm-dd') class_end_date
			 , to_char(hcpf.creation_date, 'yyyy-mm-dd hh24:mi:ss') customer_profile_created
			 , hcpf.created_by customer_profile_created_by
			 , to_char(hcpf.last_update_date, 'yyyy-mm-dd hh24:mi:ss') customer_profile_last_update_date
			 , hcpf.last_updated_by customer_profile_last_updated_by
			 , '#' iex_strategy_____
			 , '#' || iex_strat.strategy_id strategy_id
			 , to_char(hcpf.creation_date, 'yyyy-mm-dd hh24:mi:ss') strat_created
			 , hcpf.created_by strat_created_by
			 , to_char(hcpf.last_update_date, 'yyyy-mm-dd hh24:mi:ss') strat_updated
			 , hcpf.last_updated_by strat_updated_by
			 , iex_strat.request_id strat_request_id
			 , iex_strat.status_code strat_status_code
			 , '#' iex_strategy_assignment_____
			 , '#' || isam.strategy_assignment_matrix_id isam_matrix_id
			 , to_char(isam.creation_date, 'yyyy-mm-dd hh24:mi:ss') isam_created
			 , isam.created_by isam_created_by
			 , to_char(isam.last_update_date, 'yyyy-mm-dd hh24:mi:ss') isam_updated
			 , isam.last_updated_by isam_updated_by
			 , isam.strategy_assign_matrix_name
			 , '#' profile_class_id_compare____
			 , '#' || hcpf.profile_class_id ar_profile_class_id
			 , '#' || isam.profile_class_id iex_profile_class_id
			 , idsa.display_name
			 , idsa.number_delinquencies delinq_sum_num_del_trxns
			 , idsa.total_amount_due delinq_sum_total_amt_due_cust
		  from hz_cust_accounts hca
		  join hz_parties hp on hp.party_id = hca.party_id
		  join hz_cust_acct_sites_all hcasa on hca.cust_account_id = hcasa.cust_account_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id
		  join hz_customer_profiles_f hcpf on hcpf.cust_account_id = hca.cust_account_id and hcpf.cust_account_id = hcasa.cust_account_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = hcpf.site_use_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join ar_collectors ac on ac.collector_id = hcpf.collector_id
		  join hz_cust_profile_classes hcpc on hcpc.profile_class_id = hcpf.profile_class_id
	 left join iex_strategies iex_strat on iex_strat.cust_account_id = hca.cust_account_id
	 left join iex_strategy_assignment_matrix isam on isam.strategy_assignment_matrix_id = iex_strat.strategy_assignment_matrix_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca.cust_account_id and idsa.site_use_id = hcsua.site_use_id
		  join hr_all_organization_units haou on haou.organization_id = idsa.org_id
		 where 1 = 1
		   and iex_strat.status_code = 'OPEN'
		   and hcpf.profile_class_id != isam.profile_class_id
		   and 1 = 1

-- ##################################################################
-- SQL TO REPORT ON TO BE CREATED STRATEGY TASKS FOR TRANSACTION
-- ##################################################################

/*
SR 3-32940593369 : Daily 35671265 Continuation of 3-32362213321: Automatic Strategy Task has not been executed
*/

SELECT
XREF.WORK_ITEM_ORDER WKITEM_ORDER ,
TEMP_WORK_ITEMS_VL.NAME WKITEM_TEMPLATE_NAME ,
TEMP_WORK_ITEMS_VL.CATEGORY_TYPE CATEGORY ,
'NOTCREATED' STATUS ,
TEMP_WORK_ITEMS_VL.OPTIONAL_YN,
TEMP_WORK_ITEMS_VL.OPTION_WAIT_TIME AS OPTIONAL_WAIT_TIME,
TEMP_WORK_ITEMS_VL.OPTION_WAIT_TIME_UOM AS OPTIONAL_WAIT_TIME_UOM,
TEMP_WORK_ITEMS_VL.PRE_EXECUTION_WAIT,
TEMP_WORK_ITEMS_VL.SCHEDULE_UOM AS PRE_EXECUTION_TIME_UOM,
TEMP_WORK_ITEMS_VL.POST_EXECUTION_WAIT,
TEMP_WORK_ITEMS_VL.EXECUTION_TIME_UOM,
TEMP_WORK_ITEMS_VL.CLOSURE_TIME_LIMIT AS ESCALATE_WAIT_TIME,
TEMP_WORK_ITEMS_VL.CLOSURE_TIME_UOM AS ESCALATE_WAIT_TIME_UOM
FROM IEX_STRATEGIES STRY ,
IEX_STRATEGY_WORK_TEMP_XREF XREF ,
IEX_STRY_TEMP_WORK_ITEMS_VL TEMP_WORK_ITEMS_VL
WHERE STRY.STRATEGY_TEMPLATE_ID = XREF.STRATEGY_TEMP_ID
AND XREF.WORK_ITEM_TEMP_ID = TEMP_WORK_ITEMS_VL.WORK_ITEM_TEMP_ID
AND STRY.STATUS_CODE NOT IN ('CANCELLED','CLOSED')
AND XREF.WORK_ITEM_ORDER >
(SELECT NVL(MAX (WKITEM.WORK_ITEM_ORDER),0)
FROM IEX_STRATEGY_WORK_ITEMS WKITEM
WHERE WKITEM.STRATEGY_ID = STRY.STRATEGY_ID
AND WKITEM.PAYMENT_SCHEDULE_ID = :b_payment_schedule_id)

/*
Next best thing?
*/

		select distinct hca.account_number account_number_
			 , hca.account_name account_name_
			 , xref.work_item_order wkitem_order_
			 , temp_work_items_vl.name wkitem_template_name_
			 , temp_work_items_vl.category_type category_
			 , to_char(xref.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , xref.created_by
			 , to_char(xref.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , xref.last_updated_by
			 , temp_work_items_vl.optional_yn optional_yn_
			 , temp_work_items_vl.option_wait_time as optional_wait_time_
			 , temp_work_items_vl.option_wait_time_uom as optional_wait_time_uom_
			 , temp_work_items_vl.pre_execution_wait pre_execution_wait_
			 , temp_work_items_vl.schedule_uom as pre_execution_time_uom_
			 , temp_work_items_vl.post_execution_wait post_execution_wait_
			 , temp_work_items_vl.execution_time_uom execution_time_uom_
			 , temp_work_items_vl.closure_time_limit as escalate_wait_time_
			 , temp_work_items_vl.closure_time_uom as escalate_wait_time_uom_
			 , temp_work_items_vl.EXECUTION_CONDITION_VALUE
		  from iex_strategies stry
		  join hz_cust_accounts hca on stry.cust_account_id = hca.cust_account_id
		  join iex_strategy_work_temp_xref xref on stry.strategy_template_id = xref.strategy_temp_id
		  join iex_stry_temp_work_items_vl temp_work_items_vl on xref.work_item_temp_id = temp_work_items_vl.work_item_temp_id
		 where 1 = 1
		   and stry.status_code not in ('CANCELLED','CLOSED')
		   and temp_work_items_vl.optional_yn = 'N'
		   -- and stry.cust_account_id = 100000043724465
		   /*and xref.work_item_order > (select nvl(max (wkitem.work_item_order),0) 
										 from iex_strategy_work_items wkitem
										where wkitem.strategy_id = stry.strategy_id
										  and wkitem.payment_schedule_id = :b_payment_schedule_id
										  and 1 = 1)*/

-- ##################################################################
-- DUNNING SETUP TABLE
-- ##################################################################

/*
Oracle Cloud: How to Redirect Dunning Letters to a Testing Email Address. (Doc ID 2630245.1)

Holds send email address etc.

e.g.

Collections Dispute Confirmation Delivery Data Model

SELECT
ied.dunning_id KEY,
ied.letter_name TEMPLATE,
'RTF' TEMPLATE_FORMAT,
ied.locale LOCALE,
'PDF' OUTPUT_FORMAT,
ied.dunning_method DEL_CHANNEL,
decode(ied.dunning_method,'EMAIL',ied.contact_destination) PARAMETER1,
decode(ied.dunning_method,'FAX',ied.contact_destination) PARAMETER2,
 decode(ied.dunning_method,'EMAIL',(SELECT questionnaire_varchar_value FROM iex_questionnaire_items
WHERE questionnaire_code = 'DEFAULT_EMAIL_ADDRESS' 
AND set_id = 0))  PARAMETER3,
decode(ied.dunning_method,'EMAIL',iex_dunning.dunning_letter_subject(ied.locale)) PARAMETER4,
decode(ied.dunning_method,'EMAIL',iex_dunning.dispute_letter_body(ied.locale)) PARAMETER5,
decode(ied.dunning_method,'EMAIL','true') PARAMETER6,
decode(ied.dunning_method,'EMAIL',(SELECT questionnaire_varchar_value FROM iex_questionnaire_items
WHERE questionnaire_code = 'DEFAULT_EMAIL_ADDRESS' 
AND set_id = 0)) PARAMETER7
FROM 
iex_dunnings ied
*/

select * from iex_questionnaire_items
