/*
File Name: exm-expenses.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMPS
-- REPORT HEADERS
-- EXM_EXP_REP_PROCESSING
-- REPORT HEADERS AND EXPENSE LINES (ITEMS)
-- REPORT HEADERS, EXPENSE LINES (ITEMS) AND DISTRIBUTIONS
-- EXPENSE REPORT APPROVER

*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from exm_expense_reports where created_by = 'USER123'
select * from exm_expense_reports where expense_report_total < 0 order by creation_date desc
select * from exm_expense_reports where expense_report_num in ('EXP123')
select * from exm_expenses where expense_report_id = 123456

-- ##############################################################
-- REPORT HEADERS
-- ##############################################################

		select eer.expense_report_id
			 , eer.expense_report_num
			 , to_char(eer.expense_report_date, 'yyyy-mm-dd') expense_report_date
			 , to_char(eer.report_submit_date, 'yyyy-mm-dd') report_submit_date
			 , to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , eer.created_by
			 , eer.expense_status_code
			 , eer.expense_report_total
			 , eer.purpose
			 , eer.current_approver_id
			 , eer.receipts_status_code
			 , eer.audit_code
			 , eer.report_creation_method_code
		  from exm_expense_reports eer
		 where 1 = 1
		   and 1 = 1
	  order by eer.expense_report_id desc

-- ##############################################################
-- COUNT BY CREATED BY
-- ##############################################################

		select eer.created_by
			 , min(eer.expense_report_num) min_num
			 , max(eer.expense_report_num) max_num
			 , min(to_char(eer.expense_report_date, 'yyyy-mm-dd')) min_expense_report_date
			 , max(to_char(eer.expense_report_date, 'yyyy-mm-dd')) max_expense_report_date
			 , min(to_char(eer.report_submit_date, 'yyyy-mm-dd')) min_report_submit_date
			 , max(to_char(eer.report_submit_date, 'yyyy-mm-dd')) max_report_submit_date
			 , min(to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , count(*) count_
		  from exm_expense_reports eer
		 where 1 = 1
		   and 1 = 1
	  group by eer.created_by
	  order by eer.created_by

-- ##############################################################
-- EXM_EXP_REP_PROCESSING
-- ##############################################################

/*
This table is used to store processing status for an expense report.
*/

		select eerp.*
		  from exm_expense_reports eer
		  join exm_exp_rep_processing eerp on eer.expense_report_id = eerp.expense_report_id
		 where 1 = 1
		   and eer.expense_report_num in ('EXP123')
		   and 1 = 1

-- ##############################################################
-- REPORT HEADERS AND EXPENSE LINES (ITEMS)
-- ##############################################################

		select eer.expense_report_id
			 , eer.expense_report_num hdr_expense_report_num
			 , to_char(eer.expense_report_date, 'yyyy-mm-dd') hdr_expense_report_date
			 , to_char(eer.report_submit_date, 'yyyy-mm-dd') hdr_report_submit_date
			 , to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss') hdr_creation_date
			 , eer.expense_status_code hdr_expense_status_code
			 , eer.expense_report_total hdr_expense_report_total
			 , eer.purpose hdr_purpose
			 , eer.current_approver_id hdr_current_approver_id
			 , eer.receipts_status_code hdr_receipts_status_code
			 , eer.audit_code hdr_audit_code
			 , eer.report_creation_method_code hdr_report_creation_method_code
			 , '###############' eeee
			 , ee.*
		  from exm_expense_reports eer
		  join exm_expenses ee on eer.expense_report_id = ee.expense_report_id
		 where 1 = 1
		   and 1 = 1
	  order by eer.creation_date desc

-- ##############################################################
-- REPORT HEADERS, EXPENSE LINES (ITEMS) AND DISTRIBUTIONS
-- ##############################################################

		select eer.expense_report_id
			 , eer.expense_report_num rpt_num
			 , to_char(eer.expense_report_date, 'yyyy-mm-dd') rpt_date
			 , to_char(eer.report_submit_date, 'yyyy-mm-dd') rpt_submitted
			 , to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss') rpt_created
			 , eer.created_by rpt_created_by
			 , eer.expense_status_code
			 , eer.expense_report_total
			 , eer.purpose
			 , eer.payment_method_code
			 , et.name template_name
			 , eet.name type_name
			 , '#' || gcc.segment1 segment1
			 , '#' || gcc.segment2 segment2
			 , '#' || gcc.segment3 segment3
			 , '#' || gcc.segment4 segment4
			 , '#' || gcc.segment5 segment5
			 , '#' || gcc.segment6 segment6
			 , '#' || gcc.segment7 segment7
			 , '#' || gcc.segment8 segment8
			 , ee.expense_id
			 , ee.person_id
			 , ee.assignment_id
			 , ee.reimbursable_amount
			 , ee.emp_default_cost_center
			 , ee.vehicle_type
			 , ee.distance_unit_code
			 , ee.destination_from
			 , ee.destination_to
			 , ee.trip_distance
			 , to_char(ee.start_date, 'yyyy-mm-dd') expense_start
			 , to_char(ee.end_date, 'yyyy-mm-dd') expense_end
			 , ee.expense_type_category_code
			 , ee.receipt_amount
			 , gcc.code_combination_id
		  from exm_expense_reports eer
		  join exm_expenses ee on ee.expense_report_id = eer.expense_report_id
		  join exm_expense_templates et on et.expense_template_id = ee.expense_template_id
		  join exm_expense_types eet on eet.expense_type_id = ee.expense_type_id
	 left join exm_expense_dists eed on eed.expense_id = ee.expense_id and eed.expense_report_id = ee.expense_report_id
	 left join gl_code_combinations gcc on gcc.code_combination_id=eed.code_combination_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- EXPENSE REPORT APPROVER
-- ##############################################################

/*
https://rpforacle.blogspot.com/2020/08/sql-query-to-get-expense-report.html
*/

		select display_name 
		  from per_person_names_f_v ppnfv
			 , (select a1.event_performer_id
				  from (select eerp.event_performer_id
						  from exm_exp_rep_processing eerp
							 , exm_expense_reports eer1
						 where eerp.expense_report_id = eer1.expense_report_id 
						   -- and eerp.approval_level = 1
						   and eer1.expense_report_num=:p_expense_number
						   and eerp.expense_status_code like '%PEND_MGR_APPROVAL%'
						   and eerp.event_performer_id not in ('-1')
					  order by event_date desc) a1
		 where rownum = 1) b
		 where ppnfv.person_id = b.event_performer_id
		   and ppnfv.effective_end_date > sysdate and rownum = 1
