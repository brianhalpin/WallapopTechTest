import Foundation

protocol GetHeroesUseCaseProtocol {
    func execute(offset: Int, limit: Int) async throws -> CharacterDataContainer
}

struct GetHeroes: GetHeroesUseCaseProtocol {
    private let repository: MarvelRepositoryProtocol

    init(repository: MarvelRepositoryProtocol = MarvelRepository()) {
        self.repository = repository
    }

    func execute(offset: Int = 0, limit: Int = 20) async throws -> CharacterDataContainer {
        try await repository.getHeroes(offset: offset, limit: limit)
    }
}
