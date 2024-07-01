//
//  Artist.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/7/1.
//

struct ArtistSearchResponse: Codable {
    let results: [Artist]
}

struct Artist: Codable {
    let artistName: String
    let artistId: Int
    // Add other artist properties as needed
}
