/*
File Name: 02_xla_ae_headers.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

https://docs.oracle.com/en/cloud/saas/financials/22d/oedmf/xlaaeheaders-9352.html#xlaaeheaders-9352
This table contains subledger accounting journal entries.

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- XLA AE HEADERS BASIC
-- DATA FROM SOURCE_ID_INT_1

*/

-- ##############################################################
-- XLA AE HEADERS BASIC
-- ##############################################################

select * from xla_ae_headers where entity_id = 12345678

-- ##############################################################
-- DATA FROM SOURCE_ID_INT_1
-- ##############################################################

		select *
		  from xla_ae_headers xah
		 where xah.application_id = 200
		   and xah.entity_id in (select xte.entity_id
								   from xla_transaction_entities xte
								  where xte.application_id = xah.application_id
								    and xte.entity_code = 'AP_INVOICES'
								    and xte.source_id_int_1 in (12345678))
