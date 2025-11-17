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
    var searchString: String = .empty
    
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
        if #available(iOS 26.0, *) {
            iOS26Observation()
        } else {
            priorToiOS26Observation()
            
            Task {
                for await query in channel.removeDuplicates().debounce(for: .seconds(0.3)) {
                    searchTeams(for: query)
                }
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
    
    @available(iOS 26.0, *)
    func iOS26Observation() {
        Task { [weak self] in
            let values = Observations { [weak self] in
                guard let self else { return String.empty }
                return self.searchString
            }
            
            for await query in values.removeDuplicates().debounce(for: .seconds(0.3)) {
                guard let self else { break }
                self.searchTeams(for: query)
            }
        }
    }
    
    func priorToiOS26Observation() {
        withObservationTracking({
            withMutation(keyPath: \.searchString, {
                setChannel(query: searchString)
            })
        }, onChange: { [weak self] in
            guard let self else { return }
            
            Task { @MainActor in
                self.priorToiOS26Observation()
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
            .sorted(using: KeyPathComparator(\.name, order: .reverse))
            .enumerated().compactMap({
                $0.offset.isMultiple(of: 2) ? $0.element : nil
            })
    }
}
