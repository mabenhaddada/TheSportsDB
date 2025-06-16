//
//  TheSportsDB.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 09/06/2025.
//

import Foundation

// MARK: TheSportsDB Namespace

enum TheSportsDB {
    static let config: APIConfig = .theSportsDB
}


// MARK: LeaguesList DTO

extension TheSportsDB {
    struct LeaguesList: Codable {
        let leagues: [League]
    }

    // MARK: - League Model
    struct League: Codable {
        let idLeague: String
        let strLeague: String
        let strSport: String
    }
}


// MARK: TeamsList DTO

extension TheSportsDB {
    struct TeamsList: Codable {
        let teams: [Team]
    }

    // MARK: - Team Model
    struct Team: Codable {
        let idTeam: String
        let strTeam: String
        let strSport: String
        let strLeague: String
        let idLeague: String
        let strDescriptionFR: String?
        let strDescriptionEN: String?
        let strCountry: String
        let strBadge: String
        let strBanner: String?
    }
}
