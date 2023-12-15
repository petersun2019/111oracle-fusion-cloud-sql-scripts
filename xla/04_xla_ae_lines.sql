/*
File Name: 04_xla_ae_lines.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

https://docs.oracle.com/en/cloud/saas/financials/22d/oedmf/xlaaelines-8375.html#xlaaelines-8375
This table contains the journal entry lines for each subledger accounting journal entry.

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- XLA LINES BASIC
-- DATA FROM SOURCE_ID_INT_1
-- ALL JOINED UP

*/

-- ##############################################################
-- XLA LINES BASIC
-- ##############################################################

select * from xla_ae_lines xal where ae_header_id = 12345678

-- ##############################################################
-- DATA FROM SOURCE_ID_INT_1
-- ##############################################################

		select *
		  from xla_ae_lines xal
		 where xal.application_id = 222
		   and xal.ae_header_id in (select ae_header_id
									  from xla_ae_headers xah
									 where xah.application_id = xal.application_id
									   and xah.entity_id in (select xte.entity_id
															   from xla_transaction_entities xte
															  where xte.application_id = xal.application_id
															    and xte.entity_code = 'TRANSACTIONS'
															    and xte.source_id_int_1 = 12345678))
		   and 1 = 1
	  order by xal.code_combination_id

-- ##############################################################
-- ALL JOINED UP 1 (WITH LINES)
-- ##############################################################

		select '####' xla_transaction_entities
			 , xte.entity_id
			 , xte.source_id_int_1
			 , xte.transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_ae_headers
			 , xah.ae_header_id
			 , decode(xah.balance_type_code,'E','Encumbrance','A','Actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , xah.group_id
			 , xah.description
			 , '####' xla_events
			 , xe.event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_lines
			 , xal.code_combination_id
			 , xal.creation_date line_created
			 , xal.created_by line_created_by
			 , xal.overridden_code_combination_id
			 , xal.override_reason
			 , gcc.segment1
			 , gcc.segment2
			 , gcc.segment3
			 , gcc.segment4
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xal.displayed_line_number
			 , nvl(xal.entered_dr, 0) entered_dr
			 , nvl(xal.entered_cr, 0) entered_cr
			 , nvl(xal.accounted_dr, 0) accounted_dr
			 , nvl(xal.accounted_cr, 0) accounted_cr
			 , xal.gl_sl_link_table
			 , xal.gl_sl_link_id
			 , xal.currency_code
			 , xal.currency_conversion_rate
			 , xal.currency_conversion_type
			 , (replace(replace(xal.description,chr(10),''),chr(13),' ')) xal_description
			 , to_char(xal.currency_conversion_date, 'yyyy-mm-dd') currency_conversion_date
		  from xla_ae_headers xah
		  join xla_transaction_entities xte on xah.entity_id = xte.entity_id and xah.application_id = xte.application_id
	 left join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
	 left join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
	 left join gl_code_combinations gcc on gcc.code_combination_id = xal.code_combination_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ALL JOINED UP 2 (WITHOUT LINES) - AP INVOICES
-- ##############################################################

		select '####' ap_invoices
			 , '#' || aia.invoice_num invoice_num
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.created_by inv_created_by
			 , to_char(aia.last_update_date, 'yyyy-mm-dd hh24:mi:ss') inv_updated
			 , aia.last_updated_by inv_updated_by
			 , '####' xla_transaction_entities
			 , xte.entity_id
			 , xte.source_id_int_1
			 , xte.transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , to_char(xte.creation_date, 'yyyy-mm-dd hh24:mi:ss') xte_created
			 , xte.created_by xte_created_by
			 , to_char(xte.last_update_date, 'yyyy-mm-dd hh24:mi:ss') xte_updated
			 , xte.last_updated_by xte_updated_by
			 , '####' xla_ae_headers
			 , xah.ae_header_id
			 , decode(xah.balance_type_code,'E','Encumbrance','A','Actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id xah_request_id
			 , xah.group_id
			 , xah.description
			 , to_char(xah.creation_date, 'yyyy-mm-dd hh24:mi:ss') xah_created
			 , xah.created_by xah_created_by
			 , to_char(xah.last_update_date, 'yyyy-mm-dd hh24:mi:ss') xah_updated
			 , xah.last_updated_by xah_updated_by
			 , '####' xla_events
			 , xe.event_id
			 , xe.event_number
			 , xe.request_id xe_request_id
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , to_char(xe.creation_date, 'yyyy-mm-dd hh24:mi:ss') xe_created
			 , xe.created_by xe_created_by
			 , to_char(xe.last_update_date, 'yyyy-mm-dd hh24:mi:ss') xe_updated
			 , xe.last_updated_by xe_updated_by
		  from xla_ae_headers xah
		  join xla_transaction_entities xte on xah.entity_id = xte.entity_id and xah.application_id = xte.application_id
	 left join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join ap_invoices_all aia on aia.invoice_id = xte.source_id_int_1
		 where 1 = 1
		   and 1 = 1
	  order by to_char(xe.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc
