/*
File Name: 06_xla_accounting_errors.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Find details about SLA errors - the kind you'd normally see in the output of the Create Accounting reports

Queries:

-- TABLE DUMP
-- ERROR DETAILS
-- ERROR DETAILS - INCLUDING EVENT CLASS AND EVENT TYPE
-- COUNT BY APPLICATION
-- COUNT BY APPLICATION, IDs AND MESSAGE_NAME
-- COUNT BY APPLICATION, LEDGER AND ERROR NUMBER
-- COUNT BY APPLICATION, LEDGER, ENTITY CODE, EVENT TYPE, PERIOD, ERROR NUMBER, JOINED TO OTHER XLA TABLES

*/

-- ##############################################################
-- TABLE DUMP
-- ##############################################################

		select *
		  from xla_accounting_errors 
	  order by creation_date desc

-- ##############################################################
-- ERROR DETAILS
-- ##############################################################

		select fat.application_name app
			 , xae.event_id
			 , xae.oar_id
			 , xae.accounting_error_id
			 , xae.entity_id
			 , xae.ledger_id
			 , xae.accounting_batch_id
			 , replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ') encoded_msg
			 , translate(replace(replace(xae.encoded_msg,chr(10),''),chr(13),' '), 'a0123456789', 'a') encoded_msg_translate -- remove numbers (https://stackoverflow.com/a/21464781)
			 , xae.ae_header_id
			 , xae.ae_line_num
			 , xae.message_number
			 , xae.error_source_code
			 , xae.application_id
			 , xae.created_by
			 , xae.creation_date
			 , xae.last_update_date
			 , xae.last_updated_by
			 , xae.last_update_login
			 , xae.request_id
			 , xae.job_definition_name
			 , xae.job_definition_package
			 , xae.object_version_number
			 , xae.message_name
		  from xla_accounting_errors xae
		  join fnd_application_tl fat on xae.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and fat.application_name = 'Payables'
		   and xae.message_name not in ('XLA_AP_NO_EVENT_TO_PROCESS','XLA_AP_INVALID_GL_DATE')
		   and 1 = 1
	  order by xae.creation_date desc

-- ##############################################################
-- ERROR DETAILS - INCLUDING EVENT CLASS AND EVENT TYPE
-- ##############################################################

		select '####' xla_transaction_entities
			 , xte.entity_id
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xte.source_id_int_3
			 , '#' || xte.transaction_number transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_events
			 , xe.event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_headers
			 , xah.ae_header_id
			 , decode(xah.balance_type_code,'e','encumbrance','a','actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , to_char(xal.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , xah.group_id
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) header_description
			 , '####' xla_ae_lines
			 , xal.code_combination_id
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , xal.accounting_class_code
			 , flv1.meaning accounting_class
			 , xal.ae_line_num
			 , xal.displayed_line_number
			 , xal.currency_code currency
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
			 , '####' xla_errors
			 , replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ') encoded_msg
			 , translate(replace(replace(xae.encoded_msg,chr(10),''),chr(13),' '), 'a0123456789', 'a') encoded_msg_translate -- remove numbers (https://stackoverflow.com/a/21464781)
			 , xae.message_name
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
		  join xla_accounting_errors xae on xae.event_id = xe.event_id and xae.entity_id = xah.entity_id and xae.ae_header_id = xah.ae_header_id and xae.ae_line_num = xal.ae_line_num
		 where 1 = 1
		   and fat.application_name = 'Payables'
		   and xae.message_name not in ('XLA_AP_NO_EVENT_TO_PROCESS','XLA_AP_INVALID_GL_DATE')
		   and 1 = 1
	  order by to_char(xah.accounting_date, 'yyyy-mm-dd') desc

-- ##############################################################
-- COUNT BY APPLICATION
-- ##############################################################

		select fat.application_name app
			 , min(to_char(xae.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(xae.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(xae.request_id) min_request_id
			 , max(xae.request_id) max_request_id
			 , count(*)
		  from xla_accounting_errors xae
		  join fnd_application_tl fat on xae.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name

-- ##############################################################
-- COUNT BY APPLICATION, IDs AND MESSAGE_NAME
-- ##############################################################

		select fat.application_name app
			 , nvl2(xae.event_id, 'Y', 'N') event_id
			 , nvl2(xae.entity_id, 'Y', 'N') entity_id
			 , nvl2(xae.ae_header_id, 'Y', 'N') ae_header_id
			 , nvl2(xae.ae_line_num, 'Y', 'N') ae_line_num
			 , message_name
			 , min(to_char(xae.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(xae.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(xae.request_id) min_request_id
			 , max(xae.request_id) max_request_id
			 , count(*)
		  from xla_accounting_errors xae
		  join fnd_application_tl fat on xae.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , nvl2(xae.event_id, 'Y', 'N')
			 , nvl2(xae.entity_id, 'Y', 'N')
			 , nvl2(xae.ae_header_id, 'Y', 'N')
			 , nvl2(xae.ae_line_num, 'Y', 'N')
			 , xae.message_name

-- ##############################################################
-- COUNT BY APPLICATION, LEDGER AND ERROR NUMBER
-- ##############################################################

		select fat.application_name app
			 , gl.name ledger
			 , xae.message_number
			 , replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ') encoded_msg
			 , min(to_char(xae.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(xae.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(xae.request_id) min_request_id
			 , max(xae.request_id) max_request_id
			 , count(*)
		  from xla_accounting_errors xae
		  join fnd_application_tl fat on xae.application_id = fat.application_id and fat.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = xae.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ')
			 , fat.application_name
			 , gl.name
			 , xae.message_number

-- ##############################################################
-- COUNT BY APPLICATION, LEDGER, ENTITY CODE, EVENT TYPE, PERIOD, ERROR NUMBER, JOINED TO OTHER XLA TABLES
-- ##############################################################

		select fat.application_name app
			 , gl.name ledger
			 , xte.entity_code
			 , xe.event_type_code
			 , xah.period_name
			 , xae.message_number
			 , replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ') encoded_msg
			 , min(to_char(xae.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(xae.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min(xae.request_id) min_request_id
			 , max(xae.request_id) max_request_id
			 , count(*)
		  from xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join xla_events xe on xe.entity_id = xte.entity_id and xte.application_id = xe.application_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join xla_accounting_errors xae on xae.event_id = xe.event_id and xae.entity_id = xah.entity_id and xae.ae_header_id = xah.ae_header_id
		  join gl_ledgers gl on gl.ledger_id = xae.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by replace(replace(xae.encoded_msg,chr(10),''),chr(13),' ')
			 , fat.application_name
			 , gl.name
			 , xte.entity_code
			 , xe.event_type_code
			 , xah.period_name
			 , xae.message_number
