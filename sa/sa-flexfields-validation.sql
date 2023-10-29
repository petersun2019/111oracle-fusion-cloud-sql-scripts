/*
File Name: sa-flexfields-validation.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- VALUE SETS - SIMPLE LIST
-- VALUE SETS - DEFINITION
-- VALUE SETS - VALUES
-- VALUE SETS - VALUES - COUNT PER VALUE SET
-- TABLE VALIDATION DETAILS

*/

-- ##############################################################
-- VALUE SETS - SIMPLE LIST
-- ##############################################################

		select *
		  from fnd_flex_value_sets ffvs
		 where 1 = 1 -- ffvs.flex_value_set_name = 'CE_BANK_BRANCHES'
	  order by flex_value_set_name

-- ##############################################################
-- VALUE SETS - DEFINITION
-- ##############################################################

		select ffvs.flex_value_set_name name
			 , ffvs.description
			 , decode (ffvs.longlist_flag
						 , 'N', 'List of Values'
						 , 'X', 'Poplist'
						 , 'Y', 'Long List of Values'
						 , 'Other') list_type
			 , decode (ffvs.security_enabled_flag
						 , 'N', 'No Security'
						 , 'Y', 'Non-Hierarchical Security'
						 , 'H', 'Hierarchical Security'
						 , 'Other') security_type
			 , decode (ffvs.format_type
						 , 'C', 'Char'
						 , 'D', 'Date'
						 , 'T', 'DateTime'
						 , 'N', 'Number'
						 , 'X', 'Standard Date'
						 , 'Y', 'Standard DateTime'
						 , 'I', 'Time'
						 , 'NULL') format_type
			 , decode (ffvs.validation_type
						 , 'Y', 'Translatable Dependent'
						 , 'X', 'Translatable Independent'
						 , 'F', 'Table'
						 , 'U', 'Special'
						 , 'D', 'Dependent'
						 , 'I', 'Independent'
						 , 'N', 'None'
						 , 'P', 'Pair') validation_type
			 , ffvs.maximum_size max_size
			 , ffvs.number_precision precision
			 , case when ffvs.format_type = 'N' then 'Y' else 'N' end numbers_only
			 , ffvs.numeric_mode_enabled_flag right_justify
			 , ffvs.uppercase_only_flag uppercase
			 , ffvs.protected_flag
			 , ffvs.security_enabled_flag
			 , ffvs.uppercase_only_flag
			 , ffvs.dependant_default_value
			 , ffvs.dependant_default_meaning
			 , ffvs2.flex_value_set_name independent_value_set
			 , ffvs.created_by
		  from fnd_flex_value_sets ffvs
	 left join fnd_flex_value_sets ffvs2 on ffvs.parent_flex_value_set_id = ffvs2.flex_value_set_id 
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- VALUE SETS - VALUES
-- ##############################################################

		select flex_value_set_name
			 , fnd_value.flex_value
			 , fnd_value_tl.description
			 , fnd_value.enabled_flag
			 , fnd_value.creation_date
			 , fnd_value.created_by
		  from fnd_flex_value_sets fnd_set
		  join fnd_flex_values fnd_value on fnd_set.flex_value_set_id = fnd_value.flex_value_set_id 
		  join fnd_flex_values_tl fnd_value_tl on fnd_value_tl.flex_value_id = fnd_value.flex_value_id and fnd_value_tl.language = userenv('lang')
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- VALUE SETS - VALUES - COUNT PER VALUE SET
-- ##############################################################

		select flex_value_set_name
			 , count(fnd_value.flex_value_set_id) record_count
		  from fnd_flex_value_sets fnd_set
	 left join fnd_flex_values fnd_value on fnd_set.flex_value_set_id = fnd_value.flex_value_set_id 
		 where 1 = 1
		   -- and fnd_set.flex_value_set_name in ('XX_GL_COMPANY','XX_GL_ACCOUNT','XX_GL_COST CENTER','XX_GL_COMPANY')
		   and 1 = 1
	  group by flex_value_set_name

-- ##############################################################
-- TABLE VALIDATION DETAILS
-- ##############################################################

		select ffvs.flex_value_set_name name
			 , nvl (fat.application_name, 'n/a') tbl_app
			 , ffvt.application_table_name tbl_name
			 , ffvt.value_column_name
			 , ffvt.meaning_column_name
			 , ffvt.id_column_name
			 , ffvt.additional_where_clause where_
			 , ffvt.summary_allowed_flag
			 , ffvt.last_update_date
			 , ffvt.last_updated_by
		  from fnd_flex_value_sets ffvs
		  join fnd_flex_validation_tables ffvt on ffvs.flex_value_set_id = ffvt.flex_value_set_id 
	 left join fnd_application_tl fat on ffvt.table_application_id = fat.application_id and fat.language = userenv('lang')
		 where 1 = 1
		   and ffvs.flex_value_set_name = 'XX_GRADE_LEVEL_VS'
		   and 1 = 1
