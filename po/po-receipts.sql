/*
File Name: po-receipts.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- RECEIPT HEADERS
-- RECEIPT TRANSACTIONS
-- RECEIPTS JOINED TO PO TABLE 1
-- RECEIPTS JOINED TO PO TABLE 2
-- RECEIPTS JOINED TO PO HEADERS AND LINES
-- AP INVOICE > PO > RECEIPT (MATCH TO PO) 1
-- AP INVOICE > PO > RECEIPT (MATCH TO PO) 2
-- REQ -> PO -> RECEIPT -> ID DATA DISTINCT

*/

-- ##############################################################
-- RECEIPT HEADERS
-- ##############################################################

		select rsh.*
		  from rcv_shipment_headers rsh
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- RECEIPT TRANSACTIONS
-- ##############################################################

		select rsh.receipt_num
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , rsh.created_by receipt_created_by
			 , rt.*
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- RECEIPTS JOINED TO PO TABLE 1
-- ##############################################################

		select rsh.shipment_header_id
			 , pha.segment1 po
			 , bu.bu_name
			 , psv.vendor_name
			 , rsh.receipt_num
			 , to_char(rsh.creation_date, 'yyyy-mm-dd') gl_date
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , rsh.created_by receipt_created_by
			 , rt.quantity receipt_qty
			 , '####################'
			 , rt.transaction_id
			 , to_char(rt.creation_date, 'yyyy-mm-dd hh24:mi:ss') rx_trx_created
			 , to_char(rt.transaction_date, 'yyyy-mm-dd') transaction_date
			 , rt.amount receipt_amount
			 , rt.transaction_type receipt_type
			 , rt.destination_type_code receipt_destination
			 , rt.currency_code receipt_currency
			 , rt.currency_conversion_type receipt_curr_conv_type
			 , rt.currency_conversion_rate
			 , to_char(rt.currency_conversion_date, 'yyyy-mm-dd') receipt_conv_date
			 , to_char(rsh.last_update_date, 'yyyy-mm-dd hh24:mi:ss') rsh_updated
			 , to_char(rt.last_update_date, 'yyyy-mm-dd hh24:mi:ss') rt_updated
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		  join po_headers_all pha on rt.po_header_id = pha.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join fun_all_business_units_v bu on bu.bu_id = pha.req_bu_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################

		select rsh.shipment_header_id shipment_header_id_
			 , pha.segment1 po_
			 , rsh.receipt_num rx_num
			 , '####################'
			 , rt.*
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		  join po_headers_all pha on rt.po_header_id = pha.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join fun_all_business_units_v bu on bu.bu_id = pha.req_bu_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################

		select rsh.shipment_header_id
			 , pha.segment1 po_
			 , rsh.receipt_num rx_num
			 , rsh.created_by
			 , count(*)
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		  join po_headers_all pha on rt.po_header_id = pha.po_header_id
		  join poz_suppliers_v psv on pha.vendor_id = psv.vendor_id
		  join fun_all_business_units_v bu on bu.bu_id = pha.req_bu_id
		 where 1 = 1
		   and 1 = 1
	  group by rsh.shipment_header_id
			 , pha.segment1
			 , rsh.receipt_num
			 , rsh.created_by
	    having count(*) = 2

-- ##############################################################
-- RECEIPTS JOINED TO PO TABLE 2
-- ##############################################################

		select rt.*
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		  join po_headers_all pha on rt.po_header_id = pha.po_header_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- RECEIPTS JOINED TO PO HEADERS AND LINES
-- ##############################################################

		select pha.segment1 po
			 , pha.created_by po_created_by
			 , rsh.receipt_num
			 , rsh.shipment_header_id
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , rsh.created_by receipt_created_by
			 , rt.quantity receipt_qty
			 , rt.source_doc_quantity
			 , rt.quantity_billed
			 , pla.unit_price po_line_unit_price
			 , pla.line_num po_line_num
			 , pla.quantity po_line_quantity
			 , pla.amount po_line_amount
			 , '####################'
			 , to_char(rt.creation_date, 'yyyy-mm-dd hh24:mi:ss') rx_trx_created
			 , rt.amount receipt_amount
			 , rt.transaction_type receipt_type
			 , rt.destination_type_code receipt_destination
			 , rt.currency_code receipt_currency
			 , rt.currency_conversion_type receipt_curr_conv_type
			 , '#' || rt.currency_conversion_rate receipt_conv_rate
			 , rt.currency_conversion_date receipt_conv_date
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		  join po_headers_all pha on rt.po_header_id = pha.po_header_id
		  join po_lines_all pla on rt.po_line_id = pla.po_line_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- AP INVOICE > PO > RECEIPT (MATCH TO PO) 1
