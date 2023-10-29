/*
File Name: sa-payroll-sla-flow-name.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

I used this when trying to link up a payroll transaction number appearing in a Payroll Create Accounting report's output With the SLA data

Queries:

-- GET SLA_FLOW_NAME
-- GET TRANSACTION NUMBER FROM THE ERROR IN CREATE ACCOUNTING EXECUTION REPORT
-- PAY_FLOW_INSTANCES
-- QUERY 1
-- GET INSTANCE NAME FROM FLOW_INSTANCE_ID
-- PAY_PAYROLL_ACTIONS
-- XLA DATA 1
-- XLA DATA 2
-- XLA DATA 3 - ERRORS
-- XLA DATA 4 - SUMMARY

*/

-- ##############################################################
-- GET SLA_FLOW_NAME
-- ##############################################################

select * from fusion.xla_transaction_entities where transaction_number in ('123456')

-- ##############################################################
-- GET TRANSACTION NUMBER FROM THE ERROR IN CREATE ACCOUNTING EXECUTION REPORT
-- ##############################################################

select * from fusion.xla_events where application_id = 801 and entity_id = 123456

-- ##############################################################
-- PAY_FLOW_INSTANCES
-- ##############################################################

		select *
		from pay_flow_instances
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- QUERY 1
-- ##############################################################

		select xte.transaction_number
			 , xe.entity_id
			 , xe.event_id
			 , pxe.payroll_rel_action_id
		  from xla_events xe
		  join xla_transaction_entities xte on xte.entity_id = xe.entity_id
		  join pay_xla_events pxe on pxe.event_id = xe.event_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- GET INSTANCE NAME FROM FLOW_INSTANCE_ID
-- ##############################################################
		   
		select fi.instance_name
		  from fusion.pay_flow_instances fi
		  join fusion.pay_requests pr on fi.flow_instance_id = pr.flow_instance_id
		  join fusion.pay_payroll_actions ppa on ppa.pay_request_id = pr.pay_request_id 
		  join fusion.pay_payroll_rel_actions pra on ppa.payroll_action_id = pra.payroll_action_id 
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PAY_PAYROLL_ACTIONS
-- ##############################################################

		select distinct ppa.*
		  from fusion.pay_flow_instances fi
		  join fusion.pay_requests pr on fi.flow_instance_id = pr.flow_instance_id
		  join fusion.pay_payroll_actions ppa on ppa.pay_request_id = pr.pay_request_id 
		  join fusion.pay_payroll_rel_actions pra on ppa.payroll_action_id = pra.payroll_action_id 
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- XLA DATA 1
-- ##############################################################

		select gl.name ledger
			 , fat.application_name
			 , fi.instance_name
			 , xte.transaction_number
			 , xte.source_id_int_1
			 , xte.source_id_int_2
			 , xte.entity_code
			 , xte.source_id_char_1
			 , xte.security_id_int_1
			 , xe.entity_id
			 , xe.event_id
			 , pxe.payroll_rel_action_id
			 , ppa.payroll_action_id
			 , to_date(pra.start_date, 'yyyy-mm-dd') start_date
			 , to_date(pra.end_date, 'yyyy-mm-dd') end_date
			 , to_date(fi.fi_process_date, 'yyyy-mm-dd') fi_process_date
			 , to_date(fi.attribute6, 'yyyy-mm-dd') fi_attribute6
			 , to_date(fi.attribute6, 'yyyy-mm-dd') fi_attribute7
		  from pay_flow_instances fi
		  join pay_requests pr on fi.flow_instance_id = pr.flow_instance_id 
		  join pay_payroll_actions ppa on ppa.pay_request_id = pr.pay_request_id 
		  join pay_payroll_rel_actions pra on ppa.payroll_action_id = pra.payroll_action_id 
		  join pay_xla_events pxe on pxe.payroll_rel_action_id = pra.payroll_rel_action_id
		  join xla_events xe on pxe.event_id = xe.event_id
		  join xla_transaction_entities xte on xte.entity_id = xe.entity_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = xte.ledger_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- XLA DATA 2
