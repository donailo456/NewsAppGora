//
//  NetworkService.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import Foundation

final class NetworkService {
    
    let decoder = JSONDecoder()
    
    private enum Constants {
        static let scheme = "https"
        static let host = "newsapi.org"
        static let appKey = "d57a4cd02eca4d6c968677bc3ce2b0fd"
        static let pathCurrent = "/v2/top-headlines"
    }
    
    private func getURL(_ path: String, page: Int?, category: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = path
        let queryItemPage = URLQueryItem(name: "page", value: String(page ?? 0))
        let queryItemPageSize = URLQueryItem(name: "pageSize", value: "5")
        let queryItemCategory = URLQueryItem(name: "category", value: category)
        let queryItemToken = URLQueryItem(name: "apiKey", value: Constants.appKey)
        let queryItemCountry = URLQueryItem(name: "country", value: "ru")
        components.queryItems = [queryItemPage, queryItemPageSize, queryItemCategory, queryItemToken, queryItemCountry]
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
    
    func getNews(category: String?, page: Int?, complition: @escaping (Result<[Article]?, NetworkError>) -> Void) {
        let request = URLRequest(url: getURL(Constants.pathCurrent, page: page, category: category), cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: Double.infinity)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if error != nil {
                complition(.failure(.urlError))
            }
            else if let data = data {
                do {
                    let result = try self?.decoder.decode(NewsModel.self, from: data)
                    complition(.success(result?.articles))
                } catch {
                    complition(.failure(.canNotParseData))
                }
            }
            
        } .resume()
    }
}
