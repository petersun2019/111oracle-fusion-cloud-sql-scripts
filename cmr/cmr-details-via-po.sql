/*
File Name: cmr-details-via-po.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts
*/

-- ##############################################################
-- TABLE DUMPS
-- ##############################################################

select * from cmr_purchase_order_dtls where po_number in ('PO123456');
select * from cmr_rcv_transactions where po_line_location_id in (select po_line_location_id from cmr_purchase_order_dtls where po_number in ('PO123456'));
select * from cmr_transactions where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456'));
select * from cmr_transaction_taxes where transaction_id in (select transaction_id from cmr_transactions where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456')));
select * from cmr_rcv_events where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456'));
select * from cmr_rcv_event_costs where accounting_event_id in (select accounting_event_id from cmr_rcv_events where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456')));
select * from cmr_rcv_distributions where accounting_event_id in (select accounting_event_id from cmr_rcv_events where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456')));
select * from cmr_exp_po_dist_costs where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456'));
select * from cmr_ap_invoice_dtls where cmr_po_distribution_id in (select cmr_po_distribution_id from cmr_purchase_order_dtls where po_number in ('PO123456'));
