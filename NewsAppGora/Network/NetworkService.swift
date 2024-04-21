//
//  NetworkService.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import Foundation

final class NetworkService {
    
    private enum Constants {
        static let scheme = "https"
        static let host = "newsapi.org"
        static let appKey = "d57a4cd02eca4d6c968677bc3ce2b0fd"
        static let pathCurrent = "/v2/top-headlines"
    }
    
    private let decoder = JSONDecoder()
    private let session = URLSession.shared
    private let cache = NSCache<NSString, NSData>()
    
    
    private func getURL(_ path: String, category: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = path
        let queryItemPage = URLQueryItem(name: "page", value: "1")
        let queryItemPageSize = URLQueryItem(name: "pageSize", value: "20")
        let queryItemCategory = URLQueryItem(name: "category", value: category)
        let queryItemToken = URLQueryItem(name: "apiKey", value: Constants.appKey)
        let queryItemCountry = URLQueryItem(name: "country", value: "us")
        components.queryItems = [queryItemPage, queryItemPageSize, queryItemCategory, queryItemToken, queryItemCountry]
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
    
    func getNews(category: String?, complition: @escaping (Result<[Article]?, NetworkError>) -> Void) {
        let request = URLRequest(url: getURL(Constants.pathCurrent, category: category), cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: Double.infinity)
        
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
    
    func downloadImage(from url: URL, completion: @escaping (Data) -> Void) {
        if let cachedData = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedData as Data)
            return
        }
        
        getDataImage(from: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            self?.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async() { [weak self] in
                guard self != nil else { return }
                completion(data)
            }
        }
    }
    
    private func getDataImage(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        session.dataTask(with: url, completionHandler: completion).resume()
    }
}
