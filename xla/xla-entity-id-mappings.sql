/*
File Name: xla-entity-id-mappings.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Why is the XLA_ENTITY_ID_MAPPINGS table useful?
-- ##################################################################

As described here:

http://www.oracleappstoday.com/2014/05/join-gl-tables-with-xla-subledger.html

The source_id_int_1 column of XLA_TRANSACTION_ENTITIES stores the primary_id value for the transactions.
You can join the XLA_TRANSACTION_ENTITIES table with the corresponding transactions table for obtaining additional information of the transaction.
For e.g you join the XLA_TRANSACTION_ENTITIES table with RA_CUSTOMER_TRX_ALL for obtaining receivables transactions information 
or with MTL_MATERIAL_TRANSACTIONS table for obtaining material transactions information.
The ENTITY_ID mappings can be obtained from the XLA_ENTITY_ID_MAPPINGS table

And also here:

http://interestingoracle.blogspot.com/2016/10/gl-sourceidint1-mappings.html

The SOURCE_ID_INT_1 on the XLA_TRANSACTION_ENTITIES table can be used to join from SLA to related transactions in the sub-ledgers.
There is a very useful table called XLA_ENTITY_ID_MAPPINGS which contains the mapping information.

For example, for an AP Invoice, the query below returns:

APPLICATION_ID: 200
ENTITY_CODE: AP_INVOICES
APP: AP
APPLICATION_NAME: Payables
SOURCE_ID_COL_NAME_1: SOURCE_ID_INT_1
TRANSACTION_ID_COL_NAME_1: INVOICE_ID

Therefore, we can see that if the XLA_TRANSACTION_ENTITIES table contains an entry where the ENTITY_CODE = "AP_INVOICES" then
The info in the XLA_ENTITY_ID_MAPPINGS confirms that the SOURCE_ID_INT_1 value will be the INVOICE_ID of the AP Invoice.

This helps with being able to work out e.g. the SQL to find the XLA and journal info linked to a specific source transaction.

Related Queries:

xla/05_xla_all.sql
gl/gl-journals-xla.sql

Queries:

-- SOURCE_ID_INT_1 MAPPINGS
-- MAPPING SUMMARY FOR MAPPINGS IN USE, LINKED TO SLA AND GL JOURNAL TABLES

*/

-- ##################################################################
-- SOURCE_ID_INT_1 MAPPINGS
-- ##################################################################

		select fa.application_id
			 , fa.application_short_name app
			 , fat.application_name
			 , xeim.entity_code
			 , xeim.source_id_col_name_1
			 , xeim.transaction_id_col_name_1
			 , xeim.source_id_col_name_2
			 , xeim.transaction_id_col_name_2
			 , xeim.source_id_col_name_3
			 , xeim.transaction_id_col_name_3
			 , xeim.source_id_col_name_4
			 , xeim.transaction_id_col_name_4
		  from xla_entity_id_mappings xeim
		  join fnd_application fa on xeim.application_id = fa.application_id
		  join fnd_application_tl fat on fa.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  order by fat.application_name
			 , xeim.entity_code

-- ##################################################################
-- MAPPING SUMMARY FOR MAPPINGS IN USE, LINKED TO SLA AND GL JOURNAL TABLES
-- ##################################################################

		select gl.name ledger
			 , gjst.user_je_source_name source
			 , gjct.user_je_category_name category
			 , xte.entity_code
			 , fat.application_name
			 , fat.application_id app_id
			 , xeim.source_id_col_name_1
			 , xeim.transaction_id_col_name_1
			 , xeim.source_id_col_name_2
			 , xeim.transaction_id_col_name_2
			 , xeim.source_id_col_name_3
			 , xeim.transaction_id_col_name_3
			 , xeim.source_id_col_name_4
			 , xeim.transaction_id_col_name_4
			 , count(distinct gjh.je_header_id) jnl_count
			 , count(*) line_count
			 , min(to_char(gjh.creation_date, 'yyyy-mm-dd')) min_jnl_created
			 , max(to_char(gjh.creation_date, 'yyyy-mm-dd')) max_jnl_created
		  from gl_je_headers gjh 
		  join gl_je_lines gjl on gjh.je_header_id = gjl.je_header_id
		  join gl_je_sources_tl gjst on gjh.je_source = gjst.je_source_name
		  join gl_je_categories_tl gjct on gjh.je_category = gjct.je_category_name
		  join gl_import_references gir on gjh.je_header_id = gir.je_header_id and gir.je_line_num = gjl.je_line_num and gir.je_line_num = gjl.je_line_num and gir.je_header_id = gjl.je_header_id
		  join xla_ae_lines xal on gir.gl_sl_link_table = xal.gl_sl_link_table and gir.gl_sl_link_id = xal.gl_sl_link_id
		  join xla_ae_headers xah on xal.application_id = xah.application_id and xal.ae_header_id = xah.ae_header_id
		  join xla_events xe on xah.application_id = xe.application_id and xah.event_id = xe.event_id
		  join xla_transaction_entities xte on xe.application_id = xte.application_id and xe.entity_id = xte.entity_id
		  join gl_ledgers gl on gl.ledger_id = gjh.ledger_id
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
	 left join xla_entity_id_mappings xeim on xeim.application_id = fat.application_id and xeim.entity_code = xte.entity_code
		 where 1 = 1
		   and 1 = 1
	  group by gl.name
			 , gjst.user_je_source_name
			 , gjct.user_je_category_name
			 , xte.entity_code
			 , fat.application_name
			 , fat.application_id
			 , xeim.source_id_col_name_1
			 , xeim.transaction_id_col_name_1
			 , xeim.source_id_col_name_2
			 , xeim.transaction_id_col_name_2
			 , xeim.source_id_col_name_3
			 , xeim.transaction_id_col_name_3
			 , xeim.source_id_col_name_4
			 , xeim.transaction_id_col_name_4
