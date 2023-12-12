/*
File Name: gl-journals-xla.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- JOURNAL BATCHES AND HEADERS AND LINES AND XLA DATA
-- WITH XLA_DISTRIBUTION_LINKS
-- XLA SUMMARY - BY PERIOD
-- XLA SUMMARY - NOT BY PERIOD
-- XLA SUMMARY - NOT BY PERIOD NO GCC NO EVENT_TYPE_CODE
-- XLA SUMMARY - NOT BY PERIOD NO GCC WITH EVENT_TYPE_CODE
-- COUNTING - XLA
-- JOURNAL BATCHES AND HEADERS AND LINES AND XLA DATA AND AP INVOICES
-- JOURNAL LINE DESCRIPTION ANALYSIS
*/

-- ##############################################################
-- JOURNAL BATCHES AND HEADERS AND LINES AND XLA DATA
-- ##############################################################

		select gl.name ledger
			 , gjb.group_id
			 , fat.application_name
			 , gjh.je_header_id
			 , gjh.parent_je_header_id
			 , nvl(gjh.reversed_je_header_id, null) reversed_je_header_id
			 , to_char(gjb.creation_date, 'yyyy-mm-dd hh24:mi:ss') batch_created
			 , gjb.je_batch_id
			 , gjb.created_by batch_created_by
			 , to_char(gjh.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_created
			 , gjh.created_by journal_created_by
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , decode(gjh.actual_flag,'A','Actual','E','Encumbrance','Other') jnl_type
			 , decode(gjh.status,'U','Unposted','P','Posted','Other') status 
			 , gjb.request_id
			 , gjb.name batch_name
			 , gjh.period_name period
			 , gjh.name jnl_name
			 , gjh.doc_sequence_value doc
			 , gjb.running_total_cr batch_cr
			 , gjb.running_total_dr batch_dr
			 , gjh.running_total_cr jnl_cr
			 , gjh.running_total_dr jnl_dr
			 , '#' jnl_line_data___
			 , to_char(gjl.creation_date, 'yyyy-mm-dd hh24:mi:ss') journal_line_created
			 , to_char(gjl.effective_date, 'yyyy-mm-dd') gl_date_line
			 , gjl.je_line_num line
			 , (replace(replace(gjl.description,chr(10),''),chr(13),' ')) line_descr
			 , gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' || gcc.segment7 cgh_acct
			 , '#' || gcc.segment1 segment1
			 , '#' || gcc.segment2 segment2
			 , '#' || gcc.segment3 segment3
			 , '#' || gcc.segment4 segment4
			 , '#' || gcc.segment5 segment5
			 , '#' || gcc.segment6 segment6
			 , '#' || gcc.segment7 segment7
			 , gjl.accounted_dr dr
			 , gjl.accounted_cr cr
			 , case when gjl.accounted_dr is not null then -1 * gjl.accounted_dr when gjl.accounted_cr is not null then gjl.accounted_cr end accounted_net
			 , '#' sla_data___
			 , '#' || xte.transaction_number transaction_number
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xte.source_id_int_3
			 , xah.event_type_code
			 , xah.product_rule_code
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) xah_description
			 , xte.entity_code
			 , xal.ae_line_num
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xe.event_id
			 , gjl.code_combination_id
			 , xal.overridden_code_combination_id
			 , xal.override_reason
			 , (replace(replace(xal.description,chr(10),''),chr(13),' ')) xal_description
			 , xal.entered_dr
			 , xal.entered_cr
			 , case when xal.entered_dr is not null then -1 * xal.entered_dr when xal.entered_cr is not null then xal.entered_cr end xal_entered_net
			 , xal.accounted_dr
			 , xal.accounted_cr
			 , case when xal.accounted_dr is not null then -1 * xal.accounted_dr when xal.accounted_cr is not null then xal.accounted_cr end xal_accounted_net
			 , xal.accounting_date
			 , glx.name xal_ledger
			 , xal.creation_date xal_created
			 , xal.jgzz_recon_ref xla_jgzz_recon_ref
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code xetl_event_type_code
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
	 left join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
	 left join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
	 left join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
	 left join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
	 left join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
	 left join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
	 left join gl_ledgers glx on glx.ledger_id = xal.ledger_id
	 left join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
	 left join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
	 left join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- WITH XLA_DISTRIBUTION_LINKS
