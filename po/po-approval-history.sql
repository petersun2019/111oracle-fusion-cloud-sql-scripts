/*
File Name: po-approval-history.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- REQ ACTION HISTORY
-- PO ACTION HISTORY

*/

-- ##############################################################
-- REQ ACTION HISTORY
-- ##############################################################

		select prha.requisition_number req
			 , prha.requisition_header_id
			 , prha.approved_date req_approved_date
			 , prha.document_status req_status
			 , to_char(prha.approved_date, 'yyyy-mm-dd hh24:mi:ss') approved_date
			 , pah.sequence_num seq
			 , to_char(pah.action_date, 'yyyy-mm-dd hh24:mi:ss') action_date
			 , pah.action_code
			 , ppnf.full_name person
			 , fu.username person_username
		  from po_action_history pah
		  join por_requisition_headers_all prha on pah.object_id = prha.requisition_header_id
	 left join per_all_people_f papf on papf.person_id = pah.performer_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_users fu on fu.person_id = papf.person_id
		 where 1 = 1
		   and pah.object_type_code = 'REQ'
		   and 1 = 1
	  order by prha.requisition_header_id
			 , pah.sequence_num

-- ##############################################################
-- PO ACTION HISTORY
-- ##############################################################

		select pha.segment1 po
			 , pha.po_header_id
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_created
			 , pha.created_by po_created_by
			 , flv_po_status.meaning po_status
			 , to_char(pha.approved_date, 'yyyy-mm-dd hh24:mi:ss') approved_date
			 , pah.sequence_num seq
			 , pah.role_code
			 , (replace(replace(pah.note,chr(10),''),chr(13),' ')) note
			 , to_char(pah.action_date, 'yyyy-mm-dd hh24:mi:ss') action_date
			 , po_action.meaning action
			 , ppnf.full_name person
			 , fu.username person_username
		  from po_action_history pah
		  join po_headers_all pha on pah.object_id = pha.po_header_id
		  join fnd_lookup_values_vl po_action on po_action.lookup_code = pah.action_code and po_action.view_application_id = 201 and po_action.lookup_type = 'PO_ACTION'
		  join fnd_lookup_values_vl flv_po_status on flv_po_status.lookup_code = pha.document_status and flv_po_status.view_application_id = 201 and flv_po_status.lookup_type = 'ORDER_STATUS'
	 left join per_all_people_f papf on papf.person_id = pah.performer_id and sysdate between papf.effective_start_date and papf.effective_end_date
	 left join per_person_names_f ppnf on papf.person_id = ppnf.person_id and ppnf.name_type = 'GLOBAL' and sysdate between ppnf.effective_start_date and ppnf.effective_end_date
	 left join per_users fu on fu.person_id = papf.person_id
		 where 1 = 1
		   and pah.object_type_code = 'PO'
		   and 1 = 1
	  order by pha.segment1
			 , pah.sequence_num
