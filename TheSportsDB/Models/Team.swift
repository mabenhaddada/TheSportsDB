//
//  Team.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 09/06/2025.
//

import Foundation

struct Team: Codable, Identifiable {
    let id: Int
    
    let name: String
    
    let sport: String
    
    let league: String
    
    let leagueId: Int
    
    let description: String?
    
    let country: String
    
    let badge: URL?
    
    let banner: URL?
}

extension Team: Hashable, Equatable {}


// MARK: - Persistence

#if canImport(GRDB)
import GRDB

extension Team: FetchableRecord, PersistableRecord {
    
    // MARK: Columns
    
    enum Columns {
        static let id = Column(Team.CodingKeys.id)
        static let name = Column(Team.CodingKeys.name)
        static let sport = Column(Team.CodingKeys.sport)
        static let league = Column(Team.CodingKeys.league)
        static let leagueId = Column(Team.CodingKeys.leagueId)
        static let description = Column(Team.CodingKeys.description)
        static let country = Column(Team.CodingKeys.country)
        static let badge = Column(Team.CodingKeys.badge)
        static let banner = Column(Team.CodingKeys.banner)
    }
}

extension DerivableRequest where RowDecoder == Team {
    func filter(name: String) -> Self {
        return filter(Team.Columns.name == name)
    }
    
    func filter(leagueId: Int) -> Self {
        return filter(Team.Columns.leagueId == leagueId)
    }
}
#endif


// MARK: TheSportsDB.Team DTO to Model mapper

extension Team {
    init(_ dto: TheSportsDB.Team) {
        guard let id = Int(dto.idTeam),
              let leagueId = Int(dto.idLeague) else {
            preconditionFailure()
        }
        
        self.id = id
        self.name = dto.strTeam
        self.sport = dto.strSport
        self.league = dto.strLeague
        self.leagueId = leagueId
        self.description = dto.strDescriptionFR ?? dto.strDescriptionEN ?? .empty
        self.country = dto.strCountry
        self.badge = URL(string: dto.strBadge)
        self.banner = URL(string: dto.strBanner?.removingPercentEncoding ?? .empty)
    }
}
