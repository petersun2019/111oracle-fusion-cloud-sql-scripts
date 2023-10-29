/*
File Name: gl-segment-values.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- CHART OF ACCOUNTS SEGMENT VALUES
-- CHART OF ACCOUNTS VALUE SET VALUES SUMMARY BY VALUE SET

*/

-- ##############################################################
-- CHART OF ACCOUNTS SEGMENT VALUES
-- ##############################################################

		select fksib.structure_instance_code
			 , fksi.segment_code
			 , fvvs.value_set_code value_set
			 , fvvv.value segment_value
			 , fvvv.description segment_description
			 , fvvv.enabled_flag
			 , to_char(fvvv.start_date_active, 'yyyy-mm-dd') start_date
			 , to_char(fvvv.end_date_active, 'yyyy-mm-dd') end_date
			 , to_char(fvvv.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , fvvv.created_by
			 , to_char(fvvv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') updated
			 , fvvv.last_updated_by
			 , '#' segment_attribs____
			 , fvvv.summary_flag
			 , fvvv.flex_value_attribute1 posting_allowed
			 , fvvv.flex_value_attribute2 budgeting_allowed
			 , fvvv.flex_value_attribute3 account_type
			 , fvvv.flex_value_attribute4 control_account
			 , fvvv.flex_value_attribute5 reconciliation_flag
			 , fvvv.flex_value_attribute6 financial_category
			 , '#' id_info____
			 , fksib.structure_instance_id
			 , fksib.structure_id
			 , fksi.value_set_id
		  from fnd_kf_segment_instances fksi
		  join fnd_kf_str_instances_b fksib on fksi.structure_instance_id = fksib.structure_instance_id
		  join fnd_vs_value_sets fvvs on fvvs.value_set_id = fksi.value_set_id
		  join fnd_vs_values_vl fvvv on fvvv.value_set_id = fvvs.value_set_id
		 where 1 = 1
		   and fksib.application_id = 101
		   and fksib.key_flexfield_code = 'GL#'
		   and 1 = 1

-- ##############################################################
-- CHART OF ACCOUNTS VALUE SET VALUES SUMMARY BY VALUE SET
-- ##############################################################

		select fifsv.id_flex_structure_code segment_code
			 , fifsv.id_flex_structure_name segment_title
			 , fnd_set.flex_value_set_id
			 , fifsvl.segment_num
			 , fifsvl.segment_name name
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_size
			 , min(segvals.value) min_value
			 , max(segvals.value) max_value
			 , min(to_char(segvals.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(segvals.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , count(*)
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
		  join fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		  join fnd_vs_values_vl segvals on segvals.value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   and 1 = 1
	  group by fifsv.id_flex_structure_code
			 , fifsv.id_flex_structure_name
			 , fnd_set.flex_value_set_id
			 , fifsvl.segment_num
			 , fifsvl.segment_name
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_size
	  order by fifsv.id_flex_structure_code
			 , fifsv.id_flex_structure_name
			 , fifsvl.segment_num
