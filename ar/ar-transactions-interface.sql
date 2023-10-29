/*
File Name: ar-transactions-interface.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- LINES
-- DISTRIBUTONS
-- ERRORS
-- DETAILS

*/

-- ##############################################################
-- LINES
-- ##############################################################

		select * 
		  from ra_interface_lines_all 
		 where 1 = 1
		   and interface_line_id = 123456789
		   and interface_line_context = 'INTERNAL_ALLOCATIONS'
		   -- and batch_source_name = 'Global Intercompany'
		   -- and description <> 'Transactions from Global Intercompany'
		   and to_char(creation_date, 'yyyy-mm-dd') > '2023-01-01'
		   and 1 = 1
	  order by creation_date desc

-- ##############################################################
-- DISTRIBUTONS
-- ##############################################################

		select * 
		  from ra_interface_distributions_all
		 where 1 = 1
		   and interface_line_id = 123456789
		   and 1 = 1
	  order by creation_date desc

-- ##############################################################
-- ERRORS
-- ##############################################################

		select * 
		  from ra_interface_errors_all
		 where 1 = 1
		   and  message_text like 'Review and correct%'
		   and 1 = 1
	  order by creation_date desc

-- ##############################################################
-- DETAILS
-- ##############################################################

		select '#' || rila.interface_line_id interface_line_id
			 , '#' || rila.set_of_books_id set_of_books_id
			 , rila.line_type
			 , (replace(replace(rila.description,chr(10),''),chr(13),' ')) description
			 , rila.batch_source_name
			 , rila.cust_trx_type_name
			 , rila.term_name
			 , '#' || rila.term_id term_id
			 , '#' || rila.customer_trx_id customer_trx_id
			 , rila.interface_status
			 , rila.purchase_order
			 , rila.interface_line_context
			 , rila.interface_line_attribute1
			 , rila.interface_line_attribute2
			 , rila.interface_line_attribute3
			 , rila.interface_line_attribute4
			 , rila.interface_line_attribute5
			 , rila.interface_line_attribute6
			 , rila.interface_line_attribute7
			 , rila.interface_line_attribute8
			 , rila.interface_line_attribute9
			 , rila.currency_code
			 , rila.amount
			 , rila.quantity
			 , rila.quantity_ordered
			 , rila.unit_selling_price
			 , rila.orig_system_batch_name
			 , rila.orig_system_bill_customer_ref
			 , '#' || rila.orig_system_bill_customer_id orig_system_bill_customer_id
			 , '#' || rila.orig_system_bill_address_id orig_system_bill_address_id
			 , rila.orig_system_ship_customer_ref
			 , hca_bill.account_number
			 , hp_bill.party_name account_name
			 , rila.receipt_method_id
			 , to_char(rila.trx_date, 'yyyy-mm-dd') trx_date
			 , to_char(rila.gl_date, 'yyyy-mm-dd') gl_date
			 , rila.document_number
			 , rila.trx_number
			 , rila.line_number
			 , rila.request_id
			 , rila.tax_rate
			 , rila.tax_code
			 , rila.tax_regime_code
			 , rila.tax
			 , rila.tax_status_code
			 , rila.tax_rate_code
			 , rila.taxable_amount
			 , rila.taxable_flag
			 , rila.assessable_value
			 , rila.primary_salesrep_number
			 , rila.memo_line_name
			 , rila.memo_line_id
			 , '#' || rila.inventory_item_id inventory_item_id
			 , '#' distributions____
			 , '#' || rida.interface_distribution_id interface_distribution_id
			 , rida.account_class
			 , rida.amount dist_amount
			 , '#' || rida.code_combination_id code_combination_id
			 , '#' || gcc.segment1 segment1
			 , '#' || gcc.segment2 segment2
			 , '#' || gcc.segment3 segment3
			 , '#' || gcc.segment4 segment4
			 , '#' || gcc.segment5 segment5
			 , '#' || gcc.segment6 segment6
			 , '#' || gcc.segment7 segment7
			 , '#' || gcc.segment8 segment8
			 , '#' errors____
			 , riea.message_text error_message
			 , riea.invalid_value
			 , riea.load_request_id -- request id for the "Load Interface File for Import" job that loaded the data to the interface
		  from ra_interface_lines_all rila
		  join ra_interface_distributions_all rida on rila.interface_line_id = rida.interface_line_id
	 left join ra_interface_errors_all riea on rila.interface_line_id = riea.interface_line_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = rida.code_combination_id
	 left join hz_cust_accounts hca_bill on hca_bill.cust_account_id = rila.orig_system_bill_customer_id
	 left join hz_parties hp_bill on hp_bill.party_id = hca_bill.party_id
		 where 1 = 1
		   and rila.interface_line_id = 123456789
		   -- and riea.message_text like 'Review and correct%'
		   and 1 = 1
	  order by creation_date desc