-- ##############################################################

		select '#' || ppra.payroll_rel_action_id payroll_rel_action_id
			 , '#' || ppra.payroll_action_id payroll_action_id
			 , '#' || ppra.payroll_relationship_id payroll_relationship_id
			 , ppra.action_status
			 , ppra.object_version_number
			 , '#' || ppra.action_sequence chunk_number
			 , '#' || ppa.payroll_id payroll_id
			 , '#' || ppa.pay_request_id pay_request_id
			 , ppa.display_run_number
			 , to_char(ppa.start_date, 'yyyy-mm-dd') ppa_start_date
			 , to_char(ppa.end_date, 'yyyy-mm-dd') ppa_end_date
			 , to_char(ppa.effective_date, 'yyyy-mm-dd') ppa_effective_date
			 , to_char(ppa.creation_date, 'yyyy-mm-dd hh24:mi:ss') ppa_creation_date
			 , ppa.action_status ppa_action_status
			 , ppa.action_population_status
			 , papf.payroll_name 
			 , papf.reporting_name
			 , '#' || prgd.relationship_group_id relationship_group_id
			 , to_char(prgd.start_date, 'yyyy-mm-dd') prgd_start_date
			 , to_char(prgd.end_date, 'yyyy-mm-dd') prgd_end_date
			 , '#' || prgd.assignment_id assignment_id
			 , prgd.assignment_number
			 , to_char(prgd.creation_date, 'yyyy-mm-dd hh24:mi:ss') prgd_creation_date
			 , prgd.created_by prgd_created_by
			 , to_char(prgd.last_update_date, 'yyyy-mm-dd hh24:mi:ss') prgd_last_update_date
			 , prgd.last_updated_by prgd_last_updated_by
			 , '#' || pprd.person_id person_id
			 , '#' || papf2.person_number emp_num
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.full_name
			 , pfi.instance_name
			 , pc.debit_or_credit
			 , gl.name ledger
			 , '####' pxe_____________
			 , '#' || pxe.event_id pxe_event_id
			 , '#' || pxe.payroll_rel_action_id pxe_payroll_rel_action_id
			 , '#' || pxe.payroll_id pxe_payroll_id
			 , '#' || pxe.cost_action_id pxe_cost_action_id
			 , pxe.cost_type pxe_cost_type
			 , pxe.event_status pxe_event_status
			 , '####' xla_transaction_entities_____________
			 , '#' || xte.entity_id entity_id
			 , '#' || xte.source_id_int_1 source_id_int_1
			 , '#' || xte.source_id_int_2 source_id_int_2
			 , '#' || xte.source_id_int_3 source_id_int_3
			 , '#' || xte.transaction_number transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_events_____________
			 , '#' || xe.event_id event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_headers_____________
			 , '#' || xah.ae_header_id ae_header_id
			 , decode(xah.balance_type_code,'e','encumbrance','a','actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , to_char(xal.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , '#' || xah.group_id group_id
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) header_description
			 , '####' xla_ae_lines_____________
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
			 , (replace(replace(xal.description,chr(10),''),chr(13),' ')) xal_description
			 , '####' event_type_class_____________
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code xetl_event_type_code
		  from pay_payroll_rel_actions ppra
		  join pay_payroll_actions ppa on ppa.payroll_action_id = ppra.payroll_action_id
		  join pay_all_payrolls_f papf on papf.payroll_id = ppa.payroll_id and ppa.effective_date between papf.effective_start_date and papf.effective_end_date
		  join pay_rel_groups_dn prgd on prgd.payroll_relationship_id = ppra.payroll_relationship_id and ppa.effective_date between prgd.start_date and prgd.end_date
		  join pay_pay_relationships_dn pprd on pprd.payroll_relationship_id = ppra.payroll_relationship_id and ppa.effective_date between pprd.start_date and pprd.end_date
		  join per_all_assignments_f paaf on prgd.assignment_id = paaf.assignment_id and ppa.effective_date between paaf.effective_start_date and paaf.effective_end_date
		  join per_all_people_f papf2 on papf2.person_id = paaf.person_id and ppa.effective_date between papf2.effective_start_date and papf2.effective_end_date
		  join per_person_names_f ppnf on ppnf.person_id = papf2.person_id and ppnf.name_type = 'GLOBAL' and ppa.effective_date between ppnf.effective_start_date and ppnf.effective_end_date
		  join pay_requests pr on pr.pay_request_id = ppa.pay_request_id
		  join pay_flow_instances pfi on pfi.flow_instance_id = pr.flow_instance_id 
		  join pay_xla_events pxe on pxe.payroll_rel_action_id = ppra.payroll_rel_action_id
		  join xla_events xe on pxe.event_id = xe.event_id
		  join xla_transaction_entities xte on xte.entity_id = xe.entity_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = xte.ledger_id
		  join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
		  join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
	 left join pay_costs pc on pc.payroll_rel_action_id = ppra.payroll_rel_action_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = xal.code_combination_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- XLA DATA 3 - ERRORS
