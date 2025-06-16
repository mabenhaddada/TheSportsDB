//
//  Decodable+App.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 13/06/2025.
//

import Foundation

extension Decodable {
    static func decode<T: Decodable>(mockJSON: String, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let data = mockJSON.data(using: .utf8) else {
            throw Networking.Error.invalidData
        }
        
        return try decoder.decode(T.self, from: data)
    }
}
