import UIKit
import SwiftUI

final class ListHeroesAdapter: NSObject, UITableViewDataSource {
    var heroes: [CharacterDataModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var showLoadingFooter: Bool = true {
        didSet {
            updateFooterVisibility()
        }
    }
    
    private let tableView: UITableView
    private let footerSpinner = UIActivityIndicatorView(style: .medium)
    private let footerView: UIView
    
    init(tableView: UITableView) {
        self.tableView = tableView
        // Set up the footer view
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        super.init()
        
        self.tableView.dataSource = self
        
        let spinner = UIActivityIndicatorView(style: .medium)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        spinner.startAnimating()
        tableView.tableFooterView = footerView
        
        updateFooterVisibility()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListHeroesTableViewCell", for: indexPath) as! ListHeroesTableViewCell
        let model = heroes[indexPath.row]
        cell.configure(model: model)
        return cell
    }
    
    private func updateFooterVisibility() {
        Task { @MainActor in
            self.tableView.tableFooterView = self.showLoadingFooter ? self.footerView : nil
        }
    }

}
