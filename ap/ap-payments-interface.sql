/*
File Name: ap-payments-interface.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- PAYMENTS INTERFACE 1
-- PAYMENTS INTERFACE 2
-- PAYMENTS INTERFACE REJECTIONS - SUMMARY

*/

-- ##############################################################
-- PAYMENTS INTERFACE 1
-- ##############################################################

/*
Import job: Import Payables Payment Requests
*/

		select apri.payment_request_interface_id
			 , apri.invoice_id
			 , apri.new_invoice_id
			 , apri.load_request_id
			 , '#' || apri.invoice_num
			 , to_char(apri.creation_date, 'yyyy-mm-dd hh24:mi:ss') int_record_created
			 , to_char(apri.last_update_date, 'yyyy-mm-dd hh24:mi:ss') int_record_updated
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , to_char(gcc.creation_date, 'yyyy-mm-dd hh24:mi:ss') code_comb_created
			 , to_char(apri.invoice_date, 'yyyy-mm-dd') invoice_date
			 , apri.amount
			 , apri.invoice_currency_code curr
			 , apri.source
			 , apri.party_name
			 , apri.party_type
			 , apri.address_line1
			 , apri.address_line2
			 , apri.city
			 , apri.postal_code
			 , apri.country
			 , apri.party_orig_system
			 , apri.party_orig_system_reference
			 , apri.bank_country_code
			 , apri.bank_account_num
			 , apri.bank_account_name
			 , apri.branch_number
			 , apri.bank_account_currency_code
			 , apri.operating_unit
			 , apri.legal_entity_name
			 , apri.payment_method_code
			 , apri.terms_name
			 , apri.invoice_description
			 , apri.group_id
			 , apri.line_number
			 , apri.dist_code_concatenated
			 , gcc.code_combination_id ccid
			 , apri.line_description
			 , apri.status
			 , apri.request_id
			 , apri.last_updated_by
			 , apri.created_by
			 , apri.party_id
			 , apri.party_site_id
			 , apri.object_version_number
			 , apri.location_orig_system_reference
			 , apri.batch_id
			 , apri.file_record_num
			 , apri.upload_status
			 , '###################'
			 , air.reject_lookup_code
			 , air.rejection_message
			 , '####################'
			 , aia.invoice_id aia_inv_id
			 , '#' || aia.invoice_num aia_inv_num
			 -- , (select count(aiaha.invoice_id) from ap_inv_aprvl_hist_all aiaha where aiaha.invoice_id = aia.invoice_id) approval_lines_count
		  from ap_payment_requests_int apri
	 left join ap_interface_rejections air on air.parent_id = apri.payment_request_interface_id
	 left join ap_invoices_all aia on aia.invoice_id = apri.new_invoice_id
	 left join gl_code_combinations gcc on gcc.segment1 || '-' || gcc.segment2 || '-' || gcc.segment3 || '-' || gcc.segment4 || '-' || gcc.segment5 || '-' || gcc.segment6 || '-' || gcc.segment7 || '-' || gcc.segment8 = apri.dist_code_concatenated
		 where 1 = 1
		   and 1 = 1
	  order by apri.creation_date desc

