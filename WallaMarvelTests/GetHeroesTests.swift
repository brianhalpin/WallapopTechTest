//
//  GetHeroesTests.swift
//  WallaMarvelTests
//
//  Created by Brian Halpin on 14/04/2025.
//

import XCTest
@testable import WallaMarvel // Replace with your module name

// --- GetHeroes Use Case Tests ---
class GetHeroesTests: XCTestCase {
    var useCase: GetHeroes!
    var mockRepository: MockMarvelRepository!

    override func setUpWithError() throws {
        mockRepository = MockMarvelRepository()
        useCase = GetHeroes(repository: mockRepository)
    }

    override func tearDownWithError() throws {
        useCase = nil
        mockRepository = nil
    }

    func test_execute_success_callsRepositoryAndReturnsData() async throws {
        // Given
        let offset = 10
        let limit = 5
        let expectedContainer = MockDataFactory.createCharacterContainer(count: limit, limit: limit, offset: offset)
        mockRepository.getHeroesResult = .success(expectedContainer)

        // When
        let resultContainer = try await useCase.execute(offset: offset, limit: limit)

        // Then
        XCTAssertTrue(mockRepository.getHeroesCalled)
        XCTAssertEqual(mockRepository.lastOffset, offset)
        XCTAssertEqual(mockRepository.lastLimit, limit)
        XCTAssertEqual(resultContainer.count, expectedContainer.count)
        XCTAssertEqual(resultContainer.characters.first?.id, expectedContainer.characters.first?.id)
    }

    func test_execute_failure_callsRepositoryAndThrowsError() async throws {
        // Given
        let offset = 0
        let limit = 20
        let expectedError = MockError.genericError
        mockRepository.getHeroesResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await useCase.execute(offset: offset, limit: limit)
            XCTFail("Expected execute to throw an error, but it did not.")
        } catch {
            XCTAssertTrue(mockRepository.getHeroesCalled)
            XCTAssertEqual(mockRepository.lastOffset, offset)
            XCTAssertEqual(mockRepository.lastLimit, limit)
            XCTAssertEqual(error as? MockError, expectedError)
        }
    }
}

// --- MarvelRepository Tests ---
class MarvelRepositoryTests: XCTestCase {
    var repository: MarvelRepository!
    var mockDataSource: MockMarvelDataSource!

     override func setUpWithError() throws {
        mockDataSource = MockMarvelDataSource()
        repository = MarvelRepository(dataSource: mockDataSource)
    }

    override func tearDownWithError() throws {
        repository = nil
        mockDataSource = nil
    }

    func test_getHeroes_success_callsDataSourceAndReturnsData() async throws {
       // Given
        let offset = 0
        let limit = 10
        let expectedContainer = MockDataFactory.createCharacterContainer(count: limit, limit: limit, offset: offset)
        mockDataSource.getHeroesResult = .success(expectedContainer)

        // When
        let resultContainer = try await repository.getHeroes(offset: offset, limit: limit)

        // Then
        XCTAssertTrue(mockDataSource.getHeroesCalled)
        XCTAssertEqual(mockDataSource.lastOffset, offset)
        XCTAssertEqual(mockDataSource.lastLimit, limit)
        XCTAssertEqual(resultContainer.count, expectedContainer.count)
    }

     func test_getHeroes_failure_callsDataSourceAndThrowsError() async throws {
        // Given
        let offset = 0
        let limit = 10
        let expectedError = MockError.genericError
        mockDataSource.getHeroesResult = .failure(expectedError)

        // When & Then
         do {
            _ = try await repository.getHeroes(offset: offset, limit: limit)
            XCTFail("Expected getHeroes to throw an error, but it did not.")
        } catch {
            XCTAssertTrue(mockDataSource.getHeroesCalled)
            XCTAssertEqual(error as? MockError, expectedError)
        }
    }
}


// --- MarvelDataSource Tests ---
class MarvelDataSourceTests: XCTestCase {
    var dataSource: MarvelDataSource!
    var mockAPIClient: MockAPIClient!

     override func setUpWithError() throws {
        mockAPIClient = MockAPIClient()
        dataSource = MarvelDataSource(apiClient: mockAPIClient)
    }

    override func tearDownWithError() throws {
        dataSource = nil
        mockAPIClient = nil
    }

    func test_getHeroes_success_callsAPIClientAndReturnsData() async throws {
       // Given
        let offset = 20
        let limit = 20
        let expectedContainer = MockDataFactory.createCharacterContainer(count: limit, limit: limit, offset: offset)
        mockAPIClient.getHeroesResult = .success(expectedContainer)

        // When
        let resultContainer = try await dataSource.getHeroes(offset: offset, limit: limit)

        // Then
        XCTAssertTrue(mockAPIClient.getHeroesCalled)
        XCTAssertEqual(mockAPIClient.lastOffset, offset)
        XCTAssertEqual(mockAPIClient.lastLimit, limit)
        XCTAssertEqual(resultContainer.count, expectedContainer.count)
    }

     func test_getHeroes_failure_callsAPIClientAndThrowsError() async throws {
        // Given
        let offset = 0
        let limit = 10
        let expectedError = MockError.genericError
        mockAPIClient.getHeroesResult = .failure(expectedError)

        // When & Then
         do {
            _ = try await dataSource.getHeroes(offset: offset, limit: limit)
            XCTFail("Expected getHeroes to throw an error, but it did not.")
        } catch {
            XCTAssertTrue(mockAPIClient.getHeroesCalled)
            XCTAssertEqual(error as? MockError, expectedError)
        }
    }
}
