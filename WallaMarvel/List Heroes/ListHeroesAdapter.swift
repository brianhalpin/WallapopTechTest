import UIKit
import SwiftUI

final class ListHeroesAdapter: NSObject, UITableViewDataSource {
    var heroes: [CharacterDataModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        
        // Configure loading footer
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let spinner = UIActivityIndicatorView(style: .medium)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        spinner.startAnimating()
        tableView.tableFooterView = footerView
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
}
