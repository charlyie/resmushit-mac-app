import Foundation

func optimizeImage(at url: URL, quality: Int, completion: @escaping (URL?) -> Void) {
    // Construire l'URL avec le paramètre "qlty" pour la qualité
    let apiUrl = "https://api.resmush.it/ws.php"
    guard var urlComponents = URLComponents(string: apiUrl) else {
        print("Erreur : URL de l'API invalide.")
        completion(nil)
        return
    }

    // Ajouter le paramètre "qlty" à l'URL
    urlComponents.queryItems = [
        URLQueryItem(name: "qlty", value: "\(quality)")
    ]

    guard let finalUrl = urlComponents.url else {
        print("Erreur : Impossible de générer l'URL finale.")
        completion(nil)
        return
    }

    var request = URLRequest(url: finalUrl)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    guard let imageData = try? Data(contentsOf: url) else {
        print("Erreur : Impossible de lire l'image.")
        completion(nil)
        return
    }

    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Erreur lors de l'optimisation : \(error)")
            completion(nil)
            return
        }

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let destUrlString = json["dest"] as? String,
              let destUrl = URL(string: destUrlString) else {
            print("Erreur : Réponse invalide de l'API.")
            completion(nil)
            return
        }

        completion(destUrl)
    }.resume()
}
