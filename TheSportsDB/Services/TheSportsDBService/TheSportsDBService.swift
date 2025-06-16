//
//  TheSportsDBService.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 09/06/2025.
//

import Foundation
import Dependencies

// MARK: Live Implementation of the service

@globalActor
final actor TheSportsDBLiveService: TheSportsDBServiceProtocol {
    
    static let shared: TheSportsDBLiveService = .init()
    
    @Dependency(\.apiService) private var apiService
    @Dependency(\.repoService) private var repoService
    
    var searchTeams: SearchTeams {
        {
            let request = try await self.apiService.forgeRequest(
                for: TheSportsDB.config.baseURL,
                appending: "/\(TheSportsDB.config.apiKey)/searchteams.php",
                params: [.init(name: "t", value: $0)]
            )
            
            let teamList: TheSportsDB.TeamsList = try await self.apiService.performRequest(request)
            
            try await self.repoService.syncTeams(teamList)
            
            return try await self.repoService.fetchTeam(named: $0)
        }
    }
    
    var getLeagues: GetLeagues {
        {
            let request = try await self.apiService.forgeRequest(
                for: TheSportsDB.config.baseURL,
                appending: "/\(TheSportsDB.config.apiKey)/all_leagues.php"
            )
            
            let leagueList: TheSportsDB.LeaguesList = try await self.apiService.performRequest(request)
            
            try await self.repoService.syncLeagues(leagueList)
            
            return try await self.repoService.fetchLeagues()
        }
    }
    
    var getTeams: GetTeams {
        {
            let request = try await self.apiService.forgeRequest(
                for: TheSportsDB.config.baseURL,
                appending: "/\(TheSportsDB.config.apiKey)/search_all_teams.php",
                params: [
                    .init(name: "id", value: "\($0)")
                ]
            )
            
            let teamList: TheSportsDB.TeamsList = try await self.apiService.performRequest(request)
            
            try await self.repoService.syncTeams(teamList)
            
            return try await self.repoService.fetchTeams(for: $0)
        }
    }
}


#if DEBUG

// MARK: Mocked Implementation of the service

@globalActor
final actor TheSportsDBMockService: TheSportsDBServiceProtocol {
    
    static let shared: TheSportsDBMockService = .init()
    
    @Dependency(\.apiService) private var apiService
    @Dependency(\.repoService) private var repoService
    
    var searchTeams: SearchTeams {
        {
            guard let url = AppPaths.arsenalTeam else  {
                preconditionFailure("⚠️ Failed to load arsenalTeam.json file")
            }
            
            let request = try await self.apiService.forgeRequest(for: url)
            
            let teamList: TheSportsDB.TeamsList = try await self.apiService.performRequest(request)
            
            try await self.repoService.syncTeams(teamList)
            
            return try await self.repoService.fetchTeam(named: $0)
        }
    }
    
    var getLeagues: GetLeagues {
        {
            guard let url = AppPaths.allLeagues else  {
                preconditionFailure("⚠️ Failed to load allLeagues.json file")
            }
            
            let request = try await self.apiService.forgeRequest(for: url)
            
            let leagueList: TheSportsDB.LeaguesList = try await self.apiService.performRequest(request)
            
            try await self.repoService.syncLeagues(leagueList)
            
            return try await self.repoService.fetchLeagues()
        }
    }
    
    var getTeams: GetTeams {
        { leagueId in
            guard let url = AppPaths.teams(leagueId: leagueId) else  {
                preconditionFailure("⚠️ Failed to load Teams_\(leagueId).json file")
            }
            
            let request = try await self.apiService.forgeRequest(for: url)
            
            let teamList: TheSportsDB.TeamsList = try await self.apiService.performRequest(request)
            
            try await self.repoService.syncTeams(teamList)
            
            return try await self.repoService.fetchTeams(for: leagueId)
        }
    }
}


// MARK: Unimplemented
@globalActor
final actor TheSportsDBUnimplementedService: TheSportsDBServiceProtocol {
    
    static let shared: TheSportsDBUnimplementedService = .unimplemented
    
    @Dependency(\.apiService) private var apiService
    @Dependency(\.repoService) private var repoService
    
    var searchTeams: SearchTeams
    
    var getLeagues: GetLeagues
    
    var getTeams: GetTeams
    
    init(
        searchTeams: @escaping SearchTeams = { _ in nil },
        getLeagues: @escaping GetLeagues = { [] },
        getTeams: @escaping GetTeams = { _ in [] }
    ) {
        self.searchTeams = searchTeams
        self.getLeagues = getLeagues
        self.getTeams = getTeams
    }
}

extension TheSportsDBUnimplementedService {
    static var unimplemented: Self {
        .init()
    }
}
#endif

// MARK: Dependencies setup

private enum TheSportsDBServiceKey: DependencyKey {
    static let liveValue: any TheSportsDBServiceProtocol = TheSportsDBLiveService.shared
    
#if DEBUG
    static let previewValue: any TheSportsDBServiceProtocol = TheSportsDBMockService.shared
    static let testValue: any TheSportsDBServiceProtocol = TheSportsDBUnimplementedService.unimplemented
#endif
}

extension DependencyValues {
    var theSportsDBService: any TheSportsDBServiceProtocol {
        get { self[TheSportsDBServiceKey.self] }
        set { self[TheSportsDBServiceKey.self] = newValue }
    }
}