-- ##############################################################

		select '#' || ppra.payroll_rel_action_id payroll_rel_action_id
			 , '#' || ppra.payroll_action_id payroll_action_id
			 , '#' || ppra.payroll_relationship_id payroll_relationship_id
			 , ppra.action_status
			 , ppra.object_version_number
			 , '#' || ppra.action_sequence chunk_number
			 , '#' || ppa.payroll_id payroll_id
			 , '#' || ppa.pay_request_id pay_request_id
			 , ppa.display_run_number
			 , to_char(ppa.start_date, 'yyyy-mm-dd') ppa_start_date
			 , to_char(ppa.end_date, 'yyyy-mm-dd') ppa_end_date
			 , to_char(ppa.effective_date, 'yyyy-mm-dd') ppa_effective_date
			 , to_char(ppa.creation_date, 'yyyy-mm-dd hh24:mi:ss') ppa_creation_date
			 , ppa.action_status ppa_action_status
			 , ppa.action_population_status
			 , papf.payroll_name 
			 , papf.reporting_name
			 , '#' || prgd.relationship_group_id relationship_group_id
			 , to_char(prgd.start_date, 'yyyy-mm-dd') prgd_start_date
			 , to_char(prgd.end_date, 'yyyy-mm-dd') prgd_end_date
			 , '#' || prgd.assignment_id assignment_id
			 , prgd.assignment_number
			 , to_char(prgd.creation_date, 'yyyy-mm-dd hh24:mi:ss') prgd_creation_date
			 , prgd.created_by prgd_created_by
			 , to_char(prgd.last_update_date, 'yyyy-mm-dd hh24:mi:ss') prgd_last_update_date
			 , prgd.last_updated_by prgd_last_updated_by
			 , '#' || pprd.person_id person_id
			 , '#' || papf2.person_number emp_num
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.full_name
			 , pfi.instance_name
			 , pc.debit_or_credit
			 , gl.name ledger
			 , '####' pxe_____________
			 , '#' || pxe.event_id pxe_event_id
			 , '#' || pxe.payroll_rel_action_id pxe_payroll_rel_action_id
			 , '#' || pxe.payroll_id pxe_payroll_id
			 , '#' || pxe.cost_action_id pxe_cost_action_id
			 , pxe.cost_type pxe_cost_type
			 , pxe.event_status pxe_event_status
			 , '####' xla_transaction_entities_____________
			 , '#' || xte.entity_id entity_id
			 , '#' || xte.source_id_int_1 source_id_int_1
			 , '#' || xte.source_id_int_2 source_id_int_2
			 , '#' || xte.source_id_int_3 source_id_int_3
			 , '#' || xte.transaction_number transaction_number
			 , xte.entity_code
			 , fat.application_name app
			 , '####' xla_events_____________
			 , '#' || xe.event_id event_id
			 , xe.event_number
			 , xe.creation_date event_created
			 , flv2.meaning event_status
			 , flv3.meaning event_process_status
			 , xe.event_type_code
			 , '####' xla_ae_headers_____________
			 , '#' || xah.ae_header_id ae_header_id
			 , decode(xah.balance_type_code,'e','encumbrance','a','actual') balance_type
			 , xah.period_name
			 , xah.completed_date
			 , to_char(xah.accounting_date, 'yyyy-mm-dd') accounting_date
			 , to_char(xal.accounting_date, 'yyyy-mm-dd') line_accounting_date
			 , xah.gl_transfer_status_code
			 , xah.je_category_name
			 , xah.creation_date
			 , xah.request_id
			 , '#' || xah.group_id group_id
			 , (replace(replace(xah.description,chr(10),''),chr(13),' ')) header_description
			 , '####' xla_ae_lines_____________
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
			 , (replace(replace(xal.description,chr(10),''),chr(13),' ')) xal_description
			 , '####' event_type_class_____________
			 , xecl.name event_class
			 , xecl.event_class_code
			 , xetl.name event_type
			 , xetl.event_type_code xetl_event_type_code
			 , '####' errors_____________
			 , xae.accounting_error_id
			 , xae.encoded_msg
			 , xae.error_source_code
			 , xae.message_name
		  from pay_payroll_rel_actions ppra
		  join pay_payroll_actions ppa on ppa.payroll_action_id = ppra.payroll_action_id
		  join pay_all_payrolls_f papf on papf.payroll_id = ppa.payroll_id and ppa.effective_date between papf.effective_start_date and papf.effective_end_date
		  join pay_rel_groups_dn prgd on prgd.payroll_relationship_id = ppra.payroll_relationship_id and ppa.effective_date between prgd.start_date and prgd.end_date
		  join pay_pay_relationships_dn pprd on pprd.payroll_relationship_id = ppra.payroll_relationship_id and ppa.effective_date between pprd.start_date and pprd.end_date
		  join per_all_assignments_f paaf on prgd.assignment_id = paaf.assignment_id and ppa.effective_date between paaf.effective_start_date and paaf.effective_end_date
		  join per_all_people_f papf2 on papf2.person_id = paaf.person_id and ppa.effective_date between papf2.effective_start_date and papf2.effective_end_date
		  join per_person_names_f ppnf on ppnf.person_id = papf2.person_id and ppnf.name_type = 'GLOBAL' and ppa.effective_date between ppnf.effective_start_date and ppnf.effective_end_date
		  join pay_requests pr on pr.pay_request_id = ppa.pay_request_id
		  join pay_flow_instances pfi on pfi.flow_instance_id = pr.flow_instance_id 
		  join pay_xla_events pxe on pxe.payroll_rel_action_id = ppra.payroll_rel_action_id
		  join xla_events xe on pxe.event_id = xe.event_id
		  join xla_transaction_entities xte on xte.entity_id = xe.entity_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join xla_ae_lines xal on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		  join gl_ledgers gl on gl.ledger_id = xte.ledger_id
		  join xla_event_types_tl xetl on xetl.event_type_code = xe.event_type_code and xetl.application_id = xe.application_id and xetl.language = userenv('lang')
		  join xla_event_classes_tl xecl on xecl.entity_code = xetl.entity_code and xecl.event_class_code = xetl.event_class_code and xecl.application_id = xetl.application_id and xecl.language = userenv('lang')
		  join xla_accounting_errors xae on xae.event_id = xe.event_id and xae.entity_id = xte.entity_id and xae.ae_header_id = xah.ae_header_id and xae.ae_line_num = xal.ae_line_num
	 left join fnd_lookup_values_vl flv1 on xal.accounting_class_code = flv1.lookup_code and flv1.lookup_type = 'XLA_ACCOUNTING_CLASS'
	 left join fnd_lookup_values_vl flv2 on xe.event_status_code = flv2.lookup_code and flv2.lookup_type = 'XLA_EVENT_STATUS'
	 left join fnd_lookup_values_vl flv3 on xe.process_status_code = flv3.lookup_code and flv3.lookup_type = 'XLA_EVENT_PROCESS_STATUS'
	 left join pay_costs pc on pc.payroll_rel_action_id = ppra.payroll_rel_action_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = xal.code_combination_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- XLA DATA 4 - SUMMARY
