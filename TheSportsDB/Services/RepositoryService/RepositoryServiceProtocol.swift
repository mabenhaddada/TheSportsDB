//
//  DBSyncServiceProtocol.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import GRDB

typealias RepositoryServiceProtocol = RepositorySyncServiceProtocol & RepositoryCRUDServiceProtocol & Sendable

// MARK: TheSportsDB Sync

protocol RepositorySyncServiceProtocol {
    func syncLeagues(_ fromApi: TheSportsDB.LeaguesList) async throws
    
    func syncTeams(_ fromApi: TheSportsDB.TeamsList) async throws
}

extension RepositorySyncServiceProtocol
{
    // MARK: Sync DB Records Helper
    static func syncRecords<APIRecord, DBRecord: FetchableRecord & PersistableRecord, Key>(
        from apiElements: [APIRecord],
        mapping transform: (APIRecord) throws -> DBRecord?,
        dbRequest: QueryInterfaceRequest<DBRecord> = DBRecord.all(),
        identifiedBy kp: KeyPath<DBRecord, Key>,
        in db: Database) throws where Key: Comparable
    {
        let key: (DBRecord) -> Key = { $0[keyPath: kp] }
        let sort: (DBRecord, DBRecord) -> Bool = { $0[keyPath: kp] < $1[keyPath: kp] }
        let fromAPI = try apiElements
            .compactMap(transform)
            .sorted(by: sort)
        let fromDB = try dbRequest
            .fetchAll(db)
            .sorted(by: sort)
        for change in SortedDifference(left: fromDB, identifiedBy: key, right: fromAPI, identifiedBy: key) {
            switch change {
            case let .left(old):
                try old.delete(db)
            case let .right(new):
                try new.insert(db)
            case let .common(old, new):
                try new.updateChanges(db, from: old)
            }
        }
    }

    static func syncRecords<APIRecord, DBRecord: FetchableRecord & PersistableRecord>(
        from apiElements: [APIRecord],
        mapping transform: (APIRecord) throws -> DBRecord?,
        dbRequest: QueryInterfaceRequest<DBRecord> = DBRecord.all(),
        in db: Database) throws where DBRecord: Identifiable, DBRecord.ID: Comparable
    {
        try syncRecords(
            from: apiElements,
            mapping: transform,
            dbRequest: dbRequest,
            identifiedBy: \.id,
            in: db
        )
    }
}

// MARK: TheSportsDB Read

protocol RepositoryCRUDServiceProtocol {
    func fetchLeagues() async throws -> [League]
    
    func fetchTeams(for leagueId: Int) async throws -> [Team]
    
    func fetchTeam(named name: String) async throws -> Team?
}
