import UIKit
import SwiftUI

final class ListHeroesViewController: UIViewController {
    var mainView: ListHeroesView { return view as! ListHeroesView  }
    
    var presenter: ListHeroesPresenterProtocol?
    var listHeroesProvider: ListHeroesAdapter?
    
    override func loadView() {
        view = ListHeroesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listHeroesProvider = ListHeroesAdapter(tableView: mainView.heroesTableView)
        presenter?.getHeroes()
        presenter?.ui = self
        
        title = presenter?.screenTitle()
        navigationItem.backButtonTitle = "Back"
        
        mainView.heroesTableView.delegate = self
    }
}

extension ListHeroesViewController: ListHeroesUI {
    func update(heroes: [CharacterDataModel]) {
        listHeroesProvider?.heroes = heroes
    }
}

extension ListHeroesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let hero = listHeroesProvider?.heroes[indexPath.row] else {
            print("Failed to get hero at index \(indexPath.row)")
            return
        }

        let imageUrl = URL(string: hero.thumbnail.path + "/portrait_uncanny." + hero.thumbnail.extension)!
        let detailView = HeroDetailView(hero: hero, imageURL: imageUrl)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}


