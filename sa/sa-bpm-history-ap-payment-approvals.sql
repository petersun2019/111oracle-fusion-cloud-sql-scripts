/*
File Name: sa-bpm-history-ap-payment-approvals.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- JOINED TO AP INVOICE TABLE
-- AP PAYMENT APPROVAL BPM INFO
-- STAGES OF PAYMENT BATCH APPROVALS

*/

-- ##############################################################
-- JOINED TO AP INVOICE TABLE
-- ##############################################################

		select '#' || aia.invoice_num invoice_num
			 , hou.name bu
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , (replace(replace(aia.description,chr(10),''),chr(13),' ')) inv_description
			 , psv.vendor_name supplier
			 , psv.segment1 supplier#
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , aia.invoice_amount inv_amt
			 , aia.payment_status_flag pay_flag
			 , aia.amount_paid amt_paid
			 , aia.approval_status
			 , aia.wfapproval_status
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , nvl2(aia.cancelled_amount, 'Y', 'N') cancelled
			 , to_char(aia.cancelled_date, 'yyyy-mm-dd') cancelled_date
			 , aia.cancelled_by
			 , aia.cancelled_amount
			 , decode(ap_invoices_utility_pkg.get_approval_status(aia.invoice_id,aia.invoice_amount,aia.payment_status_flag,aia.invoice_type_lookup_code), 'FULL' , 'Fully Applied', 'NEVER APPROVED' , 'Never Validated', 'NEEDS REAPPROVAL', 'Needs Revalidation', 'CANCELLED' , 'Cancelled', 'UNPAID' , 'Unpaid', 'AVAILABLE' , 'Available', 'UNAPPROVED' , 'Unvalidated', 'APPROVED' , 'Validated', 'PERMANENT' , 'Permanent Prepayment', null) status
			 , (select distinct approver_id from ap_inv_aprvl_hist_all h2 where h2.invoice_id = aia.invoice_id and h2.response = 'ORA_ASSIGNED TO' and approver_id like '%@%' and approver_id != aia.created_by and rownum = 1) other_approver
			 , '#######################'
			 , fwt.taskdefinitionname
			 , '#' || fwt.taskid taskid
			 , '#' || fwt.identificationkey identificationkey
			 , fwt.tasknumber
			 , to_char(fwt.createddate, 'yyyy-mm-dd hh24:mi:ss') createddate
			 , to_char(fwt.assigneddate, 'yyyy-mm-dd hh24:mi:ss') assigneddate
			 , to_char(fwt.enddate, 'yyyy-mm-dd hh24:mi:ss') enddate
			 , fwt.fromuserdisplayname
			 , fwt.state
			 , fwt.title
			 , fwt.componentname
			 , fwt.packagename
			 , fwt.assignees
			 , fwt.assigneesdisplayname
			 , fwt.outcome
			 , fwt.assignmentcontext
		  from fa_fusion_soainfra.wftask fwt
		  join ap_invoices_all aia on '#' || fwt.identificationkey = '#' || aia.invoice_id
	 left join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
	 left join hr_operating_units hou on aia.org_id = hou.organization_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- AP PAYMENT APPROVAL BPM INFO
