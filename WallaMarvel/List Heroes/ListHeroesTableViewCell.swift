import Foundation
import UIKit
import Kingfisher

final class ListHeroesTableViewCell: UITableViewCell {
    
    private enum Constant {
        static let padding: CGFloat = 12
        static let imageSize: CGFloat = 80
        static let textSpacing: CGFloat = 8
    }
    
    private let heroeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let heroeName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubviews()
        addContraints()
    }
    
    private func addSubviews() {
        addSubview(heroeImageView)
        addSubview(heroeName)
    }
    
    private func addContraints() {
        NSLayoutConstraint.activate([
            heroeImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.padding),
            heroeImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constant.padding),
            heroeImageView.heightAnchor.constraint(equalToConstant: Constant.imageSize),
            heroeImageView.widthAnchor.constraint(equalToConstant: Constant.imageSize),
            heroeImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constant.padding),
            
            heroeName.leadingAnchor.constraint(equalTo: heroeImageView.trailingAnchor, constant: Constant.padding),
            heroeName.topAnchor.constraint(equalTo: heroeImageView.topAnchor, constant: Constant.textSpacing),
        ])
    }
    
    func configure(model: CharacterDataModel) {
        heroeImageView.kf.setImage(with: URL(string: model.thumbnail.path + "/portrait_small." + model.thumbnail.extension))
        heroeName.text = model.name
    }
}
