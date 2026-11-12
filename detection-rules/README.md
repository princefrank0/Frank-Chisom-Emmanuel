# Detection rules

Sigma versions of detections I designed or tuned in production SIEM work. The originals run in FortiSIEM; they are rewritten here in a vendor-neutral format with all client accounts, hosts and addresses replaced by placeholders (RFC 5737 addresses, `svc_*` account names).

Each rule came from a real investigation or tuning exercise. The description field records the reasoning, including what was deliberately *not* suppressed.

## Windows

| Rule | ATT&CK | Level | Origin |
|---|---|---|---|
| [Svchost loads unsigned DLL from System32](windows/win_image_load_svchost_unsigned_system32_dll.yml) | T1543.003, T1036.005 | High | [Cryptominer investigation](../write-ups/xmrig-cryptominer-investigation.md) |
| [New svchost service group registered](windows/win_registry_svchost_group_added.yml) | T1543.003 | Medium | Cryptominer investigation |
| [Svchost executed from outside system directories](windows/win_proc_creation_svchost_outside_system_path.yml) | T1036.005 | High | Cryptominer investigation |
| [XMRig loader service installation (IOC)](windows/win_system_service_install_xmrig_loader_ioc.yml) | T1543.003, T1496 | Critical | Cryptominer investigation |
| [DNS query to cryptomining pool domain](windows/net_dns_cryptomining_pool_query.yml) | T1496 | High | Cryptominer investigation |
| [System proxy or PAC configuration modified](windows/win_registry_proxy_autoconfig_modified.yml) | T1090, T1557 | Medium | [Chromium injection investigation](../write-ups/chromium-web-content-injection.md) |
| [Root certificate installed by non-system process](windows/win_registry_root_certificate_installed.yml) | T1553.004 | High | Chromium injection investigation |

## Linux

| Rule | ATT&CK | Level | Origin |
|---|---|---|---|
| [Account login shell changed](linux/lnx_auth_usermod_shell_change.yml) | T1098, T1531 | Medium | Live incident: `usermod` shell change on a production server |
| [Timestomping with touch](linux/lnx_proc_creation_touch_timestomp.yml) | T1070.006 | Medium | Rule tuning: lineage-based exclusions instead of a root exemption |
| [Kernel module loaded manually](linux/lnx_proc_creation_kernel_module_load.yml) | T1547.006 | High | Rule tuning: kept high-fidelity, no user or threshold suppression |

## Database (Imperva SecureSphere DAM, MSSQL)

Built from a baseline of roughly 220,000 audit events and 161 distinct query patterns, attributing each pattern to an account, source and application before writing any exclusion.

| Rule | ATT&CK | PCI DSS v4.0 | Level |
|---|---|---|---|
| [Extended stored procedure run by unapproved account](database/imperva_dam_extended_procedure_unapproved_account.yml) | T1505.001, T1082 | 10.2.1.2, 10.4.1.1 | High |
| [Data modification from unapproved source](database/imperva_dam_data_modification_unapproved_source.yml) | T1565.001 | 10.2.1.1, 10.2.1.2, 10.4.1.1, 7.2.6 | High |
| [Credential column read by unapproved account](database/imperva_dam_credential_column_read.yml) | T1213, T1555 | 10.2.1, 10.4.1.1 | High |

The DAM rules use a custom log source (`product: imperva`, `service: securesphere_dam`). The CEF-to-field mapping is in each rule's description.

## Tuning principles

1. **Tune on lineage, not on user.** Exempting root or SYSTEM removes the cases that matter.
2. **Baseline before excluding.** Every exclusion is tied to a named account, source and application seen in real data.
3. **Thresholds only for volume behaviours.** Archive creation can take a threshold. Kernel module loads cannot.
4. **Keep the raw event.** Parsed fields lose detail, such as bind variable values in database audit logs.
