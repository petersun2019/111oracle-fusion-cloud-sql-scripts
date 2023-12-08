# Oracle Fusion Cloud SQL Scripts Library

## Intro

This is a collection of SQL scripts I've built up since starting to work with Oracle Fusion in 2019.

## Download

You can download the scripts via [this link](https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts/archive/refs/heads/main.zip).

## ⚠️Disclaimer

Please treat the scripts with caution!

I can't confirm for certain that all of the scripts work perfectly and without error.

However, they should work as a starting point, and might help people out which is why I'm putting them on Github.

However - if they break your systems or do other strange and mysterious things, I want to put an official line here such as the [disclaimer on oracle-base](https://oracle-base.com/misc/site-info#copyright):

> All information is offered in good faith and in the hope that it may be of use, but is not guaranteed to be correct, up to date or suitable for any particular purpose. I accept no liability in respect of these scripts or their use.

I've put these scripts online in case they are of use to others, but please use them with caution, and test them thoroughly.

If you find any errors with joins etc. please let me know as per the `Issues` heading below.

## Issues

If you have any problems with the scripts, [please log an issue](https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts/issues) or get in touch using [this contact form](https://jimpix.co.uk/contact/).

## Contents

```
|   
+---ap
|       ap-expenses.sql
|       ap-idr-options.sql
|       ap-invoices-holds.sql
|       ap-invoices-interface.sql
|       ap-invoices-terms.sql
|       ap-invoices-transaction-business-category.sql
|       ap-invoices.sql
|       ap-payments-interface.sql
|       ap-payments.sql
|       ap-suppliers-bank-accounts.sql
|       ap-suppliers.sql
|       ap-system-parameters.sql
|       
+---ar
|       ar-adjustments.sql
|       ar-approval-limits.sql
|       ar-customers.sql
|       ar-memo-lines.sql
|       ar-payment-terms.sql
|       ar-receipts.sql
|       ar-transactions-interface.sql
|       ar-transactions.sql
|       
+---ask
|       ask.sql
|       
+---ce
|       ce-bank-accounts.sql
|       ce-statements.sql
|       
+---cmr
|       cmr-details-via-po.sql
|       cmr-distributions.sql
|       
+---cst
|       cst.sql
|       
+---dba
|       dba-schema-browser.sql
|       
+---exm
|       exm-expenses.sql
|       
+---fa
|       fa-asset-categories.sql
|       
+---fun
|       fun.sql
|       
+---gl
|       gl-balances.sql
|       gl-budgets.sql
|       gl-code-combinations.sql
|       gl-cross-validation-rules.sql
|       gl-hierarchy.sql
|       gl-interface.sql
|       gl-journals-xla.sql
|       gl-journals.sql
|       gl-ledgers-legal-entities.sql
|       gl-periods.sql
|       gl-segment-values.sql
|       
+---iby
|       iby-bank-accounts.sql
|       
+---iex
|       iex-collectors.sql
|       iex.sql
|       
+---inv
|       inv-items.sql
|       inv-orgs.sql
|       inv-transactions.sql
|       
+---pa
|       pa-billing-events.sql
|       pa-budgets.sql
|       pa-burden-schedules.sql
|       pa-contracts.sql
|       pa-expenditure-types.sql
|       pa-expenditures-interface.sql
|       pa-expenditures.sql
|       pa-invoices.sql
|       pa-key-members.sql
|       pa-orgs.sql
|       pa-projects.sql
|       pa-settings.sql
|       pa-transaction-sources.sql
|       
+---po
|       po-approval-history.sql
|       po-categories.sql
|       po-procurement-agents.sql
|       po-purchase-orders-housekeeping.sql
|       po-purchase-orders.sql
|       po-receipts.sql
|       po-requisitions-purchase-orders-join.sql
|       po-requisitions.sql
|       po-transaction-business-categories.sql
|       po_agents.sql
|       
+---sa
|       sa-applications.sql
|       sa-approval-groups.sql
|       sa-attachments.sql
|       sa-audit.sql
|       sa-bpm-history-ap-payment-approvals.sql
|       sa-bpm-history.sql
|       sa-business-units.sql
|       sa-departments-cost-centre-managers.sql
|       sa-flexfields-descriptive.sql
|       sa-flexfields-key.sql
|       sa-flexfields-validation.sql
|       sa-hdl.sql
|       sa-hr-organizations.sql
|       sa-hr-records-bank-details.sql
|       sa-hr-records-skills-quals.sql
|       sa-hr-records.sql
|       sa-lookup-values.sql
|       sa-manager-hierarchy.sql
|       sa-payroll-sla-flow-name.sql
|       sa-profiles.sql
|       sa-purge-job-frequency.sql
|       sa-requests-history.sql
|       sa-requests-properties-single-param-values.sql
|       sa-requests-properties.sql
|       sa-role-mappings.sql
|       sa-roles-data-access.sql
|       sa-roles.sql
|       sa-ucm.sql
|       sa-users.sql
|       
+---xcc
|       xcc.sql
|       
+---xla
|       01_xla_transaction_entities.sql
|       02_xla_ae_headers.sql
|       03_xla_events.sql
|       04_xla_ae_lines.sql
|       05_xla_all.sql
|       06_xla_accounting_errors.sql
|       xla-entity-id-mappings.sql
|       xla-event-classes.sql
|       xla-event-types.sql
|       xla-mapping-sets.sql
|       xla-subledger-option.sql
|       
+---zx
|       zx-tax-reporting.sql
|       
\---_misc
        misc-count-volumes-group-by-rollup.sql
```
