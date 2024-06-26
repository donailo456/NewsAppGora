//
//  NewsCellModel.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import Foundation

struct NewsCellModel: Hashable {
    var id = UUID().uuidString
    var title: String?
    var url: String?
    let iconURL: String?
    var iconData: Data?
}
