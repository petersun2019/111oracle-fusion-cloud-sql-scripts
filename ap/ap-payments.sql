/*
File Name: ap-payments.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PAYMENT REQUEST TEMPLATES
-- PAYMENT RUNS - NOT LINKED TO INVOICES
-- PAYMENT RUNS - SELECTED INVOICES ONLY, BEFORE GETS ONTO LATER STAGES (AP_SELECTED_INVOICES_ALL)
-- PAYMENT RUNS - LINKED TO INVOICES
-- COUNT OF EMAIL ADDRESSES PER PAYMENT
-- COUNTING
-- UNSELECTED INVOICES
-- PAYMENT DOCUMENTS

*/

-- ##############################################################
-- PAYMENT REQUEST TEMPLATES
-- ##############################################################

		select apt.template_name
			 , apt.description
			 , apt.payment_method_code
			 , apt.zero_inv_allowed_flag inc_zero_amt_inv	
			 , cba.bank_account_name
			 , '#' || cba.bank_account_num bank_account_num
			 , nvl(cba.zero_amount_allowed, 'N') bank_zero_amt_allowed
			 , cbv.bank_name
			 , '#' || cbbv.branch_number branch_number
			 , '#' || cbbv.bank_branch_name bank_branch_name
			 , ipp.system_profile_code
			 , '#' || ipp.payment_profile_id payment_profile_id
			 , ipp.payment_format_code
			 , ipp.system_profile_name
			 , ipp.system_profile_description
			 , ipp.payment_profile_name payment_process_profile
			 , ipp.system_profile_description ppp_description
			 , ipp.outbound_pmt_file_directory ppp_out_directory
			 , ipp.outbound_pmt_file_extension ppp_extn
			 , ipp.outbound_pmt_file_prefix ppp_prefix
			 , ift.format_name payment_instruction_format -- this is the "name" of the payment format
			 , ifb.format_template_code -- this is the name of the "bi publisher template", and appears in the "name" column in "disbursement payment file formats" accesed via tools > reports and analytics > /shared folders/financials/payments - then can get xsl name etc from front-end
			 , (select count(*) from ap_inv_selection_criteria_all aisc where apt.template_id = aisc.template_id) ct
		  from ap_payment_templates apt
		  join ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
		  join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
		  join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
		  join iby_payment_profiles ipp on apt.payment_profile_id = ipp.payment_profile_id
		  join iby_formats_b ifb on ifb.format_code = ipp.payment_format_code
		  join iby_formats_tl ift on ifb.format_code = ift.format_code and ift.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PAYMENT RUNS - NOT LINKED TO INVOICES
-- ##############################################################

		select aisc.checkrun_name
			 , aisc.status
			 , aisc.created_by
			 , aisc.request_id
			 , to_char(aisc.creation_date, 'yyyy-mm-dd hh24:mi:ss') checkrun_created
			 , to_char(aisc.creation_date, 'yyyy-mm-dd') checkrun_created1
			 , apt.template_name
			 , apt.description
			 , apt.payment_method_code
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
			 , ipp.payment_profile_id
			 , ipp.payment_format_code
			 , ipp.system_profile_name
			 , ipp.system_profile_description
			 , ipp.payment_profile_name payment_process_profile
			 , ipp.system_profile_description ppp_description
			 , ipp.outbound_pmt_file_directory ppp_out_directory
			 , ipp.outbound_pmt_file_extension ppp_extn
			 , ipp.outbound_pmt_file_prefix ppp_prefix
			 , ipp.print_instruction_immed_flag
			 , ipp.transmit_instr_immed_flag
			 , ift.format_name payment_instruction_format
			 , to_char(aisc.check_date, 'yyyy-mm-dd') check_date
			 , to_char(aisc.pay_thru_date, 'yyyy-mm-dd') pay_thru_date
			 , aisc.pay_group_option
			 , iras.remittance_advice_format_code
			  , ift_remit.format_name
		  from ap_payment_templates apt
	 left join ap_inv_selection_criteria_all aisc on apt.template_id = aisc.template_id
	 left join ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
	 left join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
	 left join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
	 left join iby_payment_profiles ipp on apt.payment_profile_id = ipp.payment_profile_id
	 left join iby_formats_b ifb on ifb.format_code = ipp.payment_format_code
	 left join iby_formats_tl ift on ifb.format_code = ift.format_code and ift.language = userenv('lang')
	 left join iby_remit_advice_setup iras on ipp.system_profile_code = iras.system_profile_code
	 left join iby_formats_b ifb_remit on ifb_remit.format_code = iras.remittance_advice_format_code
	 left join iby_formats_tl ift_remit on ifb_remit.format_code = ift_remit.format_code
		 where 1 = 1
		   and 1 = 1
	  order by aisc.creation_date desc

