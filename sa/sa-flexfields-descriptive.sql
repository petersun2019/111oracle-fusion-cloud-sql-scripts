/*
File Name: sa-flexfields-descriptive.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- DESCRIPTIIVE FLEXFIELDS
-- DESCRIPTIIVE FLEXFIELDS - SEGMENTS
-- DESCRIPTIIVE FLEXFIELDS - COUNTING

*/

-- ##############################################################
-- DESCRIPTIIVE FLEXFIELDS
-- ##############################################################

		select fat.application_name
			 , fdfv.title dff_title
			 , fdfv.description dff_description
			 , to_char(fdfv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , fdfv.created_by
			 , to_char(fdfv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , fdfv.last_updated_by
			 , fdfv.descriptive_flexfield_name dff_name
			 , fdfcv.global_flag -- if N then other DESCRIPTIVE_FLEX_CONTEXT_NAME values = Context values
			 , fdfcv.descriptive_flex_context_code
			 , fdfcv.descriptive_flex_context_name
			 , fdfcv.description context_description
			 , fdfcv.enabled_flag enabled
			 , fdfv.application_table_name
			 , fdfv.freeze_flex_definition_flag
			 , fdfv.concatenated_segment_delimiter
			 , fdfv.context_column_name
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfcv.descriptive_flexfield_name = fdfv.descriptive_flexfield_name 
		 where 1 = 1
		   -- and fdfv.title = 'PO Headers'
		   and fdfv.descriptive_flexfield_name = 'ANC_PER_ABS_ENTRIES_DFF'
		   -- and fat.application_name = 'Payables'
		   -- and fdfv.title = 'Flexfield Segment Values'
		   and 1 = 1
	  order by fdfcv.descriptive_flex_context_code

-- ##############################################################
-- DESCRIPTIIVE FLEXFIELDS - SEGMENTS
-- ##############################################################

/*
I find this userful if I can see e.g. a prompt on a DFF and do not know which field on the related table it sits on.
I can search for the prompt on the dff to find out.
*/

		select fat.application_name
			 , fdfv.title dff_title
			 , fdfv.description dff_description
			 , to_char(fdfv.creation_date, 'yyyy-mm-dd hh24:mi:ss') dff_created
			 , fdfv.created_by dff_created_by
			 , to_char(fdfv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') dff_updated
			 , fdfv.last_updated_by dff_updated_by
			 , fdfv.descriptive_flexfield_name dff_name
			 , fdfcv.global_flag -- if N then other DESCRIPTIVE_FLEX_CONTEXT_NAME values = Context values
			 , fdfcv.descriptive_flex_context_code
			 , fdfcv.descriptive_flex_context_name
			 , fdfcv.description context_description
			 , fdfcv.enabled_flag context_enabled
			 , fdfv.application_table_name
			 , fdfv.freeze_flex_definition_flag
			 , fdfv.concatenated_segment_delimiter
			 , fdfv.context_column_name
			 , '####' segments____
			 , fdfcuv.column_seq_num seq
			 , fdfcuv.end_user_column_name
			 , fdfcuv.form_left_prompt
			 , fdfcuv.application_column_name
			 , ffvs.flex_value_set_name
			 , ffvs.description value_set_description
			 , fdfcuv.required_flag required
			 , fdfcuv.display_flag display
			 , fdfcuv.enabled_flag enabled
			 , fdfcuv.security_enabled_flag
			 , (replace(replace(fdfcuv.default_value,chr(10),''),chr(13),' ')) default_val
			 , to_char(fdfcuv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , fdfcuv.created_by
			 , to_char(fdfcuv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , fdfcuv.last_updated_by
			 -- , '#########################################################'
			 -- , fdfcuv.*
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfv.descriptive_flexfield_name = fdfcv.descriptive_flexfield_name
		  join fnd_descr_flex_col_usage_vl fdfcuv on fdfcv.descriptive_flexfield_name = fdfcuv.descriptive_flexfield_name and fdfcuv.descriptive_flex_context_code = fdfcv.descriptive_flex_context_code
		  join fnd_flex_value_sets ffvs on fdfcv.descriptive_flex_context_code = fdfcuv.descriptive_flex_context_code and fdfcuv.flex_value_set_id = ffvs.flex_value_set_id
		 where 1 = 1
		   and 1 = 1
	  order by fdfcuv.last_update_date desc

-- ##############################################################
-- DESCRIPTIIVE FLEXFIELDS - COUNTING
-- ##############################################################

		select fat.application_name
			 , fdfv.title
			 , min(fdfcuv.last_update_date)
			 , max(fdfcuv.last_update_date)
			 , count(*)
		  from fnd_descriptive_flexs_vl fdfv
		  join fnd_application_tl fat on fdfv.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_descr_flex_contexts_vl fdfcv on fdfv.descriptive_flexfield_name = fdfcv.descriptive_flexfield_name
		  join fnd_descr_flex_col_usage_vl fdfcuv on fdfcv.descriptive_flexfield_name = fdfcuv.descriptive_flexfield_name and fdfcuv.descriptive_flex_context_code = fdfcv.descriptive_flex_context_code
	 left join fnd_flex_value_sets ffvs on fdfcv.descriptive_flex_context_code = fdfcuv.descriptive_flex_context_code and fdfcuv.flex_value_set_id = ffvs.flex_value_set_id
		 where 1 = 1
		   and 1 = 1
	  group by fat.application_name
			 , fdfv.title
	  order by fat.application_name
			 , fdfv.title
