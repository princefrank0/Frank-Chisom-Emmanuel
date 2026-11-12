# One domain, every Chromium engine: triaging a system-level web-content injection

**Role:** Lead investigator (Tier 3) · **Tooling:** Trend Micro Apex One, Trend Vision One Workbench, PowerShell · **Environment:** Windows enterprise endpoints (client details withheld)

## Summary

A recurring endpoint alert flagged connections to `survey-smiles[.]com`, categorised as a malware accomplice site, across several endpoints. The Workbench case correlated 39 alerts. The initial reading of the alert contained three errors that would have closed the case wrongly. After correcting them, the pattern of affected processes showed that the cause could not be a browser extension or a single application. It had to be something on the host that sits in the path of all web traffic.

## Step 1: Correct the alert reading

| Initial assumption | What the evidence showed |
|---|---|
| The connection was blocked | The action field was `Pass`. The connection was allowed. The policy gap was a finding in itself. |
| A second IP in the alert was attacker infrastructure | It belonged to the security vendor's own cloud service. |
| The remediation text named a specific malicious IP | It was generic template text from the SIEM and unrelated to this alert. |

A separate row in the same case showed a command-and-control callback from the endpoint agent's own real-time scan service to a CDN address. That CDN fronts the vendor's update and reputation services. I split it into its own ticket as a likely false positive, to be confirmed by binary signature check and reverse DNS before adding an exception. Keeping it in the main case would have inflated the severity and confused the timeline.

## Step 2: Read the process list as a pattern

Every flagged process was a Chromium-based engine, and nothing else appeared:

- `msedgewebview2.exe` (three different runtime versions)
- `msedge.exe`
- `chrome.exe`
- `AcroCEF.exe` (the PDF reader's embedded browser)
- `Slack.exe` (Electron)

These applications share no profile, no extension store and no user-data directory. The only things they have in common are the Chromium codebase and the fact that they render web content using the Windows network settings.

That ruled out the usual explanations:

| Hypothesis | Why it fails |
|---|---|
| Malicious browser extension | Extensions are per browser. Slack and the PDF reader have none. |
| Notification permission abuse | Per site and per profile. |
| Malvertising inside one application | Would affect one application. |
| Adware bundle with its own WebView2 | Would appear as one extra process, not inside five existing ones. |

What remains is a mechanism at host or network level that inserts the resource before it reaches each renderer: a hostile proxy or PAC configuration, a local interception proxy with its own root certificate, or a module hooked into the network path.

## Step 3: Test the hypotheses

**Registry sweep.** A search of HKCU and HKLM for the domain returned nothing, which argued against simple registry-persisted adware.

**Process lineage.** All renderers parented correctly to their own browser root process. That is normal Chromium multi-process behaviour and showed no injected parent at that level. The next step was to walk each root process up to whatever launched it.

**Decisive checks**, in order:

```powershell
# 1. System proxy and PAC
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" |
  Select-Object AutoConfigURL, ProxyServer, ProxyEnable
netsh winhttp show proxy

# 2. Recently added root certificates
Get-ChildItem Cert:\LocalMachine\Root, Cert:\CurrentUser\Root |
  Sort-Object NotBefore -Descending |
  Select-Object -First 15 Subject, Issuer, NotBefore, Thumbprint

# 3. Loopback listeners (a local interception proxy listens on 127.0.0.1)
Get-NetTCPConnection -State Listen |
  Where-Object LocalAddress -in '127.0.0.1','::1' |
  Select-Object LocalPort, OwningProcess,
    @{n='Process';e={(Get-Process -Id $_.OwningProcess).Path}}

# 4. Traces of the domain in DNS cache and hosts file
ipconfig /displaydns | Select-String "survey-smiles"
Select-String -Path C:\Windows\System32\drivers\etc\hosts -Pattern "survey-smiles"
```

A PAC URL pointing somewhere unexpected, or a recent non-standard root CA paired with a loopback listener, confirms the mechanism and decides the remediation path.

<!-- TODO before publishing: add the confirmed mechanism and the containment actions taken. -->

## MITRE ATT&CK

Techniques correlated by the Workbench case: T1204 and T1204.001 (User Execution), T1105 (Ingress Tool Transfer), T1567 (Exfiltration Over Web Service), T1606.001 (Forge Web Credentials: Web Cookies).

Techniques relevant to the injection mechanism: T1090 (Proxy), T1557 (Adversary-in-the-Middle), T1553.004 (Install Root Certificate).

## Detections produced

- [System proxy or PAC configuration modified](../detection-rules/windows/win_registry_proxy_autoconfig_modified.yml)
- [Root certificate installed by non-system process](../detection-rules/windows/win_registry_root_certificate_installed.yml)

## Lessons

- Read the action field before anything else. "Detected" and "blocked" are different outcomes.
- Verify ownership of every IP in an alert. Security tools generate traffic that looks like the thing they detect.
- A list of affected processes is evidence in its own right. What the processes have in common narrows the cause faster than investigating each one.
- Split unrelated findings into separate tickets early.
