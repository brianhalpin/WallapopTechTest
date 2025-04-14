import Foundation

protocol MarvelDataSourceProtocol {
    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer
}

final class MarvelDataSource: MarvelDataSourceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer {
        try await apiClient.getHeroes(offset: offset, limit: limit)
    }
}

