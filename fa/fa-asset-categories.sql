/*
File Name: fa-asset-categories.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- ASSET CATEGORIES
-- ##############################################################

		select fcb.category_id
			 , fcb.segment1
			 , fcb.segment2
			 , fcb.owned_leased
			 , fcb.category_type
			 , fcb.capitalize_flag
			 , fcb.creation_date
			 , fcb.created_by
			 , fcb.last_update_date
			 , fcb.last_updated_by
			 , fcbook.asset_cost_account_ccid
			 , gcc1.segment1 || '-' || gcc1.segment2 || '-' || gcc1.segment3 || '-' || gcc1.segment4 || '-' || gcc1.segment5 || '-' || gcc1.segment6 asset_cost_account
			 , gcc2.segment1 || '-' || gcc2.segment2 || '-' || gcc2.segment3 || '-' || gcc2.segment4 || '-' || gcc2.segment5 || '-' || gcc2.segment6 asset_clearing_account
			 , gcc3.segment1 || '-' || gcc3.segment2 || '-' || gcc3.segment3 || '-' || gcc3.segment4 || '-' || gcc3.segment5 || '-' || gcc3.segment6 deprn_expense_account
			 , gcc4.segment1 || '-' || gcc4.segment2 || '-' || gcc4.segment3 || '-' || gcc4.segment4 || '-' || gcc4.segment5 || '-' || gcc4.segment6 reserve_account
			 , gcc5.segment1 || '-' || gcc5.segment2 || '-' || gcc5.segment3 || '-' || gcc5.segment4 || '-' || gcc5.segment5 || '-' || gcc5.segment6 bonus_expense_account
			 , gcc6.segment1 || '-' || gcc6.segment2 || '-' || gcc6.segment3 || '-' || gcc6.segment4 || '-' || gcc6.segment5 || '-' || gcc6.segment6 bonus_reserve_acct
			 , fcbook.creation_date book_line_created
			 , fcbook.created_by book_line_created_by
			 , fcbook.last_update_date book_line_last_update_date
			 , fcbook.last_updated_by book_line_last_updated_by
		  from fa_categories_b fcb 
	 left join fa_category_books fcbook on fcbook.category_id = fcb.category_id
	 left join gl_code_combinations gcc1 on gcc1.code_combination_id = fcbook.asset_cost_account_ccid
	 left join gl_code_combinations gcc2 on gcc2.code_combination_id = fcbook.asset_clearing_account_ccid
	 left join gl_code_combinations gcc3 on gcc3.code_combination_id = fcbook.deprn_expense_account_ccid
	 left join gl_code_combinations gcc4 on gcc4.code_combination_id = fcbook.reserve_account_ccid
	 left join gl_code_combinations gcc5 on gcc5.code_combination_id = fcbook.bonus_expense_account_ccid
	 left join gl_code_combinations gcc6 on gcc6.code_combination_id = fcbook.bonus_reserve_acct_ccid
