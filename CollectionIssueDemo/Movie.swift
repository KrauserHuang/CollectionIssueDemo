//
//  Movie.swift
//  CollectionIssueDemo
//
//  Created by IT-MAC-02 on 2025/3/13.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable, Hashable {
    let id: Int
    let title: String
    let overview: String
}
