//
//  MusicManager.swift
//  SentiMate
//
//  Created by 李芫萱 on 2024/4/13.
//

import Foundation

class MusicManager {
    
    var songs: [StoreItem] = []
    
    func getAPIData(for artist: String, completion: @escaping (Result<[StoreItem], Error>) -> Void) {
            
        //可以查中文歌手
        guard let encodeUrlString = artist.addingPercentEncoding(withAllowedCharacters:
                .urlQueryAllowed) else {
            return
        }
        
            let urlString: String = "https://itunes.apple.com/search?term=\(encodeUrlString)&media=music&country=tw"
            
            if let url = URL(string: urlString) {
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(URLError(.badServerResponse)))
                        return
                    }
                    
                    do {
                        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                        completion(.success(searchResponse.results))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            }
        }
}