-- ##############################################################
-- PAYMENT RUNS - SELECTED INVOICES ONLY, BEFORE GETS ONTO LATER STAGES (AP_SELECTED_INVOICES_ALL)
-- ##############################################################

		select aisc.checkrun_name
			 , aisc.status
			 , aisc.created_by
			 , to_char(aisc.creation_date, 'yyyy-mm-dd hh24:mi:ss') checkrun_created
			 , to_char(aisc.check_date, 'yyyy-mm-dd') check_date
			 , to_char(aisc.pay_thru_date, 'yyyy-mm-dd') pay_thru_date
			 , aisc.pay_group_option
			 , asia.invoice_id
			 , '#' || asia.invoice_num invoice_num
			 , asia.invoice_amount
			 , asia.amount_remaining
			 , asia.payment_amount
			 , asia.vendor_name
			 , asia.vendor_num
			 , asia.vendor_site_code site
			 , '################'
			 , case when iepa.ext_payee_id is not null and iepa.party_site_id is null and iepa.supplier_site_id is null then 'Supplier Header'
					when iepa.ext_payee_id is not null and iepa.party_site_id is not null and iepa.supplier_site_id is null then 'Address'
					when iepa.ext_payee_id is not null and iepa.party_site_id is not null and iepa.supplier_site_id is not null then 'Site'
			   end email_set_at
			 , iepa.remit_advice_email "iepa remit_advice_email"
			 , iepa.remit_advice_delivery_method "iepa remit_advice_delivery_method"
			 , to_char(iepa.creation_date, 'yyyy-mm-dd hh24:mi:ss') disb_created
			 , to_char(iepa.last_update_date, 'yyyy-mm-dd hh24:mi:ss') disb_updated
			 , iepa.last_updated_by disb_updated_by
		  from ap_payment_templates apt
		  join ap_inv_selection_criteria_all aisc on apt.template_id = aisc.template_id
		  join ap_selected_invoices_all asia on asia.checkrun_name = aisc.checkrun_name
		  join poz_suppliers_v psv on asia.vendor_id = psv.vendor_id
		  join hz_parties hp on psv.party_id = hp.party_id
		  join iby_external_payees_all iepa on iepa.payee_party_id = hp.party_id and iepa.payment_function = 'PAYABLES_DISB'
		 where 1 = 1
		   and 1 = 1
	  order by aisc.creation_date desc

-- ##############################################################
-- PAYMENT RUNS - LINKED TO INVOICES
-- ##############################################################

