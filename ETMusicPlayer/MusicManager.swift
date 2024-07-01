//
//  MusicManager.swift
//  SentiMate
//
//  Created by 李芫萱 on 2024/4/13.
//

import Foundation

class MusicManager {
    
    func lookupArtist(by searchText: String, completion: @escaping (Result<[Artist], Error>) -> Void) {
           let urlString = "https://itunes.apple.com/search?term=\(searchText)&entity=musicArtist"
           guard let url = URL(string: urlString) else {
               completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
               return
           }

           let task = URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               guard let data = data else {
                   completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                   return
               }

               do {
                   let result = try JSONDecoder().decode(ArtistSearchResponse.self, from: data)
                   let artists = result.results
                   completion(.success(artists))
               } catch {
                   completion(.failure(error))
               }
           }

           task.resume()
       }

    
    func getAPIData(for artist: String, completion: @escaping (Result<[StoreItem], Error>) -> Void) {
        //可以查中文歌手
        guard let encodeUrlString = artist.addingPercentEncoding(withAllowedCharacters:
                .urlQueryAllowed) else {
            return
        }
        
            let urlString: String = "https://itunes.apple.com/search?term=\(artist)&media=music&country=tw"
            
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
