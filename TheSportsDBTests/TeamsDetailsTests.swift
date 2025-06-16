//
//  TeamsDetailsTests.swift
//  TheSportsDBTests
//
//  Created by Mohamed Amine BEN HADDADA on 16/06/2025.
//

import Testing
import Dependencies
@testable import TheSportsDB

@MainActor
@Suite("TeamDetailsTests Tests")
struct TeamsDetailsTests {
    
    @Test("Should Load Team")
    func shouldLoadTeam() async throws {
        // given
        let vm = withDependencies {
            $0.theSportsDBService = TheSportsDBMockService.shared
        } operation: {
            TeamsDetailsViewModel.current(teamName: "Arsenal")
        }
        
        // when
        try await vm.searchTeams()
        
        // then
        #expect(vm.team != nil && vm.team!.name == "Arsenal")
    }
    
    @Test("Should return nil when not found Team")
    func shouldntLoadAnyTeam() async throws {
        // given
        let vm = withDependencies {
            $0.theSportsDBService = TheSportsDBMockService.shared
        } operation: {
            TeamsDetailsViewModel.current(teamName: "ABC")
        }
        
        // when
        try await vm.searchTeams()
        
        // then
        #expect(vm.team == nil)
    }
}
