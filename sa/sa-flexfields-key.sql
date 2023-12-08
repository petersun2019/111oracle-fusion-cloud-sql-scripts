/*
File Name: sa-flexfields-key.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- KEY FLEXFIELDS
-- KEY FLEXFIELD STRUCTURE - ACCOUNTING FLEXFIELD
-- KEY FLEXFIELD STRUCTURE - ACCOUNTING FLEXFIELD - SEGMENTS
-- KEY FLEXFIELD STRUCTURE - ACCOUNTING FLEXFIELD - SEGMENTS - VALUES
-- KEY FLEXFIELD - ACCOUNTING SEGMENTS BASIC SQL
-- KEY FLEXFIELD - FIND NATURAL AND BALANCING SEGMENTS
-- GET COST CENTRE SEGMENT NAME

*/

-- ##############################################################
-- KEY FLEXFIELDS
-- ##############################################################

/*
At its most basic, a list of key flexfields, without the list of segments
This sql is useful as it shows you the underlying application table name associated with the key flexfield.
There are a number of key flexfields - e.g.

APPLICATION_ID	ID_FLEX_CODE	ID_FLEX_NAME					APPLICATION_TABLE_NAME			UNIQUE_ID_COLUMN_NAME			SET_DEFINING_COLUMN_NAME
--------------------------------------------------------------------------------------------------------------------------------------------------------
707				VALU			Valuation Unit Flexfield		CST_VAL_UNIT_COMBINATIONS		VAL_UNIT_COMBINATION_ID			STRUCTURE_INSTANCE_NUMBER
707				CONS			Consigned Flexfield				CST_VAL_UNIT_CONS_COMBINATIONS	VAL_UNIT_CONS_COMBINATION_ID	STRUCTURE_INSTANCE_NUMBER
10011			MCAT			Item Categories					EGP_CATEGORIES_B				CATEGORY_ID						STRUCTURE_INSTANCE_NUMBER
140				KEY#			Asset Key Flexfield				FA_ASSET_KEYWORDS				CODE_COMBINATION_ID				STRUCTURE_INSTANCE_NUMBER
140				CAT#			Category Flexfield				FA_CATEGORIES_B					CATEGORY_ID						STRUCTURE_INSTANCE_NUMBER
140				LOC#			Location Flexfield				FA_LOCATIONS					LOCATION_ID						STRUCTURE_INSTANCE_NUMBER
101				GL#				Accounting Flexfield			GL_CODE_COMBINATIONS			CODE_COMBINATION_ID				CHART_OF_ACCOUNTS_ID
401				MDSP			Account Alias Flexfield			INV_GENERIC_DISPOSITIONS		DISPOSITION_ID	
401				MTLL			Locator Flexfield				INV_ITEM_LOCATIONS				INVENTORY_LOCATION_ID			STRUCTURE_INSTANCE_NUMBER
801				COST			Cost Allocation Flexfield		PAY_COST_ALLOC_KEYFLEX			COST_ALLOCATION_KEYFLEX_ID		ID_FLEX_NUM
800				PPG				People Group Flexfield			PER_PEOPLE_GROUPS				PEOPLE_GROUP_ID					ID_FLEX_NUM
10455			VRM				Pricing Dimensions Flexfield	VRM_PRICING_COMBINATIONS		PRICING_COMBINATION_ID			STRUCTURE_INSTANCE_NUMBER
10052			XCC				Budgeting Flexfield				XCC_BUDGET_ACCOUNTS				BUDGET_CODE_COMBINATION_ID		BUDGET_CHART_OF_ACCOUNTS_ID
*/

		select fif.*
		  from fnd_id_flexs fif 
		  join fnd_application_tl fat on fif.application_id = fat.application_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#'
		   -- and fif.id_flex_code = 'MSTK'
		   -- and fif.id_flex_name like 'Accounting%'
		   and 1 = 1

