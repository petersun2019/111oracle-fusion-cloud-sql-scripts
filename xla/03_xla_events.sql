/*
File Name: 03_xla_events.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

https://docs.oracle.com/en/cloud/saas/financials/22d/oedmf/xlaaeheaders-9352.html#xlaaeheaders-9352
This table contains subledger accounting journal entries.

XLA_TRANSACTION_ENTITIES.SOURCE_ID_INT_1 column is often used for the main identifier for a transaction such as an AP Invoice, AR Transaction etc.
So if you have that ID, you can check what SLA data exists for that Transaction by searching against it using the SOURCE_ID_INT_1 column.

Queries:

-- XLA EVENTS BASIC 1
-- DATA FROM SOURCE_ID_INT_1
-- XLA EVENTS SUMMARY 1
-- XLA EVENTS SUMMARY 2 - GROUP BY STATUS CODE AND PROCESS CODE

*/

-- ##############################################################
-- XLA EVENTS BASIC 1
-- ##############################################################

select * from xla_events where event_id = 12345678

-- ##############################################################
-- DATA FROM SOURCE_ID_INT_1
-- ##############################################################

		select *
		  from xla_events xe
		 where xe.application_id = 200
		   and xe.entity_id in (select entity_id
								  from xla_transaction_entities xte
								 where xte.application_id = xe.application_id
								   and xte.entity_code = 'AP_INVOICES'
								   and xte.source_id_int_1 in (2, 3, 4))

-- ##############################################################
-- XLA EVENTS SUMMARY 1
-- ##############################################################

		select xe.event_status_code
			 , flv2.meaning event_status
			 , xe.process_status_code
			 , flv1.meaning process_status
			 , fat.application_name app
			 , max(to_char(xe.event_date, 'yyyy-mm-dd')) max_event_date
			 , max(to_char(xe.transaction_date, 'yyyy-mm-dd')) max_transaction_date
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , count(*)
		  from xla_events xe
		  join fnd_application_tl fat on xe.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_lookup_values_vl flv1 on flv1.lookup_code = xe.process_status_code and flv1.lookup_type = 'XLA_EVENT_PROCESS_STATUS' and flv1.view_application_id = 10037
		  join fnd_lookup_values_vl flv2 on flv2.lookup_code = xe.event_status_code and flv2.lookup_type = 'XLA_EVENT_STATUS' and flv2.view_application_id = 10037
		 where xe.application_id = 10037 -- PJF (Project Foundation)
	  group by xe.event_status_code
			 , xe.process_status_code
			 , fat.application_name
			 , flv1.meaning
			 , flv2.meaning

-- ##############################################################
-- XLA EVENTS SUMMARY 2 - GROUP BY STATUS CODE AND PROCESS CODE
-- ##############################################################

		select fat.application_name
			 , event_status_code || process_status_code dd
			 , xe.event_type_code
			 , min(to_char(xe.creation_date, 'yyyy-mm-dd')) min_created
			 , max(to_char(xe.creation_date, 'yyyy-mm-dd')) max_created
			 , count(*) ct
		  from xla_events xe
		  join fnd_application_tl fat on xe.application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1
	  group by event_status_code || process_status_code
			 , xe.event_type_code
			 , fat.application_name

