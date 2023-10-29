/*
File Name: ap-expenses.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- HEADERS SIMPLE
-- DETAILS WITH DELEGATION INFO
-- DELEGATIONS
-- DISTRIBUTIONS

*/

-- ##############################################################
-- HEADERS SIMPLE
-- ##############################################################

		select '#' || eer.expense_report_id expense_report_id
			 , creation_date
			 , created_by
			 , , '#' || person_id person_id
			 , , '#' || preparer_id preparer_id
			 , , '#' || assignment_id assignment_id
		  from exm_expense_reports
	  order by expense_report_id desc

-- ##############################################################
-- DETAILS WITH DELEGATION INFO
-- ##############################################################

/*
Delegation - if delegated, the delegation info is the info (preparer_id) for the person who has actually raised the expense report_submit_date
If, via "manage delegations", they are raising expenses on behalf of someone else, that someone else is the person_id
*/

		select '#' || eer.expense_report_id expense_report_id
			 , to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss') expense_created
			 , eer.created_by expense_created_by
			 , flv_status.meaning expense_report_status
			 , to_char(eer.expense_report_date, 'yyyy-mm-dd') expense_report_date
			 , to_char(eer.report_submit_date, 'yyyy-mm-dd') report_submit_date
			 , to_char(eer.final_approval_date, 'yyyy-mm-dd') final_approval_date
			 , to_char(eer.expense_status_date, 'yyyy-mm-dd') expense_status_date
			 , eer.expense_report_num
			 , eer.expense_report_total
			 , eer.purpose
			 , '------ raise'
			 , '#' || eer.person_id person_id
			 , ppnf_raise.first_name raised_first_name
			 , ppnf_raise.last_name raised_last_name
			 , ppnf_raise.full_name raised_full_name
			 , nvl(pea_raise.email_address, 'no-email') raise_email
			 , fu_raise.username raise_user
			 , '------ deleg'
			 , '#' || , eer.preparer_id preparer_id
			 , ppnf_deleg.first_name preparer_first_name
			 , ppnf_deleg.last_name preparer_last_name
			 , ppnf_deleg.full_name preparer_full_name
			 , nvl(pea_deleg.email_address, 'no-email') preparer_email
			 , fu_deleg.username preparer_user
		  from exm_expense_reports eer
		  join fnd_lookup_values_vl flv_status on flv_status.lookup_code = eer.expense_status_code and flv_status.lookup_type = 'EXM_REPORT_STATUS' and flv_status.view_application_id = 0
-- raised by
	 left join per_all_people_f papf_raise on papf_raise.person_id = eer.person_id and sysdate between papf_raise.effective_start_date and papf_raise.effective_end_date
	 left join per_person_names_f ppnf_raise on ppnf_raise.person_id = papf_raise.person_id and ppnf_raise.name_type = 'GLOBAL' and sysdate between ppnf_raise.effective_start_date and ppnf_raise.effective_end_date
	 left join per_email_addresses pea_raise on pea_raise.person_id = eer.person_id and pea_raise.email_type = 'W1'
	 left join per_users fu_raise on fu_raise.person_id = eer.person_id
-- delgation
	 left join per_all_people_f papf_deleg on papf_deleg.person_id = eer.preparer_id and sysdate between papf_deleg.effective_start_date and papf_deleg.effective_end_date 
	 left join per_person_names_f ppnf_deleg on ppnf_deleg.person_id = papf_deleg.person_id and ppnf_deleg.name_type = 'GLOBAL' and sysdate between ppnf_deleg.effective_start_date and ppnf_deleg.effective_end_date
	 left join per_email_addresses pea_deleg on pea_deleg.person_id = eer.preparer_id and pea_deleg.email_type = 'W1'
	 left join per_users fu_deleg on fu_deleg.person_id = eer.preparer_id
		 where 1 = 1
		   and 1 = 1
	  order by eer.creation_date desc

