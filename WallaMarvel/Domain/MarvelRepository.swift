import Foundation

protocol MarvelRepositoryProtocol {
    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer
}

final class MarvelRepository: MarvelRepositoryProtocol {
    private let dataSource: MarvelDataSourceProtocol

    init(dataSource: MarvelDataSourceProtocol = MarvelDataSource()) {
        self.dataSource = dataSource
    }

    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer {
        return try await dataSource.getHeroes(offset: offset, limit: limit)
    }
}