-- ##############################################################
-- PAYMENTS INTERFACE 2
-- ##############################################################

		select apri.payment_request_interface_id
			 , apri.invoice_id
			 , apri.load_request_id
			 , apri.invoice_num
			 , apri.invoice_date
			 , apri.amount
			 , apri.invoice_currency_code
			 , apri.accts_pay_code_concatenated
			 , apri.source
			 , apri.party_name
			 , apri.party_type
			 , apri.address_line1
			 , apri.address_line2
			 , apri.address_line3
			 , apri.address_line4
			 , apri.address_lines_phonetic
			 , apri.addr_element_attribute1
			 , apri.addr_element_attribute2
			 , apri.addr_element_attribute3
			 , apri.addr_element_attribute4
			 , apri.addr_element_attribute5
			 , apri.building
			 , apri.floor_number
			 , apri.city
			 , apri.state
			 , apri.province
			 , apri.county
			 , apri.postal_code
			 , apri.postal_plus4_code
			 , apri.country
			 , apri.addressee
			 , apri.global_location_number
			 , apri.party_site_language
			 , apri.phone_country_code
			 , apri.phone_area_code
			 , apri.phone
			 , apri.phone_extension
			 , apri.remit_advice_email
			 , apri.party_orig_system
			 , apri.party_orig_system_reference
			 , apri.third_party_registration_num
			 , apri.bank_country_code
			 , apri.bank_name
			 , apri.bank_number
			 , apri.bank_account_num
			 , apri.bank_account_name
			 , apri.bank_branch_name
			 , apri.branch_number
			 , apri.eft_swift_code
			 , apri.bank_account_currency_code
			 , apri.iban
			 , apri.bank_account_type
			 , apri.secondary_account_reference
			 , apri.check_digits
			 , apri.bank_account_description
			 , apri.bank_account_name_alt
			 , apri.operating_unit
			 , apri.legal_entity_name
			 , apri.payment_method_code
			 , apri.terms_name
			 , apri.invoice_description
			 , apri.group_id
			 , apri.pay_group_lookup_code
			 , apri.doc_category_code
			 , apri.voucher_num
			 , apri.requester_first_name
			 , apri.requester_last_name
			 , apri.payment_priority
			 , apri.payment_reason_comments
			 , apri.line_number
			 , apri.dist_code_concatenated
			 , apri.line_description
			 , apri.line_requester_first_name
			 , apri.line_requester_last_name
			 , apri.distribution_set_name
			 , apri.line_type_lookup_code
			 , apri.status
			 , apri.request_id
			 , apri.job_definition_name
			 , apri.job_definition_package
			 , apri.last_update_date
			 , apri.last_updated_by
			 , apri.last_update_login
			 , apri.creation_date
			 , apri.created_by
			 , apri.attribute_category
			 , apri.attribute1
			 , apri.attribute2
			 , apri.attribute3
			 , apri.attribute4
			 , apri.attribute5
			 , apri.attribute6
			 , apri.attribute7
			 , apri.attribute8
			 , apri.attribute9
			 , apri.attribute10
			 , apri.attribute11
			 , apri.attribute12
			 , apri.attribute13
			 , apri.attribute14
			 , apri.attribute15
			 , apri.reference_key1
			 , apri.reference_key2
			 , apri.reference_key3
			 , apri.reference_key4
			 , apri.reference_key5
			 , apri.party_id
			 , apri.party_site_id
			 , apri.external_bank_account_id
			 , apri.attribute_number1
			 , apri.attribute_number2
			 , apri.attribute_number3
			 , apri.attribute_number4
			 , apri.attribute_number5
			 , apri.attribute_date1
			 , apri.attribute_date2
			 , apri.attribute_date3
			 , apri.attribute_date4
			 , apri.attribute_date5
			 , apri.line_attribute_category
			 , apri.line_attribute1
			 , apri.line_attribute2
			 , apri.line_attribute3
			 , apri.line_attribute4
			 , apri.line_attribute5
			 , apri.line_attribute6
			 , apri.line_attribute7
			 , apri.line_attribute8
			 , apri.line_attribute9
			 , apri.line_attribute10
			 , apri.line_attribute11
			 , apri.line_attribute12
			 , apri.line_attribute13
			 , apri.line_attribute14
			 , apri.line_attribute15
			 , apri.line_attribute_number1
			 , apri.line_attribute_number2
			 , apri.line_attribute_number3
			 , apri.line_attribute_number4
			 , apri.line_attribute_number5
			 , apri.line_attribute_date1
			 , apri.line_attribute_date2
			 , apri.line_attribute_date3
			 , apri.line_attribute_date4
			 , apri.line_attribute_date5
			 , apri.new_invoice_id
			 , apri.object_version_number
			 , apri.location_orig_system_reference
			 , apri.batch_id
			 , apri.file_record_num
			 , apri.upload_status
			 , apri.upload_request_id
			 , apri.account_suffix
			 , apri.payment_reason_code
			 , '######################'
			 , '#' || aia.invoice_num xx_invoice_num
			 , hou.name xx_bu
			 , aia.invoice_type_lookup_code xx_inv_type
			 , aia.source xx_src
			 , (replace(replace(aia.description,chr(10),''),chr(13),' ')) xx_inv_desc
			 , psv.vendor_name xx_supplier
			 , psv.segment1 xx_supp_num
			 , pssam.vendor_site_code xx_site
			 , aia.created_by xx_inv_created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') xx_inv_created
			 , aia.invoice_amount xx_inv_amt
			 , aia.payment_status_flag xx_pay_flag
			 , aia.amount_paid xx_amt_paid
			 , aia.approval_status xx_apprv_status
			 , aia.wfapproval_status xx_wf_apprv_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) xx_accounted
			 , nvl2(aia.cancelled_amount, 'Y', 'N') xx_cancelled
			 , to_char(aia.cancelled_date, 'yyyy-mm-dd') xx_cancelled_date
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) xx_inv_status
			 , (select distinct approver_id from ap_inv_aprvl_hist_all h2 where h2.invoice_id = aia.invoice_id and h2.response = 'ORA_ASSIGNED TO' and approver_id like '%@%' and approver_id != aia.created_by and rownum = 1) xx_other_approver
			 , air.reject_lookup_code
			 , air.rejection_message
		  from ap_payment_requests_int apri
	 left join ap_interface_rejections air on air.parent_id = apri.payment_request_interface_id and air.parent_table = 'AP_PAYMENT_REQUESTS_INT'
	 left join ap_invoices_all aia on aia.invoice_id = apri.new_invoice_id
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- PAYMENTS INTERFACE REJECTIONS - SUMMARY
-- ##############################################################

		select air.parent_table
			 , air.reject_lookup_code
			 , min(to_char(air.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(air.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , count(*)
		  from ap_interface_rejections air
	  group by air.parent_table
			 , air.reject_lookup_code