-- ##############################################################

/*
If PO Match is set to Match to PO (held on PO Shipment (po_line_locations_all.match_option)) then PO receipts do not link back to AP Invoice
Meaning can have 1 AP invoice matched to 1 PO.
However, if 10 receipts done against that PO, the SQL will return 10 rows, since the receipts cannot be joined to AP tables.
When the PO match is set as "MATCH TO PO" the Invoice will not get the RCV_TRANSACTION_ID
*/

		select aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount inv_amt
			 , aia.amount_paid
			 , aia.payment_status_flag inv_paid
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , pha.segment1 po
			 , pha.document_status po_doc_status
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_created
			 , sum(nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount when (plla.amount is null) then pla.unit_price * plla.quantity end, 0)) po_value
			 , rsh.receipt_num
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , sum(nvl(rt.amount, (rt.quantity*rt.po_unit_price))) receipt_value
			 , sum(nvl(rt.amount_billed, rt.quantity_billed)) receipt_billed_value
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_lines_all pla on pla.po_line_id = pda.po_line_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join po_headers_all pha on pha.po_header_id = pla.po_header_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
	 left join rcv_transactions rt on rt.po_header_id = pha.po_header_id and rt.po_header_id = pha.po_header_id and rt.po_line_id = pla.po_line_id and rt.po_line_location_id = plla.line_location_id and rt.po_distribution_id = pda.po_distribution_id and rt.transaction_type = 'RECEIVE' and rt.USER_ENTERED_FLAG = 'Y'
	 left join rcv_shipment_headers rsh on rt.shipment_header_id = rsh.shipment_header_id
		 where 1 = 1
		   and 1 = 1
	  group by aia.invoice_id
			 , '#' || aia.invoice_num
			 , hou.name
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name
			 , pssam.vendor_site_code
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(aia.invoice_date, 'yyyy-mm-dd')
			 , aia.invoice_amount
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id)
			 , pha.segment1
			 , pha.document_status
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , rsh.receipt_num

-- ##############################################################
-- AP INVOICE > PO > RECEIPT (MATCH TO PO) 2
-- ##############################################################

