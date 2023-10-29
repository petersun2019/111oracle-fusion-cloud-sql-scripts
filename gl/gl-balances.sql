/*
File Name: gl-balances.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- GL BALANCES ATTEMPT 1
-- GL BALANCES ATTEMPT 2
-- GL BALANCES ATTEMPT 3
-- GL BALANCES ATTEMPT 4

*/

-- ##############################################################
-- GL BALANCES ATTEMPT 1
-- ##############################################################

		select glv.name ledger
			 , gb.period_name
			 , gcc.code_combination_id ccid
			 , '#' || gcc.segment1 seg1
			 , '#' || gcc.segment2 seg2
			 , '#' || gcc.segment3 seg3
			 , '#' || gcc.segment4 seg4
			 , '#' || gcc.segment5 seg5
			 , '#' || gcc.segment6 seg6
			 , '#' || gcc.segment7 seg7
			 , '#' || gcc.segment8 seg8
			 , gb.currency_code
			 , to_char(gp.start_date, 'yyyy-mm-dd') period_start
			 , to_char(gp.end_date, 'yyyy-mm-dd') period_end
			 , gcc.account_type
			 , (nvl(gb.begin_balance_dr, 0) - nvl(gb.begin_balance_cr, 0)) begin_bal
			 , (nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)) period_net
			 , (nvl(gb.begin_balance_dr, 0) - nvl(gb.begin_balance_cr, 0) + nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)) end_bal
			 , to_char(gb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , gb.last_updated_by
		  from gl_balances gb 
		  join gl_code_combinations gcc on gcc.code_combination_id = gb.code_combination_id
		  join gl_periods gp on gb.period_name = gp.period_name
		  join gl_ledgers glv on gb.ledger_id = glv.ledger_id
		 where 1 = 1
		   and 1 = 1
	  order by glv.name
			 , gb.period_name
			 , '#' || gcc.segment1
			 , '#' || gcc.segment2
			 , '#' || gcc.segment3
			 , '#' || gcc.segment4
			 , '#' || gcc.segment5
			 , '#' || gcc.segment6
			 , '#' || gcc.segment7
			 , '#' || gcc.segment8
			 , gb.currency_code
			 , gb.period_year
			 , gb.period_num
			 , gcc.account_type

-- ##############################################################
-- GL BALANCES ATTEMPT 2
-- ##############################################################

		select gb.currency_code
			 , glv.name ledger
			 , gb.period_name
			 , '#' || gcc.segment1
			 , '#' || gcc.segment2
			 , '#' || gcc.segment3
			 , sum(gb.begin_balance_dr) begin_dr
			 , sum(gb.begin_balance_cr) begin_cr
			 , sum(gb.period_net_dr) period_dr
			 , sum(gb.period_net_cr) period_cr
			 , max(to_char(gb.last_update_date, 'yyyy-mm-dd hh24:mi:ss')) max_last_update_date
			 , count(*)
		  from gl_balances gb
		  join gl_code_combinations gcc on gb.code_combination_id = gcc.code_combination_id
		  join gl_period_statuses gps on gps.period_name = gb.period_name
		  join gl_ledgers glv on gb.ledger_id = glv.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by gb.currency_code
			 , glv.name
			 , gb.period_name
			 , '#' || gcc.segment1
			 , '#' || gcc.segment2
			 , '#' || gcc.segment3

-- ##############################################################
-- GL BALANCES ATTEMPT 3
-- ##############################################################

		select glv.name ledger
			 , gb.period_name
			 , '#' || gcc.segment1
			 , '#' || gcc.segment2
			 , '#' || gcc.segment3
			 , sum((gb.begin_balance_dr_beq-gb.begin_balance_cr_beq+gb.period_net_dr_beq-gb.period_net_cr_beq)) - sum(nvl(gb.period_net_dr_beq,0)-nvl(gb.period_net_cr_beq,0)) beginning_balance
			 , sum(nvl(gb.period_net_dr_beq,0)-nvl(gb.period_net_cr_beq,0)) ptd_balance
			 , sum((gb.begin_balance_dr_beq-gb.begin_balance_cr_beq+gb.period_net_dr_beq-gb.period_net_cr_beq)) ytd_balance
			 , count(*)
		  from gl_balances gb
		  join gl_code_combinations gcc on gcc.code_combination_id = gb.code_combination_id
		  join gl_ledgers glv on gb.ledger_id = glv.ledger_id
		 where 1 = 1
		   and 1 = 1
	  group by glv.name
			 , gb.period_name
			 , '#' || gcc.segment1
			 , '#' || gcc.segment2
			 , '#' || gcc.segment3

-- ##############################################################
-- GL BALANCES ATTEMPT 4
-- ##############################################################

		select gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' || gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' || gcc.segment7 cgh_acct
			 , gb.currency_code
			 , gb.period_name
			 , gb.ledger_id
			 , gb.code_combination_id
			 , gb.actual_flag
			 , gb.last_update_date
			 , gb.last_updated_by
			 , gb.budget_version_id
			 , gb.encumbrance_type_id
			 , gb.translated_flag
			 , gb.revaluation_status
			 , gb.period_type
			 , gb.period_year
			 , gb.period_num
			 , gb.period_net_dr
			 , gb.period_net_cr
			 , gb.period_to_date_adb
			 , gb.quarter_to_date_dr
			 , gb.quarter_to_date_cr
			 , gb.quarter_to_date_adb
			 , gb.year_to_date_adb
			 , gb.project_to_date_dr
			 , gb.project_to_date_cr
			 , gb.project_to_date_adb
			 , gb.begin_balance_dr
			 , gb.begin_balance_cr
			 , gb.period_net_dr_beq
			 , gb.period_net_cr_beq
			 , gb.quarter_to_date_dr_beq
			 , gb.quarter_to_date_cr_beq
			 , gb.project_to_date_dr_beq
			 , gb.project_to_date_cr_beq
			 , gb.begin_balance_dr_beq
			 , gb.begin_balance_cr_beq
			 , gb.template_id
			 , gb.encumbrance_doc_id
			 , gb.encumbrance_line_num
			 , gb.object_version_number
		  from gl_balances gb
		  join gl_ledgers glv on gb.ledger_id = glv.ledger_id
		  join gl_code_combinations gcc on gb.code_combination_id = gcc.code_combination_id
		 where 1 = 1
		   and 1 = 1