-- ##############################################################
-- KEY FLEXFIELD STRUCTURE - ACCOUNTING FLEXFIELD
-- ##############################################################

/*
Lists the structures associated with a key flexfield
Each structure can have different options - e.g. enabled, separator etc
*/

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , '------> STRUCTURE'
			 , fifsv.id_flex_num
			 , fifsv.id_flex_structure_code code
			 , fifsv.id_flex_structure_name title
			 , fifsv.description
			 -- , fifsv.structure_view_name view_name
			 , fifsv.concatenated_segment_delimiter segment_separator
			 , fifsv.freeze_flex_definition_flag freeze_flexfield_definition
			 , fifsv.cross_segment_validation_flag cross_validate_segments
			 , fifsv.enabled_flag enabled
			 , fifsv.freeze_structured_hier_flag freeze_rollup_groups
			 , fifsv.last_update_date
			 , fifsv.dynamic_inserts_allowed_flag dynamic_insert_allowed
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		 where 1 = 1
		   and fif.id_flex_code = 'GL#' -- Accounting Flexfield
		   and 1 = 1

-- ##############################################################
-- KEY FLEXFIELD STRUCTURE - ACCOUNTING FLEXFIELD - SEGMENTS
-- ##############################################################

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , '------> STRUCTURE'
			 , fifsv.id_flex_structure_code segment_code
			 , fifsv.id_flex_structure_name segment_title
			 , '------> SEGMENTS'
			 , fnd_set.flex_value_set_id
			 , fifsvl.id_flex_num
			 , fifsvl.segment_num
			 , fifsvl.segment_name name
			 , fifsvl.form_left_prompt prompt
			 , fifsvl.description
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag displayed
			 , fifsvl.enabled_flag enabled
			 , fifsvl.display_size
			 , '#' || fifsvl.default_value default_value
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
	 left join fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fif.id_flex_code = 'GL#' -- Accounting Flexfield
		   and 1 = 1
	  order by fifsv.id_flex_structure_code
			 , fifsvl.segment_num

/*
From the above, you can see that a segment can have a list of values associated with it
When that happens, you can drill down to see the records in that list of values
*/

-- ##############################################################
-- KEY FLEXFIELD STRUCTURE - ACCOUNTING FLEXFIELD - SEGMENTS - VALUES
-- ##############################################################

		select '------> KEY FLEXFIELD'
			 , fat.application_name
			 , fif.id_flex_name flexfield_title
			 , fif.id_flex_code
			 , fifsv.id_flex_num
			 , '------> STRUCTURE'
			 , fifsv.id_flex_structure_code
			 , fifsv.id_flex_structure_name
			 , '------> SEGMENTS'
			 , fifsvl.segment_name name
			 , fifsvl.form_left_prompt prompt
			 , fifsvl.application_column_name 
			 , fnd_set.flex_value_set_name
			 , fifsvl.display_flag displayed
			 , fifsvl.enabled_flag enabled
			 , '------> VALUES'
			 , fnd_value.flex_value
			 , fnd_value_tl.description
			 , fnd_value.end_date_active
			 , fnd_value.enabled_flag
			 , fnd_value.summary_flag parent
			 , substr(replace(replace(fnd_value.compiled_value_attributes,chr(10),''),chr(13),' '),1,1) budg_flag
			 , substr(replace(replace(fnd_value.compiled_value_attributes,chr(10),''),chr(13),' '),2,1) post_flag
		  from fnd_id_flexs fif
		  join fnd_application_tl fat on fif.application_id = fat.application_id and fat.language = userenv('lang')
		  join fnd_id_flex_structures_vl fifsv on fif.id_flex_code = fifsv.id_flex_code
		  join fnd_id_flex_segments_vl fifsvl on fifsvl.id_flex_code = fifsv.id_flex_code and fifsvl.id_flex_num = fifsv.id_flex_num
	 left join fnd_flex_value_sets fnd_set on fifsvl.flex_value_set_id = fnd_set.flex_value_set_id
		  join fnd_flex_values fnd_value on fnd_value.flex_value_set_id = fnd_set.flex_value_set_id
		  join fnd_flex_values_tl fnd_value_tl on fnd_value.flex_value_id = fnd_value_tl.flex_value_id and fnd_value_tl.language = userenv('lang')
		 where fif.id_flex_code = 'GL#'
		   and 1 = 1

