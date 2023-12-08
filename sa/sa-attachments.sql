/*
File Name: sa-attachments.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- ATTACHMENTS SUMMARY
-- ##############################################################

		select fad.category_name
			 , fad.entity_name
			 , min(to_char(fad.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_min
			 , max(to_char(fad.creation_date, 'yyyy-mm-dd hh24:mi:ss')) created_max
			 , min(fad.pk1_value) pk1_value_min
			 , max(fad.pk1_value) pk1_value_max
			 , min(fdt.dm_document_id) min_dm_document_id
			 , max(fdt.dm_document_id) max_dm_document_id
			 , min(fad.attached_document_id) min_attached_document_id
			 , max(fad.attached_document_id) max_attached_document_id
			 , min(fad.document_id) min_document_id
			 , max(fad.document_id) max_document_id
			 , count(*)
		  from fnd_attached_documents fad
	 left join fnd_documents_tl fdt on fad.document_id = fdt.document_id
	  group by fad.category_name
			 , fad.entity_name
	  order by fad.category_name
			 , fad.entity_name
