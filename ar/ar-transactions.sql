/*
File Name: ar-transactions.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- TRANSACTIONS
-- TRANSACTIONS - BILL TO SITE
-- TRANSACTIONS - APPLIED
-- TRANSACTIONS AND LINES
-- TRANSACTIONS PLUS LINES PLUS DISTRIBUTIONS
-- TRANSACTIONS, LINES, DISTRIBUTIONS AND APPLICATIONS
-- TRANSACTIONS - COUNT BY SOURCE
-- TRANSACTIONS - COUNT BY SOURCE AND TRANSACTION TYPE
-- TRANSACTIONS - COUNT BY CREATED BY
-- TRANSACTIONS - COUNT BY LINE COUNT
-- TRANSACTIONS - COUNT BY RECEIPT CLASS AND RECEIPT METHOD

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from ra_customer_trx_all where customer_trx_id = 123
select * from ra_customer_trx_all where trx_number in ('123')
select * from ra_customer_trx_lines_all where customer_trx_id = 123
select * from ar_payment_schedules_all where customer_trx_id = 123
select * from ar_adjustments_all where customer_trx_id = 123

-- ##############################################################
-- TRANSACTIONS
-- ##############################################################

		select rcta.trx_number
			 , rcta.customer_trx_id trx_id
			 , haou.name org
			 , rcta.bill_template_name -- populated after transaction is printed, if never printed, this remains null
			 , rcta.interface_header_attribute1 reference
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , rcta.created_by
			 , to_char(rcta.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , rcta.last_updated_by
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , to_char(rcta.printing_original_date, 'yyyy-mm-dd') printing_original_date
			 , to_char(rcta.printing_last_printed, 'yyyy-mm-dd') printing_last_printed
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.request_id
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , rctta.accounting_affect_flag -- must be Y for transactions to be printed
			 , rctta.default_printing_option -- Printing option to default for invoices of this transaction type
			 , rcta.interface_header_context context_value
			 , rcta.complete_flag complete
			 , rcta.printing_option -- if Miscellaneous > Generate Bill = Yes, PRINTING_OPTION = PRI. If No, PRINTING_PENDING = N, If NULL, PRINTING_OPTION = NULL
			 , rcta.printing_pending -- if Miscellaneous > Generate Bill = Yes, PRINTING_PENDING = Y. If No, PRINTING_PENDING = N, If NULL, PRINTING_PENDING = N
			 , rcta.printing_count
			 , rcta.print_request_id
			 , rcta.batch_id
			 , rcta.old_trx_number
			 , rcta.upgrade_method
			 , rcta.del_contact_email_address
			 , rcta.delivery_method_code
			 , rcta.trx_business_category
			 , rcta.payment_attributes
			 , rcta.interface_header_context
			 , rcta.interface_header_attribute1
			 , rcta.interface_header_attribute2
			 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
			 , hp.party_name
			 , hca.account_number
			 , hca.customer_class_code
			 , arc.name receipt_class
			 , arm.name receipt_method
			 , to_char(arm.start_date, 'yyyy-mm-dd') receipt_method_start_date
			 , to_char(arm.end_date, 'yyyy-mm-dd') receipt_method_end_date
		  from ra_customer_trx_all rcta
	 left join hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
	 left join ar_receipt_methods arm on arm.receipt_method_id = rcta.receipt_method_id
	 left join ar_receipt_classes arc on arc.receipt_class_id = arm.receipt_class_id
		 where 1 = 1
		   and 1 = 1
	  order by rcta.creation_date desc

-- ##############################################################
-- TRANSACTIONS - BILL TO SITE
-- ##############################################################

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , haou.name org
			 , rcta.bill_template_name -- populated after transaction is printed, if never printed, this remains null
			 , rcta.interface_header_attribute1 reference
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , rcta.created_by
			 , to_char(rcta.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , rcta.last_updated_by
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , to_char(rcta.printing_original_date, 'yyyy-mm-dd') printing_original_date
			 , to_char(rcta.printing_last_printed, 'yyyy-mm-dd') printing_last_printed
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.request_id
			 , rtt.name term_name
			 , rtb.billing_cycle_id -- if populated, trx will not be printed
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , rctta.accounting_affect_flag -- must be Y for transactions to be printed
			 , rctta.default_printing_option -- Printing option to default for invoices of this transaction type
			 , rcta.complete_flag complete
			 , rcta.printing_option -- if Miscellaneous > Generate Bill = Yes, PRINTING_OPTION = PRI. If No, PRINTING_PENDING = N, If NULL, PRINTING_OPTION = NULL
			 , rcta.printing_pending -- if Miscellaneous > Generate Bill = Yes, PRINTING_PENDING = Y. If No, PRINTING_PENDING = N, If NULL, PRINTING_PENDING = N
			 , rcta.printing_count
			 , rcta.print_request_id
			 , rcta.batch_id
			 , rcta.old_trx_number
			 , rcta.upgrade_method
			 , rcta.del_contact_email_address
			 , rcta.delivery_method_code
			 , rcta.trx_business_category
			 , rcta.payment_attributes
			 , rcta.interface_header_context
			 , rcta.interface_header_attribute1
			 , rcta.interface_header_attribute2
			 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
			 , ' -- CUSTOMER ###########################'
			 , hca.cust_account_id
			 , hp.party_name
			 , hca.account_number
			 , hca.customer_class_code
			 , rcta.bill_to_site_use_id
			 , ' -- PARTY SITE ###########################'
			 , hps.party_site_id
			 , hps.party_site_number
			 , hps.status party_site_status
			 , ' -- CUST_ACCOUNT_SITES ###########################'
			 , hcasa.cust_acct_site_id
			 , hcasa.status cust_account_site_status
			 , hcasa.bill_to_flag
			 , ' -- CUST_ACCOUNT_SITE_USES ###########################'
			 , hcsua.site_use_id
			 , hcsua.status site_use_status
			 , hcsua.site_use_code
			 , hcsua.location
			 , hcsua.primary_flag
			 , ' -- PROFILES ###########################'
			 , profile_acct.stmt_delivery_method acct_statement_del_method -- Method of delivering statements to the customer. Valid values are E-Mail,PRINT and XML.	
			 , profile_acct.txn_delivery_method acct_txn_del_method -- Method of delivering transactions to the customer. Valid values are PRINT and XML.
			 , profile_site.stmt_delivery_method site_statement_del_method -- Method of delivering statements to the customer. Valid values are E-Mail,PRINT and XML.	
			 , profile_site.txn_delivery_method site_txn_del_method -- Method of delivering transactions to the customer. Valid values are PRINT and XML.
		  from ra_customer_trx_all rcta
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca.cust_account_id = hcasa.cust_account_id
		  join ra_terms_b rtb on rtb.term_id = rcta.term_id
		  join ra_terms_tl rtt on rtt.term_id = rtb.term_id and rtt.language = userenv('lang')
	 left join hz_customer_profiles_f profile_acct on profile_acct.cust_account_id = hca.cust_account_id and profile_acct.site_use_id is null
	 left join hz_customer_profiles_f profile_site on profile_site.site_use_id = hcsua.site_use_id
		 where 1 = 1
		   and 1 = 1
	  order by rcta.creation_date desc

-- ##############################################################
-- TRANSACTIONS - APPLIED
-- ##############################################################

/*
11-JUL-2023
This doesn't really work but it's a starting point
*/

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , haou.name org
			 , rcta.bill_template_name -- populated after transaction is printed, if never printed, this remains null
			 , rcta.interface_header_attribute1 reference
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , rcta.created_by
			 , to_char(rcta.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , rcta.last_updated_by
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , to_char(rcta.printing_original_date, 'yyyy-mm-dd') printing_original_date
			 , to_char(rcta.printing_last_printed, 'yyyy-mm-dd') printing_last_printed
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.request_id
			 , rtt.name term_name
			 , rtb.billing_cycle_id -- if populated, trx will not be printed
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , rctta.accounting_affect_flag -- must be Y for transactions to be printed
			 , rctta.default_printing_option -- Printing option to default for invoices of this transaction type
			 , rcta.complete_flag complete
			 , rcta.printing_option -- if Miscellaneous > Generate Bill = Yes, PRINTING_OPTION = PRI. If No, PRINTING_PENDING = N, If NULL, PRINTING_OPTION = NULL
			 , rcta.printing_pending -- if Miscellaneous > Generate Bill = Yes, PRINTING_PENDING = Y. If No, PRINTING_PENDING = N, If NULL, PRINTING_PENDING = N
			 , rcta.printing_count
			 , rcta.print_request_id
			 , rcta.batch_id
			 , rcta.old_trx_number
			 , rcta.upgrade_method
			 , rcta.del_contact_email_address
			 , rcta.delivery_method_code
			 , rcta.trx_business_category
			 , rcta.payment_attributes
			 , rcta.interface_header_context
			 , rcta.interface_header_attribute1
			 , rcta.interface_header_attribute2
			 -- , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 -- , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 -- , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
			 , ' -- CUSTOMER ###########################'
			 , hca.cust_account_id
			 , hp.party_name customer_name
			 , hca.account_number
			 , hca.customer_class_code
			 , rcta.bill_to_site_use_id
			 , ' -- PARTY SITE ###########################'
			 , hps.party_site_id
			 , hps.party_site_number site
			 , hps.status party_site_status
			 , ' -- CUST_ACCOUNT_SITES ###########################'
			 , hcasa.cust_acct_site_id
			 , hcasa.status cust_account_site_status
			 , hcasa.bill_to_flag
			 , ' -- CUST_ACCOUNT_SITE_USES ###########################'
			 , hcsua.site_use_id
			 , hcsua.status site_use_status
			 , hcsua.site_use_code
			 , hcsua.location
			 , hcsua.primary_flag
			 , ' -- PROFILES ###########################'
			 , profile_acct.stmt_delivery_method acct_statement_del_method -- Method of delivering statements to the customer. Valid values are E-Mail,PRINT and XML.	
			 , profile_acct.txn_delivery_method acct_txn_del_method -- Method of delivering transactions to the customer. Valid values are PRINT and XML.
			 , profile_site.stmt_delivery_method site_statement_del_method -- Method of delivering statements to the customer. Valid values are E-Mail,PRINT and XML.	
			 , profile_site.txn_delivery_method site_txn_del_method -- Method of delivering transactions to the customer. Valid values are PRINT and XML.
			 , ' -- APPLICATIONS ###########################'
			 , araa.receivable_application_id
			 , araa.payment_schedule_id
			 , to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss') applic_created
			 , araa.created_by applic_created_by
			 , araa.amount_applied
			 , acra.receipt_number
			 , to_char(acra.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , acra.created_by receipt_created_by
		  from ra_customer_trx_all rcta
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = rcta.bill_to_site_use_id
		  join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id and hca.cust_account_id = hcasa.cust_account_id
		  join ra_terms_b rtb on rtb.term_id = rcta.term_id
		  join ra_terms_tl rtt on rtt.term_id = rtb.term_id and rtt.language = userenv('lang')
	 left join ar_receivable_applications_all araa on araa.applied_customer_trx_id = rcta.customer_trx_id and araa.display = 'Y' and araa.APPLIED_CUSTOMER_TRX_ID is not null
	 left join ar_payment_schedules_all apsa on apsa.PAYMENT_SCHEDULE_ID = araa.APPLIED_PAYMENT_SCHEDULE_ID and apsa.class = 'PMT'
	 left join ar_cash_receipts_all acra on acra.cash_receipt_id = araa.cash_receipt_id
	 left join hz_customer_profiles_f profile_acct on profile_acct.cust_account_id = hca.cust_account_id and profile_acct.site_use_id is null
	 left join hz_customer_profiles_f profile_site on profile_site.site_use_id = hcsua.site_use_id
		 where 1 = 1
		   and 1 = 1
	  order by rcta.creation_date desc

-- ##############################################################
-- TRANSACTIONS AND LINES
-- ##############################################################

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , rctla.line_number line
			 , rctla.description
		  from ra_customer_trx_all rcta
		  join ra_customer_trx_lines_all rctla on rctla.customer_trx_id = rcta.customer_trx_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id
	 left join hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and 1 = 1
	  order by rcta.creation_date desc
			 , rcta.trx_number
			 , rctla.line_number

-- ##############################################################
-- TRANSACTIONS PLUS LINES PLUS DISTRIBUTIONS
-- ##############################################################

		select '------ TRANSACTION HEADER -----'
			 , rcta.trx_number
			 , rcta.customer_trx_id
			 , haou.name org
			 , rcta.interface_header_attribute1 reference
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(rcta.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.interface_header_context context_value
			 , rcta.complete_flag complete
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , '------ APPLIED -----'
			 , rcta_appl.trx_number applied_trx
			 , rcta_appl.customer_trx_id applied_trx_id
			 , '------ BILL TO CUSTOMER -----'
			 , hp.party_name
			 , hca.account_number
			 , hca.customer_class_code
			 , '------ LINES -----'
			 , rctla.line_number
			 , al_type.meaning line_type
			 , rctla.quantity_credited line_qty
			 , rctla.unit_selling_price line_amount
			 , rctla.tax_classification_code
			 , rctla.tax_rate
			 , rctla.taxable_amount
			 , rctla.extended_amount
			 , rctla.description
			 , rctla.reason_code
			 , to_char(rctla.creation_date, 'yyyy-mm-dd hh24:mi:ss') line_created
			 , amlat.name memo_line
			 , '------ DISTRIBUTIONS -----'
			 , rctlgda.amount dist_amount
			 , rctlgda.acctd_amount
			 , rctlgda.event_id
			 , rctlgda.account_class
			 , to_char(rctlgda.gl_date, 'yyyy-mm-dd') gl_date
			 , to_char(rctlgda.gl_posted_date, 'yyyy-mm-dd') gl_posted_date
			 , gcc.code_combination_id
			 , '#' || gcc.segment1 segment1
			 , '#' || gcc.segment2 segment2
			 , '#' || gcc.segment3 segment3
			 , '#' || gcc.segment4 segment4
			 , '#' || gcc.segment5 segment5
			 , '#' || gcc.segment6 segment6
			 , '#' || gcc.segment7 segment7
		  from ra_customer_trx_all rcta
		  join ra_customer_trx_lines_all rctla on rctla.customer_trx_id = rcta.customer_trx_id
	 left join hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join ra_cust_trx_line_gl_dist_all rctlgda on rcta.customer_trx_id = rctlgda.customer_trx_id and rctla.customer_trx_line_id = rctlgda.customer_trx_line_id
	 left join gl_code_combinations gcc on rctlgda.code_combination_id = gcc.code_combination_id
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
	 left join ar_payment_schedules_all apsa on apsa.customer_trx_id = rcta.customer_trx_id
	 left join ar_receivable_applications_all araa on araa.payment_schedule_id = apsa.payment_schedule_id
	 left join ra_customer_trx_all rcta_appl on rcta_appl.customer_trx_id = araa.applied_customer_trx_id
	 left join ar_lookups al_type on rctla.line_type = al_type.lookup_code and al_type.lookup_type = 'STD_LINE_TYPE'
	 left join ar_memo_lines_all_b amlab on rctla.memo_line_seq_id = amlab.memo_line_seq_id
	 left join ar_memo_lines_all_tl amlat on amlab.memo_line_id = amlat.memo_line_id
		 where 1 = 1
		   and 1 = 1
	  order by to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- TRANSACTIONS, LINES, DISTRIBUTIONS AND APPLICATIONS
-- ##############################################################

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , rcta.trx_class
			 , rcta.interface_header_attribute1 reference
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(rcta.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , rcta.created_by trx_created_by
			 , to_char(rcta.trx_date, 'yyyy-mm-dd') trx_date
			 , rcta.invoice_currency_code currency
			 , rcta.doc_sequence_value doc_num
			 , rcta.interface_header_context context_value
			 , rcta.complete_flag complete
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , hp.party_name
			 , hca.account_number
			 , hca.customer_class_code
			 , '------ LINES -----'
			 , decode(rctla.link_to_cust_trx_line_id, null, rctla.line_number, rctla.line_number) line_number
			 , al_type.meaning line_type
			 , rctla.quantity_credited qty
			 , rctla.unit_selling_price amount
			 , rctla.tax_classification_code
			 , rctla.tax_rate
			 , rctla.taxable_amount
			 , rctla.extended_amount
			 , (select count(distinct rctla2.tax_classification_code) from ra_customer_trx_lines_all rctla2 where rctla2.customer_trx_id = rcta.customer_trx_id) ffffffff
			 , rctla.description line_description
			 , rctla.reason_code
			 , rctla.creation_date line_created
			 , rctla.created_by line_created_by
			 , rctla.last_update_date line_updated
			 , rctla.last_updated_by line_updated_by
			 , '------ DISTS -----'
			 , rctlgda.creation_date dist_created
			 , rctlgda.created_by dist_created_by
			 , rctlgda.last_update_date dist_updated
			 , rctlgda.last_updated_by dist_updated_by
			 , '#' || gcc.segment1 segment1
			 , '#' || gcc.segment2 segment2
			 , '#' || gcc.segment3 segment3
			 , '#' || gcc.segment4 segment4
			 , '#' || gcc.segment5 segment5
			 , '#' || gcc.segment6 segment6
			 , '#' || gcc.segment7 segment7
			 , '==========applied ======='
			 , rcta_appl.trx_number applied_trx
			 , rcta_appl.customer_trx_id applied_trx_id
			 , gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 code_comb
			 , '#' || gcc.segment1 segment1_applied
			 , '#' || gcc.segment2 segment2_applied
			 , '#' || gcc.segment3 segment3_applied
			 , '#' || gcc.segment4 segment4_applied
			 , '#' || gcc.segment5 segment5_applied
			 , '#' || gcc.segment6 segment6_applied
			 , '#' || gcc.segment7 segment7_applied
		  from ra_customer_trx_all rcta
	 left join ra_customer_trx_lines_all rctla on rctla.customer_trx_id = rcta.customer_trx_id
	 left join ra_cust_trx_line_gl_dist_all rctlgda on rcta.customer_trx_id = rctlgda.customer_trx_id and rctlgda.customer_trx_line_id = rctla.customer_trx_line_id
	 left join gl_code_combinations gcc on rctlgda.code_combination_id = gcc.code_combination_id
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id
	 left join ar_lookups al_type on rctla.line_type = al_type.lookup_code and al_type.lookup_type = 'STD_LINE_TYPE'
	 -- application...
	 left join ar_payment_schedules_all apsa on apsa.customer_trx_id = rcta.customer_trx_id
	 left join ar_receivable_applications_all araa on araa.payment_schedule_id = apsa.payment_schedule_id
	 left join ra_customer_trx_all rcta_appl on rcta_appl.customer_trx_id = araa.applied_customer_trx_id
	 left join ra_customer_trx_lines_all rctla1 on rctla1.customer_trx_id = rcta_appl.customer_trx_id
	 left join ra_customer_trx_lines_all rctla_line1 on rctla1.link_to_cust_trx_line_id = rctla_line1.customer_trx_line_id
	 left join ra_cust_trx_line_gl_dist_all rctlgda1 on rctla1.customer_trx_id = rctlgda1.customer_trx_id and rctlgda1.customer_trx_line_id = rctla1.customer_trx_line_id
		 where 1 = 1
		   and 1 = 1
	  order by rcta.customer_trx_id desc

-- ##############################################################
-- TRANSACTIONS - COUNT BY SOURCE
-- ##############################################################

		select rbsa.name trx_source
			 , min(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_trx_created
			 , max(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_trx_created
			 , count(*) trx_count
		  from ra_customer_trx_all rcta
	 left join hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		 where 1 = 1
		   and 1 = 1
	  group by rbsa.name

-- ##############################################################
-- TRANSACTIONS - COUNT BY SOURCE AND TRANSACTION TYPE
-- ##############################################################

		select rbsa.name trx_source
			 , rctta.name trx_type
			 , min(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_trx_created
			 , max(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_trx_created
			 , count(*) trx_count
		  from ra_customer_trx_all rcta
	 left join hr_all_organization_units haou on rcta.org_id = haou.organization_id
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		 where 1 = 1
		   and 1 = 1
	  group by rbsa.name
			 , rctta.name

-- ##############################################################
-- TRANSACTIONS - COUNT BY CREATED BY
-- ##############################################################

		select created_by
			 , min(to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , count(*)
		  from ra_customer_trx_all
	  group by created_by
	  order by created_by

-- ##############################################################
-- TRANSACTIONS - COUNT BY LINE COUNT
-- ##############################################################

		select rcta.trx_number
			 , rcta.customer_trx_id
			 , haou.name org
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , hp.party_name
			 , hca.account_number
			 , hca.customer_class_code
			 , count(*) line_count
		  from ra_customer_trx_all rcta
		  join ra_customer_trx_lines_all rctla on rctla.customer_trx_id = rcta.customer_trx_id
		  join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		 where 1 = 1
		   and 1 = 1
	  group by rcta.trx_number
			 , rcta.customer_trx_id
			 , haou.name
			 , rbsa.name
			 , rctta.name
			 , hp.party_name
			 , hca.account_number
			 , hca.customer_class_code
	    having count(*) >= 8
	  order by count(*) desc

-- ##############################################################
-- TRANSACTIONS - COUNT BY RECEIPT CLASS AND RECEIPT METHOD
-- ##############################################################

		select haou.name org
			 , substr(rcta.trx_number, 0, 1) trx_start
			 , arc.name receipt_class
			 , arm.name receipt_method
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , min(rcta.trx_number) min_trx
			 , max(rcta.trx_number) max_trx
			 , min(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(to_char(rcta.trx_date, 'yyyy-mm-dd')) min_trx_date
			 , max(to_char(rcta.trx_date, 'yyyy-mm-dd')) max_trx_date
			 , count(*)
		  from ra_customer_trx_all rcta
		  join hr_all_organization_units haou on rcta.org_id = haou.organization_id
		  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
		  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		  join ar_receipt_methods arm on arm.receipt_method_id = rcta.receipt_method_id
		  join ar_receipt_classes arc on arc.receipt_class_id = arm.receipt_class_id
		 where 1 = 1
		   and 1 = 1
	  group by haou.name
			 , substr(rcta.trx_number, 0, 1)
			 , arc.name
			 , arm.name
			 , rbsa.name
			 , rctta.name
