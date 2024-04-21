//
//   Section.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 19.04.2024.
//

import Foundation

enum Section: CaseIterable {
    case business
    case science
    case sports
    case technology
    case general
    case entertainment
    case health
    
    var title: String {
        switch self {
        case .business:
            return "business"
        case .science:
            return "science"
        case .sports:
            return "sports"
        case .technology:
            return "technology"
        case .entertainment:
            return "entertainment"
        case .general:
            return "general"
        case .health:
            return "health"
        }
    }
}