-- ##############################################################

		select distinct gl.name ledger
			 , xdl.*
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join gl_ledgers glx on glx.ledger_id = xal.ledger_id
		  join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
	 left join xla_distribution_links xdl on xdl.application_id = xal.application_id and xdl.ae_header_id = xal.ae_header_id and xdl.ae_line_num = xal.ae_line_num
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- XLA SUMMARY - BY PERIOD
-- ##############################################################

		select gl.name ledger
			 , fat.application_name
			 , gjh.period_name
			 , gjh.actual_flag
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xecl.name event_class
			 , xetl.name event_type
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjh.created_by) min_gjh_created_by
			 , max(gjh.created_by) max_gjh_created_by
			 , min(gjh.name) min_jnl_name
			 , max(gjh.name) max_jnl_name
			 , min(gjb.name) min_batch_name
			 , max(gjb.name) max_batch_name
			 , min(xte.source_id_int_1) min_id_int_1
			 , max(xte.source_id_int_1) max_id_int_1
			 , min(xte.transaction_number) min_trx_num
			 , max(xte.transaction_number) max_trx_num
			 , min(gjh.period_name) min_period
			 , max(gjh.period_name) max_period
			 , count(distinct gjb.je_batch_id) count_jnl_batches
			 , count(distinct gjh.je_header_id) count_jnl_headers
			 , count(*) count_lines
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		  join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
		  join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , fat.application_name
			 , gjh.period_name
			 , gjh.actual_flag
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xecl.name
			 , xetl.name
			 , xal.accounting_class_code
			 , flv1.meaning

-- ##############################################################
-- XLA SUMMARY - NOT BY PERIOD
-- ##############################################################

		select gl.name ledger
			 , fat.application_name
			 , gjh.actual_flag
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xecl.name event_class
			 , xetl.name event_type
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjh.created_by) min_gjh_created_by
			 , max(gjh.created_by) max_gjh_created_by
			 , min(gjh.name) min_jnl_name
			 , max(gjh.name) max_jnl_name
			 , min(gjb.name) min_batch_name
			 , max(gjb.name) max_batch_name
			 , min(xte.source_id_int_1) min_id_int_1
			 , max(xte.source_id_int_1) max_id_int_1
			 , min(xte.transaction_number) min_trx_num
			 , max(xte.transaction_number) max_trx_num
			 , min(gjh.period_name) min_period
			 , max(gjh.period_name) max_period
			 , count(distinct gjb.je_batch_id) count_jnl_batches
			 , count(distinct gjh.je_header_id) count_jnl_headers
			 , count(*) count_lines
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		  join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
		  join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , fat.application_name
			 , gjh.actual_flag
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , xecl.name
			 , xetl.name
			 , xal.accounting_class_code
			 , flv1.meaning

-- ##############################################################
-- XLA SUMMARY - NOT BY PERIOD NO GCC NO EVENT_TYPE_CODE
-- ##############################################################

		select gl.name ledger
			 , fat.application_name
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjh.created_by) min_gjh_created_by
			 , max(gjh.created_by) max_gjh_created_by
			 , min(gjh.name) min_jnl_name
			 , max(gjh.name) max_jnl_name
			 , min(gjb.name) min_batch_name
			 , max(gjb.name) max_batch_name
			 , min(xte.source_id_int_1) min_id_int_1
			 , max(xte.source_id_int_1) max_id_int_1
			 , min('#' || xte.transaction_number) min_trx_num
			 , max('#' || xte.transaction_number) max_trx_num
			 , count(distinct gjb.je_batch_id) count_jnl_batches
			 , count(distinct gjh.je_header_id) count_jnl_headers
			 , count(*) count_lines
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
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , fat.application_name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , flv1.meaning

-- ##############################################################
-- XLA SUMMARY - NOT BY PERIOD NO GCC WITH EVENT_TYPE_CODE
-- ##############################################################

		select gl.name ledger
			 , fat.application_name
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , xah.product_rule_code
			 , xte.entity_code
			 , xe.event_type_code
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_gjh_cr_date
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_gjh_cr_date
			 , min(gjh.created_by) min_gjh_created_by
			 , max(gjh.created_by) max_gjh_created_by
			 , min(gjh.name) min_jnl_name
			 , max(gjh.name) max_jnl_name
			 , min(gjb.name) min_batch_name
			 , max(gjb.name) max_batch_name
			 , min(xte.source_id_int_1) min_id_int_1
			 , max(xte.source_id_int_1) max_id_int_1
			 , min('#' || xte.transaction_number) min_trx_num
			 , max('#' || xte.transaction_number) max_trx_num
			 , count(distinct gjb.je_batch_id) count_jnl_batches
			 , count(distinct gjh.je_header_id) count_jnl_headers
			 , count(xte.transaction_number) count_sla_transactions
			 , min(gjh.period_name) min_period
			 , max(gjh.period_name) max_period
			 , count(*) count_lines
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
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
		  join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , fat.application_name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.product_rule_code
			 , xte.entity_code
			 , xe.event_type_code
			 , xal.accounting_class_code
			 , flv1.meaning

