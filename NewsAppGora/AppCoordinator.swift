//
//  AppCoordinator.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    
    var parentCoordinator: CoordinatorProtocol?
    var children: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainVC()
    }
    
    private func showMainVC() {
        let mainViewController = MainViewController()
        let networkService = NetworkService()
        let mainViewModel = MainViewModel.init(networkService: networkService)
        mainViewModel.coordinator = self
        
        mainViewController.viewModel = mainViewModel
        navigationController.navigationBar.barTintColor = .white
        navigationController.pushViewController(mainViewController, animated: true)
    }
}
