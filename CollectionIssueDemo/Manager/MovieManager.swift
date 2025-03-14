//
//  MovieManager.swift
//  CollectionIssueDemo
//
//  Created by IT-MAC-02 on 2025/3/14.
//

import Foundation
import Combine

class MovieManager {
    static let shared = MovieManager()
    
    private let apiKey = "ab78eda72ff6817210f05012a437246c" // Temporary apiKey
    private let decoder = JSONDecoder()
    @Published private(set) var movies: [Movie] = []
    
    private init() {
        Task {
            do {
                movies = try await fetchMoviesAsync()
            } catch {
                print(error)
            }
        }
    }
    
    private func fetchMoviesAsync() async throws -> [Movie] {
        let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []   // 先回傳空值
        }
        
        do {
            let decoded = try decoder.decode(MovieResponse.self, from: data)
            return decoded.results
        } catch {
            return []   // 先回傳空值
        }
    }
}
