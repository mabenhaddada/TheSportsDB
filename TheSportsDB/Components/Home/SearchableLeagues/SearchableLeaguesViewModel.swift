//
//  LeaguesListViewModel.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import Dependencies
import Observation

@Observable @MainActor
class SearchableLeaguesViewModel {
    var searchString: String = ""
    
    private(set) var leagues: [League] = []
    private(set) var teams: [Team] = []
    private(set) var suggestions: [League] = []
    
    @ObservationIgnored
    private(set) var tasks = [Task<Void, any Error>]()
    
    @ObservationIgnored
    @Dependency(\.theSportsDBService) private var theSportsDBService
    
    private init() {
        subscribe()
    }
}

extension SearchableLeaguesViewModel {
    static func current() -> SearchableLeaguesViewModel {
        .init()
    }
}

extension SearchableLeaguesViewModel {
    @discardableResult
    func fetchLeagues() async throws -> [League] {
        leagues = try await theSportsDBService.getLeagues()
        
        return leagues
    }
    
    func subscribe() {
        withObservationTracking({
            withMutation(keyPath: \.searchString, {
                searchTeams(for: searchString)
            })
        }, onChange: { [weak self] in
            guard let self else { return }
            
            Task { @MainActor in
                self.subscribe()
            }
        })
    }
    
    private func searchTeams(for searchString: String) {
        Task {
            try await updateSuggestions(basedOn: searchString)
            try await loadTeamsIfNeeded(for: nil)
        }
    }
    
    private func updateSuggestions(basedOn searchString: String) async throws {
        suggestions = leagues.filter({
            $0.name.lowercased()
                .contains(searchString.lowercased())
        })
    }
    
    private func loadTeamsIfNeeded(for league: League?) async throws {
        guard let league = leagues.first(where: { $0.name == searchString }) else { return }
        
        teams = try await theSportsDBService.getTeams(league.id)
    }
}
