/*
File Name: sa-hr-records-bank-details.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- BANK ACCOUNT DETAILS FOR STAFF
-- ##############################################################

		select per.person_number
			 , '#' || eba.bank_account_num bank_account_num
			 , p.primary_flag
			 , ppnf.first_name
			 , ppnf.last_name
			 , ppnf.full_name
		  from hz_parties h
		  join hz_orig_sys_references hosp on hosp.owner_table_id = h.party_id
		  join per_all_people_f per on to_number(hosp.orig_system_reference) = per.person_id
		  join per_person_names_f ppnf on ppnf.person_id = per.person_id and ppnf.name_type = 'GLOBAL'
		  join iby_account_owners ao on ao.account_owner_party_id = h.party_id
		  join iby_ext_bank_accounts eba on eba.ext_bank_account_id = ao.ext_bank_account_id
		  join iby_external_payees_all x on x.payee_party_id = h.party_id
		  join iby_pmt_instr_uses_all p on x.ext_payee_id = p.ext_pmt_party_id and p.instrument_id = ao.ext_bank_account_id
		 where hosp.owner_table_name = 'HZ_PARTIES'
		   and hosp.orig_system = 'FUSION_HCM'
		   and sysdate between eba.start_date and eba.end_date
		   and sysdate between per.effective_start_date and per.effective_end_date
		   and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	  order by eba.last_update_date
