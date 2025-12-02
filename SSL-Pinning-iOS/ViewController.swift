import UIKit

// ViewController demonstrating how to call SSLService with SSL pinning
class ViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // 🔹 Start API call with SSL pinning
        callPinnedAPI()
    }

    // MARK: - API Request with SSL Pinning

    // Calls the Thrones API with SSL pinning
    func callPinnedAPI() {
        // 1️⃣ Ensure URL is valid
        guard let url = URL(string: "https://thronesapi.com/api/v2/Characters") else {
            print("⚠️ Invalid URL")
            return
        }

        // 2️⃣ Start the request using SSLService (certificate & public key pinning handled internally)
        SSLService.shared.startRequest(url: url) { data, response, error in
            // 3️⃣ Handle errors
            if let error = error {
                print("❌ Request failed:", error.localizedDescription)
                return
            }

            // 4️⃣ Ensure data is returned
            guard let data = data else {
                print("⚠️ No data returned")
                return
            }

            // 5️⃣ Convert Data to String (for demonstration)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("✅ Response:\n\(jsonString)")
            }
        }
    }

    // MARK: - API Request without SSL Pinning

    func fireAPIRequest() {
        // 1️⃣ Create URL
        guard let url = URL(string: "https://thronesapi.com/api/v2/Characters") else {
            print("⚠️ Invalid URL")
            return
        }

        // 2️⃣ Create data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 3️⃣ Handle errors
            if let error = error {
                print("❌ Request failed:", error.localizedDescription)
                return
            }

            // 4️⃣ Ensure data exists
            guard let data = data else {
                print("⚠️ No data returned")
                return
            }

            // 5️⃣ Convert data to string for demonstration
            if let jsonString = String(data: data, encoding: .utf8) {
                print("✅ Response:\n\(jsonString)")
            }
        }

        // 6️⃣ Start the task
        task.resume()
    }
}