/*
To see Remittance Delivery Method defined against Payment Process Profile
Look in IBY_REMIT_ADVICE_SETUP table
REMIT_ADVICE_DELIVERY_METHOD: Remittance advice delivery method. Values from the lookup IBY_DELIVERY_METHODS include EMAIL, FAX, and PRINTED.
*/

		select aisc.checkrun_name
			 , aisc.status
			 , aisc.created_by
			 , to_char(aisc.creation_date, 'yyyy-mm-dd hh24:mi:ss') checkrun_created
			 , apt.template_name
			 , apt.description
			 , apt.payment_method_code
			 , '########' bank_______
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
			 , '########' supplier_inv_______
			 , '#' || aia.invoice_id inv_id
			 , '#' || aia.invoice_num inv_num
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') invoice_date
			 , to_char(aia.invoice_received_date, 'yyyy-mm-dd') invoice_received_date
			 , att.name invoice_terms
			 , hou_inv.name inv_org
			 , psv.vendor_name supplier
			 , psv.segment1 supplier_num
			 , pssam.vendor_site_code site
			 , '########' check_______
			 , aca.check_id
			 , aca.check_number
			 , hou.name check_org
			 , '########' payment_______
			 , ift.format_name payment_instruction_format
			 , to_char(aisc.check_date, 'yyyy-mm-dd') check_date
			 , to_char(aisc.pay_thru_date, 'yyyy-mm-dd') pay_thru_date
			 , aisc.pay_group_option
			 , '#' || aipa.invoice_payment_id invoice_payment_id
			 , aipa.amount aipa_payment_amount
			 , to_char(aipa.creation_date, 'yyyy-mm-dd hh24:mi:ss') aipa_created
			 , '#### payment info ####'
			 , '#' || ipa.payment_instruction_id payment_instruction_id -- payment file name
			 , '#' || ipa.payment_id payment_id
			 , to_char(ipa.creation_date, 'yyyy-mm-dd hh24:mi:ss') ipa_created
			 , to_char(ipa.payment_date, 'yyyy-mm-dd') payment_date
			 , ipa.payment_status
			 , ipa.payment_amount
			 , ipa.payment_reference_number
			 , ipa.paper_document_number payment_number
			 , ipa.ext_branch_number
			 , ipa.ext_bank_account_name
			 , ipa.ext_bank_account_number
			 , ipa.payee_name
			 , ipa.payment_profile_sys_name
			 , ipa.payment_process_request_name
			 , ipa.request_id
			 , ipa.payment_service_request_id
			 , ipa.bep_status
			 , ipa.bep_error_code
			 , ipa.bep_error_message_text
			 , ipa.funds_status_code
			 , ipa.acknowledgement_date
			 , '#### void info ####'
			 , nvl(ipa.voided_by, 'N/A') voided_by
			 , to_char(ipa.void_date, 'yyyy-mm-dd hh24:mi:ss') void_date
			 , ipa.void_reason
			 , '#### remittance info ####'
			 , ipa.separate_remit_advice_req_flag
			 , ipa.remit_advice_delivery_method
			 , ipa.remit_advice_email
			 , iras.remittance_advice_format_code
			 , ift_remit.format_name
		  from ap_inv_selection_criteria_all aisc
	 left join ap_payment_templates apt on apt.template_id = aisc.template_id
	 left join ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
	 left join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
	 left join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
	 left join iby_payment_profiles ipp on apt.payment_profile_id = ipp.payment_profile_id
	 left join iby_formats_b ifb on ifb.format_code = ipp.payment_format_code
	 left join iby_formats_tl ift on ifb.format_code = ift.format_code -- and ift.language = userenv('lang')
	 left join ap_checks_all aca on aca.checkrun_id = aisc.checkrun_id
	 left join hr_operating_units hou on hou.organization_id = aca.org_id
	 left join ap_invoice_payments_all aipa on aipa.check_id = aca.check_id
	 left join ap_invoices_all aia on aia.invoice_id = aipa.invoice_id
	 left join ap_terms_tl att on aia.terms_id = att.term_id and att.language = userenv('lang')
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join hz_parties hp on psv.party_id = hp.party_id
	 left join iby_payments_all ipa on ipa.payment_process_request_name = aisc.checkrun_name and ipa.payment_id = aca.payment_id
	 left join iby_remit_advice_setup iras on ipp.system_profile_code = iras.system_profile_code
	 left join iby_formats_b ifb_remit on ifb_remit.format_code = iras.remittance_advice_format_code
	 left join iby_formats_tl ift_remit on ifb_remit.format_code = ift_remit.format_code
	 left join hr_operating_units hou_inv on aia.org_id = hou_inv.organization_id
		  -- join xle_entity_profiles xep on aia.legal_entity_id = xep.legal_entity_id
		  -- join gl_sets_of_books gsob on aia.set_of_books_id = gsob.set_of_books_id
		  -- join xle_registrations reg on xep.legal_entity_id = reg.source_id
	 -- left join hr_locations_all hrl on hrl.location_id = reg.location_id
	 -- left join hr_operating_units hro on xep.legal_entity_id = hro.default_legal_context_id
		  -- join gl_ledgers gl on hro.set_of_books_id = gl.ledger_id
		 where 1 = 1
		   and 1 = 1
	  order by aisc.creation_date desc