-- ##############################################################

		select papf.payroll_name 
			 , papf.reporting_name
			 , pfi.instance_name
			 , gl.name ledger
			 , xah.request_id
			 , pxe.event_status
			 , xe.event_status_code
			 , xe.process_status_code
			 , to_char(ppa.start_date, 'yyyy-mm-dd') ppa_start_date
			 , to_char(ppa.end_date, 'yyyy-mm-dd') ppa_end_date
			 , to_char(ppa.effective_date, 'yyyy-mm-dd') ppa_effective_date
			 , to_char(ppa.creation_date, 'yyyy-mm-dd hh24:mi:ss') ppa_creation_date
			 , count(*) count_
		  from pay_payroll_rel_actions ppra
		  join pay_payroll_actions ppa on ppa.payroll_action_id = ppra.payroll_action_id
		  join pay_all_payrolls_f papf on papf.payroll_id = ppa.payroll_id and ppa.effective_date between papf.effective_start_date and papf.effective_end_date
		  join pay_rel_groups_dn prgd on prgd.payroll_relationship_id = ppra.payroll_relationship_id and ppa.effective_date between prgd.start_date and prgd.end_date
		  join pay_pay_relationships_dn pprd on pprd.payroll_relationship_id = ppra.payroll_relationship_id and ppa.effective_date between pprd.start_date and pprd.end_date
		  join pay_requests pr on pr.pay_request_id = ppa.pay_request_id
		  join pay_flow_instances pfi on pfi.flow_instance_id = pr.flow_instance_id 
		  join pay_xla_events pxe on pxe.payroll_rel_action_id = ppra.payroll_rel_action_id
		  join xla_events xe on pxe.event_id = xe.event_id
		  join xla_transaction_entities xte on xte.entity_id = xe.entity_id
		  join xla_ae_headers xah on xah.entity_id = xe.entity_id and xah.event_id = xe.event_id and xah.application_id = xe.application_id
		  join gl_ledgers gl on gl.ledger_id = xte.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by papf.payroll_name 
			 , papf.reporting_name
			 , pfi.instance_name
			 , gl.name
			 , xah.request_id
			 , pxe.event_status
			 , xe.event_status_code
			 , xe.process_status_code
			 , to_char(ppa.start_date, 'yyyy-mm-dd')
			 , to_char(ppa.end_date, 'yyyy-mm-dd')
			 , to_char(ppa.effective_date, 'yyyy-mm-dd')
			 , to_char(ppa.creation_date, 'yyyy-mm-dd hh24:mi:ss')
	  order by to_char(ppa.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc
