/*
File Name: xla-subledger-option.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

https://docs.oracle.com/en/cloud/saas/financials/23a/oedmf/xlasubledgeroptionsv-4106.html#xlasubledgeroptionsv-4106

Queries:

-- XLA_SUBLEDGER_OPTIONS_V
-- SUBLEDGER OPTIONS

*/

-- ##############################################################
-- XLA_SUBLEDGER_OPTIONS_V
-- ##############################################################

		select *
		  from xla_subledger_options_v
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- SUBLEDGER OPTIONS
-- ##############################################################

	SELECT ledg.ledger_id  /* primary or secondary ledger id */
		 , subl.application_id
		 , glr.primary_ledger_id  /* primary ledger for all ledgers */
		 , glr.sl_coa_mapping_id  /* COA Account Mapping ID */
		 , glr.target_ledger_name name
		 , glr.sla_ledger_id
		 , glr.relationship_enabled_flag
		 , glr.alc_default_conv_rate_type
		 , glr.alc_inherit_conversion_type
		 , glr.alc_no_rate_action_code
		 , glr.alc_max_days_roll_rate
		 , ledg.ledger_category_code
		 , ledg.sla_accounting_method_code
		 , ledg.sla_accounting_method_type
		 , ledg.completion_status_code
		 , ledg.currency_code  /* user key */
		 , ledg.short_name  /* ledger short name */
		 , ledg.enable_budgetary_control_flag  /* if budgetary control is used */
		 , ledg.chart_of_accounts_id  /* chart of accounts id */
		 , ledg.period_set_name  /* ledger calendar */
		 , ledg.sla_description_language  /* description language */
		 , ledg.sla_entered_cur_bal_sus_ccid  /* entered currency balancing cc_id */
		 , ledg.latest_encumbrance_year
		 , ledg.sla_bal_by_ledger_curr_flag
		 , ledg.sla_ledger_cur_bal_sus_ccid
		 , ledg.res_encumb_code_combination_id
		 , ledg.rounding_code_combination_id
		 , ledg.bal_seg_column_name  /* column that contains bsv */
		 , ledg.mgt_seg_column_name  /* column that contains msv */
		 , ledg.bal_seg_value_option_code
		 , ledg.mgt_seg_value_option_code
		 , ledg.allow_intercompany_post_flag
		 , ledg.enable_average_balances_flag
		 , ledg.transaction_calendar_id
		 , popt.accounting_mode_code
		 , popt.accounting_mode_override_flag
		 , popt.summary_report_flag
		 , popt.summary_report_override_flag
		 , popt.submit_transfer_to_gl_flag
		 , popt.submit_transfer_override_flag
		 , popt.submit_gl_post_flag
		 , popt.submit_gl_post_override_flag
		 , popt.error_limit
		 , popt.processes
		 , popt.processing_unit_size
		 , lopt.transfer_to_gl_mode_code
		 , lopt.acct_reversal_option_code
		 , lopt.enabled_flag
		 , lopt.capture_event_flag
		 , lopt.rounding_rule_code
		 , subl.je_source_name
		 , subl.control_account_type_code
		 , subl.alc_enabled_flag
		 , subl.valuation_method_flag
		 , lopt.merge_acct_option_code
		 , ledg.suspense_allowed_flag
	  FROM gl_ledgers ledg
	  join gl_ledger_relationships glr on ledg.ledger_id = glr.target_ledger_id
	  join xla_ledger_options lopt on ledg.ledger_id = lopt.ledger_id
 left join xla_launch_options popt on lopt.ledger_id = popt.ledger_id and lopt.application_id = popt.application_id
 left join xla_subledgers subl on subl.application_id = lopt.application_id
	 WHERE 1 = 1
	   and ledg.object_type_code = 'L' /* only ledgers ( not ledger sets ) */
	   AND ledg.le_ledger_type_code = 'L' /* only legal ledgers */
	   AND ledg.ledger_category_code in ('PRIMARY',  'SECONDARY')
	   AND glr.application_id = 101
	   AND ((glr.relationship_type_code = 'SUBLEDGER') OR (glr.target_ledger_category_code = 'PRIMARY' AND glr.relationship_type_code = 'NONE'))
