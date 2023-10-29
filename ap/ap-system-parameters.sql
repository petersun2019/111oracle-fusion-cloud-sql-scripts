/*
File Name: ap-system-parameters.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- AP SYSTEM PARAMETERS
-- ##############################################################

		select gl.name ledger
			 , gsob.name set_of_books
			 , hou.name org
			 , to_char(aspa.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_updated
			 , aspa.last_updated_by
			 , to_char(aspa.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , aspa.created_by
			 , aspa.recalc_pay_schedule_flag -- Flag that indicates whether Recalculate Payment Installments (Y or N)
			 , aspa.prepayment_available_mesg_flag -- Indicates whether available prepayments are shown during invoice entry
			 , aspa.require_invoice_group_flag -- Setting that indicates whether invoice group is mandatory during invoice entry
			 , aspa.base_currency_code -- Functional currency code associated with the ledger
			 , aspa.invoice_currency_code
			 , aspa.payment_currency_code
			 , att.name invoice_terms
			 , aspa.pay_date_basis_lookup_code -- Basis used for selecting invoices for payment
			 , aspa.add_days_settlement_date -- Number of days added to system date to calculate settlement date for a prepayment
			 , aspa.days_between_check_cycles -- Number of days between normal payment printing cycles, used to determine Pay Through Date for automatic payment batch
			 , hla.location_code -- Location identifier for headquarters location of your company (prints on 1099 forms)
			 , aspa.terms_date_basis -- Date used together with payment terms and invoice amount to create invoice scheduled payment
			 , aspa.gl_transfer_mode -- GL Interface Transfer Summary Level. Detail (D), summarized by accounting date (A), summarized by accounting period (P)
			 , aspa.approval_workflow_flag
			 , aspa.allow_force_approval_flag
			 , aspa.validate_before_approval_flag
			 , gcc_liability.segment1 || '.' || gcc_liability.segment2 || '.' || gcc_liability.segment3 || '.' || gcc_liability.segment4 || '.' || gcc_discount.segment5 || '.' || gcc_liability.segment6 code_comb_liability -- Accounting Flexfield identifier for accounts payable liability account
			 , gcc_discount.segment1 || '.' || gcc_discount.segment2 || '.' || gcc_discount.segment3 || '.' || gcc_discount.segment4 || '.' || gcc_liability.segment5 || '.' || gcc_discount.segment6 code_comb_discounts -- Accounting Flexfield identifier for discounts taken account
			 , gcc_prepay.segment1 || '.' || gcc_prepay.segment2 || '.' || gcc_prepay.segment3 || '.' || gcc_prepay.segment4 || '.' || gcc_prepay.segment5 || '.' || gcc_prepay.segment6 code_comb_prepayment -- Accounting Flexfield identifier for prepayment account
			 , gcc_gain.segment1 || '.' || gcc_gain.segment2 || '.' || gcc_gain.segment3 || '.' || gcc_gain.segment4 || '.' || gcc_gain.segment5 || '.' || gcc_gain.segment6 code_comb_gain -- Accounting Flexfield identifier for account to which realized exchange rate gains are posted
			 , gcc_loss.segment1 || '.' || gcc_loss.segment2 || '.' || gcc_loss.segment3 || '.' || gcc_loss.segment4 || '.' || gcc_loss.segment5 || '.' || gcc_loss.segment6 code_comb_loss -- Accounting Flexfield identifier for account to which realized exchange rate losses are posted			 
		  from ap_system_parameters_all aspa
		  join gl_ledgers gl on aspa.set_of_books_id = gl.ledger_id
		  join gl_sets_of_books gsob on gsob.set_of_books_id = aspa.set_of_books_id
		  join hr_operating_units hou on hou.organization_id = aspa.org_id
	 left join ap_terms_tl att on att.term_id = aspa.terms_id and att.language = userenv('lang')
	 left join gl_code_combinations gcc_liability on gcc_liability.code_combination_id = aspa.accts_pay_code_combination_id
	 left join gl_code_combinations gcc_discount on gcc_discount.code_combination_id = aspa.disc_taken_code_combination_id
	 left join gl_code_combinations gcc_prepay on gcc_prepay.code_combination_id = aspa.prepay_code_combination_id
	 left join gl_code_combinations gcc_gain on gcc_gain.code_combination_id = aspa.gain_code_combination_id
	 left join gl_code_combinations gcc_loss on gcc_loss.code_combination_id = aspa.loss_code_combination_id
	 left join hr_locations_all hla on hla.location_id = aspa.location_id
		 where 1 = 1
		   and 1 = 1
