import Foundation

func optimizeImage(at url: URL, quality: Int, completion: @escaping (URL?) -> Void) {
    // Build the URL with the "qlty" parameter for quality
    let apiUrl = "https://api.resmush.it/ws.php"
    guard var urlComponents = URLComponents(string: apiUrl) else {
        print("Error: Invalid API URL.")
        completion(nil)
        return
    }

    // Add the "qlty" parameter to the URL
    urlComponents.queryItems = [
        URLQueryItem(name: "qlty", value: "\(quality)")
    ]

    guard let finalUrl = urlComponents.url else {
        print("Error: Failed to generate the final URL.")
        completion(nil)
        return
    }

    var request = URLRequest(url: finalUrl)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    // Load the image data
    guard let imageData = try? Data(contentsOf: url) else {
        print("Error: Unable to read the image.")
        completion(nil)
        return
    }

    // Prepare the request body
    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    // Send the request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error during optimization: \(error)")
            completion(nil)
            return
        }

        // Check and parse the response
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let destUrlString = json["dest"] as? String,
              let destUrl = URL(string: destUrlString) else {
            print("Error: Invalid API response.")
            completion(nil)
            return
        }

        // Return the URL of the optimized image
        completion(destUrl)
    }.resume()
}
