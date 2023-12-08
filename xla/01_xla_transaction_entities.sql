/*
File Name: 01_xla_transaction_entities.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

https://docs.oracle.com/en/cloud/saas/financials/22d/oedmf/xlatransactionentities-24404.html
This table contains a row for each transaction for which events have been raised in Subledger Accounting.

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.
*/

-- ##############################################################
-- XLA TRANSACTION ENTITIES
-- ##############################################################

		select fat.application_name
			 , fat.application_id app_id
			 , xte.*
		  from xla_transaction_entities xte
		  join fnd_application_tl fat on xte.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
