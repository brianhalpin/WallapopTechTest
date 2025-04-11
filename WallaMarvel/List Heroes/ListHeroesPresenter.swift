import Foundation

protocol ListHeroesPresenterProtocol: AnyObject {
    var ui: ListHeroesUI? { get set }
    func screenTitle() -> String
    func getHeroes()
}

protocol ListHeroesUI: AnyObject {
    func update(heroes: [CharacterDataModel])
}

final class ListHeroesPresenter: ListHeroesPresenterProtocol {
    var ui: ListHeroesUI?
    private let getHeroesUseCase: GetHeroesUseCaseProtocol
    
    init(getHeroesUseCase: GetHeroesUseCaseProtocol = GetHeroes()) {
        self.getHeroesUseCase = getHeroesUseCase
    }
    
    func screenTitle() -> String {
        "List of Heroes"
    }
    
    // MARK: UseCases
    
    func getHeroes() {
        Task {
            do {
                let container = try await getHeroesUseCase.execute()
                let characters = container.characters
                
                // Using the MainActor here ensures the UI activity will get executed on the main thread.
                await MainActor.run {
                    print("Characters \(characters)")
                    self.ui?.update(heroes: characters)
                }
            } catch {
                print("Failed to load heroes: \(error)")
            }
        }
    }

}

