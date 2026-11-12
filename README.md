# Frank Chisom Emmanuel

**Tier 3 SOC Analyst & Technical Lead** | Detection Engineering · DFIR · SIEM Architecture · Threat Intelligence · Security Assessments

Nigeria-based security practitioner with over six years of experience, currently at [SHELT](https://www.shelt.com), a cybersecurity-as-a-service firm headquartered in Cyprus. I lead technical delivery for managed SOC operations and security assessments across enterprise and banking clients.

[Portfolio site](https://princefrank0.github.io/Frank-Chisom-Emmanuel/) · [LinkedIn](https://www.linkedin.com/in/frank-chisom-emmanuel/) · [Email](mailto:emmanuel.frankchisom@gmail.com)

**Live site:** [princefrank0.github.io/Frank-Chisom-Emmanuel](https://princefrank0.github.io/Frank-Chisom-Emmanuel/)

---

## In this repository

| Folder | Contents |
|---|---|
| [`detection-rules/`](detection-rules/) | 13 Sigma rules for Windows, Linux and database activity monitoring, mapped to MITRE ATT&CK and PCI DSS v4.0 |
| [`write-ups/`](write-ups/) | Sanitised investigation case studies: a persistent XMRig cryptominer and a system-level web-content injection |
| [`dashboards/`](dashboards/) | CISO executive dashboard layout as a self-contained HTML page with demo data |
| [`tools/`](tools/) | Windows network troubleshooting toolkit (batch) |

---

## What I do

| Area | Focus |
|---|---|
| **Detection engineering** | Correlation rule design and tuning, log source onboarding, threat intel feed integration, compliance-mapped detections |
| **DFIR** | Endpoint and identity investigations, root cause analysis, breach origin attribution, incident reporting |
| **SIEM architecture** | FortiSIEM deployment, DR, scaling, storage and ingestion troubleshooting; Microsoft Sentinel SOAR |
| **Threat intelligence & hunting** | Hypothesis-driven hunts, MITRE ATT&CK mapping, CTI analysis of ransomware and data-leak claims, client advisories |
| **Security assessments** | Enterprise risk and maturity assessments, infrastructure security reviews, cloud and AI agent assessment scoping |
| **SOC leadership** | Tier role and workflow design, SLA and RACI documentation, analyst hiring and interviewing |

---

## Experience

**Tier 3 SOC Analyst and Technical Lead** · SHELT · 2026 – present
Senior escalation point for managed SOC operations across banking and enterprise clients: advanced detection, forensic investigation, incident response, and technical lead on assessments and SIEM projects.

**Technical Support Specialist and Cybersecurity Project Engineer** · MAG Technologies Systems Limited · 2023 – 2026
Deployed and managed enterprise security platforms from proof of concept to post-implementation support:

- **Cymulate** — breach and attack simulation for continuous threat validation
- **Velotix** — AI-based data governance and access control
- **FlowSec** — DDoS protection and traffic mitigation
- **Validit AI** — AI-driven fraud prevention and verification
- **Wazuh** — SOC-as-a-service: SIEM and file integrity monitoring
- **Utimaco HSM** — HSM-as-a-service for cryptographic key management

Also led ransomware protection, API security, brand protection and OSINT initiatives; ran PCI DSS vulnerability scans and awareness training; maintained ISO 27001, NDPR and PCI DSS audit evidence; and introduced project tracking and escalation systems that cut incident resolution time by 30%.

---

## Selected work

> Client names are withheld for confidentiality. Details are generalised.

### SIEM engineering (FortiSIEM, banking sector)

- **Large-scale asset onboarding** — Onboarded ~300 Linux and Windows assets into FortiSIEM for a banking client using WMI/OMI discovery and Ansible-driven rsyslog pipelines.
- **Disaster recovery implementation** — Delivered a FortiSIEM DR implementation under a tight deadline.
- **Platform troubleshooting (FortiSIEM 7.5)** — Root cause analysis of storage latency and event dropping; resolved Windows Server 2022 discovery failures (OMI over WMI, Kerberos PTR record issues); macOS agentless onboarding.
- **Database activity monitoring detections** — Built correlation rules for Imperva SecureSphere DAM CEF logs, mapped to PCI DSS requirements.
- **Threat intelligence integration** — Configured external feeds (C2 Tracker, MalwareBazaar, URLhaus) and tuned Linux detection rules to cut noise.
- **CISO dashboard design** — Designed executive-level dashboards for security posture reporting.
- **Tier 3 analyst tooling** — Built a React-based FortiSIEM assistant with a rule library, copy/download functions, and a screenshot-driven troubleshooting mode.

### Incident response and forensics

- **Cryptominer investigation (CrowdStrike Falcon)** — Traced and resolved an XMRig infection persisting through a rogue Windows service and malicious DLL beaconing to a Monero mining pool.
- **Process injection investigation (Trend Micro)** — Investigated Chromium-based process injection alerts across multiple endpoints.
- **Third-party breach attribution** — Led a DFIR investigation for a university that concluded the credential exposure originated at a third-party platform, not the client's environment.
- **Live incident handling** — Responded to a live Linux incident involving unauthorised `usermod` shell changes.

### Threat hunting and intelligence

- **Hypothesis-driven threat hunt** — Conducted a threat hunting engagement for a natural resources holding company, delivering a report with MITRE ATT&CK mappings.
- **Ransomware claim analysis** — Produced CTI assessments of threat actor breach claims against financial and utility sector organisations, with client advisories.

### Assessments and GRC

- **Enterprise risk and maturity assessment (bank)** — Remote assessment scoped against PCI DSS v4.0, NIST SP 800-53, NIST CSF 2.0 and NIST IR 8374, covering SOC maturity, a ransomware tabletop simulation and technical work packages. Built a self-contained HTML assessment console with 87 evidence-first checks, CMMI 1–5 scoring, framework mapping and a tabletop module using Atomic Red Team.
- **IT infrastructure security review (bank)** — Reviewed Check Point and Cisco Firepower firewalls, Microsoft Defender and Intune, wireless, and CMDB.
- **AI agent security assessment (bank)** — Technical lead for scoping the assessment of a Microsoft Copilot-based chatbot agent: access control, data exposure, prompt injection, agent permissions, integrations, logging, and hosting architecture.
- **Cloud posture assessment** — Scoped a two-tenant Entra ID / Azure / Microsoft 365 posture assessment against CIS benchmarks alongside a cloud penetration test.
- **Vulnerability scanner evaluation** — Comparative analysis of OpenVAS and Nessus Essentials.

### Security architecture

- **Blockchain project security rebuild** — Led the security infrastructure rebuild for a blockchain project: server hardening, AWS KMS signing keys, Safe multisig, and Microsoft Intune management across a mixed Windows/macOS fleet.

### SOC operations and enablement

- **Microsoft Sentinel SOAR simulation runbook** — Authored a validated 15-day programme covering 10 scenarios.
- **Tabletop exercise playbooks** — Documented exercises using Atomic Red Team, Metasploit and Nmap.
- **Service documentation** — Produced customer-facing SLA documentation, RACI matrix reviews, and SOC tier role and workflow mappings.
- **Hiring** — Designed scenario-based interview sets and interviewed candidates for Tier 1 SOC analyst roles.
- **Windows Network Troubleshooting Toolkit** — Batch-based diagnostics toolkit for Windows 10/11 endpoints.

---

## Tools and technologies

**SIEM / SOAR:** FortiSIEM, Microsoft Sentinel, Wazuh  
**EDR / Endpoint:** CrowdStrike Falcon, Trend Micro, Microsoft Defender, Microsoft Intune  
**Network:** FortiGate (HA), Check Point, Cisco Firepower  
**Breach and attack simulation:** Cymulate  
**Data security:** Imperva SecureSphere DAM, Velotix, Utimaco HSM  
**Fraud prevention / DDoS:** Validit AI, SumSub, FlowSec  
**Cloud / Identity:** Microsoft Entra ID, Azure, Microsoft 365, AWS KMS  
**Offensive / Simulation:** Atomic Red Team, Metasploit, Nmap, Burp Suite, Kali Linux  
**Automation:** Ansible, rsyslog, Batch, React  
**Frameworks:** MITRE ATT&CK, PCI DSS v4.0, NIST CSF 2.0, NIST SP 800-53, NIST IR 8374, ISO/IEC 27001, CIS Benchmarks, CMMI  

---

## Certifications

- ISO/IEC 27001
- ISC2 — *add certification name*
- IBM — *add certification name*
- Google — *add certification name*
- NITDA — *add certification name*
- EC-Council Certified Security Analyst (ECSA) — issued October 2026
- EC-Council Certified Incident Handler (ECIH) — *in progress*
- EC-Council CEH v13 — *in progress*

---

## Contact

Open to collaboration on detection engineering, DFIR and SOC maturity work.

- LinkedIn: [linkedin.com/in/frank-chisom-emmanuel](https://www.linkedin.com/in/frank-chisom-emmanuel/)
- Email: emmanuel.frankchisom@gmail.com
