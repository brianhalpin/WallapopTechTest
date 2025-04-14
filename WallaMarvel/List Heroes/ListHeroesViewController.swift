import UIKit
import SwiftUI
import Combine

final class ListHeroesViewController: UIViewController {
    // MARK: Properties
    var mainView: ListHeroesView { return view as! ListHeroesView }
    var listHeroesAdapter: ListHeroesAdapter?
    
    private let viewModel: ListHeroesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initialization
    init(viewModel: ListHeroesViewModel = ListHeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func loadView() {
        view = ListHeroesView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadHeroes()
    }
    
    // MARK: Setup
    private func setupUI() {
        title = viewModel.screenTitle()
        navigationItem.backButtonTitle = "Back"
        
        listHeroesAdapter = ListHeroesAdapter(tableView: mainView.heroesTableView)
        mainView.heroesTableView.delegate = self
    }
    
    private func setupBindings() {
        // Bind heroes array updates to the adapter
        viewModel.$heroes
            .receive(on: RunLoop.main)
            .sink { [weak self] heroes in
                self?.listHeroesAdapter?.heroes = heroes
            }
            .store(in: &cancellables)
        
        // Bind error state (you could show an alert here)
        viewModel.$error
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load heroes: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ListHeroesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let heroDetail = viewModel.heroSelected(at: indexPath.row) else {
            print("Failed to get hero at index \(indexPath.row)")
            return
        }
        
        let detailView = HeroDetailView(hero: heroDetail.hero, imageURL: heroDetail.imageURL)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        // Load more data when user scrolls near the bottom
        if offsetY > contentHeight - screenHeight - 200 {
            viewModel.loadHeroes()
        }
    }
}
