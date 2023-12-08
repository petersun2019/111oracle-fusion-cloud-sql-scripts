/*
File Name: iby-bank-accounts.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- BANK ACCOUNTS - SUPPLIER / EMPLOYEE / CUSTOMER
-- BANK ACCOUNT OWNERS

*/

-- ##############################################################
-- BANK ACCOUNTS - SUPPLIER / EMPLOYEE / CUSTOMER
-- ##############################################################

		select ieba.ext_bank_account_id
			 , ieba.bank_account_name
			 , ieba.bank_account_num
			 , ieba.currency_code curr
			 , to_char(ieba.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_created
			 , ieba.created_by bank_acct_created_by
			 , to_char(ieba.last_update_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_updated
			 , ieba.last_updated_by bank_acct_updated_by
			 , bank.party_name bank_name
			 , branch.party_name branch_name
			 , branch.party_name branch_number
			 , ipiua.instrument_payment_use_id
			 , ipiua.payment_flow "ipiua.payment_flow payment_flow" -- Specifies funds capture or disbursement flow. Values taken from lookup: IBY_PAYMENT_FLOW. DISBURSEMENT = Paying money out, FUNDS_CAPTURE is money coming in
			 , ipiua.payment_function "ipiua.payment_function"
			 , iepa.payment_function "iepa.payment_function"
			 , ipiua.ext_pmt_party_id
			 , ipiua.instrument_type instrument_type
			 , ipiua.instrument_id
			 , ipiua.order_of_preference order_of_preference
			 , ipiua.primary_flag primary_flag
			 , ipiua.created_by instr_created_by
			 , to_char(ipiua.creation_date, 'yyyy-mm-dd hh24:mi:ss') instr_created
			 , ipiua.last_updated_by instr_updated_by
			 , to_char(ipiua.last_update_date, 'yyyy-mm-dd hh24:mi:ss') instr_updated
			 , to_char(ipiua.start_date, 'yyyy-mm-dd') instr_start
			 , to_char(ipiua.end_date, 'yyyy-mm-dd') instr_end
			 , ps.segment1 vendor_num
			 , party_supplier.party_name vendor_name
			 , party_supplier.address1 || ', ' || party_supplier.address2 || ', ' || party_supplier.address3 || ', ' || party_supplier.city || ', ' || party_supplier.postal_code vendor_address
			 , pssm.vendor_site_code site
			 , prc_bu_id.bu_name procurement_bu
			 , iepa.ext_payee_id "iepa.ext_payee_id"
			 , iepa_ext.ext_payer_id "iepa_ext.ext_payer_id"
			 , iepa.remit_advice_delivery_method remit_advice_delivery_method
			 , iepa.remit_advice_email remit_advice_email
			 , party_employee_fc.party_name employee_funds_capture
			 , papf_fc.person_number person_number_funds_capture
			 , party_employee_fc.address1 || ', ' || party_employee_fc.address2 || ', ' || party_employee_fc.address3 || ', ' || party_employee_fc.city || ', ' || party_employee_fc.postal_code employee_fc_address
			 , party_employee_disb.party_name employee_disb
			 , papf_disb.person_number person_number_disb
			 , party_employee_disb.address1 || ', ' || party_employee_disb.address2 || ', ' || party_employee_disb.address3 || ', ' || party_employee_disb.city || ', ' || party_employee_disb.postal_code employee_disb_address
			 , party_customer.party_name customer_name
			 , hca.account_number customer_acct_num
			 , hps.party_site_number
			 , party_customer.address1 || ', ' || party_customer.address2 || ', ' || party_customer.address3 || ', ' || party_customer.city || ', ' || party_customer.postal_code customer_address
		  from iby_ext_bank_accounts ieba
	 left join hz_parties bank on ieba.bank_id = bank.party_id
	 left join hz_parties branch on ieba.branch_id = branch.party_id
	 left join iby_pmt_instr_uses_all ipiua on ipiua.instrument_id = ieba.ext_bank_account_id
	 -- external_payees_all -- details for PAYEES - entities being paid
	 left join iby_external_payees_all iepa on iepa.ext_payee_id = ipiua.ext_pmt_party_id -- IBY_EXTERNAL_PAYEES_ALL stores payment-related attributes for the funds disbursement payment process for external party payees. This table corresponds to the supplier attributes.
	 left join poz_supplier_sites_all_m pssm on iepa.supplier_site_id = pssm.vendor_site_id
	 left join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pssm.prc_bu_id
	 left join poz_suppliers ps on ps.vendor_id = pssm.vendor_id
	 left join hz_parties party_supplier on party_supplier.party_id = iepa.payee_party_id and iepa.payment_function = 'PAYABLES_DISB' and ipiua.payment_flow = 'DISBURSEMENTS' and ipiua.payment_function = 'PAYABLES_DISB'
	 left join hz_parties party_employee_fc on party_employee_fc.party_id = iepa.payee_party_id and iepa.payment_function = 'EMPLOYEE_EXP'  and ipiua.payment_flow = 'FUNDS_CAPTURE' and ipiua.payment_function = 'CUSTOMER_PAYMENT'
	 left join per_all_people_f papf_fc on papf_fc.person_id = party_employee_fc.orig_system_reference and sysdate between papf_fc.effective_start_date and papf_fc.effective_end_date
	 left join hz_parties party_employee_disb on party_employee_disb.party_id = iepa.payee_party_id and iepa.payment_function = 'EMPLOYEE_EXP'  and ipiua.payment_flow = 'DISBURSEMENTS' and ipiua.payment_function = 'EMPLOYEE_EXP'
	 left join per_all_people_f papf_disb on papf_disb.person_id = party_employee_disb.orig_system_reference and sysdate between papf_disb.effective_start_date and papf_disb.effective_end_date
	 -- external_payers_all -- details for PAYERS - entities paying in
	 left join iby_external_payers_all iepa_ext on iepa_ext.ext_payer_id = ipiua.ext_pmt_party_id and ipiua.payment_flow = 'FUNDS_CAPTURE' and ipiua.payment_function = 'CUSTOMER_PAYMENT' -- Payment attributes of the customer
	 left join hz_parties party_customer on party_customer.party_id = iepa_ext.party_id
	 left join hz_cust_accounts hca on hca.cust_account_id = iepa_ext.cust_account_id
	 left join hz_cust_acct_sites_all hcasa on hcasa.cust_account_id = hca.cust_account_id
	 left join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id
	 left join hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id and iepa_ext.acct_site_use_id = hcsua.site_use_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BANK ACCOUNT OWNERS
-- ##############################################################

		select ieba.ext_bank_account_id
			 , ieba.bank_account_name
			 , ieba.bank_account_num
			 , ieba.currency_code curr
			 , to_char(ieba.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_created
			 , ieba.created_by bank_acct_created_by
			 , to_char(ieba.last_update_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_updated
			 , ieba.last_updated_by bank_acct_updated_by
			 , iao.account_owner_id
			 , iao.primary_flag
			 , to_char(ieba.creation_date, 'yyyy-mm-dd hh24:mi:ss') owner_created
			 , iao.created_by owner_created_by
			 , to_char(iao.last_update_date, 'yyyy-mm-dd hh24:mi:ss') owner_updated
			 , iao.last_updated_by owner_updated_by
			 , to_char(iao.start_date, 'yyyy-mm-dd') owner_start
			 , to_char(iao.end_date, 'yyyy-mm-dd') owner_end
			 , party_owner.party_id
			 , party_owner.party_name
			 , party_owner.party_type
			 , party_owner.orig_system_reference
			 , party_owner.created_by_module
			 , party_owner.address1
			 , party_owner.address2
			 , party_owner.address3
			 , party_owner.city
			 , party_owner.postal_code
			 , psv.vendor_name
			 , psv.segment1 supplier_num
			 , hca.account_number customer_acct_num
			 , papf.person_number
		  from iby_ext_bank_accounts ieba
		  join iby_account_owners iao on ieba.ext_bank_account_id = iao.ext_bank_account_id
		  join hz_parties party_owner on party_owner.party_id = iao.account_owner_party_id
	 left join poz_suppliers_v psv on psv.party_id = party_owner.orig_system_reference and party_owner.created_by_module = 'POS_SUPPLIER_MGMT'
	 left join hz_cust_accounts hca on '#' || hca.cust_account_id = '#' || party_owner.orig_system_reference and party_owner.created_by_module = 'ORA_HZ_DATA_IMPORT'
	 left join per_all_people_f papf on '#' || papf.person_id = '#' || party_owner.orig_system_reference and party_owner.created_by_module = 'PERSON_USER_SERVICE'
		 where 1 = 1
		   and 1 = 1
	  order by to_char(iao.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc
