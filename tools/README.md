# Tools

## Network Troubleshooting Toolkit

[`network-troubleshooting-toolkit.bat`](network-troubleshooting-toolkit.bat) is a menu-driven diagnostics script for Windows 10 and 11 endpoints. It uses only built-in Windows commands, so it runs on locked-down machines with nothing to install.

| Option | What it does | Changes the system |
|---|---|---|
| 1 | Adapter and IP configuration | No |
| 2 | Layered connectivity test (gateway, internet by IP, DNS, internet by name) with a guide to reading the result | No |
| 3 | DNS servers, resolution tests, hosts file, DNS cache | No |
| 4 | Routing table, path trace, ARP cache | No |
| 5 | Wi-Fi interface, saved profiles, driver details | No |
| 6 | Proxy, PAC and firewall status | No |
| 7 | Listening ports and established connections with PIDs | No |
| 8 | Reset network stack (DNS flush, DHCP renew, Winsock and TCP/IP reset) | **Yes**, after typed confirmation; saves current config first |
| 9 | Full report to a timestamped text file on the Desktop | No |

**Usage:** right-click the file and choose *Run as administrator*.

Option 6 flags unexpected proxy or PAC settings as a security finding to escalate, not a fault to clear. That check comes from an investigation where a system-level proxy change was the cause of malicious web traffic across every browser engine on a host.
