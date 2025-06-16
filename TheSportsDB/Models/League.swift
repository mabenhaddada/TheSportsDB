//
//  League.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 09/06/2025.
//

import Foundation

struct League: Codable, Identifiable {
    let id: Int
    
    let name: String
    
    let sport: String
}

extension League: Equatable, Hashable {}

// MARK: - Persistence

#if canImport(GRDB)
import GRDB

extension League: FetchableRecord, PersistableRecord {
    
    // MARK: Columns
    
    enum Columns {
        static let id = Column(League.CodingKeys.id)
        static let name = Column(League.CodingKeys.name)
        static let sport = Column(League.CodingKeys.sport)
    }
}
#endif


// MARK: TheSportsDB.League DTO to Model mapper

extension League {
    init(_ dto: TheSportsDB.League) {
        guard let id = Int(dto.idLeague) else {
            preconditionFailure()
        }
        
        self.id = id
        self.name = dto.strLeague
        self.sport = dto.strSport
    }
}