-- ##############################################################
-- DELEGATIONS
-- ##############################################################

		select '#' || ed.delegation_id delegation_id
			 , to_char(ed.creation_date, 'yyyy-mm-dd hh24:mi:ss') deleg_created
			 , ed.created_by deleg_created_by
			 , to_char(ed.start_date, 'yyyy-mm-dd') start_date
			 , '------------ FROM'
			 , , '#' || ed.delegate_person_id from_person_id
			 , papf_deleg.person_number from_person_number
			 , ppnf_deleg.full_name from_person_name
			 , fu_deleg.username from_person_username
			 , (select max(plu.email) from per_ldap_users plu where plu.user_guid = fu_deleg.user_guid and plu.email like '%@%') to_plu_email
			 , '------------ TO'
			 , , '#' || ed.person_id to_person_id
			 , papf_person.person_number to_person_number
			 , ppnf_person.full_name to_person_name
			 , fu_person.username to_person_username
			 , (select max(plu.email) from per_ldap_users plu where plu.user_guid = fu_person.user_guid and plu.email like '%@%') from_plu_email
		  from exm_delegations ed
		  join per_all_people_f papf_person on papf_person.person_id = ed.person_id
		  join per_all_people_f papf_deleg on papf_deleg.person_id = ed.delegate_person_id
	 left join per_users fu_person on fu_person.person_id = papf_person.person_id
	 left join per_users fu_deleg on fu_deleg.person_id = papf_deleg.person_id
		  join per_person_names_f ppnf_person on ppnf_person.person_id = papf_person.person_id and ppnf_person.name_type = 'GLOBAL'
		  join per_person_names_f ppnf_deleg on ppnf_deleg.person_id = papf_deleg.person_id and ppnf_deleg.name_type = 'GLOBAL'
		 where 1 = 1
		   and sysdate between papf_person.effective_start_date and papf_person.effective_end_date
		   and sysdate between papf_deleg.effective_start_date and papf_deleg.effective_end_date
		   and sysdate between ppnf_person.effective_start_date and ppnf_person.effective_end_date
		   and sysdate between ppnf_deleg.effective_start_date and ppnf_deleg.effective_end_date
		   and 1 = 1
	  order by ed.creation_date desc

-- ##############################################################
-- DISTRIBUTIONS
-- ##############################################################

		select '#' || eer.expense_report_id expense_report_id
			 , to_char(eer.creation_date, 'yyyy-mm-dd hh24:mi:ss') expense_created
			 , eer.created_by expense_created_by
			 , to_char(eer.expense_report_date, 'yyyy-mm-dd') expense_report_date
			 , to_char(eer.report_submit_date, 'yyyy-mm-dd') report_submit_date
			 , to_char(eer.final_approval_date, 'yyyy-mm-dd') final_approval_date
			 , to_char(eer.expense_status_date, 'yyyy-mm-dd') expense_status_date
			 , eer.expense_report_num
			 , eer.expense_report_total
			 , eer.purpose
			 , '#' || eer.person_id person_id
			 , '#' 
			 , eed.reimbursable_amount
			 , eed.cost_center
			 , eed.segment1 dist_seg1
			 , eed.segment2 dist_seg2
			 , eed.segment3 dist_seg3
			 , '##'
			 , gcc.segment1 cc_seg1
			 , gcc.segment2 cc_seg2
			 , gcc.segment3 cc_seg3
			 , gcc.segment4 cc_seg4
			 , gcc.segment5 cc_seg5
			 , gcc.segment6 cc_seg6
			 , gcc.segment7 cc_seg7
			 , gcc.segment8 cc_seg8
			 , gcc.code_combination_id ccid
			 , to_char(gcc.creation_date, 'yyyy-mm-dd hh24:mi:ss') gcc_created
			 , gcc.created_by gcc_created_by
			 , '###'
			 , ee.description
			 , eet.name expense_type
			 , ee.expense_source
			 , ee.expense_type_category_code
			 , ee.func_currency_amount
			 , ee.receipt_amount
			 , ee.emp_default_cost_center
			 , to_char(ee.start_date, 'yyyy-mm-dd') start_date
			 , to_char(ee.end_date, 'yyyy-mm-dd') end_date
			 , '------ raise'
			 , ppnf_raise.first_name raised_first_name
			 , ppnf_raise.last_name raised_last_name
			 , ppnf_raise.full_name raised_full_name
			 , nvl(pea_raise.email_address, 'no-email') raise_email
			 , fu_raise.username raise_user
		  from exm_expense_reports eer
		  join exm_expenses ee on ee.expense_report_id = eer.expense_report_id
		  join exm_expense_types eet on eet.expense_type_id = ee.expense_type_id
		  join exm_expense_dists eed on eed.expense_report_id = eer.expense_report_id and eed.expense_id = ee.expense_id
	 left join gl_code_combinations gcc on gcc.code_combination_id = eed.code_combination_id
-- raised by
	 left join per_all_people_f papf_raise on papf_raise.person_id = eer.person_id and sysdate between papf_raise.effective_start_date and papf_raise.effective_end_date
	 left join per_person_names_f ppnf_raise on ppnf_raise.person_id = papf_raise.person_id and ppnf_raise.name_type = 'GLOBAL' and sysdate between ppnf_raise.effective_start_date and ppnf_raise.effective_end_date
	 left join per_email_addresses pea_raise on pea_raise.person_id = eer.person_id and pea_raise.email_type = 'W1'
	 left join per_users fu_raise on fu_raise.person_id = eer.person_id
		 where 1 = 1
		   and 1 = 1
	  order by eer.creation_date desc
