//
//  Music.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/6/29.
//

import Foundation

// Apple Music API
struct SearchResponse: Codable {
    let resultCount : Int
    let results: [StoreItem]
}
// 歌曲 struct - 情緒特調
struct StoreItem: Codable, Equatable {
    let artistName: String
    let trackName: String
    let collectionName: String?
    let previewUrl: URL
    let artworkUrl100: URL
    let trackPrice: Double?
    let releaseDate: Date
    let isStreamable: Bool?
}
