//
//  MainViewModel.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class MainViewModel: NSObject {
    
    weak var coordinator: AppCoordinator!
    var onDataReload: (([NewsCellModel]?, Section) -> Void)?
    var onDataReloadNew: (([SectionData]?) -> Void)?
    
    private var networkService = NetworkService()
    private var dataSource: [Article]?
    private var cellDataSource: [NewsCellModel]?
    private var SNAP: [SectionData] = []
    
    func getCurrentWeather(currentSection: Section) {
        switch currentSection.self {
        case .business:
            networkService.getNews(category: "business" ,page: 1) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let news):
                        self.dataSource = news
                        self.mapCellData(currentSection)
                    case .failure(let error):
                        debugPrint(error)
                    }
                }
            }
        case .generala:
            networkService.getNews(category: "general" ,page: 1) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let news):
                        self.dataSource = news
                        self.mapCellData(currentSection)
                    case .failure(let error):
                        debugPrint(error)
                    }
                }
            }
        default:
            debugPrint("default")
        }
    }
    
    private func mapCellData(_ section: Section) {
        cellDataSource = dataSource?.compactMap{ NewsCellModel(title: $0.title) }

        onDataReload?(cellDataSource, section)
    }
    
    
}
