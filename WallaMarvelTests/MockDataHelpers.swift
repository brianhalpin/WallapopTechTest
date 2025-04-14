//
//  MockDataHelpers.swift
//  WallaMarvelTests
//
//  Created by Brian Halpin on 14/04/2025.
//

import Foundation
import Combine
@testable import WallaMarvel // Replace WallaMarvel with your actual module name

// --- Mock Data Helpers ---

// Simple error for testing
enum MockError: Error, Equatable {
    case genericError
}

// Factory for creating sample CharacterDataModel
struct MockDataFactory {
    static func createCharacter(id: Int, name: String) -> CharacterDataModel {
        // Create minimal required nested structs
        let thumbnail = WallaMarvel.Thumbnail(path: "path/to/\(id)", extension: "jpg")
        let series = WallaMarvel.Series(items: [])
        let comics = WallaMarvel.Comics(items: [])
        return CharacterDataModel(
            id: id,
            name: name,
            description: "Description for \(name)",
            thumbnail: thumbnail,
            series: series,
            comics: comics
        )
    }

    static func createCharacterContainer(count: Int, limit: Int, offset: Int, total: Int = 100) -> CharacterDataContainer {
        let characters = (offset..<min(offset + count, total)).map { i in
            createCharacter(id: i, name: "Hero \(i)")
        }
        return CharacterDataContainer(
            count: characters.count, // Actual count returned
            limit: limit,
            offset: offset,
            characters: characters
            // You might need 'total' in CharacterDataContainer if your API provides it
            // for hasMoreData logic, otherwise infer from 'count == limit'.
        )
    }
}

// --- Mocks for Data Layer Protocols ---

class MockGetHeroesUseCase: GetHeroesUseCaseProtocol {
    var executeResult: Result<CharacterDataContainer, Error>?
    var executeCalled = false
    var lastOffset: Int?
    var lastLimit: Int?

    func execute(offset: Int, limit: Int) async throws -> CharacterDataContainer {
        executeCalled = true
        lastOffset = offset
        lastLimit = limit

        guard let result = executeResult else {
            fatalError("MockGetHeroesUseCase executeResult not set")
        }

        switch result {
        case .success(let container):
            return container
        case .failure(let error):
            throw error
        }
    }
}

class MockMarvelRepository: MarvelRepositoryProtocol {
    var getHeroesResult: Result<CharacterDataContainer, Error>?
    var getHeroesCalled = false
    var lastOffset: Int?
    var lastLimit: Int?

    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer {
        getHeroesCalled = true
        lastOffset = offset
        lastLimit = limit

        guard let result = getHeroesResult else {
            fatalError("MockMarvelRepository getHeroesResult not set")
        }

        switch result {
        case .success(let container):
            return container
        case .failure(let error):
            throw error
        }
    }
}

class MockMarvelDataSource: MarvelDataSourceProtocol {
    var getHeroesResult: Result<CharacterDataContainer, Error>?
    var getHeroesCalled = false
    var lastOffset: Int?
    var lastLimit: Int?

    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer {
        getHeroesCalled = true
        lastOffset = offset
        lastLimit = limit

        guard let result = getHeroesResult else {
            fatalError("MockMarvelDataSource getHeroesResult not set")
        }

        switch result {
        case .success(let container):
            return container
        case .failure(let error):
            throw error
        }
    }
}

class MockAPIClient: APIClientProtocol {
    var getHeroesResult: Result<CharacterDataContainer, Error>?
    var getHeroesCalled = false
    var lastOffset: Int?
    var lastLimit: Int?

    func getHeroes(offset: Int, limit: Int) async throws -> CharacterDataContainer {
        getHeroesCalled = true
        lastOffset = offset
        lastLimit = limit

        guard let result = getHeroesResult else {
            fatalError("MockAPIClient getHeroesResult not set")
        }

        switch result {
        case .success(let container):
            return container
        case .failure(let error):
            throw error
        }
    }
}

struct Thumbnail: Decodable { let path: String; let `extension`: String }
struct Series: Decodable { let items: [ReferenceItem] }
struct Comics: Decodable { let items: [ReferenceItem] }
struct ReferenceItem: Decodable { let resourceURI: String; let name: String }
struct HeroDetailInfo { let hero: CharacterDataModel; let imageURL: URL } // Assuming this structure