select * from iby_payments_all where payment_process_request_name = 'XCC PAY RUN 26.05.23' -- 927

-- ##############################################################
-- COUNT OF EMAIL ADDRESSES PER PAYMENT
-- ##############################################################

/*
When payment run is done, the "Send Separate Remittance Advice" job has a value in the "request_property" table which is "submit.argument1"
That is the ID of the "payment_instruction_id" from the "IBY_PAYMENTS_ALL" table
So we can get the request ID of the Send Separate Remittance Advice job then check the log file
Look for errors - e.g. might contain
iby.shared.util.ess.program.common.util.SRAAndPayerNotif.doElectronicProcessing()::Warning: error returned from BIP delivery: EMail Delivery Status: Message has been successfully sent to all addresses., Code=0_
*/

		select count(distinct ipa.remit_advice_email)
		  from ap_inv_selection_criteria_all aisc
	 left join ap_payment_templates apt on apt.template_id = aisc.template_id
	 left join ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
	 left join ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
	 left join ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
	 left join iby_payment_profiles ipp on apt.payment_profile_id = ipp.payment_profile_id
	 left join iby_formats_b ifb on ifb.format_code = ipp.payment_format_code
	 left join iby_formats_tl ift on ifb.format_code = ift.format_code -- and ift.language = userenv('lang')
	 left join ap_checks_all aca on aca.checkrun_id = aisc.checkrun_id
	 left join hr_operating_units hou on hou.organization_id = aca.org_id
	 left join ap_invoice_payments_all aipa on aipa.check_id = aca.check_id
	 left join ap_invoices_all aia on aia.invoice_id = aipa.invoice_id
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join hz_parties hp on psv.party_id = hp.party_id
	 left join iby_payments_all ipa on ipa.payment_process_request_name = aisc.checkrun_name and ipa.payment_id = aca.payment_id
	 left join iby_remit_advice_setup iras on ipp.system_profile_code = iras.system_profile_code
	 left join iby_formats_b ifb_remit on ifb_remit.format_code = iras.remittance_advice_format_code
	 left join iby_formats_tl ift_remit on ifb_remit.format_code = ift_remit.format_code
	 left join hr_operating_units hou_inv on aia.org_id = hou_inv.organization_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- COUNTING
-- ##############################################################

		select ipa.payment_process_request_name
			 , ipa.payment_status
			 , ipa.payment_instruction_id
			 , to_char(ipa.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , ipa.created_by
			 , min(ipa.payment_id) min_payment_id
			 , max(ipa.payment_id) max_payment_id
			 , sum(ipa.payment_amount) payment_amount
			 , count(*) payment_count
		  from iby_payments_all ipa
		 where 1 = 1
		   and 1 = 1
	  group by ipa.payment_process_request_name
			 , ipa.payment_status
			 , ipa.payment_instruction_id
			 , to_char(ipa.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , ipa.created_by

-- ##############################################################
-- UNSELECTED INVOICES
-- ##############################################################

		select *
		  from ap_unselected_invoices_all
	  order by creation_date desc

-- ############################################################## 
-- PAYMENT DOCUMENTS
-- ##############################################################

/*
Contains the xml output that can be useful for linking to xsl payment file formats
*/

		select *
		  from iby_trxn_documents
	  order by creation_date desc
