/*
File Name: ar-payment-terms.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- AR PAYMENT TERMS
-- ##############################################################

/*
https://docs.oracle.com/en/cloud/saas/financials/23b/oedmf/ratermsb-18567.html#ratermsb-18567
The RA_TERMS_B table stores standard payment term information
*/

		select rtb.term_id
			 , to_char(rtb.creation_date, 'yyyy-mm-dd hh24:mi:ss') term_created
			 , rtb.created_by term_created_by
			 , rtb.credit_check_flag
			 , to_char(rtb.start_date_active, 'yyyy-mm-dd') term_start_date
			 , to_char(rtb.end_date_active, 'yyyy-mm-dd') term_end_date
			 , rtb.base_amount
			 , rtb.calc_discount_on_lines_flag
			 , rtb.discount_basis_date_type
			 , rtb.first_installment_code
			 , rtb.in_use
			 , rtb.partial_discount_flag
			 , rtb.prepayment_flag
			 , rtt.name payment_term_name
			 , rtt.description payment_term_description
		  from ra_terms_b rtb
		  join ra_terms_tl rtt on rtb.term_id = rtt.term_id and rtt.language = userenv('lang')
		 where 1 = 1
		   and rtt.name = 'IMMEDIATE'
		   and 1 = 1
