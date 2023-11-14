/*
File Name: 05_xla_all.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

I find this useful if I have e.g. an AP Invoice ID and want to see all of the SLA accounting data linked to it

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- DETAILS - INCLUDING EVENT CLASS AND EVENT TYPE
-- DETAILS - INCLUDING XLA_DISTRIBUTION_LINKS - 1
-- DETAILS - INCLUDING XLA_DISTRIBUTION_LINKS - 2
-- SUMMARY BY PERIOD
-- SUMMARY NOT BY PERIOD
-- SUMMARY NOT BY PERIOD WITH XLA_DISTRIBUTION_LINKS
-- SUMMARY WITHOUT LEGAL ENTITY SUMMARY AND WITHOUT ACCOUNTING LINES
-- SUMMARY WITHOUT LEGAL ENTITY SUMMARY AND WITH ACCOUNTING LINES
-- SUMMARY BY ENTITY CODE, EVENT TYPE, PERIOD, GL TRANSFER STATUS AND ACCOUNTING ENTRY STATUS
-- SUMMARY BY APPLICATION, ENTITY_CODE, STATUSES, EVENT CLASS AND TYPE
-- DETAILS NOT AT XLA LINE LEVEL

*/

-- ##############################################################
-- DETAILS - INCLUDING EVENT CLASS AND EVENT TYPE
-- ##############################################################

		select '####' xla_transaction_entities
			 , '#' || xte.entity_id entity_id
			 , '#' || xte.source_id_int_1 source_id_int_1
			 , '#' || xte.source_id_int_2 source_id_int_2
			 , '#' || xte.source_id_int_3 source_id_int_3
			 , '#' || xte.transaction_number transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_events
			 , '#' || xe.event_id event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_headers
			 , '#' || xah.ae_header_id ae_header_id
			 , decode(xah.balance_type_code,'e','encumbrance','a','actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , to_char(xal.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , '#' || xah.group_id group_id
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) header_description
			 , '####' xla_ae_lines
			 , '#' || xal.code_combination_id code_combination_id
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xal.displayed_line_number
			 , xal.entered_dr
			 , xal.entered_cr
			 , xal.accounted_dr
			 , xal.accounted_cr
			 , xal.creation_date line_created
			 , xal.last_update_date line_updated
			 , xal.currency_code
			 , xal.currency_conversion_rate
			 , xal.currency_conversion_type
			 , to_char(xal.currency_conversion_date, 'yyyy-mm-dd') currency_conversion_date
			 , (replace(replace(xal.description,chr(10),''),chr(13),' ')) xal_description
			 , '####' event_type_class
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code xetl_event_type_code
		  from xla_transaction_entities xte
	 left join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
	 left join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
	 left join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
	 left join gl_code_combinations gcc on gcc.code_combination_id = xal.code_combination_id
	 left join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
	 left join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  order by to_char(xah.accounting_date, 'yyyy-mm-dd') desc

-- ##############################################################
-- DETAILS - INCLUDING XLA_DISTRIBUTION_LINKS - 1
-- ##############################################################

		select '####' xla_transaction_entities
			 , '#' || xte.entity_id entity_id
			 , '#' || xte.source_id_int_1 source_id_int_1
			 , '#' || xte.source_id_int_2 source_id_int_2
			 , '#' || xte.source_id_int_3 source_id_int_3
			 , '#' || xte.transaction_number transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_events
			 , '#' || xe.event_id event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_headers
			 , '#' || xah.ae_header_id ae_header_id
			 , decode(xah.balance_type_code,'e','encumbrance','a','actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , to_char(xal.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , '#' || xah.group_id group_id
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) description
			 , '####' xla_ae_lines
			 , '#' || xal.code_combination_id code_combination_id
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xal.displayed_line_number
			 , xal.currency_code currency
			 , xal.entered_dr
			 , xal.entered_cr
			 , xal.accounted_dr
			 , xal.accounted_cr
			 , xal.creation_date line_created
			 , xal.last_update_date line_updated
		  from xla_transaction_entities xte
	 left join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
	 left join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
	 left join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
	 left join gl_code_combinations gcc on gcc.code_combination_id = xal.code_combination_id
	 left join xla_distribution_links xdl on xdl.application_id = xal.application_id and xdl.ae_header_id = xal.ae_header_id and xdl.ae_line_num = xal.ae_line_num
		 where 1 = 1
		   and 1 = 1
	  order by to_char(xah.accounting_date, 'yyyy-mm-dd') desc

