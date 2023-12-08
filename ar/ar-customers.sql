/*
File Name: ar-customers.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- CUSTOMERS 1
-- CUSTOMERS 2
-- CUSTOMERS 3
-- CUSTOMERS 4
-- HZ_CUSTOMER_PROFILES_F
-- CUSTOMER BANK ACCOUNTS 1
-- CUSTOMER BANK ACCOUNTS 2
-- CUSTOMER BANK ACCOUNTS 3
-- CUSTOMER CONTACTS (EMAIL)
-- CUSTOMERS COUNT 1
-- CUSTOMERS COUNT 2
-- CONTACTS RUBBISH 1
-- FA: SCM: OM: SQL Query to Obtain Customer Contact Information. (Doc ID 2737284.1)
-- CONTACTS RUBBISH 2
-- CONTACTS RUBBISH 3
-- CONTACTS RUBBISH 4
-- CONTACTS RUBBISH 5

*/

-- ##############################################################
-- CUSTOMERS 1
-- ##############################################################

		select hca.*
		  from hz_cust_accounts hca
		  join hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CUSTOMERS 2
-- ##############################################################

		select ' -- PARTY ###########################' party____
			 , hp.party_id
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , to_char(hp.creation_date, 'yyyy-mm-dd hh24:mi:ss') party_created
			 , hp.created_by party_created_by
			 , hp.status party_status
			 , ' -- CUSTOMER ###########################' customer____
			 , hca.cust_account_id
			 , hca.account_number
			 , hca.account_name
			 , hca.status account_status
			 , to_char(hca.creation_date, 'yyyy-mm-dd hh24:mi:ss') cust_created
			 , hca.created_by cust_created_by
			 , ' -- PARTY SITE ###########################' party_site____
			 , hps.party_site_id
			 , hps.party_site_number
			 , hps.status party_site_status
			 , to_char(hps.creation_date, 'yyyy-mm-dd hh24:mi:ss') site_created
			 , hps.created_by site_created_by
		  from hz_parties hp
		  join hz_party_sites hps on hp.party_id = hps.party_id
		  join hz_locations hl on hps.location_id = hl.location_id
		  join hz_cust_accounts hca on hp.party_id = hca.party_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CUSTOMERS 3
