//
//  LeaguesListViewModel.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import Dependencies

@Observable @MainActor
class TeamsDetailsViewModel {
    
    var teamName: String = ""
    
    private(set) var team: Team?

    @ObservationIgnored
    @Dependency(\.theSportsDBService) private var theSportsDBService
    
    private init(teamName: String){
        self.teamName = teamName
    }
}

extension TeamsDetailsViewModel {
    static func current(teamName: String) -> TeamsDetailsViewModel {
        .init(teamName: teamName)
    }
}

extension TeamsDetailsViewModel {
    @discardableResult
    func searchTeams() async throws -> Team? {
        team = try await theSportsDBService.searchTeams(teamName)
        
        return team
    }
}
