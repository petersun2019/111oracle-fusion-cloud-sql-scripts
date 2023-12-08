/*
File Name: sa-hdl.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

HDL: HCM Data Loader

Queries:

-- HDL HEADERS
-- HDL HEADERS AND LINES
-- HDL HEADERS, LINES AND ERRORS
-- HDL SOURCE SYSTEM OWNER - INTEGRATION KEYS
-- HCM SPREADSHEET DATA LOAD (HSDL)

*/

-- ##############################################################
-- HDL HEADERS
-- ##############################################################

		select hdds.data_set_id
			 , hdds.ucm_content_id
			 , hdds.request_id process_id
			 , to_char(hdds.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , hdds.created_by
			 , hdds.data_set_name
			 , hdds.transfer_status
			 , hdds.imported_status
			 , hdds.loaded_status
			 , hdds.validated_status
			 , hdds.import_lines_success_count
			 , hdds.import_lines_error_count
			 , hdds.import_lines_total_count
			 , hdds.import_success_count
			 , hdds.import_error_count
			 , hdds.loaded_count
			 , hdds.error_count
		  from hrc_dl_data_sets hdds
		 where 1 = 1
		   and 1 = 1
	  order by hdds.data_set_id desc
			 , to_char(hdds.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- HDL HEADERS AND LINES
-- ##############################################################

		select hdds.data_set_id
			 , hdds.ucm_content_id
			 , hdds.request_id process_id
			 , to_char(hdds.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , hdds.created_by
			 , hdds.data_set_name
			 , hdds.transfer_status
			 , hdds.imported_status
			 , hdds.loaded_status
			 , hdds.validated_status
			 , hdds.import_lines_success_count
			 , hdds.import_lines_error_count
			 , hdds.import_lines_total_count
			 , hdds.import_success_count
			 , hdds.import_error_count
			 , hdds.loaded_count
			 , hdds.error_count
			 , hdfl.data_set_bus_obj_id
			 , hdfl.line_id
			 , hdfl.text
			 , hdfl.seq_num line_seq
		  from hrc_dl_data_sets hdds
		  join hrc_dl_data_set_bus_objs hddsbo on hdds.data_set_id = hddsbo.data_set_id
		  join hrc_dl_file_lines hdfl on hdfl.data_set_bus_obj_id = hddsbo.data_set_bus_obj_id
		 where 1 = 1
		   and 1 = 1
	  order by hdds.data_set_id desc
			 , to_char(hdds.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- HDL HEADERS, LINES AND ERRORS
-- ##############################################################

		select hdds.request_id process_id
			 -- , hdds.ucm_content_id
			 -- , hdds.data_set_id
			 , to_char(hdds.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , hdds.created_by
			 , hdds.data_set_name
			 , hdds.transfer_status
			 , hdds.imported_status
			 , hdds.loaded_status
			 -- , hdds.validated_status
			 -- , hdds.import_lines_success_count
			 -- , hdds.import_lines_error_count
			 -- , hdds.import_lines_total_count
			 -- , hdds.import_success_count
			 -- , hdds.import_error_count
			 -- , hdds.loaded_count
			 , hdds.error_count
			 -- , hdfl.data_set_bus_obj_id
			 -- , hdfl.line_id
			 , hdfl.text line_text
			 , hdml.message_source_table_name
			 , hdml.originating_process
			 , hdml.generated_by
			 , hdml.message_type
			 -- , hdml.message_source_line_id
			 -- , hdml.request_id request_id_err
			 , hdml.group_by_expr_val
			 , hdml.msg_text error_message
			 , hdml.message_user_details
		  from hrc_dl_data_sets hdds
		  join hrc_dl_data_set_bus_objs hddsbo on hdds.data_set_id = hddsbo.data_set_id
		  join hrc_dl_file_lines hdfl on hdfl.data_set_bus_obj_id = hddsbo.data_set_bus_obj_id
	 left join hrc_dl_message_lines hdml on hdml.data_set_bus_obj_id = hdfl.data_set_bus_obj_id
		 where 1 = 1
		   and 1 = 1
	  order by hdds.request_id desc

-- ##############################################################
-- HDL SOURCE SYSTEM OWNER - INTEGRATION KEYS
-- ##############################################################

/*
Steps to create/define the source system owner for hdl in oracle fusion
https://rpforacle.blogspot.com/2019/11/how-to-define-source-system-owner-for-hdl-in-oracle-fusion.html
In Fusion Applications > click on Navigator > Setup and Maintenance > Manage Common Lookups > HRC_SOURCE_SYSTEM_OWNER

Integration Keys
https://doyensys.com/blogs/oracle-fusion-hcm-data-loader-hdl-keys/
*/

		select object_name
			 , source_system_id
			 , source_system_owner
			 , surrogate_id
			 , rawtohex (guid) guid
		  from fusion.hrc_integration_key_map

-- ##############################################################
-- HCM SPREADSHEET DATA LOAD (HSDL)
-- ##############################################################

/*
https://docs.oracle.com/en/cloud/saas/human-resources/22b/oedmh/hrcsdlinterfaceheader-5729.html#hrcsdlinterfaceheader-5729
*/

select * from hrc_sdl_interface_header
select * from hrc_sdl_interface_lines
