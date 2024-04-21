//
//  MainViewModel.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class MainViewModel: NSObject {
    
    // MARK: - Internal properties
    
    weak var coordinator: AppCoordinator!
    var onDataReload: (([SectionData]?) -> Void)?
    var onIsLoading: ((Bool)-> Void)?
    
    // MARK: - Private properties
    
    private var networkService: NetworkService?
    private var dataSource: [Article]?
    private var cellDataSource: [NewsCellModel]?
    private var dataCellSection: [SectionData] = []
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - Internal Methods
    
    func getCurrentWeather(currentSection: [Section]) {
        currentSection.forEach {
            getNews(currentSection: $0, category: $0.title, page: 1)
        }
    }
    
    func search(for searchText: String) -> [SectionData] {
        if searchText == "" {
            return dataCellSection
        }
        else {
            return self.dataCellSection.compactMap { sectionData in
                let filteredValues = sectionData.values.filter { $0.title?.localizedCaseInsensitiveContains(searchText) ?? false}
                guard !filteredValues.isEmpty else { return nil }
                return SectionData(key: sectionData.key, values: filteredValues)
            } 
        }
    }
    
    // MARK: - Private Methods
    
    private func getNews(currentSection: Section, category: String, page: Int) {
        onIsLoading?(true)
        networkService?.getNews(category: category) { [weak self] result in
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
        guard !dataCellSection.isEmpty else { return }
        
        let group = DispatchGroup()
        let lock = NSLock()
        
        for (indexSnap, snapElement) in dataCellSection.enumerated() {
            for (index, value) in snapElement.values.enumerated() {
                guard let urlString = value.iconURL, let url = URL(string: urlString) else { continue }
                guard value.iconData == nil else { continue }
                
                group.enter()
                networkService?.downloadImage(from: url) { [weak self] data in
                    guard let self = self else { return }
                    
                    defer {
                        group.leave()
                    }
                    
                    lock.lock()
                    self.dataCellSection[indexSnap].values[index].iconData = data
                    lock.unlock()
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
