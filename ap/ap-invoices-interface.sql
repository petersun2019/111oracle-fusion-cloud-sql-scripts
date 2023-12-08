/*
File Name: ap-invoices-interface.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- HEADERS - TABLE DUMP 1
-- HEADERS - TABLE DUMP 2 BASED ON DATE
-- LINES TABLE DUMP
-- REJECTIONS TABLE DUMP
-- HEADERS - REJECTED
-- HEADERS - DETAILS
-- SUMMARY BY SOURCE AND STATUS
-- SUMMARY BY MONTH
-- SUMMARY BY DAY
-- SUMMARY BY STATUS
-- AP_INVOICES_INTERFACE & LINES
-- REJECTIONS SUMMARY

*/

-- ##############################################################
-- HEADERS - TABLE DUMP 1
-- ##############################################################

select * from ap_invoices_interface where invoice_id = 1234
select * from ap_invoices_interface where invoice_num in ('123')
select * from ap_invoices_interface order by creation_date desc

-- ##############################################################
-- HEADERS - TABLE DUMP 2 BASED ON DATE
-- ##############################################################

		select *
		  from fusion.ap_invoices_interface aii
		 where 1 = 1
		   and to_char(creation_date, 'YYYY') = '2022'
		   and to_char(creation_date, 'MM') = '09'
		   and to_char(creation_date, 'DD') = '06'

-- ##############################################################
-- LINES TABLE DUMP
-- ##############################################################

select * from ap_invoice_lines_interface
select * from ap_invoice_lines_interface order by creation_date desc
select * from ap_invoice_lines_interface where invoice_id in (123)
select * from ap_invoice_lines_interface where description like 'CHEESE%'

-- ##############################################################
-- REJECTIONS TABLE DUMP
-- ##############################################################

select * from ap_interface_rejections order by creation_date desc
select * from ap_interface_rejections where to_char(creation_date, 'yyyy-mm-dd') = '2022-07-13'
select * from ap_interface_rejections where invoice_id in (123,234,345)

-- ##############################################################
-- HEADERS - REJECTED
-- ##############################################################

		select *
		  from fusion.ap_invoices_interface aii
		 where 1 = 1
		   and status = 'REJECTED'
		   and 1 = 1
	  order by creation_date

-- ##############################################################
-- HEADERS - DETAILS
-- ##############################################################

		select aii.invoice_id
			 , '#' || aii.invoice_num invoice_num
			 , hou.name operating_unit
			 , aii.invoice_type_lookup_code
			 , aii.source
			 , flv_source.meaning source_description
			 , (replace(replace(aii.description,chr(10),''),chr(13),' ')) description
			 , psv.vendor_name supplier
			 , psv.segment1 supplier#
			 , pssam.vendor_site_code site
			 , aii.created_by
			 , to_char(aii.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aii.invoice_date, 'yyyy-mm-dd') inv_date
			 , aii.invoice_amount
			 , aii.status
			 , aii.group_id
			 , aii.request_id
		  from ap_invoices_interface aii
	 left join poz_suppliers_v psv on aii.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aii.vendor_site_id = pssam.vendor_site_id
	 left join hz_party_sites hps on hps.party_site_id = pssam.party_site_id
	 left join hr_operating_units hou on aii.org_id = hou.organization_id
	 left join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aii.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
		 where 1 = 1
		   and 1 = 1
	  order by to_char(aii.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc

-- ##############################################################
-- SUMMARY BY SOURCE AND STATUS
-- ##############################################################

		select source
			 , status
			 , min(to_char(creation_date, 'yyyy-mm-dd')) min_
			 , max(to_char(creation_date, 'yyyy-mm-dd')) max_
			 , count(*)
		  from fusion.ap_invoices_interface aii
	  group by source
			 , status

-- ##############################################################
-- SUMMARY BY MONTH
-- ##############################################################

		select to_char(creation_date, 'YYYY-MM')
			 , min(to_char(creation_date, 'yyyy-mm-dd')) min_
			 , max(to_char(creation_date, 'yyyy-mm-dd')) max_
			 , count(*)
		  from fusion.ap_invoices_interface aii
	  group by to_char(creation_date, 'YYYY-MM')
	  order by to_char(creation_date, 'YYYY-MM')

-- ##############################################################
-- SUMMARY BY DAY
-- ##############################################################
	  
		select to_char(creation_date, 'YYYY-MM-DD')
			 , count(*)
		  from fusion.ap_invoices_interface aii
		 where 1 = 1
		   and to_char(creation_date, 'YYYY') = '2022'
		   and to_char(creation_date, 'MM') = '09'
		   -- and to_char(creation_date, 'DD') = '13'
		   and 1 = 1
	  group by to_char(creation_date, 'YYYY-MM-DD')
	  order by to_char(creation_date, 'YYYY-MM-DD')

-- ##############################################################
-- SUMMARY BY STATUS
-- ##############################################################

		select status
			 , min(to_char(creation_date, 'yyyy-mm-dd')) min_
			 , max(to_char(creation_date, 'yyyy-mm-dd')) max_
			 , count(*)
		  from fusion.ap_invoices_interface aii
		 where 1 = 1
		   and to_char(creation_date, 'YYYY') = '2022'
		   and to_char(creation_date, 'MM') = '09'
		   -- and to_char(creation_date, 'DD') = '13'
		   and 1 = 1
	  group by status

-- ##############################################################
-- AP_INVOICES_INTERFACE & LINES
-- ##############################################################

		select aii.invoice_id
			 , '#' || aii.invoice_num invoice_num
			 , hou.name operating_unit
			 , aii.invoice_type_lookup_code
			 , aii.source
			 , flv_source.meaning source_description
			 , (replace(replace(aii.description,chr(10),''),chr(13),' ')) description
			 , psv.vendor_name supplier
			 , psv.segment1 supplier#
			 , pssam.vendor_site_code site
			 , aii.created_by
			 , to_char(aii.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(aii.invoice_date, 'yyyy-mm-dd') inv_date
			 , aii.invoice_amount
			 , aii.status
			 , aii.group_id
			 , aii.request_id
			 , '############' lines________________
			 , aili.line_type_lookup_code
			 , aili.amount line_amount
			 , (replace(replace(aili.description,chr(10),''),chr(13),' ')) line_descr
			 , (replace(replace(aili.item_description,chr(10),''),chr(13),' ')) line_item_descr
			 , pha.segment1 po
		  from ap_invoices_interface aii
	 left join ap_invoice_lines_interface aili on aii.invoice_id = aili.invoice_id
	 left join poz_suppliers_v psv on aii.vendor_id = psv.vendor_id
	 left join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aii.vendor_site_id = pssam.vendor_site_id
	 left join hz_party_sites hps on hps.party_site_id = pssam.party_site_id
	 left join hr_operating_units hou on aii.org_id = hou.organization_id
	 left join fnd_lookup_values_vl flv_source on flv_source.lookup_code = aii.source and flv_source.lookup_type = 'SOURCE' and flv_source.view_application_id = 200
	 left join po_headers_all pha on pha.po_header_id = aili.po_header_id
		 where 1 = 1
		   and 1 = 1
	  order by aii.invoice_id desc

-- ##############################################################
-- REJECTIONS SUMMARY
-- ##############################################################

		select reject_lookup_code
			 , parent_table
			 , min(to_char(creation_date, 'yyyy-mm-dd')) min_
			 , max(to_char(creation_date, 'yyyy-mm-dd')) max_
			 , count(*)
		  from ap_interface_rejections
	  group by reject_lookup_code
			 , parent_table
