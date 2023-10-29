/*
File Name: gl-hierarchy.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TREE VERSION DEFINITIONS
-- LEDGERS
-- CHART OF ACCOUNTS STRUCTURE
-- GL CHART OF ACCOUNTS SEGMENT HIERARCHY
-- COUNTING SUMMARY

*/

-- ##############################################################
-- TREE VERSION DEFINITIONS
-- ##############################################################

/*
Use this SQL to get the TREE_CODE and TREE_VERSION_NAME
You can then use those values in the SQL to report on a specific hierarchy
*/

		select ftv.tree_code
			 , ftvt.tree_version_name 
			 , ftv.status
			 , ftv.node_count
			 , to_char(ftv.effective_start_date, 'yyyy-mm-dd') start_date
			 , to_char(ftv.effective_end_date, 'yyyy-mm-dd') end_date
			 , to_char(ftv.last_validation_date, 'yyyy-mm-dd hh24:mi:ss') last_validation_date
			 , to_char(ftv.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , ftv.created_by
			 , to_char(ftv.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ftv.last_updated_by
		  from fnd_tree_version ftv
		  join fnd_tree_version_tl ftvt on ftvt.tree_version_id = ftv.tree_version_id and ftvt.language = userenv('lang')
		 where 1 = 1
		   and ftv.tree_structure_code = 'GL_ACCT_FLEX'
		   and 1 = 1

-- ##############################################################
-- LEDGERS
-- ##############################################################

/*
To get segment descriptions, you need to know the chart_of_accounts_id to feed into GL_FLEXFIELDS_PKG.GET_DESCRIPTION_SQL
You can run this SQL to get details about ledgers
*/

		select gllv.ledger_name
			 , gllv.legal_entity_name
			 , gllv.currency_code
			 , gllv.chart_of_accounts_id -- this is the ID to use with GL_FLEXFIELDS_PKG.GET_DESCRIPTION_SQL
			 , gllv.period_set_name
			 , gllv.ledger_category_code
			 , gllv.sla_accounting_method_code
		  from gl_ledger_le_v gllv
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CHART OF ACCOUNTS STRUCTURE
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
		   and fif.id_flex_code = 'GL#'
		   and 1 = 1
	  order by fifsv.id_flex_structure_code
			 , fifsvl.segment_num

/*
This SQL can be used to extract details about the Chart of Accounts structure.
When you run it, you can see the SEGMENT_NUM for the Chart of Accounts segment whose hierarchy you are checking

Also make a note of the FLEX_VALUE_SET_ID value for the Chart of Accounts Segment whose hierarchy you are checking
	That can be used to find if the segment in the hierarchy is enabled or not.
*/

-- ##############################################################
-- GL CHART OF ACCOUNTS SEGMENT HIERARCHY
-- ##############################################################

/*
Note about GL_FLEXFIELDS_PKG.GET_DESCRIPTION_SQL
This can be used to get the description of a segment value
For it to work, you have to pass it 2 values:

1. CHART_OF_ACCOUNTS_ID 
Get that from "LEDGERS" SQL above

2. SEGMENT_NUM
You need to know the SEGMENT_NUM from the chart of accounts segment whose description you want to extract

Additionally, you need these values to put into the hierarchy SQL:

1. TREE_CODE
2. TREE_VERSION_NAME
3. FLEX_VALUE_SET_ID

Finally, for the Hierarchy SQL to work, you need to feed in the TREE_CODE and TREE_VERSION_NAME from "TREE VERSION DEFINITIONS" SQL above.

Plus 
*/

		select ftn.tree_structure_code
			 , ftn.tree_code
			 , ftvt.tree_version_name
			 , ftn.parent_pk1_value parent
			 , ftn.child_count
			 , level
			 , ftn.depth
			 , ftn.sort_order
			 , gl_flexfields_pkg.get_description_sql(4001, 3, ftn.parent_pk1_value) parent_description -- first number is chart_of_accounts_id, second number is segment number for relevant segment (e.g. if Cost Centre is Segment 2, then number is 2)
			 , '#' || ftn.pk1_start_value child
			 , fnd_value.enabled_flag
			 , gl_flexfields_pkg.get_description_sql(4001, 3, ftn.pk1_start_value) child_description
			 , lpad('_', (level - 1) * 5, '_') || ftn.pk1_start_value start_code
			 , sys_connect_by_path((ftn.pk1_start_value), '.') as path
			 , case when level = 1 then '#' || ftn.pk1_start_value end level_01
			 , case when level = 2 then '#' || ftn.pk1_start_value end level_02
			 , case when level = 3 then '#' || ftn.pk1_start_value end level_03
			 , case when level = 4 then '#' || ftn.pk1_start_value end level_04
			 , case when level = 5 then '#' || ftn.pk1_start_value end level_05
			 , case when level = 6 then '#' || ftn.pk1_start_value end level_06
			 , case when level = 7 then '#' || ftn.pk1_start_value end level_07
			 , case when level = 8 then '#' || ftn.pk1_start_value end level_08
			 , case when level = 9 then '#' || ftn.pk1_start_value end level_09
			 , case when level = 10 then '#' || ftn.pk1_start_value end level_10
			 , '####' who___
			 , to_char(ftn.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , ftn.created_by
			 , to_char(ftn.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , ftn.last_updated_by
		  from fnd_tree_node ftn
		  join fnd_tree_version_tl ftvt on ftvt.tree_version_id = ftn.tree_version_id
		  join fnd_flex_values fnd_value on fnd_value.flex_value = ftn.pk1_start_value and fnd_value.flex_value_set_id = 65002 -- :FLEX_VALUE_SET_ID -- ID for Relevant Value Set - get IDs from "CHART OF ACCOUNTS STRUCTURE" query
		 where ftn.tree_structure_code = 'GL_ACCT_FLEX'
		   and ftn.tree_code = 'XXERP_FIN_GL_SUBJECTIVE_T' -- :TREE_CODE
		   and ftvt.tree_version_name = 'XXERP_FIN_GL_SUBJECTIVE_V1' -- :TREE_VERSION_NAME
    start with ftn.parent_tree_node_id is null
	connect by prior ftn.tree_node_id = ftn.parent_tree_node_id
	order siblings by ftn.pk1_start_value

-- ##############################################################
-- COUNTING SUMMARY
-- ##############################################################

		select ftn.tree_structure_code
			 , ftn.tree_code
			 , ftvt.tree_version_name
			 , count(*) ct
		  from fnd_tree_node ftn
		  join fnd_tree_version_tl ftvt on ftvt.tree_version_id = ftn.tree_version_id
		 where ftn.tree_structure_code = 'GL_ACCT_FLEX'
		   and ftn.tree_code = :TREE_CODE
		   and ftvt.tree_version_name = :TREE_VERSION_NAME
	  group by ftn.tree_structure_code
			 , ftn.tree_code
			 , ftvt.tree_version_name
