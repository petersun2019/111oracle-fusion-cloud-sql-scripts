/*
File Name: gl-ledgers-legal-entities.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- GL LEDGERS AND LEGAL ENTITIES
-- GL LEDGERS AND LEGAL ENTITIES - BASIC
-- GL LEDGERS, LEGAL ENTITIES, BUSINESS UNITS
-- GL LEDGERS, CALENDARS AND CUBES
-- GL LEDGERS - TABLE DUMP

*/

-- ##############################################################
-- GL LEDGERS AND LEGAL ENTITIES
-- ##############################################################

/*
https://rpforacle.blogspot.com/2019/12/legal-entity-and-ledger-relationship-table.html
*/

		select lep.legal_entity_id
			 , lep.name legal_entity_name
			 , reg.registered_name
			 , gl.name ledger_name
			 , hro.name ou_name
			 , hrl.location_code
			 , reg.registration_number
			 , hro.set_of_books_id
			 , gl.ledger_id
		  from xle_entity_profiles lep
	 left join xle_registrations reg on lep.legal_entity_id = reg.source_id
	 left join hr_locations_all hrl on hrl.location_id = reg.location_id
	 left join hr_operating_units hro on lep.legal_entity_id = hro.default_legal_context_id
	 left join gl_ledgers gl on hro.set_of_books_id = gl.ledger_id
		 where 1 = 1
		   and lep.transacting_entity_flag = 'Y'
		   and reg.source_table = 'XLE_ENTITY_PROFILES'
		   and reg.identifying_flag = 'Y'

-- ##############################################################
-- GL LEDGERS AND LEGAL ENTITIES - BASIC
-- ##############################################################

		select *
		  from gl_ledger_le_v gl_ledger_le_v
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- GL LEDGERS, LEGAL ENTITIES, BUSINESS UNITS
-- ##############################################################

/*
https://appsoracle-abhi.blogspot.com/2018/12/oracle-fusion-business-unit-ledgers.html
*/

		select hov.name bu_name
			 , hlafv.description location
			 , ppnfv.list_name manager_name
			 , decode(hov.status,'A','Active','Inactive') status
			 , gl_ledger_le_v.legal_entity_name as legal_entity_name
			 , gl_ledger_le_v.ledger_name as ledger_name
			 , fssv.set_code
			 , fssv.set_name
			 , gl_ledger_le_v.chart_of_accounts_id
			 , gl_ledger_le_v.legal_entity_id
			 , gl_ledger_le_v.ledger_id
		  from hr_organization_v hov
		  join hr_org_details_by_class_v hodbcv on hov.organization_id = hodbcv.organization_id and hov.classification_code = hodbcv.classification_code and hodbcv.org_information_context = hov.classification_code
		  join gl_ledger_le_v gl_ledger_le_v on hodbcv.org_information2 = gl_ledger_le_v.legal_entity_id and hodbcv.org_information3 = gl_ledger_le_v.ledger_id
	 left join fun_fin_business_units_v ffbuv on hodbcv.org_information7 = ffbuv.bu_id
	 left join fnd_setid_sets_vl fssv on hodbcv.org_information4 = fssv.set_id
	 left join hr_locations_all_f_vl hlafv on hov.location_id = hlafv.location_id
	 left join per_person_names_f_v ppnfv on hodbcv.org_information1 = ppnfv.person_id
		 where 1 = 1
		   and hov.classification_code = 'FUN_BUSINESS_UNIT'
		   and 1 = 1
	  order by hov.name

-- ##############################################################
-- GL LEDGERS, CALENDARS AND CUBES
-- ##############################################################

		select gl_ledgers.ledger_id ledger_id
			 , gl_ledgers.name
			 , gl_ledgers.short_name
			 , gl_ledgers.description
			 , gl_ledgers.ledger_category_code
			 , gl_ledgers.le_ledger_type_code
			 , gl_ledgers.completion_status_code
			 , gl_ledgers.currency_code
			 , gl_ledgers.period_set_name
			 , gl_ledgers.accounted_period_type
			 , gl_ledgers.allow_intercompany_post_flag
			 , gl_ledgers.enable_average_balances_flag
			 , gl_ledgers.enable_budgetary_control_flag
			 , gl_calendars.user_period_set_name
			 , decode(gl_ledgers.ledger_category_code, 'PRIMARY','Primary', 'SECONDARY', 'Secondary' ,gl_ledgers.ledger_category_code) ledger_category
			 , decode(gl_ledgers.completion_status_code, 'CONFIRMED', 'Confirmed', 'NOT_STARTED', 'Not Started', 'ERROR', 'Error',gl_ledgers.completion_status_code) completion_status
			 , gl_balances_cubes.application_name cube
		  from gl_ledgers gl_ledgers
		  join gl_calendars gl_calendars on gl_ledgers.period_set_name = gl_calendars.period_set_name and gl_ledgers.accounted_period_type = gl_calendars.period_type
	 left join gl_balances_cubes gl_balances_cubes on gl_balances_cubes.period_set_name = gl_ledgers.period_set_name and gl_balances_cubes.chart_of_accounts_id = gl_ledgers.chart_of_accounts_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- GL LEDGERS - TABLE DUMP
-- ##############################################################

		select ledger_id
			 , name
			 , short_name
			 , description
			 , ledger_category_code
			 , alc_ledger_type_code
			 , object_type_code
			 , le_ledger_type_code
			 , completion_status_code
			 , chart_of_accounts_id
			 , currency_code
			 , period_set_name
			 , accounted_period_type
			 , first_ledger_period_name
			 , ret_earn_code_combination_id
			 , suspense_allowed_flag
			 , allow_intercompany_post_flag
			 , track_rounding_imbalance_flag
			 , enable_average_balances_flag
			 , enable_budgetary_control_flag
			 , require_budget_journals_flag
			 , enable_je_approval_flag
			 , enable_automatic_tax_flag
			 , consolidation_ledger_flag
			 , translate_eod_flag
			 , translate_qatd_flag
			 , translate_yatd_flag
			 , automatically_created_flag
			 , bal_seg_value_option_code
			 , bal_seg_column_name
			 , mgt_seg_value_option_code
			 , bal_seg_value_set_id
			 , future_enterable_periods_limit
			 , ledger_attributes
			 , latest_opened_period_name
			 , latest_encumbrance_year
			 , sla_accounting_method_code
			 , sla_accounting_method_type
			 , sla_description_language
			 , sla_bal_by_ledger_curr_flag
			 , to_char(last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , last_updated_by
			 , creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , created_by
			 , enable_reconciliation_flag
			 , create_je_flag
			 , sla_ledger_cash_basis_flag
			 , complete_flag
			 , object_version_number
			 , ussgl_option_code
			 , validate_journal_ref_date
			 , jrnls_group_by_date_flag
			 , autorev_after_open_prd_flag
			 , prior_prd_notification_flag
			 , pop_up_stat_account_flag
			 , number_of_processors
			 , processing_unit_size
			 , sequencing_mode_code
			 , enf_seq_date_correlation_code
			 , net_closing_bal_flag
			 , strict_period_close_flag
			 , income_stmt_adb_status_code
			 , balance_mje_by_currency_flag
			 , single_currency_journal_flag
			 , partition_group_code
		  from gl_ledgers gl
		 where 1 = 1
		   and 1 = 1
