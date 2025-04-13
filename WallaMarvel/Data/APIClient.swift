import Foundation

protocol APIClientProtocol {
    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer
}

final class APIClient: APIClientProtocol {
    
    func getHeroes(offset: Int = 0, limit: Int = 20) async throws -> CharacterDataContainer {
        let ts = String(Int(Date().timeIntervalSince1970))
        let hash = generateHash(ts: ts)
        
        print("ts: \(ts), hash: \(hash)")

        var urlComponents = URLComponents(string: APIConstants.baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "apikey", value: APIConstants.publicKey),
            URLQueryItem(name: "ts", value: ts),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoded = try JSONDecoder().decode(CharacterDataWrapper.self, from: data)
        return decoded.data
    }
    
    private func generateHash(ts: String) -> String {
        "\(ts)\(APIConstants.privateKey)\(APIConstants.publicKey)".md5
    }
}
