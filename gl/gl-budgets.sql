/*
File Name: gl-budgets.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

If you use "Import General Ledger Budget Balances" FBDI files to import budget balance data these queries might be useful

Queries:

-- INTERFACE BASIC
-- INTERFACE SUMMARY
-- BUDGET - BASIC DETAILS 1
-- BUDGET - BASIC DETAILS 2
-- BUDGET SUMMARY
-- BUDGETS AND ACTUALS ATTEMPT

*/

-- ##############################################################
-- INTERFACE BASIC
-- ##############################################################

		select *
		  from gl_budget_interface
		 where 1 = 1
		   -- and status = 'VALIDATED'
		   and 1 = 1
	  order by creation_date desc

-- ##############################################################
-- INTERFACE SUMMARY
-- ##############################################################

		select run_name
			 , budget_name
			 , created_by
			 , status
			 -- , period_name
			 , max(to_char(creation_date, 'yyyy-mm-dd')) creation_date
			 , count(*)
		  from gl_budget_interface
		 where status = 'VALIDATED'
	  group by run_name
			 , budget_name
			 , created_by
			 , status
			 -- , period_name

-- ##############################################################
-- BUDGET - BASIC DETAILS 1
-- ##############################################################

		select *
		  from gl_budget_balances
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGET - BASIC DETAILS 2
-- ##############################################################

		select budget_name
			 , period_name
			 , segment1
			 , segment2
			 , segment3
			 , segment4
			 , segment5
			 , segment6
			 , concat_account
			 , currency_type
			 , period_net_dr
			 , period_net_cr
			 , case when period_net_dr <> 0 then 'DR' end dr_check
			 , case when period_net_cr <> 0 then 'CR' end cr_check
			 , case when period_net_dr = 0 and period_net_cr = 0 then 'both_zero' end zero_check
			 , case when period_net_dr <> 0 or period_net_cr <> 0 then (case when period_net_dr <> 0 then period_net_dr when period_net_cr <> 0 then -1 * period_net_cr end) else 0 end budget_amount
			 , to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , created_by
		  from gl_budget_balances
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- BUDGET SUMMARY
-- ##############################################################

		select budget_name
			 , period_name
			 -- , segment1
			 -- , period_name
			 , min(to_char(creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(creation_date, 'yyyy-mm-dd')) max_creation_date
			 -- , sum(case when period_net_dr <> 0 or period_net_cr <> 0 then (case when period_net_dr <> 0 then period_net_dr when period_net_cr <> 0 then -1 * period_net_cr end) else (select 0 from dual) end) value
			 , count(*)
		  from gl_budget_balances
	  group by budget_name
			 , period_name
			 -- , segment1
			 -- , period_name

-- ##############################################################
-- BUDGETS AND ACTUALS ATTEMPT
-- ##############################################################

with budget as
	   (select gbb.period_name
			 , gbb.segment1
			 , gbb.segment2
			 , round(sum(case when gbb.period_net_dr <> 0 or gbb.period_net_cr <> 0 then (case when gbb.period_net_dr <> 0 then gbb.period_net_dr when gbb.period_net_cr <> 0 then -1 * gbb.period_net_cr end) else (select 0 from dual) end),2) budget
		  from gl_budget_balances gbb
		 where 1 = 1
		   and gbb.budget_name = 'Current Annual Budget'
		   and 1 = 1
	  group by gbb.budget_name
			 , gbb.period_name
			 , gbb.segment1
			 , gbb.segment2)
, forecast as
	   (select gbb.period_name
			 , gbb.segment1
			 , gbb.segment2
			 , round(sum(case when gbb.period_net_dr <> 0 or gbb.period_net_cr <> 0 then (case when gbb.period_net_dr <> 0 then gbb.period_net_dr when gbb.period_net_cr <> 0 then -1 * gbb.period_net_cr end) else (select 0 from dual) end),2) forecast
		  from gl_budget_balances gbb
		 where 1 = 1
		   and gbb.budget_name = 'Current Forecast'
		   and 1 = 1
	  group by gbb.budget_name
			 , gbb.period_name
			 , gbb.segment1
			 , gbb.segment2)
		select gjh.period_name period
			 , gcc.segment1
			 , gcc.segment2
			 , gl_flexfields_pkg.get_description_sql(1234, 1, gcc.segment1) seg1_descr -- pass in chart_of_accounts_id and segment number to get segment description
			 , gl_flexfields_pkg.get_description_sql(1234, 2, gcc.segment2) seg2_descr -- pass in chart_of_accounts_id and segment number to get segment description
			 , nvl(sum(gjl.accounted_dr),0) - nvl(sum(gjl.accounted_cr),0) actual
			 , budget.budget
			 , forecast.forecast
		  from gl_je_headers gjh
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_code_combinations gcc on gjl.code_combination_id = gcc.code_combination_id
		  join budget budget on budget.period_name = gjh.period_name and gcc.segment1 = budget.segment1 and gcc.segment2 = budget.segment2
		  join forecast forecast on forecast.period_name = gjh.period_name and gcc.segment1 = forecast.segment1 and gcc.segment2 = forecast.segment2
		 where 1 = 1
		   and gjh.status = 'P'
		   and 1 = 1
	  group by gjh.period_name
			 , gcc.segment1
			 , gcc.segment2
			 , gl_flexfields_pkg.get_description_sql(1234, 1, gcc.segment1)
			 , gl_flexfields_pkg.get_description_sql(1234, 2, gcc.segment2)
			 , budget.budget
			 , forecast.forecast
