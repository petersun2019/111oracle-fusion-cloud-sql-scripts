/*
File Name: ar-approval-limits.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- AR APPROVAL LIMITS
-- ##############################################################

		select pu.username
			 , to_char(aaul.creation_date, 'yyyy-mm-dd hh24:mi:ss') limit_created
			 , aaul.created_by limit_created_by
			 , to_char(aaul.last_update_date, 'yyyy-mm-dd hh24:mi:ss') limit_updated
			 , aaul.last_update_date
			 , aaul.last_updated_by limit_updated_by
			 , aaul.amount_from
			 , aaul.amount_to
			 , aaul.currency_code
			 , flv_doc_type.meaning document_type
			 , aaul.reason_code
		  from ar_approval_user_limits aaul
		  join per_users pu on aaul.user_id = pu.user_guid
		  join fnd_lookup_values_vl flv_doc_type on flv_doc_type.lookup_code = aaul.document_type and flv_doc_type.lookup_type = 'AR_DOCUMENT_TYPE' and flv_doc_type.view_application_id = 222
		 where 1 = 1
		   and 1 = 1
	  order by aaul.last_update_date desc
