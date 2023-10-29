/*
File Name: ar-adjustments.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- ADJUSTMENTS
-- ADJUSTMENTS - APPROVAL HISTORY
-- COUNT BY RECEIVABLES ACTIVITY

*/

-- ##############################################################
-- ADJUSTMENTS
-- ##############################################################

		select rcta.trx_number
			 , '#' || rcta.customer_trx_id trx_id
			 , rcta.trx_class
			 , '#' || aaa.adjustment_id adjustment_id
			 , aaa.adjustment_number
			 , aaa.doc_sequence_value
			 , aaa.created_by adj_created_by
			 , to_char(aaa.creation_date, 'YYYY-MM-DD HH24:MI:SS') created
			 , to_char(aaa.apply_date, 'YYYY-MM-DD HH24:MI:SS') apply_date
			 , to_char(aaa.gl_date, 'YYYY-MM-DD HH24:MI:SS') accounting_date
			 , aaa.amount adj_amount
			 , aaa.line_adjusted adj_line_adjusted
			 , aaa.type adj_type
			 , '#' || aaa.payment_schedule_id payment_schedule_id
			 , '#' || aaa.receivables_trx_id receivables_trx_id
			 , (replace(replace(aaa.comments,chr(10),''),chr(13),' ')) adj_comments
			 , aaa.created_from
			 , aaa.reason_code
			 , aaa.event_id
			 , arta.name rx_activity
			 , arta.type rx_activity_type
			 , arta.gl_account_source rx_activity_gl_acc_source
			 , flv_status.meaning status
			 , flv_adj_type.meaning adjustment_type
			 , flv_adj_reason.meaning adjustment_reason
		  from ar_adjustments_all aaa
		  join ra_customer_trx_all rcta on aaa.customer_trx_id = rcta.customer_trx_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = aaa.status and flv_status.lookup_type = 'APPROVAL_TYPE' and flv_status.view_application_id = 222
		  join fnd_lookup_values_vl flv_adj_type on flv_adj_type.lookup_code = aaa.adjustment_type and flv_adj_type.lookup_type = 'ADJUSTMENT_CREATION_TYPE' and flv_adj_type.view_application_id = 222
		  join fnd_lookup_values_vl flv_adj_reason on flv_adj_reason.lookup_code = aaa.reason_code and flv_adj_reason.lookup_type = 'ADJUST_REASON' and flv_adj_reason.view_application_id = 222
		  join ar_receivables_trx_all arta on arta.receivables_trx_id = aaa.receivables_trx_id and aaa.org_id = arta.org_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- ADJUSTMENTS - APPROVAL HISTORY
-- ##############################################################

		select rcta.trx_number
			 , '#' || rcta.customer_trx_id trx_id
			 , rcta.trx_class
			 , '#' || aaa.adjustment_id adjustment_id
			 , aaa.adjustment_number
			 , aaa.doc_sequence_value
			 , aaa.created_by adj_created_by
			 , to_char(aaa.creation_date, 'YYYY-MM-DD HH24:MI:SS') created
			 , to_char(aaa.apply_date, 'YYYY-MM-DD HH24:MI:SS') apply_date
			 , to_char(aaa.gl_date, 'YYYY-MM-DD HH24:MI:SS') accounting_date
			 , aaa.amount adj_amount
			 , aaa.line_adjusted adj_line_adjusted
			 , aaa.type adj_type
			 , '#' || aaa.payment_schedule_id payment_schedule_id
			 , '#' || aaa.receivables_trx_id receivables_trx_id
			 , (replace(replace(aaa.comments,chr(10),''),chr(13),' ')) adj_comments
			 , aaa.created_from
			 , aaa.reason_code
			 , aaa.event_id
			 , flv_status.meaning adj_status
			 , flv_adj_type.meaning adj_type2
			 , flv_adj_reason.meaning adj_reason
			 , '##################'
			 , to_char(aaah.action_date, 'yyyy-mm-dd') apprv_action_date
			 , aaah.created_by apprv_created_by
			 , (replace(replace(aaah.comments,chr(10),''),chr(13),' ')) apprv_comments
			 , flv_action.meaning action
		  from ar_adjustments_all aaa
		  join ra_customer_trx_all rcta on aaa.customer_trx_id = rcta.customer_trx_id
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = aaa.status and flv_status.lookup_type = 'APPROVAL_TYPE' and flv_status.view_application_id = 222
		  join fnd_lookup_values_vl flv_adj_type on flv_adj_type.lookup_code = aaa.adjustment_type and flv_adj_type.lookup_type = 'ADJUSTMENT_CREATION_TYPE' and flv_adj_type.view_application_id = 222
		  join fnd_lookup_values_vl flv_adj_reason on flv_adj_reason.lookup_code = aaa.reason_code and flv_adj_reason.lookup_type = 'ADJUST_REASON' and flv_adj_reason.view_application_id = 222
	 left join ar_approval_action_history aaah on aaah.adjustment_id = aaa.adjustment_id
	 left join fnd_lookup_values_vl flv_action on flv_action.lookup_code = aaah.action_name and flv_action.lookup_type = 'APPROVAL_TYPE' and flv_action.view_application_id = 222
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- COUNT BY RECEIVABLES ACTIVITY
-- ##############################################################

		select arta.name rx_activity
			 , arta.type rx_activity_type
			 , arta.gl_account_source rx_activity_gl_acc_source
			 , min(to_char(rcta.creation_date, 'yyyy-mm-dd')) min_creation_date
			 , max(to_char(rcta.creation_date, 'yyyy-mm-dd')) max_creation_date
			 , min('#' || rcta.trx_number) trx_num_min
			 , max('#' || rcta.trx_number) trx_num_max
			 , count(*) trx_count
		  from ar_adjustments_all aaa
		  join ra_customer_trx_all rcta on aaa.customer_trx_id = rcta.customer_trx_id
		  join ar_receivables_trx_all arta on arta.receivables_trx_id = aaa.receivables_trx_id and aaa.org_id = arta.org_id
		 where 1 = 1
		   and 1 = 1
	  group by arta.name
			 , arta.type
			 , arta.gl_account_source
