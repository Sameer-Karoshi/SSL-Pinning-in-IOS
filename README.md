# SSL-Pinning-in-IOS

## Summary

This project implements **SSL pinning** in the iOS app to secure API requests against **man-in-the-middle (MITM) attacks**. SSL pinning ensures that the app only communicates with trusted servers by validating either the server certificate or public key.

---

## Changes Implemented

- Added `SSLService` singleton class for network requests with SSL pinning.
- Implemented **Certificate Pinning** – compares server certificate with a local `.cer` file.
- Implemented **Public Key Pinning** – compares server public key with a local certificate.
- Updated `ViewController` to make API calls via `SSLService`.
- Added detailed comments and `MARK`s for clarity.
- Logs pinning results for debugging:
  - `🔒 Certificate pinning passed`
  - `🔑 Public key pinning passed`
  - `❌ SSL Pinning failed`

---

## Screenshots


### 1. Without SSL Pinning (request intercepted by proxy)
<img width="700" height="400" alt="Without - SSL Pinning" src="https://github.com/user-attachments/assets/87e2bdf2-b2d8-4e83-afe3-297d3e568d50" />

### 2. With SSL Pinning (request blocked by proxy)
<img width="700" height="400" alt="With - SSL Pinning" src="https://github.com/user-attachments/assets/01ef27c6-47b2-4754-a24b-b875886b931e" />
---

## How to Test

1. Run the app on a simulator or device.
2. Observe the console logs for pinning results.
3. API requests succeed only if the server certificate or public key matches the pinned one.
4. Include local `.cer` files in the app bundle for validation.

---

## Notes

- Compatible with **iOS 15+** and Xcode 14+.
- Both pinning methods can be toggled independently.
- Improves network security and prevents interception from untrusted servers.

### Reference Links
1. https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning
2. https://bugsee.com/blog/ssl-certificate-pinning-in-mobile-applications/

