//
//  ListHeroesViewModelTests.swift
//  WallaMarvelTests
//
//  Created by Brian Halpin on 14/04/2025.
//

import XCTest
import Combine
@testable import WallaMarvel // Replace with your module name

class ListHeroesViewModelTests: XCTestCase {

    var viewModel: ListHeroesViewModel!
    var mockUseCase: MockGetHeroesUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockUseCase = MockGetHeroesUseCase()
        viewModel = ListHeroesViewModel(getHeroesUseCase: mockUseCase)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockUseCase = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    // --- Test loadHeroes Success ---
    func test_loadHeroes_success_updatesHeroesAndState() async throws {
        // Given
        let expectedLimit = 20
        let mockContainer = MockDataFactory.createCharacterContainer(count: expectedLimit, limit: expectedLimit, offset: 0)
        mockUseCase.executeResult = .success(mockContainer)

        let heroesExpectation = expectation(description: "Heroes publisher should emit")
        let loadingExpectation = expectation(description: "Loading publisher should emit true then false")
        loadingExpectation.expectedFulfillmentCount = 2 // true, then false

        var receivedHeroes: [[CharacterDataModel]] = []
        var receivedLoadingStates: [Bool] = []

        // Collect published values
        viewModel.$heroes
            .dropFirst() // Ignore initial empty value
            .sink { heroes in
                receivedHeroes.append(heroes)
                heroesExpectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .sink { isLoading in
                receivedLoadingStates.append(isLoading)
                // Only fulfill if we have both true and false states
                if receivedLoadingStates.contains(true) && receivedLoadingStates.contains(false) {
                     loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.loadHeroes() // Trigger the load

        // Then
        await fulfillment(of: [heroesExpectation, loadingExpectation], timeout: 1.0) // Wait for publishers

        XCTAssertTrue(mockUseCase.executeCalled)
        XCTAssertEqual(mockUseCase.lastOffset, 0)
        XCTAssertEqual(mockUseCase.lastLimit, expectedLimit)

        XCTAssertEqual(receivedHeroes.count, 1) // Should emit once after load
        XCTAssertEqual(receivedHeroes.first?.count, expectedLimit)
        XCTAssertEqual(receivedHeroes.first?.first?.name, "Hero 0")

        XCTAssertEqual(receivedLoadingStates.first, false, "Initial state should be false") // Check initial state captured by sink
        XCTAssertTrue(receivedLoadingStates.contains(true), "Loading should become true")
        XCTAssertEqual(receivedLoadingStates.last, false, "Loading should become false after completion")

        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.hasMoreDataAvailable) // Assuming count == limit means more data
    }

    // --- Test loadHeroes Failure ---
    func test_loadHeroes_failure_publishesErrorAndResetsLoading() async throws {
        // Given
        let expectedError = MockError.genericError
        mockUseCase.executeResult = .failure(expectedError)

        let errorExpectation = expectation(description: "Error publisher should emit")
        let loadingExpectation = expectation(description: "Loading publisher should emit true then false")
        loadingExpectation.expectedFulfillmentCount = 2

        var receivedError: Error?
        var receivedLoadingStates: [Bool] = []

        viewModel.$error
            .compactMap { $0 } // Ignore initial nil value
            .sink { error in
                receivedError = error
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

         viewModel.$isLoading
            .sink { isLoading in
                receivedLoadingStates.append(isLoading)
                 if receivedLoadingStates.contains(true) && receivedLoadingStates.contains(false) {
                     loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.loadHeroes()

        // Then
        await fulfillment(of: [errorExpectation, loadingExpectation], timeout: 1.0)

        XCTAssertTrue(mockUseCase.executeCalled)
        XCTAssertEqual(receivedError as? MockError, expectedError)
        XCTAssertEqual(viewModel.heroes.count, 0) // Heroes should remain empty

        XCTAssertEqual(receivedLoadingStates.first, false)
        XCTAssertTrue(receivedLoadingStates.contains(true))
        XCTAssertEqual(receivedLoadingStates.last, false)
    }

     // --- Test Pagination End ---
    func test_loadHeroes_paginationEnd_setsHasMoreDataFalse() async throws {
        // Given: Load returns fewer items than limit
        let limit = 20
        let returnedCount = 15
        let mockContainer = MockDataFactory.createCharacterContainer(count: returnedCount, limit: limit, offset: 0)
        mockUseCase.executeResult = .success(mockContainer)

        let heroesExpectation = expectation(description: "Heroes load")
        viewModel.$heroes.dropFirst().sink { _ in heroesExpectation.fulfill() }.store(in: &cancellables)

        // When
        viewModel.loadHeroes()
        await fulfillment(of: [heroesExpectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.heroes.count, returnedCount)
        XCTAssertFalse(viewModel.hasMoreDataAvailable, "Should set hasMoreData to false when returned count < limit")

        // Try loading again
        mockUseCase.executeCalled = false
        viewModel.loadHeroes()
        // Wait briefly to ensure no async task starts
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        XCTAssertFalse(mockUseCase.executeCalled, "Execute should not be called if hasMoreData is false")
    }

    // --- Test Selection ---
    func test_heroSelected_returnsCorrectInfo() async throws {
         // Given: Initial load
        let limit = 5
        let mockContainer = MockDataFactory.createCharacterContainer(count: limit, limit: limit, offset: 0) // Hero 0..Hero 4
        mockUseCase.executeResult = .success(mockContainer)
        let heroesExpectation1 = expectation(description: "Initial heroes load")
        viewModel.$heroes.dropFirst().sink { _ in heroesExpectation1.fulfill() }.store(in: &cancellables)
        viewModel.loadHeroes()
        await fulfillment(of: [heroesExpectation1], timeout: 1.0)

        // When
        let selectedInfo = viewModel.heroSelected(at: 2) // Select "Hero 2"

        // Then
        XCTAssertNotNil(selectedInfo)
        XCTAssertEqual(selectedInfo?.hero.id, 2)
        XCTAssertEqual(selectedInfo?.hero.name, "Hero 2")
        // Check URL construction (assuming the /portrait_uncanny. format)
        XCTAssertEqual(selectedInfo?.imageURL.absoluteString, "path/to/2/portrait_uncanny.jpg")

        // When: Invalid index
        let invalidSelection = viewModel.heroSelected(at: 10)
        XCTAssertNil(invalidSelection)
    }
}
