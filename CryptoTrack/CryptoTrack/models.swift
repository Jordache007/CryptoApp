//
//  models.swift
//  CryptoTrack
//
//  Created by Duran Govender on 2023/03/13.
//

import Foundation

struct Crypto: Codable {
    let asset_id: String?
    let name: String?
    let price_usd: Float?
    let id_icon: String?
}

struct CryptoIcon: Codable {
    let asset_id: String
    let url: String
   
}


