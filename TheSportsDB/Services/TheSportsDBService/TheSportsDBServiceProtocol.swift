//
//  Untitled.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 08/06/2025.
//

// MARK: TheSportsDB Protocol

import Dependencies

protocol TheSportsDBServiceProtocol: Actor, GlobalActor, Sendable {
    
    typealias SearchTeams = @Sendable (String) async throws -> Team?
    typealias GetLeagues = @Sendable () async throws -> [League]
    typealias GetTeams = @Sendable (Int) async throws -> [Team]
    
    // MARK: TheSportsDB API Search
    
    /// Search for any sports team by its name
    ///
    /// - Parameters:
    ///   - name: The name of the team to look for
    ///
    /// - Returns: Search for any sports team by its name. {strTeam}
    var searchTeams: SearchTeams { get }
    
    
    // MARK: TheSportsDB API List
    
    /// List all the leagues on TheSportsDB.
    var getLeagues: GetLeagues { get }


    /// List all the teams in a specific league
    ///
    /// - Parameters:
    ///   - id: The id of the legue
    ///
    /// - Returns: List all the teams in a specific league by the leagues id
    var getTeams: @Sendable (Int) async throws -> [Team] { get }
}
