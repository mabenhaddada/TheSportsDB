//
//  DBSyncService.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import Dependencies
import GRDB

@Persistence
final class RepositoryService: RepositoryServiceProtocol {
    
    @Dependency(\.persistence) private var persistence
    
    nonisolated static let instance = RepositoryService()
    
    nonisolated private init() {}
}


// MARK: TheSportsDB Sync

extension RepositoryService {
    
    // MARK: Sync Leagues
    
    func syncLeagues(_ fromApi: TheSportsDB.LeaguesList) async throws {
        try await persistence.dbWriter.write { [weak self] db in
            guard let self else { preconditionFailure() }
            
            try self.persistLeagues(fromApi.leagues, in: db)
        }
    }
    
    nonisolated private func persistLeagues(_ loaded: [TheSportsDB.League], in db: Database) throws {
        try Self.syncRecords(
            from: loaded,
            mapping: League.init,
            in: db
        )
    }
    
    
    // MARK: Sync Teams
    
    func syncTeams(_ fromApi: TheSportsDB.TeamsList) async throws {
        try await persistence.dbWriter.write { [weak self] db in
            guard let self else { preconditionFailure() }
            
            try self.persistTeams(fromApi, in: db)
        }
    }
    
    nonisolated private func persistTeams(_ loaded: TheSportsDB.TeamsList, in db: Database) throws {
        try Self.syncRecords(
            from: loaded.teams.filter({ $0.strSport == "Soccer" }),
            mapping: Team.init,
            in: db
        )
    }
}


// MARK: TheSportsDB CRUD

extension RepositoryService {
    func fetchLeagues() async throws -> [League] {
        try await persistence.dbWriter.read({
            try League.fetchAll($0)
        })
    }
    
    func fetchTeams(for leagueId: Int) async throws -> [Team] {
        try await persistence.dbWriter.read({
            try Team.all()
                .filter(leagueId: leagueId)
                .fetchAll($0)
        })
    }
    
    func fetchTeam(named name: String) async throws -> Team? {
        try await persistence.dbWriter.read({
            try Team.all()
                .filter(name: name)
                .fetchOne($0)
        })
    }
}


// MARK: Dependencies setup

private enum RepositoryServiceKey: DependencyKey {
    static let liveValue: any RepositoryServiceProtocol = RepositoryService.instance
    
    #if DEBUG
    static let previewValue: any RepositoryServiceProtocol = RepositoryService.instance
    static let testValue: any RepositoryServiceProtocol = RepositoryService.instance
    #endif
}

extension DependencyValues {
  var repoService: RepositoryServiceProtocol {
    get { self[RepositoryServiceKey.self] }
    set { self[RepositoryServiceKey.self] = newValue }
  }
}
