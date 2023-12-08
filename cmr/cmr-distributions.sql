/*
File Name: cmr-distributions.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- RECEIPT ACCOUNTING LINKED TO PO
-- RECEIPT ACCOUNTING SLA JOURNALS
-- ACCOUNTING SUMMARY FOR RECEIPT ACCOUNTING

*/

-- ##############################################################
-- RECEIPT ACCOUNTING LINKED TO PO
-- ##############################################################

		select cre.source_doc_number source_doc
			 , cre.sla_transaction_number trx_num
			 , crd.ledger_amount
			 , crd.accounting_line_type
			 , cre.accounting_event_id
			 , to_char(cre.creation_date, 'yyyy-mm-dd hh24:mi:ss') event_creation_date
			 , to_char(crd.creation_date, 'yyyy-mm-dd hh24:mi:ss') dist_creation_date
			 , to_char(cre.transaction_date, 'yyyy-mm-dd hh24:mi:ss') transaction_date
			 , to_char(cre.gl_date, 'yyyy-mm-dd') gl_date
			 , to_char(cre.root_receipt_event_date, 'yyyy-mm-dd') root_receipt_event_date
			 , to_char(cre.receipt_creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_creation_date
			 , to_char(cre.event_date, 'yyyy-mm-dd') event_date
			 , cre.event_type_code
			 , cre.event_class_code
			 , cre.accounted_flag
			 , cre.source_doc_qty
			 , cre.transaction_qty
			 , cre.event_source
			 , cre.entity_code
			 , cre.po_unit_price
			 , cre.transaction_amt
			 , cre.request_id
			 , cre.transaction_type_code
			 , cre.event_txn_table_name
			 , cre.cmr_po_distribution_id
			 , crd.accounted_qty
			 , crd.entered_currency_amount
			 , '#' || gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' || gcc.segment7 code_comb
			 , '-----------------' po
			 , pha.segment1 po_number
			 , pha.revision_num po_revision_num
			 , psv.vendor_name supplier
			 , pha.type_lookup_code po_type
			 , pha.cancel_flag
			 , pha.approved_flag
			 , pha.document_status
			 , pha.from_header_id
			 , pha.cpa_reference
			 , pha.created_by
			 , to_char(pha.approved_date, 'yyyy-mm-dd hh24:mi:ss') po_approved
			 , to_char(pha.revised_date, 'yyyy-mm-dd hh24:mi:ss') po_revised_date
			 , to_char(pha.last_billed_date, 'yyyy-mm-dd hh24:mi:ss') po_last_billed_date
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_creation_date
			 , to_char(pha.last_update_date, 'yyyy-mm-dd hh24:mi:ss') po_updated
			 , to_char(pha.closed_date, 'yyyy-mm-dd hh24:mi:ss') po_closed_date
		  from cmr_rcv_events cre
		  join cmr_rcv_distributions crd on cre.accounting_event_id = crd.accounting_event_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = crd.code_combination_id
	 left join po_headers_all pha on cre.source_doc_number = pha.segment1
	 left join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		 where 1 = 1
		   and 1 = 1
	  order by cre.creation_date desc

-- ##############################################################
-- RECEIPT ACCOUNTING SLA JOURNALS
-- ##############################################################

		select gl.name ledger
			 , fat.application_name app
			 , gjh.je_header_id
			 , gjh.parent_je_header_id
			 , nvl(gjh.reversed_je_header_id, null) reversed_je_header_id
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.je_batch_id
			 , gjb.created_by batch_created_by
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , gjst.user_je_source_name src
			 , gjct.user_je_category_name cat
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , decode(gjh.status,'U','Unposted','P','Posted','Other') status 
			 , gjb.request_id
			 , gjb.name batch_name
			 , gjh.period_name period
			 , gjh.name jnl_name
			 , to_char(gjl.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_line_created
			 , to_char(gjl.effective_date, 'yyyy-mm-dd') gl_date_line
			 , to_char(xal.accounting_date, 'YYYY-MM-DD') xla_acct_date
			 , gjl.je_line_num line
			 , (replace(replace(gjl.description,chr(10),''),chr(13),' ')) line_descr
			 , gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' || gcc.segment7 cgh_acct
			 , gjl.accounted_dr dr
			 , gjl.accounted_cr cr
			 , xte.transaction_number
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xte.source_id_int_3
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , xe.event_id
			 , xal.description
			 , xal.entered_dr
			 , xal.entered_cr
			 , xal.accounted_dr
			 , xal.accounted_cr
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code xetl_event_type_code
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
	 left join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		 where 1 = 1
		   and gjst.user_je_source_name = 'Receipt Accounting'
		   and 1 = 1

-- ##############################################################
-- ACCOUNTING SUMMARY FOR RECEIPT ACCOUNTING
-- ##############################################################

		select gl.name ledger
			 , gjst.user_je_source_name src
			 , gjct.user_je_category_name cat
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , min(gjh.je_header_id) min_id
			 , max(gjh.je_header_id) max_id
			 , min(xte.source_id_int_1) min_src_id
			 , max(xte.source_id_int_1) max_src_id
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_created
			 , count(*) ct
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and gjst.user_je_source_name = 'Receipt Accounting'
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
	  order by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