-- ##############################################################
-- KEY FLEXFIELD - ACCOUNTING SEGMENTS BASIC SQL
-- ##############################################################

		select s.* 
		  from fnd_id_flex_segments_vl s
		     , fnd_segment_attribute_values v
		 where s.id_flex_code = 'GL#'
		   and v.id_flex_code = 'GL#' 
		   -- and s.id_flex_num = :$flex$.gl_srs_coa_unvalidated
		   -- and v.id_flex_num = :$flex$.gl_srs_coa_unvalidated
		   and s.enabled_flag = 'Y' 
		   and s.application_column_name=v.application_column_name
		   and s.application_id = 101
		   and v.application_id = 101
		   and v.segment_attribute_type = 'GL_ACCOUNT'
		   -- and v.attribute_value = 'N'
	  order by segment_num

-- ##############################################################
-- KEY FLEXFIELD - FIND NATURAL AND BALANCING SEGMENTS
-- ##############################################################

/*
http://orclapp.blogspot.co.uk/2012/11/11510-sql-script-to-find-values-of.html
*/

		select fifs.id_flex_structure_code
			 , fsav.application_column_name
			 , ffsg.segment_name
			 , fnd_set.flex_value_set_name
			 , decode (fsav.segment_attribute_type
					 , 'FA_COST_CTR', 'Cost Center Segment'
					 , 'GL_ACCOUNT', 'Natural Account Segment'
					 , 'GL_BALANCING', 'Balancing Segment'
					 , 'GL_INTERCOMPANY', 'Intercompany Segment'
					 , 'GL_SECONDARY_TRACKING','Secondary Tracking Segment'
					 , 'GL_MANAGEMENT', 'Management Segment') details
		  from fnd_segment_attribute_values fsav
		  join fnd_id_flex_structures fifs on fsav.id_flex_num = fifs.id_flex_num
		  join fnd_id_flex_segments ffsg on ffsg.id_flex_num = fifs.id_flex_num and ffsg.application_column_name = fsav.application_column_name
		  join fnd_flex_value_sets fnd_set on ffsg.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fsav.attribute_value = 'Y'
		   and fsav.segment_attribute_type not in ('GL_GLOBAL', 'GL_LEDGER')
		   and decode (fsav.segment_attribute_type
					 , 'FA_COST_CTR', 'Cost Center Segment'
					 , 'GL_ACCOUNT', 'Natural Account Segment'
					 , 'GL_BALANCING', 'Balancing Segment'
					 , 'GL_INTERCOMPANY', 'Intercompany Segment'
					 , 'GL_SECONDARY_TRACKING','Secondary Tracking Segment'
					 , 'GL_MANAGEMENT', 'Management Segment') is not null

-- ##############################################################
-- GET COST CENTRE SEGMENT NAME
-- ##############################################################

		select distinct fnd_set.flex_value_set_name -- distinct because can have multiple chart of accounts
		  from fnd_segment_attribute_values fsav
		  join fnd_id_flex_structures fifs on fsav.id_flex_num = fifs.id_flex_num
		  join fnd_id_flex_segments ffsg on ffsg.id_flex_num = fifs.id_flex_num and ffsg.application_column_name = fsav.application_column_name
		  join fnd_flex_value_sets fnd_set on ffsg.flex_value_set_id = fnd_set.flex_value_set_id
		 where 1 = 1
		   and fsav.attribute_value = 'Y'
		   and fsav.segment_attribute_type not in ('GL_GLOBAL', 'GL_LEDGER')
		   and fsav.segment_attribute_type = 'FA_COST_CTR'
