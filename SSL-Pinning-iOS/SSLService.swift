import Foundation
import Security

// SSLService handles SSL pinning (certificate & public key) for API calls.
class SSLService: NSObject {

    static let shared = SSLService()

    // MARK: - URLSession with self as delegate to handle SSL pinning
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    /*
     Public API to start a network request
     - Parameters:
     - url: URL to request
     - completion: Data / URLResponse / Error closure
     **/
    func startRequest(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: url, completionHandler: completion)
        task.resume()
    }
}


// MARK: - URLSessionDelegate (SSL Pinning Handler)

extension SSLService: URLSessionDelegate {

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // 1️⃣ Check if serverTrust object is available
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let host = challenge.protectionSpace.host

        // 2️⃣ Try certificate pinning first
        if pinByCertificate(serverTrust: serverTrust, host: host) {
            print("🔒 Certificate pinning passed")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }

        // 3️⃣ If certificate pinning fails, try public key pinning
        if pinByPublicKey(serverTrust: serverTrust, host: host) {
            print("🔑 Public key pinning passed")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }

        // 4️⃣ If both fail, cancel connection
        print("❌ SSL Pinning failed")
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}


// MARK: - Certificate Pinning

extension SSLService {

    // Certificate pinning: compares the server's leaf certificate with a local certificate.
    func pinByCertificate(serverTrust: SecTrust, host: String) -> Bool {

        // ✅ Step 1: Get the full server certificate chain (modern API)
        let serverCertificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] ?? []

        guard let leafCert = serverCertificates.first else {
            print("⚠️ No certificates in server chain")
            return false
        }

        // ✅ Step 2: Load the local certificate from bundle
        guard let certPath = Bundle.main.path(forResource: "thronesapi.com", ofType: "der"),
              let localCertData = try? Data(contentsOf: URL(fileURLWithPath: certPath)) else {
            print("⚠️ Local certificate missing")
            return false
        }

        // ✅ Step 3: Convert server certificate to Data
        let serverCertData = SecCertificateCopyData(leafCert) as Data

        // ✅ Step 4: Compare server certificate with local certificate
        return serverCertData == localCertData
    }
}


// MARK: - Public Key Pinning

extension SSLService {

    // Public key pinning: compares the server's public key with the local certificate's public key.
    func pinByPublicKey(serverTrust: SecTrust, host: String) -> Bool {
        // ✅ Step 1: Get full certificate chain
        let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] ?? []
        
        // ✅ Step 2: Get leaf certificate (first in chain)
        guard let leafCert = certChain.first else {
            print("⚠️ Cannot get leaf certificate")
            return false
        }

        // ✅ Step 3: Extract server public key
        guard let serverKey = SecCertificateCopyKey(leafCert),
              let serverKeyData = SecKeyCopyExternalRepresentation(serverKey, nil) as Data? else {
            print("⚠️ Cannot extract server public key")
            return false
        }

        // ✅ Print server public key as Base64 string
        let serverKeyBase64 = serverKeyData.base64EncodedString()
        print("🔑 Server Public Key: \(serverKeyBase64)")

        // ✅ Step 4: Load local certificate
        guard let certPath = Bundle.main.path(forResource: "thronesapi.com", ofType: "der"),
              let localCertData = try? Data(contentsOf: URL(fileURLWithPath: certPath)),
              let localCert = SecCertificateCreateWithData(nil, localCertData as CFData),
              let localKey = SecCertificateCopyKey(localCert),
              let localKeyData = SecKeyCopyExternalRepresentation(localKey, nil) as Data? else {
            print("⚠️ Cannot load local certificate or extract key")
            return false
        }
        
        // ✅ Print server public key as Base64 string
        let localKeyBase64 = localKeyData.base64EncodedString()
        print("🔑 Local Public Key: \(localKeyBase64)")

        // ✅ Step 5: Compare server public key with local public key
        return serverKeyData == localKeyData
    }
}