-- ##############################################################
-- COUNTING - XLA
-- ##############################################################

		select gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , xah.product_rule_code
			 , xte.entity_code
			 , xal.accounting_class_code
			 , xah.event_type_code
			 , count(*)
			 , min(to_char(xal.creation_date, 'yyyy-mm-dd')) min_xal_creation_date
			 , max(to_char(xal.creation_date, 'yyyy-mm-dd')) max_xal_creation_date
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
	 left join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
	 left join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
	 left join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
	 left join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
	 left join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
	 left join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
	 left join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
	 left join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		 where 1 = 1
		   and 1 = 1
	  group by gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xah.product_rule_code
			 , xah.event_type_code
			 , xte.entity_code
			 , xal.accounting_class_code

-- ##############################################################
-- JOURNAL BATCHES AND HEADERS AND LINES AND XLA DATA AND AP INVOICES
-- ##############################################################

/*
http://oraclemasterminds.blogspot.com/2015/01/ap-distribution-query-ap-xla-gl.html
*/

		select '#' || aia.invoice_num invoice_num
			 , aia.invoice_id
			 , pv.vendor_name
			 , pv.segment1 vendor_number
			 , gcc.segment1
			 , gcc.segment3
			 , gcc.segment4
			 , gcc.segment5
			 , gcc.segment6
			 , gcc.segment7
			 , gjh.posted_date posted_on_dt
			 , TO_CHAR(gjh.posted_date, 'DD-MM-YY') posted_date
			 , gjh.je_category
			 , gjh.je_header_id
			 , gjh.name jnl_name
			 , gjh.external_reference acct_je_line_desc
			 , xal.description je_line_desc
			 , xal.accounting_class_code transaction_type
			 , '#' || aia.invoice_num
			 , xal.entered_dr xal_entered_dr
			 , gjl.entered_dr gjl_entered_dr
			 , xal.entered_cr xal_entered_cr
			 , gjl.entered_cr gjl_entered_cr
			 , aida.amount dist_amt
			 , gjh.period_name
			 , gl.name ledger_name
			 , xal.ae_line_num xla_line
			 , xal.accounting_class_code
			 , (replace(replace(xal.description,chr(10),''),chr(13),' ')) xla_line_descr
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aila.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
		  join xla_distribution_links xdl on xdl.source_distribution_id_num_1 = aida.invoice_distribution_id and xdl.source_distribution_type = 'AP_INV_DIST'
		  join xla_transaction_entities xte on xte.source_id_int_1 = aia.invoice_id
		  join xla_events xe on xe.application_id = xte.application_id and xdl.event_id = xe.event_id
		  join xla_ae_headers xah on xte.entity_id = xah.entity_id
		  join xla_ae_lines xal on xah.ae_header_id = xal.ae_header_id and xah.application_id = xal.application_id
		  join gl_import_references gir on xal.gl_sl_link_id = gir.gl_sl_link_id and xal.gl_sl_link_table = gir.gl_sl_link_table
		  join gl_je_lines gjl on gir.je_header_id = gjl.je_header_id and gir.je_line_num = gjl.je_line_num
		  join gl_je_headers gjh on gjh.je_header_id = gjl.je_header_id and gjh.ledger_id = xal.ledger_id
		  join poz_suppliers_v pv on aia.vendor_id = pv.vendor_id
		  join gl_ledgers gl on gjh.ledger_id = gl.ledger_id
		  join gl_code_combinations gcc on gcc.code_combination_id = gjl.code_combination_id
		 where 1 = 1
		   and xte.application_id = 200
		   and xte.entity_code = 'AP_INVOICES'
		   and 1 = 1

-- ##############################################################
-- JOURNAL LINE DESCRIPTION ANALYSIS
-- ##############################################################

		select gl.name ledger
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , case when (replace(replace(gjl.description,chr(10),''),chr(13),' ')) != 'Journal Import Created' then 'Other' else 'Journal Import Created' end line_descr_check_1
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , case when (replace(replace(gjl.description,chr(10),''),chr(13),' ')) != 'Journal Import Created' then 'Other' else 'Journal Import Created' end line_descr_check_2
			 , count(*)
			 , min(to_char(xal.creation_date, 'yyyy-mm-dd')) min_xal_creation_date
			 , max(to_char(xal.creation_date, 'yyyy-mm-dd')) max_xal_creation_date
			 , min(gjh.name) min_jnl_name
			 , max(gjh.name) max_jnl_name
			 , min(gjb.name) min_batch_name
			 , max(gjb.name) max_batch_name
		  from gl_je_headers gjh 
		  join gl_je_batches gjb on gjh.je_batch_id = gjb.je_batch_id
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name and gjst.language = userenv('lang')
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name and gjct.language = userenv('lang')
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on fat.application_id = xte.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , case when (replace(replace(gjl.description,chr(10),''),chr(13),' ')) != 'Journal Import Created' then 'Other' else 'Journal Import Created' end
			 , xah.event_type_code
			 , xah.product_rule_code
			 , xte.entity_code
			 , case when (replace(replace(gjl.description,chr(10),''),chr(13),' ')) != 'Journal Import Created' then 'Other' else 'Journal Import Created' end
