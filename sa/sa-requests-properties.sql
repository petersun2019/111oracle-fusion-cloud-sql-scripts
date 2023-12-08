/*
File Name: sa-requests-properties.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

The REQUEST_PROPERTY table can be used to access parameter values used when submitting a request

Queries:

-- REQUEST PROPERTIES - TABLE DUMPS
-- REQUEST PROPERTIES - DETAILS

*/

-- ##############################################################
-- REQUEST PROPERTIES - TABLE DUMPS
-- ##############################################################

select * from request_property where requestid = 123456
select * from request_property where requestid in (123456)

-- ##############################################################
-- REQUEST PROPERTIES - DETAILS
-- ##############################################################

		select rh.requestid id
			 , rh.absparentid -- when the process is scheduled, this field contains the parent request which is the schedule parent
			 , rh.instanceparentid -- the parent process in that instance run
			 , flv_state.meaning status
			 , rh.state state_
			 , to_char(rh.submission, 'yyyy-mm-dd hh24:mi:ss') submission
			 , to_char(rh.scheduled, 'yyyy-mm-dd hh24:mi:ss') scheduled
			 , to_char(rh.processstart, 'yyyy-mm-dd hh24:mi:ss') start_
			 , to_char(rh.processend, 'yyyy-mm-dd hh24:mi:ss') end_
			 , replace(substr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), 0, instr(to_char(rh.processend-rh.processstart, 'DD HH24:MI:SS'), '.')-1),'+0000000','') dur_ -- dd_mm_hh_ss
			 , substr(rh.definition,(instr(rh.definition,'/',-1)+1)) definition
			 , rh.product
			 , rh.username
			 , replace(replace(replace(rh.error_warning_message, chr(10), ''), chr(13), ''), chr(09), '') error_warning_message
			 , rh.error_warning_detail -- including this breaks excel export as it always has line breaks and things in it, even if you try and strip them out they always appear at the start of the field, whatever i try...
			 , rp.name
			 , rp.datatype
			 , rp.value value
			 -- ,'##################'
			 -- , rh_sub.requestid child_id
			 -- , regexp_substr(rh_sub.definition, '[^/]+', 1, length(regexp_replace(rh_sub.definition, '[^/]', ''))) child_definition
			 -- , rh_sub.state child_state
			 -- , flv_state_sub.meaning child_status
			 -- , rh_sub.absparentid
		  from request_history rh
	 left join fnd_lookup_values_vl flv_state on flv_state.lookup_code = rh.state and flv_state.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
	 -- tables for data about child jobs
	 -- left join request_history rh_sub on rh.requestid = rh_sub.absparentid
	 -- left join fnd_lookup_values_vl flv_state_sub on flv_state_sub.lookup_code = rh_sub.state and flv_state_sub.lookup_type = 'ORA_EGP_ESS_REQUEST_STATUS'
	 left join request_property rp on rp.requestid = rh.requestid
		 where 1 = 1
		   and rp.value is not null
		   and rh.requestid = 123456
		   and 1 = 1
	  order by rh.requestid desc
			 , rp.name