-- ##############################################################

		select ' -- PARTY ###########################'
			 , hp.party_id
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , hp.creation_date party_created
			 , hp.created_by party_created_by
			 , hp.status party_status
			 , hp.last_update_date party_updated
			 , hp.last_updated_by party_updated_by
			 , ' -- CUSTOMER ###########################'
			 , hca.cust_account_id
			 , hca.account_number
			 , hca.account_name
			 , hca.status account_status
			 , hca.creation_date cust_created
			 , hca.created_by cust_created_by
			 , hca.last_update_date cust_updated
			 , hca.last_updated_by cust_updated_by
			 , ' -- PARTY SITE ###########################'
			 , hps.party_site_id
			 , hps.party_site_number
			 , hps.status party_site_status
			 , hps.creation_date site_created
			 , hps.created_by site_created_by
			 , hps.last_update_date site_updated
			 , hps.last_updated_by site_updated_by
			 , ' -- LOCATION ###########################'
			 , hl.location_id
			 , hl.creation_date
			 , hl.address1
			 , hl.address2
			 , hl.address3
			 , hl.address4
			 , hl.city
			 , hl.postal_code
			 , hl.state
			 , hl.province
			 , hl.county
			 , hl.country
			 , hl.creation_date loc_created
			 , hl.created_by loc_created_by
			 , hl.last_update_date loc_updated
			 , hl.last_updated_by loc_updated_by
			 , ' -- CUST_ACCOUNT_SITES ###########################'
			 , hcasa.cust_acct_site_id
			 , hcasa.status cust_account_site_status
			 , hcasa.bill_to_flag
			 , hcasa.creation_date hcasa_created
			 , hcasa.created_by hcasa_created_by
			 , hcasa.last_update_date hcasa_updated
			 , hcasa.last_updated_by hcasa_updated_by
			 , ' -- CUST_ACCOUNT_SITE_USES ###########################'
			 , hcsua.site_use_id
			 , hcsua.status site_use_status
			 , hcsua.site_use_code
			 , hcsua.location
			 , hcsua.primary_flag
			 , hcsua.orig_system_reference
			 , hcsua.tax_reference
			 , hcsua.creation_date siteuse_created
			 , hcsua.created_by siteuse_created_by
			 , hcsua.last_update_date siteuse_updated
			 , hcsua.last_updated_by siteuse_updated_by
			 , '#################'
			 , gcc_rev.segment1 || '-' || gcc_rev.segment2 || '-' || gcc_rev.segment3 || '-' || gcc_rev.segment4 || '-' || gcc_rev.segment5 || '-' || gcc_rev.segment6 || '-' || gcc_rev.segment7 || '-' || gcc_rev.segment8 code_comb_revenue
			 , gcc_rev.code_combination_id gcc_rev_ccid
			 , gcc_rec.segment1 || '-' || gcc_rec.segment2 || '-' || gcc_rec.segment3 || '-' || gcc_rec.segment4 || '-' || gcc_rec.segment5 || '-' || gcc_rec.segment6 || '-' || gcc_rec.segment7 || '-' || gcc_rec.segment8 code_comb_receivable
			 , gcc_rec.code_combination_id gcc_rec_ccid
		  from hz_parties hp
	 left join hz_party_sites hps on hp.party_id = hps.party_id
	 left join hz_locations hl on hps.location_id = hl.location_id
	 left join hz_cust_accounts hca on hp.party_id = hca.party_id
	 left join hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id and hca.cust_account_id = hcasa.cust_account_id
	 left join hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
	 left join ar_ref_accounts_all araa on araa.source_ref_account_id = hcsua.site_use_id and araa.source_ref_table = 'HZ_CUST_SITE_USES_ALL'
	 left join gl_code_combinations gcc_rev on gcc_rev.code_combination_id = araa.rev_ccid
	 left join gl_code_combinations gcc_rec on gcc_rec.code_combination_id = araa.rec_ccid
		 where 1 = 1
		   and 1 = 1
		   and hps.party_site_number in ('15272','1052784','611933','1578350')

party_site_number: 1052784 -> location: 1578350
party_site_number: 15272 -> location: 611933

