//
//  ListHeroesFactory.swift
//  WallaMarvel
//
//  Created by Brian Halpin on 14/04/2025.
//

import UIKit

final class ListHeroesFactory {
    static func makeScene() -> UIViewController {
        let getHeroesUseCase = GetHeroes()
        let viewModel = ListHeroesViewModel(getHeroesUseCase: getHeroesUseCase)
        let viewController = ListHeroesViewController(viewModel: viewModel)
        return viewController
    }
}
