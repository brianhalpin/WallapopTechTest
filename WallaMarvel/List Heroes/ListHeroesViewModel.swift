//
//  ListHeroesViewModel.swift
//  WallaMarvel
//
//  Created by Brian Halpin on 14/04/2025.
//

import Foundation
import Combine

class ListHeroesViewModel {
    // Published properties for observable state
    @Published private(set) var heroes: [CharacterDataModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Search
    @Published var searchText: String = ""
    private var allHeroes: [CharacterDataModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Pagination
    private var currentOffset = 0
    private let limit = 20
    private var hasMoreData = true
    
    var hasMoreDataAvailable: Bool {
        return hasMoreData
    }

    
    // Dependencies
    private let getHeroesUseCase: GetHeroesUseCaseProtocol
    
    init(getHeroesUseCase: GetHeroesUseCaseProtocol = GetHeroes()) {
        self.getHeroesUseCase = getHeroesUseCase

        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applySearchFilter()
            }
            .store(in: &cancellables)
    }

    
    func screenTitle() -> String {
        return "List of Heroes"
    }
    
    func loadHeroes() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        
        Task {
            do {
                let container = try await getHeroesUseCase.execute(offset: currentOffset, limit: limit)
                let newHeroes = container.characters
                
                // Update pagination state
                self.currentOffset += newHeroes.count
                self.hasMoreData = newHeroes.count == self.limit
                
                await MainActor.run {
                    self.allHeroes.append(contentsOf: newHeroes)
                    self.heroes.append(contentsOf: newHeroes)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func heroSelected(at index: Int) -> HeroDetailInfo? {
        guard index < heroes.count else { return nil }
        
        let hero = heroes[index]
        let imageUrl = URL(string: hero.thumbnail.path + "/portrait_uncanny." + hero.thumbnail.extension)!
        
        return HeroDetailInfo(hero: hero, imageURL: imageUrl)
    }
    
    private func applySearchFilter() {
        if searchText.isEmpty {
            heroes = allHeroes
        } else {
            let lowercasedSearch = searchText.lowercased()
            heroes = allHeroes.filter { $0.name.lowercased().contains(lowercasedSearch) }
        }
    }

}
