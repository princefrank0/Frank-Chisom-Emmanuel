# Persistent XMRig cryptominer: mapping a ServiceDll implant in CrowdStrike Falcon

**Role:** Lead investigator (Tier 3) · **Tooling:** CrowdStrike Falcon (Advanced Event Search, RTR, IOC Management), PowerShell · **Environment:** Windows enterprise estate (client details withheld)

## Summary

An XMRig Monero miner kept returning on Windows hosts after the EDR killed the process. The miner was only the last stage. A rogue Windows service loaded a malicious DLL into `svchost.exe`, and that DLL re-dropped the miner each time it was removed. I mapped the full persistence chain, produced the IOC set, wrote the per-host eradication sequence, and set out the checks needed to find how the implant was being delivered to newly onboarded machines.

## Starting point

- Falcon repeatedly detected and killed a process named `svchost.exe` running from `C:\Program Files\Common Files\System\`.
- The process came back after every kill and after reboots.
- Newly onboarded devices showed the same detection soon after joining the environment.

A real `svchost.exe` only runs from `System32` or `SysWOW64`, so the binary was a masquerade. The open question was what kept recreating it.

## Investigation

### 1. Work back from the process, not the file

Killing or quarantining the miner had no lasting effect, so the persistence had to sit above it. In the Falcon process tree the miner's parent was a genuine `svchost.exe` started with an unfamiliar group: `svchost.exe -k msntsvcs`.

### 2. Check the svchost group

Service groups are defined in one registry key:

```
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost
```

The `msntsvcs` group contained exactly one member, a service also named `msntsvcs`. Windows does not ship a group by that name, and a group whose only member shares its name is not normal Windows behaviour.

### 3. Inspect the service

| Property | Value |
|---|---|
| Service name | `msntsvcs` |
| Display name | `COM+ Softwares System` |
| Start type | Automatic |
| Account | LocalSystem |
| ServiceDll | `C:\Windows\System32\msvchelp60.dll` |

The display name imitates the genuine "COM+ System Application" and contains a grammatical error.

### 4. Examine the DLL

`msvchelp60.dll` sat in System32 beside the real Visual C++ runtime libraries (`msvcp60.dll`, `msvcirt.dll` and others). Three things separated it from them:

- **No such Microsoft file exists.** The name was chosen to sort alphabetically among the genuine runtime DLLs.
- **Size.** About 17 MB, where the genuine runtime DLLs range from tens of kilobytes to about 1 MB. This is consistent with an embedded payload.
- **Signature and timestamp.** Unsigned, with a file date of January 2018 that did not match the service install time. I treated the date as timestomped and took the timeline from service install events (Event ID 7045) and EDR first-seen telemetry instead.

### 5. Full chain

```
Boot
 └─ Service "msntsvcs" (Automatic, LocalSystem)
     └─ svchost.exe -k msntsvcs
         └─ loads C:\Windows\System32\msvchelp60.dll        (loader)
             └─ drops and runs C:\Program Files\Common Files\System\svchost.exe   (XMRig)
                 └─ mine.moneropool[.]com:443
```

## MITRE ATT&CK

| Tactic | Technique | Evidence |
|---|---|---|
| Persistence | T1543.003 Windows Service | `msntsvcs` service with ServiceDll |
| Defense Evasion | T1036.004 Masquerade Task or Service | Display name imitating a COM+ service |
| Defense Evasion | T1036.005 Match Legitimate Name or Location | `svchost.exe` outside System32; DLL named like a runtime library |
| Defense Evasion | T1070.006 Timestomp | Back-dated DLL |
| Impact | T1496 Resource Hijacking | XMRig mining Monero |
| Command and Control | T1071.001 Web Protocols | Pool traffic over 443 |

## Indicators of compromise

| Type | Indicator |
|---|---|
| File | `C:\Windows\System32\msvchelp60.dll` (about 17 MB, unsigned) |
| File | `C:\Program Files\Common Files\System\svchost.exe` |
| Service | `msntsvcs` / `COM+ Softwares System` |
| Registry | `msntsvcs` value under `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost` |
| Registry | `HKLM\SYSTEM\CurrentControlSet\Services\msntsvcs` |
| Network | `mine.moneropool[.]com:443` |
| SHA256 (sample captured in the case) | `e3d84df77b279ea288cc726cbf68867dc6ae00d24e0e24985141a2ee4753682a` |
| MD5 (sample captured in the case) | `f905359ab27db1dda964d77442735cb8` |

## Containment and eradication

**Fleet-wide, first:**

1. Add both file hashes to Falcon IOC Management as block and detect.
2. Block the pool domain at DNS and the firewall.
3. Hunt on the service name and DLL path across all hosts to scope the infection.

**Per host**, after capturing the hash, signature status and timestamps for evidence:

```powershell
sc.exe stop msntsvcs
sc.exe delete msntsvcs
Remove-Item "C:\Windows\System32\msvchelp60.dll" -Force
Remove-Item "C:\Program Files\Common Files\System\svchost.exe" -Force
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /v msntsvcs /f
```

Order matters. Removing the miner first achieves nothing because the loader restores it. The service has to be stopped before the DLL can be deleted.

## Root cause of reinfection

A LocalSystem service and a write to System32 mean the installer had SYSTEM-level rights. Because new devices became infected on onboarding, the source had to be upstream of the endpoints. I set out three hypotheses in priority order:

1. **Provisioning image.** Check a freshly built machine for the DLL and service before it joins the network.
2. **Group Policy.** Check service preferences and startup scripts in SYSVOL; run `gpresult /h` on an infected host.
3. **Compromised privileged account.** Use Event ID 7045 across the fleet to find the earliest install and the installing account.

<!-- TODO before publishing: add one or two sentences on which hypothesis was confirmed and how it was closed. -->

## Detections produced

- [Svchost loads unsigned DLL from System32](../detection-rules/windows/win_image_load_svchost_unsigned_system32_dll.yml)
- [New svchost service group registered](../detection-rules/windows/win_registry_svchost_group_added.yml)
- [Svchost executed from outside system directories](../detection-rules/windows/win_proc_creation_svchost_outside_system_path.yml)
- [XMRig loader service installation (IOC)](../detection-rules/windows/win_system_service_install_xmrig_loader_ioc.yml)
- [DNS query to cryptomining pool domain](../detection-rules/windows/net_dns_cryptomining_pool_query.yml)

## Lessons

- When an EDR keeps killing the same process, the detection is working and the investigation has not started. Go up the tree.
- File names and paths are weak trust signals. Signature status and file size caught what a path allowlist would have passed.
- Do not take file timestamps as a timeline. Use service install events and EDR first-seen data.
- Cleaning endpoints does not end an incident if the delivery mechanism is upstream.