-- ##############################################################

		select payment.call_app_pay_service_req_code payment_batch_name
			 , to_char(payment.creation_date, 'yyyy-mm-dd hh24:mi:ss') payment_batch_creation_date
			 , bpm_hist.tasknumber
			 , to_char(bpm_task.createddate, 'yyyy-mm-dd hh24:mi:ss') task_created
			 , to_char(bpm_task.enddate, 'yyyy-mm-dd hh24:mi:ss') task_end
			 , bpm_task.creator task_created_by
			 , bpm_hist.fromuserdisplayname
			 , bpm_hist.acquiredby action_by
			 , bpm_hist.assigneesdisplayname
			 , bpm_hist.taskdefinitionname
			 , bpm_hist.title approval_title
			 , bpm_hist.state status
			 , bpm_hist.outcome outcome
			 , bpm_comments.wfcomment action_comment
			 , payment.created_by payment_created_by
			 , payment.payment_service_request_status
			 , apt.template_name
			 , apt.payment_method_code
			 , cba.bank_account_name
			 , cba.bank_account_num
			 , cbv.bank_name
			 , cbbv.branch_number
			 , cbbv.bank_branch_name
			 , iapp.system_profile_code
			 , isppv.payment_format_code
			 , isppv.system_profile_name
			 , iappt.payment_profile_name payment_process_profile
			 , ift.format_name payment_instruction_format
			 , ifb.format_template_code
			 , tbl_payment.payment_amount payment_file_amount
			 , tbl_payment.payment_status payment_file_status
			 , tbl_payment.payment_instruction_id payment_file
			 , tbl_payment.payment_count
		  from fa_fusion_soainfra.wftaskhistory bpm_hist
	 left join fa_fusion_soainfra.wftask_view bpm_task on bpm_task.taskid = bpm_hist.taskid
	 left join fa_fusion_soainfra.wfcomments_view bpm_comments on bpm_comments.taskid = bpm_task.taskid
	 left join fusion.iby_pay_service_requests payment on bpm_task.identificationkey = to_char(payment.payment_service_request_id)
	 left join fusion.ap_payment_templates apt on apt.payment_profile_id = payment.payment_profile_id
	 left join fusion.ce_bank_accounts cba on apt.bank_account_id = cba.bank_account_id
	 left join fusion.ce_banks_v cbv on cba.bank_id = cbv.bank_party_id
	 left join fusion.ce_bank_branches_v cbbv on cbbv.branch_party_id = cba.bank_branch_id
	 left join fusion.iby_acct_pmt_profiles_b iapp on iapp.payment_profile_id = apt.payment_profile_id
	 left join fusion.iby_acct_pmt_profiles_tl iappt on iappt.payment_profile_id = iapp.payment_profile_id and iappt.language = userenv('lang')
	 left join fusion.iby_sys_pmt_profiles_vl isppv on isppv.system_profile_code = iapp.system_profile_code
	 left join fusion.iby_formats_b ifb on ifb.format_code = isppv.payment_format_code
	 left join fusion.iby_formats_tl ift on ifb.format_code = ift.format_code and ift.language = userenv('lang')
	 left join (select ipa.payment_process_request_name
					 , sum(ipa.payment_amount) payment_amount
					 , ipa.payment_status
					 , ipa.payment_instruction_id
					 , count(*) payment_count
				  from iby_payments_all ipa
			  group by ipa.payment_process_request_name
					 , ipa.payment_status
					 , ipa.payment_instruction_id
					 , to_char(ipa.creation_date, 'yyyy-mm-dd hh24:mi:ss')
					 , ipa.created_by) tbl_payment on tbl_payment.payment_process_request_name = payment.call_app_pay_service_req_code
		 where 1 = 1
		   and 1 = 1
	  order by payment.creation_date desc

-- ##############################################################
-- STAGES OF PAYMENT BATCH APPROVALS
-- ##############################################################

		select payment.call_app_pay_service_req_code payment_batch_name
			 , to_char(payment.creation_date, 'MM-DD-YYYY') payment_batch_creation_date
			 , payment.created_by
			 , bpm_task.approvers
			 , payment.payment_service_request_status
		  from fusion.fnd_bpm_task_b bpm_task
		  join fusion.fnd_bpm_task_history_b bpm_hist on bpm_task.task_id = bpm_hist.task_id
		  join fusion.fnd_bpm_task_assignee bpm_assignee on bpm_hist.task_id = bpm_assignee.task_id
		  join fusion.iby_pay_service_requests payment on bpm_task.identification_key = to_char(payment.payment_service_request_id)
		 where 1 = 1
		   and bpm_hist.version = bpm_assignee.version
		   -- and bpm_hist.outcome_code = 'APPROVE'
		   -- and bpm_hist.status_code = 'COMPLETED'
		   and payment.payment_service_request_status = 'COMPLETED'
		   and payment.call_app_pay_service_req_code like '%ACH%'
	  order by payment.creation_date desc
