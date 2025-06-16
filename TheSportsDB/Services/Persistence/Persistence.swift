//
//  Persistence.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import os.log
import GRDB

@globalActor
final actor Persistence {
    
    static let shared = Persistence(at: AppPaths.dbWritablePath)
    
    let dbWriter: DatabaseWriter
    
    private init(at path: String) {
        os_log(
            .debug, log: log,
            "⚙️ DB: %{public}@",
            String(describing: URL(fileURLWithPath: AppPaths.dbWritablePath))
        )
        
        do {
            try AppPaths.createDirectoriesIfNeeded()
            
            var configuration = GRDB.Configuration()
            if ENV.defines(.sqlTrace) {
                configuration.prepareDatabase { db in
                    db.trace(options: .statement) { event in
                        os_log("%@", log: log, type: .debug, "\(event)")
                    }
                }
            }
            
            try self.init(try DatabasePool(path: path, configuration: configuration))
        } catch {
            preconditionFailure(String(describing: error))
        }
    }
    
    private init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try Self.setup(dbWriter)
    }
    
    private static func setup(_ dbWriter: DatabaseWriter) throws {
        try dbMigrator.migrate(dbWriter)
    }
    
    /// Create and setup a Persistence suitable to use in tests with an in-memory db
    static func forTest() -> Persistence {
        do {
            var configuration = GRDB.Configuration()
            if ENV.defines(.sqlTrace) {
                configuration.prepareDatabase { db in
                    db.trace(options: .statement) { event in
                        os_log("%@", log: log, type: .debug, "\(event)")
                    }
                }
            }
            
            return try Persistence(DatabaseQueue(configuration: configuration))
        } catch {
            preconditionFailure(String(describing: error))
        }
    }
    
    private static var dbMigrator: DatabaseMigrator = {
        var dbMigrator = DatabaseMigrator()
        
        #if DEBUG
        // Clear all Data when migrations change (Speed up Dev)
        dbMigrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        // Schema v1
        dbMigrator.registerMigration("v1.league", migrate: SchemaV1.createLeague)
        dbMigrator.registerMigration("v1.team", migrate: SchemaV1.createTeam)
        
        return dbMigrator
    }()
}


// MARK: Dependencies setup

import Dependencies

private enum PersistenceKey: DependencyKey {
    static let liveValue: Persistence = .shared
    
    #if DEBUG
    static let previewValue: Persistence = .forTest()
    static let testValue: Persistence = .forTest()
    #endif
}

extension DependencyValues {
  var persistence: Persistence {
    get { self[PersistenceKey.self] }
    set { self[PersistenceKey.self] = newValue }
  }
}

fileprivate let log = OSLog(category: "DB")