-- ##############################################################
-- DETAILS - INCLUDING XLA_DISTRIBUTION_LINKS - 2
-- ##############################################################

		select '#' || xal.gl_sl_link_id gl_sl_link_id
			 , xal.gl_sl_link_table
			 , xal.ae_line_num
			 , '#' || xte.source_id_int_1 source_id_int_1
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xal.displayed_line_number
			 , xal.currency_code currency
			 , xal.application_id
			 , '#' || xal.ae_header_id ae_header_id
			 , xal.entered_dr
			 , xal.entered_cr
			 , xal.accounted_dr
			 , xal.accounted_cr
			 , xal.creation_date line_created
			 , xal.last_update_date line_updated
			 , '#' || xdl.source_distribution_id_num_1 source_distribution_id_num_1
			 , '#_________'
			 , '#' || inv.vendor_id vendor_id
			 , '#' || inv.invoice_num invoice_num
			 , '#' || inv.invoice_id invoice_id
			 , poh.segment1 po_number
			 , su.segment1 supplier_number
			 , pty.party_name supplier_name
			 , pla.line_num po_line_num
			 , pla.item_description po_line_desc
		  from xla_transaction_entities xte
		  join xla_ae_headers xah on xte.entity_id = xah.entity_id
		  join xla_ae_lines xal on xah.ae_header_id = xal.ae_header_id
		  join ap_invoices_all inv on inv.invoice_id = xte.source_id_int_1
	 left join po_headers_all poh on poh.po_header_id = inv.po_header_id
	 left join poz_suppliers su on su.vendor_id = inv.vendor_id 
	 left join hz_parties pty on pty.party_id = su.party_id
		  join xla_distribution_links xdl on xdl.application_id = xal.application_id and xdl.ae_header_id = xal.ae_header_id and xdl.ae_line_num = xal.ae_line_num
	 left join ap_invoice_distributions_all apd on apd.invoice_distribution_id = xdl.source_distribution_id_num_1 and apd.accounting_event_id = xah.event_id
	 left join ap_invoice_lines_all ail on ail.invoice_id = apd.invoice_id and ail.line_number = apd.invoice_line_number   
	 left join po_lines_all pla on pla.po_line_id = ail.po_line_id
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUMMARY BY PERIOD
-- ##############################################################

		select gl.name ledger
			 , xte.entity_code
			 , fat.application_name app
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , xah.period_name
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.request_id
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , min(to_char(xe.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd')) max_created
			 , min(to_char(xah.accounting_date, 'yyyy-mm-dd')) min_acct_date
			 , max(to_char(xah.accounting_date, 'yyyy-mm-dd')) max_acct_date
			 , min(to_char(xal.accounting_date, 'yyyy-mm-dd')) min_line_acct_date
			 , max(to_char(xal.accounting_date, 'yyyy-mm-dd')) max_line_acct_date
			 , sum(xal.entered_dr) dr_sum
			 , sum(xal.entered_cr) cr_sum
			 , count(distinct xte.transaction_number) trx_count
			 , count(*)
		  from xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		  join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join gl_ledgers gl on gl.ledger_id = xal.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , xte.entity_code
			 , fat.application_name
			 , flv2.meaning
			 , flv3.meaning
			 , xe.event_type_code
			 , xah.period_name
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.request_id
			 , xal.accounting_class_code
			 , flv1.meaning

-- ##############################################################
-- SUMMARY NOT BY PERIOD
-- ##############################################################

		select fat.application_name app
			 , xte.entity_code
			 , gl.name ledger
			 , xe.event_type_code
			 , xah.je_category_name
			 , min(to_char(xe.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd')) max_created
			 , min('#' || xte.source_id_int_1) min_source_id_int_1
			 , max('#' || xte.source_id_int_1) max_source_id_int_1
			 , min('#' || xte.transaction_number) min_transaction_number
			 , max('#' || xte.transaction_number) max_transaction_number
			 , sum(xal.entered_dr) dr_sum
			 , sum(xal.entered_cr) cr_sum
			 , count(distinct xte.transaction_number) trx_count
			 , count(*)
		  from xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join gl_ledgers gl on gl.ledger_id = xal.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , xte.entity_code
			 , gl.name
			 , xe.event_type_code
			 , xah.je_category_name

-- ##############################################################
-- SUMMARY NOT BY PERIOD WITH XLA_DISTRIBUTION_LINKS
-- ##############################################################

		select fat.application_name app
			 , xte.entity_code
			 , gl.name ledger
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , xah.je_category_name
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xdl.event_class_code
			 , min(to_char(xe.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd')) max_created
			 , min(to_char(xah.accounting_date, 'yyyy-mm-dd')) min_acct_date
			 , max(to_char(xah.accounting_date, 'yyyy-mm-dd')) max_acct_date
			 , min(to_char(xal.accounting_date, 'yyyy-mm-dd')) min_line_acct_date
			 , max(to_char(xal.accounting_date, 'yyyy-mm-dd')) max_line_acct_date
			 , min('#' || xte.source_id_int_1) min_source_id_int_1
			 , max('#' || xte.source_id_int_1) max_source_id_int_1
			 , min('#' || xte.source_id_int_2) min_source_id_int_2
			 , max('#' || xte.source_id_int_2) max_source_id_int_2
			 , min('#' || xte.source_id_int_3) min_source_id_int_3
			 , max('#' || xte.source_id_int_3) max_source_id_int_3
			 , min('#' || xte.transaction_number) min_transaction_number
			 , max('#' || xte.transaction_number) max_transaction_number
			 , sum(xal.entered_dr) dr_sum
			 , sum(xal.entered_cr) cr_sum
			 , count(distinct xte.transaction_number) trx_count
			 , count(*)
		  from xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_distribution_links xdl on xdl.application_id = xal.application_id and xdl.ae_header_id = xal.ae_header_id and xdl.ae_line_num = xal.ae_line_num
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		  join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join gl_ledgers gl on gl.ledger_id = xal.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , xte.entity_code
			 , gl.name
			 , flv2.meaning
			 , flv3.meaning
			 , xe.event_type_code
			 , xah.je_category_name
			 , xal.accounting_class_code
			 , flv1.meaning
			 , xdl.event_class_code

-- ##############################################################
-- SUMMARY WITHOUT LEGAL ENTITY SUMMARY AND WITHOUT ACCOUNTING LINES
-- ##############################################################

		select fat.application_name app
			 , gl.name ledger
			 , xte.entity_code
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xah.je_category_name
			 , min(to_char(xe.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd')) max_created
			 , min('#' || xte.source_id_int_1) min_source_id_int_1
			 , max('#' || xte.source_id_int_1) max_source_id_int_1
			 , min('#' || xte.source_id_int_2) min_source_id_int_2
			 , max('#' || xte.source_id_int_2) max_source_id_int_2
			 , min('#' || xte.source_id_int_3) min_source_id_int_3
			 , max('#' || xte.source_id_int_3) max_source_id_int_3
			 , min('#' || xte.transaction_number) min_transaction_number
			 , max('#' || xte.transaction_number) max_transaction_number
			 , count(distinct xte.transaction_number) trx_count
			 , count(*) xal_lines_count
		  from xla_events xe
		  join xla_transaction_entities xte on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
		  join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		  join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join gl_ledgers gl on gl.ledger_id = xte.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , gl.name
			 , xte.entity_code
			 , xecl.name
			 , xecl.event_class_code
			 , xetl.name
			 , xetl.event_type_code
			 , flv2.meaning
			 , flv3.meaning
			 , xah.je_category_name

-- ##############################################################
-- SUMMARY WITHOUT LEGAL ENTITY SUMMARY AND WITH ACCOUNTING LINES
-- ##############################################################

		select fat.application_name app
			 , gl.name ledger
			 , xte.entity_code
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xah.je_category_name
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , min(to_char(xe.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd')) max_created
			 , min('#' || xte.source_id_int_1) min_source_id_int_1
			 , max('#' || xte.source_id_int_1) max_source_id_int_1
			 , min('#' || xte.source_id_int_2) min_source_id_int_2
			 , max('#' || xte.source_id_int_2) max_source_id_int_2
			 , min('#' || xte.source_id_int_3) min_source_id_int_3
			 , max('#' || xte.source_id_int_3) max_source_id_int_3
			 , min('#' || xte.transaction_number) min_transaction_number
			 , max('#' || xte.transaction_number) max_transaction_number
			 , count(distinct xte.transaction_number) trx_count
			 , count(*) xal_lines_count
		  from xla_events xe
		  join xla_transaction_entities xte on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
		  join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		  join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		  join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join gl_ledgers gl on gl.ledger_id = xal.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , gl.name
			 , xte.entity_code
			 , xecl.name
			 , xecl.event_class_code
			 , xetl.name
			 , xetl.event_type_code
			 , flv2.meaning
			 , flv3.meaning
			 , xah.je_category_name
			 , xal.accounting_class_code
			 , flv1.meaning

-- ##############################################################
-- SUMMARY BY ENTITY CODE, EVENT TYPE, PERIOD, GL TRANSFER STATUS AND ACCOUNTING ENTRY STATUS
-- ##############################################################

		select xte.entity_code
			 , fat.application_name app
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xett.name event_type
			 , xah.period_name
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code
			 , sum(round(peia.project_raw_cost,2)) project_raw_cost
			 , sum(round(peia.project_burdened_cost,2)) project_burdened_cost
			 , sum(round(peia.quantity, 2)) quantity
			 , count(*)
		  from xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_event_types_tl xett on xett.event_type_code = xe.event_type_code and xett.application_id = xe.application_id and xett.language = userenv('lang')
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
		  join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		  join pjc_exp_items_all peia on xte.source_id_int_1 = peia.expenditure_item_id
		 where 1 = 1
		   and 1 = 1
	  group by xte.entity_code
			 , fat.application_name
			 , flv2.meaning
			 , flv3.meaning
			 , xett.name
			 , xah.period_name
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code

-- ##############################################################
-- SUMMARY BY APPLICATION, ENTITY_CODE, STATUSES, EVENT CLASS AND TYPE
-- ##############################################################

		select fat.application_name
			 , xte.entity_code
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code
			 , xah.je_category_name
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code xetl_event_type_code
			 , min(to_char(xte.creation_date, 'yyyy-mm-dd')) min_xte_created
			 , max(to_char(xte.creation_date, 'yyyy-mm-dd')) max_xte_created
			 , min('#' || xte.source_id_int_1) min_id_1
			 , max('#' || xte.source_id_int_1) max_id_1
			 , min('#' || xte.transaction_number) min_trx
			 , max('#' || xte.transaction_number) max_trx
			 , min(xe.request_id) min_xe_request_id
			 , max(xe.request_id) max_xe_request_id
			 , min(xah.request_id) min_xah_request_id
			 , max(xah.request_id) max_xah_request_id
			 , count(distinct xte.entity_id) xte_count
			 , count(distinct xe.event_id) xe_count
			 , count(distinct xah.ae_header_id) xah_count
		  from xla_transaction_entities xte
	 left join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
	 left join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
	 left join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
	 left join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , xte.entity_code
			 , flv2.meaning
			 , flv3.meaning
			 , xe.event_type_code
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code
			 , xah.je_category_name
			 , xecl.name
			 , xecl.event_class_code
			 , xetl.name
			 , xetl.event_type_code

-- ##############################################################
-- DETAILS NOT AT XLA LINE LEVEL
-- ##############################################################

		select '####' xla_transaction_entities
			 , '#' || xte.entity_id entity_id
			 , '#' || xte.source_id_int_1 source_id_int_1
			 , '#' || xte.transaction_number transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_events
			 , '#' || xe.event_id event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_headers
			 , '#' || xah.ae_header_id ae_header_id
			 , decode(xah.balance_type_code,'e','encumbrance','a','actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , xah.gl_transfer_status_code
			 , xah.accounting_entry_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , xte.application_id
			 , '#' || xah.group_id group_id
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) header_description
		  from xla_transaction_entities xte
	 left join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
	 left join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
		 where 1 = 1
		   and 1 = 1
	  order by to_char(xah.accounting_date, 'yyyy-mm-dd') desc
