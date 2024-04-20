//
//  NewsModel.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import Foundation

// MARK: - Welcome
struct NewsModel: Codable {
    let articles: [Article]?
}

// MARK: - Article
struct Article: Codable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

// MARK: - Source
struct Source: Codable {
    let id, name: String?
}