-- ##############################################################
-- CUSTOMERS 4
-- ##############################################################

		select hp.party_name customer_name
			 , hca.account_number
			 , hcsua.site_use_code
			 , ac.name collector_name
			 , hps.party_site_number
			 , hcpc.name profile_class
			 , to_char(hcpf.effective_start_date, 'yyyy-mm-dd') class_start_date
			 , to_char(hcpf.effective_end_date, 'yyyy-mm-dd') class_end_date
			 , to_char(hcpf.creation_date, 'yyyy-mm-dd hh24:mi:ss') created
			 , hcpf.created_by
			 , to_char(hcpf.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , hcpf.last_updated_by
		  from hz_cust_accounts hca
		  join hz_parties hp on hp.party_id = hca.party_id
		  join hz_cust_acct_sites_all hcasa on hca.cust_account_id = hcasa.cust_account_id
		  join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id
		  join hz_customer_profiles_f hcpf on hcpf.cust_account_id = hca.cust_account_id and hcpf.cust_account_id = hcasa.cust_account_id
		  join hz_cust_site_uses_all hcsua on hcsua.site_use_id = hcpf.site_use_id and hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
		  join ar_collectors ac on ac.collector_id = hcpf.collector_id
		  join hz_cust_profile_classes hcpc on hcpc.profile_class_id = hcpf.profile_class_id
		 where 1 = 1
		   and 1 = 1
	  order by hcpf.last_update_date desc

-- ##############################################################
-- HZ_CUSTOMER_PROFILES_F
-- ##############################################################

/*
Customer Profiles can be set at Account or Site level.
If set at Customer only level, then CUST_ACCOUNT_ID is populated and SITE_USE_ID IS NULL
If set at Site level, then CUST_ACCOUNT_ID is populated and SITE_USE_ID is also populated

https://docs.oracle.com/en/cloud/saas/financials/23b/oedmf/hzcustomerprofilesf-14307.html#hzcustomerprofilesf-14307
*/

select * from hz_customer_profiles_f where cust_account_id = 123
select * from hz_customer_profiles_f where site_use_id = 321

-- ##############################################################
-- CUSTOMER BANK ACCOUNTS 1
-- ##############################################################

		select hca.account_number cust_acct_num
			 , hp.party_name cust_acct_name
			 , to_char(iby_payee_uses.start_date, 'yyyy-mm-dd') instr_start
			 , to_char(iby_payee_uses.end_date, 'yyyy-mm-dd') instr_end
			 , to_char(iby_payee_uses.creation_date, 'yyyy-mm-dd hh24:mi:ss') instr_created
			 , ieba.bank_account_num
			 , iby_eba.bank_account_name
			 , iby_eba.description
			 , iby_eba.bank_name
			 , iby_eba.bank_number
			 , iby_eba.branch_number
			 , iby_eba.iban_number
			 , nvl(ieba.currency_code, 'No Currency Defined') currency_code
			 , to_char(iby_eba.start_date, 'yyyy-mm-dd') acct_start
			 , to_char(iby_eba.end_date, 'yyyy-mm-dd') acct_end
		  from hz_cust_accounts hca
		  join hz_parties hp on hp.party_id = hca.party_id
		  join iby_external_payers_all iby_payee on hca.cust_account_id = iby_payee.cust_account_id
		  join iby_pmt_instr_uses_all iby_payee_uses on iby_payee_uses.ext_pmt_party_id = iby_payee.ext_payer_id
		  join iby_ext_bank_accounts_v iby_eba on iby_eba.ext_bank_account_id = iby_payee_uses.instrument_id
		  join iby_ext_bank_accounts ieba on ieba.ext_bank_account_id = iby_eba.ext_bank_account_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CUSTOMER BANK ACCOUNTS 2
-- ##############################################################

		selectipiu.instrument_payment_use_id
			 , ipiu.payment_flow
			 , ipiu.ext_pmt_party_id
			 , ipiu.instrument_type
			 , ipiu.instrument_id
			 , cbbv.bank_name
			 , cbbv.bank_branch_name
			 , ieb.currency_code
			 , ieb.bank_account_name
			 , ieb.bank_account_num
			 , nvl(ieb.currency_code, 'No Currency Defined') currency_code
			 , iep.org_id
			 , hp.party_name customer_name
			 , hca.account_number
			 , hps.party_site_number
		  from iby_pmt_instr_uses_all ipiu 
		  join iby_ext_bank_accounts ieb on ieb.ext_bank_account_id = ipiu.instrument_id
		  join iby_external_payers_all iep on ipiu.ext_pmt_party_id = iep.ext_payer_id
		  join ce_bank_branches_v cbbv on cbbv.branch_party_id = ieb.branch_id
		  join hz_cust_accounts hca on iep.cust_account_id = hca.cust_account_id
		  join hz_parties hp on hp.party_id = hca.party_id 
		  join hz_cust_acct_sites_all hsa on hca.cust_account_id = hsa.cust_account_id
		  join hz_party_sites hps on hsa.party_site_id = hps.party_site_id
		  join hz_cust_site_uses_all hsu on hsa.cust_acct_site_id = hsu.cust_acct_site_id and iep.acct_site_use_id = hsu.site_use_id -- and iep.org_id = hsu.org_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CUSTOMER BANK ACCOUNTS 3
-- ##############################################################

		select ieba.ext_bank_account_id
			 , '#' || ieba.bank_account_num bank_account_num
			 , '#' || ieba.masked_bank_account_num
			 , ieba.bank_account_name
			 -- , ieba.iban
			 , ieba.bank_account_type
			 , ieba.account_classification
			 , to_char(ieba.creation_date, 'yyyy-mm-dd hh24:mi:ss') ieba_created
			 , ieba.created_by ieba_created_by
			 , nvl(ieba.currency_code, 'No Currency Defined') currency_code
			 , cbbv.bank_name
			 , '#' || cbbv.bank_branch_name bank_branch_name
			 , '#### iby_pmt_instr_uses_all'
			 , ipiua.instrument_payment_use_id
			 , ipiua.payment_flow -- Specifies funds capture or disbursement flow. Values taken from lookup: IBY_PAYMENT_FLOW. DISBURSEMENT = Paying money out (Suppliers or Employees), FUNDS_CAPTURE is money coming in (AR Customers)
			 , ipiua.ext_pmt_party_id -- Foreign key to IBY_EXTERNAL_PAYERS_ALL.EXT_PAYER_ID
			 , ipiua.instrument_id
			 , ipiua.instrument_type -- Instrument type. Values from the IBY_INSTRUMENT_TYPES lookup include BANKACCOUNT, CREDITCARD, and DEBITCARD
			 , ipiua.order_of_preference
			 , ipiua.primary_flag
			 , to_char(ipiua.creation_date, 'yyyy-mm-dd hh24:mi:ss') instr_created
			 , ipiua.created_by instr_created_by
			 , to_char(ipiua.last_update_date, 'yyyy-mm-dd hh24:mi:ss') instr_updated
			 , ipiua.last_updated_by instr_updated_by
			 , to_char(ipiua.start_date, 'yyyy-mm-dd') instr_start
			 , to_char(ipiua.end_date, 'yyyy-mm-dd') instr_end
			 , '#### iby_external_payers_all'
			 , iepa.ext_payer_id iepa_ext_payer_id
			 , iepa.party_id iepa_party_id
			 , iepa.cust_account_id iepa_cust_account_id
			 , iepa.acct_site_use_id iepa_acct_site_use_id
			 , iepa.payment_function
			 , to_char(iepa.creation_date, 'yyyy-mm-dd hh24:mi:ss') iepa_created
			 , iepa.created_by iepa_created_by
			 , to_char(iepa.last_update_date, 'yyyy-mm-dd hh24:mi:ss') iepa_updated
			 , iepa.last_updated_by iepa_updated_by
			 , iepa.purpose_code
			 , '#### hz_parties'
			 , hp.party_name
			 , hp.party_number
			 , '#### hz_cust_accounts'
			 , hca.account_number
			 , '#### hz_party_sites'
			 , hps.party_site_number
		  from iby_ext_bank_accounts ieba
		  join ce_bank_branches_v cbbv on cbbv.branch_party_id = ieba.branch_id
	 left join iby_pmt_instr_uses_all ipiua on ipiua.instrument_id = ieba.ext_bank_account_id
	 left join iby_external_payers_all iepa on iepa.ext_payer_id = ipiua.ext_pmt_party_id
	 left join hz_parties hp on hp.party_id = iepa.party_id
	 left join hz_cust_accounts hca on hca.cust_account_id = iepa.cust_account_id
	 left join hz_cust_acct_sites_all hcasa on hcasa.cust_account_id = hca.cust_account_id
	 left join hz_party_sites hps on hps.party_site_id = hcasa.party_site_id
	 left join hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id and iepa.acct_site_use_id = hcsua.site_use_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CUSTOMER CONTACTS (EMAIL)
-- ##############################################################

/*
https://rpforacle.blogspot.com/2019/12/oracle-fusion-customer-contacts-query.html
*/

		select hp.party_name party_name_
			 , hca.account_number account_number_
			 , hps.party_site_number party_site_number_
			 , hps.party_site_id party_site_id_
			 , role_type role_type_
			 , hcp.email_address email_address_
			 , hcp.contact_point_type contact_point_type_
			 , hr.relationship_code relationship_code_
			 , '#' hcp____
			 , hcp.primary_flag hcp_primary
			 , nvl(hcp.primary_flag, 'Y') hcp_primary_nvl
			 , hcp.overall_primary_flag
			 , '#' hcar____
			 , hcar.primary_flag hcar_primary
			 , nvl(hcar.primary_flag, 'Y') hcar_primary_nvl
			 -- , hcp.*
		  from hz_contact_points hcp
		  join hz_relationships hr on hcp.relationship_id = hr.relationship_id and hcp.contact_point_type = 'EMAIL' and hr.relationship_code = 'CONTACT_OF'
		  join hz_parties hp on hr.object_id = hp.party_id
		  join hz_cust_accounts hca on hp.party_id = hca.party_id
		  join hz_cust_account_roles hcar on hcar.relationship_id = hcp.relationship_id and hcar.cust_account_id = hca.cust_account_id
		  join hz_cust_acct_sites_all hcsa on hca.cust_account_id = hcsa.cust_account_id and hcar.cust_acct_site_id = hcsa.cust_acct_site_id
		  join hz_party_sites hps on hcsa.party_site_id = hps.party_site_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- CUSTOMERS COUNT 1
-- ##############################################################

		select hca.created_by
			 , min(to_char(hca.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_cust_created
			 , max(to_char(hca.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_cust_created
			 , count(distinct hca.cust_account_id) customer_count
			 , count(distinct hps.party_site_id) party_sites_count
			 , count(distinct hcasa.cust_acct_site_id) customer_sites_count
			 , count(distinct hcsua.site_use_id) site_use_count
			 , min(hp.party_number)
			 , max(hp.party_number)
			 , min(hps.party_site_id)
			 , max(hps.party_site_id)
		  from hz_parties hp
	 left join hz_party_sites hps on hp.party_id = hps.party_id
	 left join hz_locations hl on hps.location_id = hl.location_id
	 left join hz_cust_accounts hca on hp.party_id = hca.party_id
	 left join hz_cust_acct_sites_all hcasa on hcasa.party_site_id = hps.party_site_id and hca.cust_account_id = hcasa.cust_account_id
	 left join hz_cust_site_uses_all hcsua on hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
		 where 1 = 1
		   and 1 = 1
	  group by hca.created_by

-- ##############################################################
-- CUSTOMERS COUNT 2
-- ##############################################################

		select created_by
			 , min(to_char(hca.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_cust_created
			 , max(to_char(hca.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_cust_created
			 , count(*) customer_count
		  from hz_cust_accounts hca
	  group by hca.created_by
	  order by customer_count desc

-- ##############################################################
-- CONTACTS RUBBISH 1
-- ##############################################################

-- FA: SCM: OM: SQL Query to Obtain Customer Contact Information. (Doc ID 2737284.1)

		SELECT RelationshipPEO.RELATIONSHIP_REC_ID
			, RelationshipPEO.RELATIONSHIP_ID
			, RelationshipPEO.DIRECTIONAL_FLAG
			, RelationshipPEO.status RelationshipPEO_status
			, OrganizationPartyPEO.PARTY_NAME
			, OrganizationPartyPEO.PARTY_ID
			, PersonPartyPEO.PARTY_NAME AS PARTY_NAME1
			, PersonPartyPEO.PARTY_ID AS PARTY_ID1
			, PersonPartyPEO.PERSON_FIRST_NAME
			, PersonPartyPEO.PERSON_LAST_NAME
			, PersonPartyPEO.status PersonPartyPEO_status
			-- HzLookupPEO.DESCRIPTION
			, HzLookupPEO.LOOKUP_TYPE
			, HzLookupPEO.LOOKUP_CODE
			, OrganizationContactPEO.JOB_TITLE
			, OrganizationContactPEO.ORG_CONTACT_ID
			, OrganizationContactPEO.DEPARTMENT
			, OrganizationPartyPEO.status OrganizationPartyPEO_status
			, EmailPEO.EMAIL_ADDRESS
			, EmailPEO.CONTACT_POINT_ID
			, EmailPEO.CONTACT_POINT_TYPE
			, EmailPEO.status EmailPEO_status
			, PhonePEO.RAW_PHONE_NUMBER
			, PhonePEO.CONTACT_POINT_ID AS CONTACT_POINT_ID1
			, PhonePEO.CONTACT_POINT_TYPE AS CONTACT_POINT_TYPE1
			, PhonePEO.PHONE_AREA_CODE
			, PhonePEO.PHONE_COUNTRY_CODE
			, PhonePEO.PHONE_NUMBER
			, PhonePEO.status PhonePEO_PhonePEO
			, WebPEO.URL
			, WebPEO.CONTACT_POINT_ID AS CONTACT_POINT_ID2
			, WebPEO.CONTACT_POINT_TYPE AS CONTACT_POINT_TYPE2
			, WebPEO.status WebPEO_status
			, OrganizationPartyPEO.SIC_CODE
			, OrganizationPartyPEO.SIC_CODE_TYPE
			, OrganizationPartyPEO.PARTY_UNIQUE_NAME
			, PersonPartyPEO.SALUTATION
			, PersonPartyPEO.PERSON_PRE_NAME_ADJUNCT
			, PersonPartySitePEO.PARTY_SITE_ID AS PERSON_PARTY_SITE_ID
			, PersonPartySitePEO.status PersonPartySitePEO_status
			, LocationPEO.LOCATION_ID AS PERSON_LOCATION_ID
			, LocationPEO.ADDRESS1
			, LocationPEO.ADDRESS2
			, LocationPEO.ADDRESS3
			, LocationPEO.ADDRESS4
			, LocationPEO.CITY
			, LocationPEO.STATE
			, LocationPEO.POSTAL_CODE
			, LocationPEO.COUNTRY
			, PartySitePEO.PARTY_SITE_ID
			, PartySitePEO.PARTY_SITE_NAME
			, PartySitePEO.status PartySitePEO_status
			, OrganizationContactPEO.REFERENCE_USE_FLAG
			, DECODE(PersonPartyPEO.PARTY_ID, NVL( OrganizationPartyPEO.PREFERRED_CONTACT_PERSON_ID, -2), 'Y', 'N') AS PRIMARY_CONTACT_FLAG
			, OrganizationContactPEO.SALES_AFFINITY_CODE
			, OrganizationContactPEO.SALES_AFFINITY_COMMENTS
			, OrganizationContactPEO.SALES_BUYING_ROLE_CODE
			, OrganizationContactPEO.SALES_INFLUENCE_LEVEL_CODE
			, OrganizationContactPEO.DEPARTMENT_CODE
			, OrganizationContactPEO.JOB_TITLE_CODE
			, RelationshipPEO.START_DATE
			, RelationshipPEO.END_DATE
			, PersonPartyPEO.EMAIL_ADDRESS AS EMAIL_ADDRESS1
			, PersonPartyPEO.URL AS URL1
			, PersonPartyPEO.PRIMARY_EMAIL_CONTACT_PT_ID
			, PersonPartyPEO.PRIMARY_PHONE_CONTACT_PT_ID
			, PersonPartyPEO.PREFERRED_CONTACT_METHOD
		 FROM fusion.HZ_RELATIONSHIPS RelationshipPEO
		 join fusion.HZ_PARTIES OrganizationPartyPEO on RelationshipPEO.OBJECT_ID = OrganizationPartyPEO.PARTY_ID
		 join fusion.HZ_PARTIES PersonPartyPEO on RelationshipPEO.SUBJECT_ID = PersonPartyPEO.PARTY_ID
		 join fusion.HZ_RELATIONSHIP_TYPES RelationshipTypePEO on RelationshipPEO.RELATIONSHIP_TYPE = RelationshipTypePEO.RELATIONSHIP_TYPE and RelationshipPEO.RELATIONSHIP_CODE = RelationshipTypePEO.FORWARD_REL_CODE and RelationshipPEO.SUBJECT_TYPE = RelationshipTypePEO.SUBJECT_TYPE and RelationshipPEO.OBJECT_TYPE = RelationshipTypePEO.OBJECT_TYPE
		 join fusion.HZ_LOOKUPS HzLookupPEO on RelationshipTypePEO.ROLE = HzLookupPEO.LOOKUP_CODE
		 join fusion.HZ_ORG_CONTACTS OrganizationContactPEO on RelationshipPEO.RELATIONSHIP_ID = OrganizationContactPEO.PARTY_RELATIONSHIP_ID
	left join fusion.HZ_CONTACT_POINTS EmailPEO on RelationshipPEO.RELATIONSHIP_ID = EmailPEO.RELATIONSHIP_ID and RelationshipPEO.SUBJECT_ID = EmailPEO.OWNER_TABLE_ID AND EmailPEO.OWNER_TABLE_NAME = 'HZ_PARTIES' AND EmailPEO.CONTACT_POINT_TYPE = 'EMAIL' AND EmailPEO.STATUS = 'A' AND SYSDATE BETWEEN EmailPEO.START_DATE AND EmailPEO.END_DATE
	left join fusion.HZ_CONTACT_POINTS PhonePEO on RelationshipPEO.RELATIONSHIP_ID = PhonePEO.RELATIONSHIP_ID and RelationshipPEO.SUBJECT_ID = PhonePEO.OWNER_TABLE_ID and PhonePEO.OWNER_TABLE_NAME = 'HZ_PARTIES' and PhonePEO.CONTACT_POINT_TYPE = 'PHONE' AND PhonePEO.STATUS = 'A' AND SYSDATE BETWEEN PhonePEO.START_DATE AND PhonePEO.END_DATE
	left join fusion.HZ_CONTACT_POINTS WebPEO on RelationshipPEO.RELATIONSHIP_ID = WebPEO.RELATIONSHIP_ID AND RelationshipPEO.SUBJECT_ID = WebPEO.OWNER_TABLE_ID AND WebPEO.OWNER_TABLE_NAME = 'HZ_PARTIES' AND WebPEO.CONTACT_POINT_TYPE = 'WEB' AND WebPEO.STATUS = 'A' AND SYSDATE BETWEEN WebPEO.START_DATE AND WebPEO.END_DATE
	left join fusion.HZ_PARTY_SITES PersonPartySitePEO on RelationshipPEO.SUBJECT_ID = PersonPartySitePEO.PARTY_ID and RelationshipPEO.RELATIONSHIP_ID = PersonPartySitePEO.RELATIONSHIP_ID
	left join fusion.HZ_LOCATIONS LocationPEO on PersonPartySitePEO.LOCATION_ID = LocationPEO.LOCATION_ID
	left join fusion.HZ_PARTY_SITES PartySitePEO on OrganizationContactPEO.PARTY_SITE_ID = PartySitePEO.PARTY_SITE_ID
	left join fusion.hz_cust_accounts hca on PersonPartyPEO.party_id = hca.party_id
		WHERE 1 = 1
		  -- and OrganizationPartyPEO.Party_NAME LIKE 'PMC%'
		  -- and RelationshipPEO.SUBJECT_TYPE = 'PERSON'
		  -- and RelationshipPEO.STATUS = 'A'
		  -- and SYSDATE BETWEEN RelationshipPEO.START_DATE AND RelationshipPEO.END_DATE
		  AND HzLookupPEO.LOOKUP_TYPE = 'HZ_RELATIONSHIP_ROLE'
		  -- and SYSDATE BETWEEN PersonPartySitePEO.START_DATE_ACTIVE AND PersonPartySitePEO.END_DATE_ACTIVE
		  -- and PersonPartySitePEO.IDENTIFYING_ADDRESS_FLAG = 'Y'
		  -- and PersonPartySitePEO.STATUS = 'A'
		  and 1 = 1

-- ##############################################################
-- CONTACTS RUBBISH 2
-- ##############################################################

select * from HZ_CONTACT_POINTS where 1 = 1 and OWNER_TABLE_NAME = 'HZ_PARTIES' and CONTACT_POINT_TYPE = 'EMAIL'

-- ##############################################################
-- CONTACTS RUBBISH 3
-- ##############################################################

/*
account level
*/

		select hcp.*
		  from hz_contact_points hcp
		  join hz_cust_account_roles hcar on hcp.relationship_id = hcar.relationship_id
		 where 1 = 1
		   and hcar.cust_acct_site_id is null
		   and hcp.contact_point_type = 'EMAIL'
		   and 1 = 1

-- ##############################################################
-- CONTACTS RUBBISH 4
-- ##############################################################

/*
site level
*/

		select hcp.*
		  from hz_contact_points hcp
		  join hz_cust_account_roles hcar on hcp.relationship_id = hcar.relationship_id
		 where 1 = 1
		   and hcar.cust_acct_site_id is not null
		   and hcp.contact_point_type = 'EMAIL'
		   and 1 = 1

-- ##############################################################
-- CONTACTS RUBBISH 5
-- ##############################################################

	select  PartySite.PARTY_SITE_NUMBER
		  , PartySite.PARTY_SITE_NAME
		  , hoc.CONTACT_NUMBER contact_id
		  , hpc.PARTY_NAME Contact_Name
		  , Location.ADDRESS1
		  , Location.ADDRESS2
		  , Location.ADDRESS3
		  , Location.CITY
		  , Location.COUNTY
		  , Location.POSTAL_CODE
		  , Location.COUNTRY bill_COUNTRY_ISO
		  , FTV.TERRITORY_SHORT_NAME Bill_COUNTRY
		  , NULL Receipt_method
		  , HCP.EMAIL_ADDRESS
		  , IEP.DEBIT_ADVICE_DELIVERY_METHOD
		FROM HZ_CUST_ACCOUNTS CustomerAccount
		   , HZ_CUST_ACCT_SITES_ALL CustomerAccountSite
		   , HZ_PARTY_SITES PartySite
		   , HZ_LOCATIONS Location
		   , hz_parties hpc
		   , hz_cust_account_roles hcar
		   , HZ_ORG_CONTACTS hoc
		   , HZ_CONTACT_POINTS HCP
		   , fnd_territories_vl FTV
		   , IBY_EXTERNAL_PAYERS_ALL IEP
		   , HZ_CUST_SITE_USES_ALL  HCS
		WHERE CustomerAccount.CUST_ACCOUNT_ID = CustomerAccountSite.CUST_ACCOUNT_ID(+)
		AND CustomerAccountSite.PARTY_SITE_ID = PartySite.PARTY_SITE_ID(+)
		AND PartySite.LOCATION_ID = Location.LOCATION_ID(+)
		AND Location.COUNTRY = FTV.TERRITORY_CODE(+)
		AND CustomerAccountSite.CUST_ACCOUNT_ID = hcar.CUST_ACCOUNT_ID(+)
		AND CustomerAccount.CUST_ACCOUNT_ID = CustomerAccountSite.CUST_ACCOUNT_ID(+)
		and CustomerAccountSite.CUST_ACCT_SITE_ID = hcar.CUST_ACCT_SITE_ID(+)
		and hoc.PARTY_RELATIONSHIP_ID(+) = hcar.relationship_id
		AND hcar.CONTACT_PERSON_ID = hpc.party_id(+)
		AND HCP.RELATIONSHIP_ID(+) = hcar.relationship_id
		AND HCP.CONTACT_POINT_TYPE(+) = 'EMAIL'
		AND HCP.OVERALL_PRIMARY_FLAG(+) = 'Y'
		AND hcar.STATUS(+) = 'A'
		AND CustomerAccount.party_id = IEP.PARTY_ID 
		AND CustomerAccount.CUST_ACCOUNT_ID(+) = IEP.CUST_ACCOUNT_ID
		AND HCS.SITE_USE_ID = IEP.ACCT_SITE_USE_ID 
		AND HCS.SITE_USE_CODE = 'BILL_TO'
		and CustomerAccount.account_number = '123456'
