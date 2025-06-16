//
//  SchemaV1.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import GRDB


enum SchemaV1 {
    
    @Sendable
    static func createLeague(_ db: Database) throws {
        try db.create(table: "league") { table in
            table.column("id", .text)
                .primaryKey()
            table.column("name", .text)
                .unique()
            table.column("sport", .text)
                .notNull()
        }
    }
    
    @Sendable
    static func createTeam(_ db: Database) throws {
        try db.create(table: "team") { table in
            table.column("id", .text)
                .primaryKey()
            table.column("name", .text)
                .unique()
            table.column("sport", .text)
                .notNull()
            table.column("badge", .text)
                .notNull()
            table.column("banner", .text)
            table.column("league", .text)
                .notNull()
            table.column("leagueId", .text)
                .notNull()
            table.column("country", .text)
                .notNull()
            table.column("description", .text)
        }
    }
}