/*
Covers scenario where PO is set up as "Match to Receipt."
See: Value For RCV_TRANSACTION_ID In AP_INVOICE_DISTRIBUTIONS_ALL Is Null (Doc ID 285282.1)

Issue:

The value for RCV_TRANSACTION_ID in the Table AP_INVOICE_DISTRIBUTIONS_ALL
does not get populated at all. Did several RTS Transaction with the auto-debit turned on,
and the debit memo's got created but the value for rcv_transaction_id in ap_invoice_distributions_all
is blank for all such debit memo's.

Solution:

When the PO match is set as "MATCH TO PO" at is the case, the Invoice will not get the RCV_TRANSACTION_ID.

RCV_TRANSACTION_ID gets populated in ap_invoice_distributions_all table
only when the PO is set up as "Match to Receipt."

Please perform the following steps to confirm if the Match Option is Set to PO or Receipt.

In the PO application, query up your puchase order.
Go to Shipments and click on the more tabs.
Check field PO Matching Option, and it will either be set to "PO" or to "Receipt."

In which case can join rcv_transactions to AP Invoice Distribution: rt.transaction_id = aida.RCV_TRANSACTION_ID
*/

		select aia.invoice_id
			 , '#' || aia.invoice_num invoice_num
			 , hou.name operating_unit
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name supplier
			 , pssam.vendor_site_code site
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss') inv_created
			 , to_char(aia.invoice_date, 'yyyy-mm-dd') inv_date
			 , aia.invoice_amount inv_amt
			 , aia.amount_paid
			 , aia.payment_status_flag inv_paid
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id) accounted
			 , pha.segment1 po
			 , pha.document_status po_doc_status
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss') po_created
			 , sum(nvl(case when (plla.quantity is null and pla.unit_price is null) then plla.amount when (plla.amount is null) then pla.unit_price * plla.quantity end, 0)) po_value
			 , rsh.receipt_num
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , sum(nvl(rt.amount, (rt.quantity*rt.po_unit_price))) receipt_value
			 , sum(nvl(rt.amount_billed, rt.quantity_billed)) receipt_billed_value
		  from ap_invoices_all aia
		  join ap_invoice_lines_all aila on aia.invoice_id = aila.invoice_id
		  join ap_invoice_distributions_all aida on aia.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
		  join po_distributions_all pda on pda.po_distribution_id = aida.po_distribution_id
		  join po_lines_all pla on pla.po_line_id = pda.po_line_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join po_headers_all pha on pha.po_header_id = pla.po_header_id
		  join poz_suppliers_v psv on aia.vendor_id = psv.vendor_id
		  join poz_supplier_sites_all_m pssam on psv.vendor_id = pssam.vendor_id and aia.vendor_site_id = pssam.vendor_site_id
		  join hr_operating_units hou on aia.org_id = hou.organization_id
		  join rcv_transactions rt on rt.po_header_id = pha.po_header_id and rt.po_header_id = pha.po_header_id and rt.po_line_id = pla.po_line_id and rt.po_line_location_id = plla.line_location_id and rt.po_distribution_id = pda.po_distribution_id and rt.transaction_type = 'RECEIVE' and rt.USER_ENTERED_FLAG = 'Y' and rt.transaction_id = aida.rcv_transaction_id
		  join rcv_shipment_headers rsh on rt.shipment_header_id = rsh.shipment_header_id
		  -- join rcv_shipment_lines rsl on rsl.shipment_header_id = rsh.shipment_header_id and rsl.po_header_id = pha.po_header_id and rsl.po_line_id = pla.po_line_id and rsl.po_line_location_id = plla.line_location_id and rsl.po_distribution_id = pda.po_distribution_id and rsl.rcv_shipment_line_id = aila.rcv_shipment_line_id
		 where 1 = 1
		   and 1 = 1
	  group by aia.invoice_id
			 , '#' || aia.invoice_num
			 , hou.name
			 , aia.invoice_type_lookup_code
			 , aia.source
			 , psv.vendor_name
			 , pssam.vendor_site_code
			 , aia.created_by
			 , to_char(aia.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(aia.invoice_date, 'yyyy-mm-dd')
			 , aia.invoice_amount
			 , aia.amount_paid
			 , aia.payment_status_flag
			 , ap_invoices_pkg.get_posting_status(aia.invoice_id)
			 , pha.segment1
			 , pha.document_status
			 , to_char(pha.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , rsh.receipt_num

-- ##############################################################
-- REQ -> PO -> RECEIPT -> ID DATA DISTINCT
-- ##############################################################

		select distinct prha.requisition_number req
			 , to_char(prha.creation_date,'yyyy-mm-dd hh24:mi:ss') req_created
			 , prha.created_by req_created_by
			 , pha.segment1 po
			 , pha.document_creation_method
			 , to_char(pha.creation_date,'yyyy-mm-dd hh24:mi:ss') po_created
			 , pha.created_by po_created_by
			 , rsh.receipt_num
			 , to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') receipt_created
			 , rsh.created_by receipt_created_by
			 , ppav.segment1 project
			 , to_char(pda.pjc_expenditure_item_date, 'yyyy-mm-dd') pjc_expenditure_item_date
			 , exp_type.expenditure_type_name exp_type
			 , '#' id_info____________
			 , prha.requisition_header_id
			 , pha.po_header_id
			 , rsh.shipment_header_id
			 , rt.transaction_id
			 , pla.po_line_id
			 , prda.requisition_line_id
			 , prda.distribution_id req_dist_id
			 , pda.po_distribution_id
		  from rcv_shipment_headers rsh
		  join rcv_transactions rt on rt.shipment_header_id = rsh.shipment_header_id
		  join po_headers_all pha on rt.po_header_id = pha.po_header_id
		  join po_lines_all pla on rt.po_line_id = pla.po_line_id
		  join po_distributions_all pda on pla.po_line_id = pda.po_line_id
		  join po_line_locations_all plla on pla.po_line_id = plla.po_line_id
		  join por_req_distributions_all prda on pda.req_distribution_id = prda.distribution_id
		  join por_requisition_lines_all prla on prla.requisition_line_id = prda.requisition_line_id
		  join por_requisition_headers_all prha on prha.requisition_header_id = prla.requisition_header_id
		  join pjf_projects_all_vl ppav on pda.pjc_project_id = ppav.project_id
		  join pjf_exp_types_tl exp_type on pda.pjc_expenditure_type_id = exp_type.expenditure_type_id and exp_type.language = userenv('lang')
		 where 1 = 1
		   and pla.item_id is not null
		   and exp_type.expenditure_type_name = 'MATERIALS'
		   -- and ppav.segment1 = '14080'
		   and 1 = 1
	order by to_char(rsh.creation_date, 'yyyy-mm-dd hh24:mi:ss') desc
