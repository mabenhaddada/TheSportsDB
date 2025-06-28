//
//  LeaguesListViewModel.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import Observation
import Dependencies
import AsyncAlgorithms

@Observable @MainActor
class SearchableLeaguesViewModel {
    var searchString: String = ""
    private let channel = AsyncChannel<String>()
    
    private(set) var suggestions: [League] = []
    
    private(set) var teams: [Team] = []
    
    @ObservationIgnored
    private(set) var leagues: [League] = []
    
    @ObservationIgnored
    private(set) var tasks = [Task<Void, any Error>]()
    
    @ObservationIgnored
    @Dependency(\.theSportsDBService) private var theSportsDBService
    
    private init() {
        subscribe()
        
        Task {
            for await query in channel.removeDuplicates().debounce(for: .seconds(0.3)) {
                searchTeams(for: query)
            }
        }
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
            .sorted(using: KeyPathComparator(\.name, order: .forward))
        
        return leagues
    }
    
    private func setChannel(query: String) {
        Task {
            await channel.send(query)
        }
    }
    
    func subscribe() {
        withObservationTracking({
            withMutation(keyPath: \.searchString, {
                setChannel(query: searchString)
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
            try await loadTeamsIfNeeded()
        }
    }
    
    private func updateSuggestions(basedOn searchString: String) async throws {
        guard !searchString.isEmpty else {
            suggestions = leagues
            return
        }
        
        suggestions = leagues.filter({
            $0.name.lowercased().contains(searchString.lowercased())
        })
    }
    
    private func loadTeamsIfNeeded() async throws {
        guard let league = leagues.first(where: { $0.name == searchString }) else { return }
        
        teams = try await theSportsDBService.getTeams(league.id)
            .sorted(using: KeyPathComparator(\.name, order: .forward))
    }
}
