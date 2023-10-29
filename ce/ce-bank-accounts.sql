/*
File Name: ce-bank-accounts.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- BANK ACCOUNTS
-- BANKS AND BRANCHES

*/

-- ##############################################################
-- BANK ACCOUNTS
-- ##############################################################

		select cba.bank_account_name
			 , cba.bank_account_num
			 , cba.last_update_date
			 , cba.last_updated_by
			 , cba.asset_code_combination_id
			 , cba.cash_clearing_ccid
			 , cba.zero_amount_allowed
		  from ce_bank_accounts cba
		 where 1 = 1
		   and 1 = 1
	  order by 3 desc

-- ##############################################################
-- BANKS AND BRANCHES
-- ##############################################################

		select cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
		  from ce_banks_v cbv
		  join ce_bank_branches_v cbbv on cbv.bank_party_id = cbbv.bank_party_id
		 where 1 = 1
	  order by 2;
