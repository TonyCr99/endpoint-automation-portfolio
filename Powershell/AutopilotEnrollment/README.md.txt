# Windows Autopilot Enrollment Script

⚠️ **Disclaimer**  
This script is provided for **demo and portfolio purposes only**.  
All sensitive values (URLs, secrets, product keys) have been replaced with placeholders.  
It is based on community work by [Viktor Sjögren](https://www.smthwentright.com/) and adapted by **Joaquin Antonio Corona Rangel** for demonstration of endpoint management automation skills.  

---

## 📌 Purpose
This script automates the process of collecting device information (serial number, hardware hash) and sending it to a webhook for **Windows Autopilot enrollment**.  

It is designed to:
- Simplify the registration of Windows devices into Autopilot.
- Automate the process using PowerShell + a simple `.bat` launcher.
- Demonstrate **endpoint provisioning, automation, and Intune/Autopilot integration**.

---

## 📂 Contents
- `Enroll-Autopilot.bat` → Launches the PowerShell script with elevated privileges.  
- `Enroll-Autopilot.ps1` → Collects device info and posts to a webhook for enrollment.  
- `sample_log.txt` → Example of expected output (with fake data).  

---

## ⚙️ Variables
Before running, update these placeholders inside `Enroll-Autopilot.ps1`:
- `$GroupTag` → Defines the device group tag (example: `"AAD"`).  
- `$WebHookUrl` → The Autopilot webhook endpoint URL.  
- `$WebhookPassword` → Secret/password for authentication.  

---

## 🚀 Usage
1. Place both files (`.bat` and `.ps1`) in the same folder.  
2. Edit `Enroll-Autopilot.ps1` and set your values for **GroupTag, WebHookUrl, WebhookPassword**.  
3. Run `Enroll-Autopilot.bat` as **Administrator**.  
   - The `.bat` will launch PowerShell with elevated privileges and execute the script.  

---

## 📑 Example Output
You can check a demo of the generated transcript in [sample_log.txt](./sample_log.txt).
