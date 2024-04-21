//
//  MainViewModel.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class MainViewModel: NSObject {
    
    weak var coordinator: AppCoordinator!
    var onDataReload: (([SectionData]?) -> Void)?
    var onIsLoading: ((Bool)-> Void)?
    
    private var networkService = NetworkService()
    private var dataSource: [Article]?
    private var cellDataSource: [NewsCellModel]?
    private var dataCellSection: [SectionData] = []
    
    func getCurrentWeather(currentSection: [Section]) {
        currentSection.forEach {
            getNews(currentSection: $0, category: $0.title, page: 1)
        }
    }
    
    private func getNews(currentSection: Section, category: String, page: Int) {
        onIsLoading?(true)
        networkService.getNews(category: category) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let news):
                    self.dataSource = news
                    self.mapCellData(currentSection)
                    self.onIsLoading?(false)
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    private func downloadDataIcon(_ section: Section) {
        guard cellDataSource != nil else { return }
        
        let group = DispatchGroup()
        let lock = NSLock()
        
        for (indexSnap, snapElement) in dataCellSection.enumerated() {
            
            for (index, _) in snapElement.values.enumerated() {
                group.enter()
                if let urlString = snapElement.values[index].iconURL, let url = URL(string: urlString) {
                    if snapElement.values[index].iconData != nil {
                        group.leave()
                        continue
                    }
                    
                    networkService.downloadImage(from: url) { [weak self] data in
                        guard let self = self else { return }
                        
                        defer {
                            group.leave()
                        }
                        
                        lock.lock()
                        dataCellSection[indexSnap].values[index].iconData = data
                        lock.unlock()
                    }
                } else {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.onDataReload?(self.dataCellSection)
        }
    }
    
    private func mapCellData(_ section: Section) {
        cellDataSource = sortedPublished(data: dataSource)?.compactMap{ NewsCellModel(title: $0.title, url: $0.url, iconURL: $0.urlToImage) }
        dataCellSection.append(.init(key: section, values: cellDataSource ?? []))
        self.onDataReload?(self.dataCellSection)
        downloadDataIcon(section)
    }
    
    private func sortedPublished(data: [Article]?) -> [Article]?  {
        let dateFormatter = ISO8601DateFormatter()
        let sortedData = dataSource?.sorted { newsItem1, newsItem2 in
            if let date1 = dateFormatter.date(from: newsItem1.publishedAt ?? ""),
               let date2 = dateFormatter.date(from: newsItem2.publishedAt ?? "") {
                return date1 > date2
            }
            return true
        }
        return sortedData
    }
}
