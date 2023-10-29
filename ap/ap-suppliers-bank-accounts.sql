/*
File Name: ap-suppliers-bank-accounts.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- SUPPLIER BANK ACCOUNTS 1
-- SUPPLIER BANK ACCOUNTS 2 - WITHOUT IBY_PMT_INSTR_USES_ALL TABLE
-- SUPPLIER BANK ACCOUNTS 3 - SUPPLIERS LIST, LISTS SUPPLIER EVEN IF NO BANK ACCOUNT
-- BANK ACCOUNTS, BANKS AND BRANCHES

*/

-- ##############################################################
-- SUPPLIER BANK ACCOUNTS 1
-- ##############################################################

		select '#' || ieb.ext_bank_account_id ext_bank_account_id
			 , '#' supplier________
			 , ps.segment1 as vendor_num
			 , hzp.party_name as vendor_name
			 , pssm.vendor_site_code site
			 , pssm.purchasing_site_flag
			 , pssm.pay_site_flag
			 , prc_bu_id.bu_name procurement_bu
			 , '#' person_____
			 , hp_empl.party_number person_party_num
			 , '#' || hp_empl.party_id person_party_id
			 , hp_empl.party_name person_party_name
			 , '#' bank_acct_____
			 , ieb.bank_account_name
			 , ieb.bank_account_num
			 , ieb.currency_code
			 , ieb.secondary_account_reference
			 , ieb.iban
			 , to_char(ieb.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_created
			 , ieb.created_by bank_acct_created_by
			 , to_char(ieb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_updated
			 , ieb.last_updated_by bank_acct_updated_by
			 , bank.party_name bank_name
			 , branch.party_name branch_name
			 , branch.party_name branch_number
			 , to_char(uses.start_date, 'yyyy-mm-dd') bank_acct_assignment_start
			 , to_char(uses.end_date, 'yyyy-mm-dd') bank_acct_assignment_end
			 , '#' instrument_____________
			 , '#' || ipiua.instrument_payment_use_id instrument_payment_use_id
			 , ipiua.payment_flow -- Specifies funds capture or disbursement flow. Values taken from lookup: IBY_PAYMENT_FLOW. DISBURSEMENT = Paying money out, FUNDS_CAPTURE is money coming in
			 , '#' || ipiua.ext_pmt_party_id ext_pmt_party_id
			 , ipiua.instrument_type
			 , '#' || ipiua.instrument_id instrument_id
			 , ipiua.payment_function
			 , ipiua.order_of_preference
			 , ipiua.primary_flag
			 , ipiua.created_by instr_created_by
			 , to_char(ipiua.creation_date, 'yyyy-mm-dd hh24:mi:ss') instr_created
			 , ipiua.last_updated_by instr_updated_by
			 , to_char(ipiua.last_update_date, 'yyyy-mm-dd hh24:mi:ss') instr_updated
			 , to_char(ipiua.start_date, 'yyyy-mm-dd') instr_start
			 , to_char(ipiua.end_date, 'yyyy-mm-dd') instr_end
		  from iby_ext_bank_accounts ieb
	 left join hz_parties bank on ieb.bank_id = bank.party_id
	 left join hz_parties branch on ieb.branch_id = branch.party_id
	 left join iby_pmt_instr_uses_all uses on uses.instrument_id = ieb.ext_bank_account_id
	 left join iby_external_payees_all payee on payee.ext_payee_id = uses.ext_pmt_party_id
	 left join poz_supplier_sites_all_m pssm on payee.supplier_site_id = pssm.vendor_site_id
	 left join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pssm.prc_bu_id
	 left join poz_suppliers ps on ps.vendor_id = pssm.vendor_id
	 left join hz_parties hzp on hzp.party_id = ps.party_id
	 left join iby_pmt_instr_uses_all ipiua on ipiua.instrument_id = ieb.ext_bank_account_id
	 left join hz_parties hp_empl on hp_empl.party_id = payee.payee_party_id and ipiua.payment_function = 'EMPLOYEE_EXP' and hp_empl.party_type = 'PERSON'
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUPPLIER BANK ACCOUNTS 2 - WITHOUT IBY_PMT_INSTR_USES_ALL TABLE
-- ##############################################################

		select'#' || ieb.ext_bank_account_id ext_bank_account_id
			 , prc_bu_id.bu_name procurement_bu
			 , ieb.bank_account_name
			 , ieb.bank_account_num
			 , ieb.currency_code
			 , to_char(ieb.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_created
			 , ieb.created_by bank_acct_created_by
			 , to_char(ieb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_updated
			 , ieb.last_updated_by bank_acct_updated_by
			 , bank.party_name bank_name
			 , branch.party_name branch_name
			 , branch.party_name branch_number
			 , to_char(uses.start_date, 'yyyy-mm-dd') bank_acct_assignment_start
			 , to_char(uses.end_date, 'yyyy-mm-dd') bank_acct_assignment_end
		  from iby_ext_bank_accounts ieb
	 left join hz_parties bank on ieb.bank_id = bank.party_id
	 left join hz_parties branch on ieb.branch_id = branch.party_id
	 left join iby_pmt_instr_uses_all uses on uses.instrument_id = ieb.ext_bank_account_id
	 left join iby_external_payees_all payee on payee.ext_payee_id = uses.ext_pmt_party_id
	 left join poz_supplier_sites_all_m pssm on payee.supplier_site_id = pssm.vendor_site_id
	 left join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pssm.prc_bu_id
	 left join poz_suppliers ps on ps.vendor_id = pssm.vendor_id
	 left join hz_parties hzp on hzp.party_id = ps.party_id
		 where 1 = 1
		   and 1 = 1
		  
-- ##############################################################
-- SUPPLIER BANK ACCOUNTS 3 - SUPPLIERS LIST, LISTS SUPPLIER EVEN IF NO BANK ACCOUNT
-- ##############################################################

		select ps.segment1 as vendor_num
			 , '#' || ieb.ext_bank_account_id ext_bank_account_id
			 , prc_bu_id.bu_name procurement_bu
			 , hzp.party_name as vendor_name
			 , pssm.vendor_site_code site
			 , pssm.purchasing_site_flag
			 , pssm.pay_site_flag
			 , bank.party_name bank_name
			 , branch.party_name branch_name
			 , branch.party_name branch_number
			 , ieb.bank_account_name
			 , ieb.bank_account_num
			 , ieb.currency_code
			 , to_char(ieb.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_created
			 , ieb.created_by bank_acct_created_by
			 , to_char(ieb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_updated
			 , ieb.last_updated_by bank_acct_updated_by
			 , to_char(uses.start_date, 'yyyy-mm-dd') bank_acct_assignment_start
			 , to_char(uses.end_date, 'yyyy-mm-dd') bank_acct_assignment_end
		  from poz_suppliers ps
		  join poz_supplier_sites_all_m pssm on ps.vendor_id = pssm.vendor_id
		  join hz_parties hzp on hzp.party_id = ps.party_id
	 left join iby_external_payees_all payee on ps.party_id = payee.payee_party_id -- and payee.supplier_site_id = pssm.vendor_site_id
	 left join iby_pmt_instr_uses_all uses on payee.ext_payee_id = uses.ext_pmt_party_id
	 left join iby_ext_bank_accounts ieb on uses.instrument_id = ieb.ext_bank_account_id
	 left join hz_parties bank on ieb.bank_id = bank.party_id
	 left join hz_parties branch on ieb.branch_id = branch.party_id
	 left join fun_all_business_units_v prc_bu_id on prc_bu_id.bu_id = pssm.prc_bu_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUPPLIER BANK ACCOUNTS 4
-- ##############################################################

/*
https://www.oracleappsdna.com/2021/01/oracle-erp-cloud-sql-query-to-find-bank-accounts-associated-with-a-supplier/
*/

		SELECT '#' || ieb.ext_bank_account_id ext_bank_account_id
			 , ieb.bank_account_name
			 , ieb.bank_account_num
			 , nvl(ieb.currency_code, 'No Currency Defined') currency_code
			 , ieb.bank_account_name_alt transit_number
			 , to_char(ieb.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_created
			 , ieb.created_by bank_acct_created_by
			 , to_char(ieb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') bank_acct_updated
			 , ieb.last_updated_by bank_acct_updated_by
			 , ieb.secondary_account_reference routing_number
			 , ps.segment1 vendor_num
			 , hzp.party_name vendor_name
			 , pssm.vendor_site_code
			 , bank.party_name bank_name
			 , branch.party_name branch_name
		  from iby_ext_bank_accounts ieb
		  join iby_pmt_instr_uses_all uses on uses.instrument_id = ieb.ext_bank_account_id
		  join iby_external_payees_all payee on payee.ext_payee_id = uses.ext_pmt_party_id
		  join poz_suppliers ps on ps.party_id = payee.payee_party_id
		  join poz_supplier_sites_all_m pssm on ps.vendor_id = pssm.vendor_id and payee.supplier_site_id = pssm.vendor_site_id
	 left join hz_parties bank on ieb.bank_id = bank.party_id
	 left join hz_parties branch on ieb.branch_id = branch.party_id
	 left join hz_parties hzp on hzp.party_id = ps.party_id
	     where 1 = 1
		   and sysdate between nvl(uses.start_date,sysdate) and nvl(uses.end_date,sysdate)
		   and sysdate between nvl(ieb.start_date,sysdate) and nvl(ieb.end_date,sysdate)
		   and nvl(ps.end_date_active,sysdate+1) > trunc (sysdate)
		   and nvl(pssm.inactive_date,sysdate+1) > trunc (sysdate)
		   and uses.instrument_type = 'BANKACCOUNT'
		   and uses.payment_function = 'PAYABLES_DISB'
		   and 1 = 1

-- ##############################################################
-- BANK ACCOUNTS, BANKS AND BRANCHES
-- ##############################################################

		select ieb.ext_bank_account_id
			 , ieb.bank_account_name
			 , ieb.bank_account_num
			 , ieb.currency_code
			 , to_char(ieb.creation_date, 'yyyy-mm-dd hh24:mi:ss') bank_created
			 , ieb.created_by bank_created_by
			 , bank.party_name bank_name
			 , branch.party_name branch_name
			 , branch.party_name branch_number
		  from iby_ext_bank_accounts ieb
	 left join hz_parties branch on ieb.branch_id = branch.party_id
	 left join hz_parties bank on ieb.bank_id = bank.party_id
		 where 1 = 1
		   and 1 = 1
