//
//  AppPaths.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import os.log

enum AppPaths {
    
    nonisolated(unsafe) private static let fileManager: FileManager = .default
    
    private static let defaultRootDirectoryURL = fileManager
        .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        .appendingPathComponent(Bundle.main.bundleIdentifier!)
    
    
    // MARK: Persistence
    
    static var dbWritablePath: String {
        defaultRootDirectoryURL
            .appendingPathComponent("db.sqlite")
            .path
    }
    
    // MARK: Mocked Data
    
    static var allLeagues: URL? {
        Bundle.main.url(forResource: "allLeagues", withExtension: "json")
    }
    
    static func teams(leagueId: Int) -> URL? {
        Bundle.main.url(forResource: "Teams_\(leagueId)", withExtension: "json")
    }
    
    static var arsenalTeam: URL? {
        Bundle.main.url(forResource: "arsenalTeam", withExtension: "json")
    }
}

extension AppPaths {
    
    /// Create needed directories, with intermediate directories, if they do not
    /// exist yet.
    static func createDirectoriesIfNeeded() throws {
        let dir = defaultRootDirectoryURL
        let fm = fileManager
        if !fm.fileExists(atPath: dir.path) {
            os_log(
                .debug, log: log,
                "%{public}@",
                "Create \(dir.absoluteString)"
            )
            try fm.createDirectory(
                at: dir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    /// Deletes directories. USE WITH CAUTION!
    static func deleteDirectories() throws {
        let dir = defaultRootDirectoryURL
        let fm = fileManager
        if fm.fileExists(atPath: dir.path) {
            os_log(
                .debug, log: log,
                "%{public}@",
                "Remove \(dir.absoluteString)"
            )
            do {
                try fm.removeItem(at: dir)
            } catch CocoaError.fileNoSuchFile {
            }
        }
    }
}


fileprivate let log = OSLog(category: "AppPaths")
