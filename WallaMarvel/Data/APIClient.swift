import Foundation

protocol APIClientProtocol {
    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer
}


final class APIClient: APIClientProtocol {
    
    private enum Constants {
        static let privateKey = "188f9a5aa76846d907c41cbea6506e4cc455293f"
        static let publicKey = "d575c26d5c746f623518e753921ac847"
        static let baseURL = "https://gateway.marvel.com:443/v1/public/characters"
    }
    
    func getHeroes(offset: Int = 0, limit: Int = 20) async throws -> CharacterDataContainer {
        let ts = String(Int(Date().timeIntervalSince1970))
        let hash = generateHash(ts: ts)

        var urlComponents = URLComponents(string: Constants.baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "apikey", value: Constants.publicKey),
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
        "\(ts)\(Constants.privateKey)\(Constants.publicKey)".md5
    }
}
