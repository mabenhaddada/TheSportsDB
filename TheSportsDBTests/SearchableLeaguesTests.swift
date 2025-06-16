//
//  SearchableLeaguesTests.swift
//  TheSportsDBTests
//
//  Created by Mohamed Amine BEN HADDADA on 15/06/2025.
//
import Testing
import Dependencies
@testable import TheSportsDB

@MainActor
@Suite("SearchableLeaguesTests Tests")
struct SearchableLeaguesTests {
    
    private let vm = withDependencies {
        $0.theSportsDBService = TheSportsDBMockService.shared
    } operation: {
        SearchableLeaguesViewModel.current()
    }
    
    @Test("Should Load Leagues")
    func shouldLoadLeagues() async throws {
        // given
        let vm = vm
        
        // when
        try await vm.fetchLeagues()
        
        // then
        #expect(!vm.leagues.isEmpty)
    }
    
    @Test("Should suggest leagues based on search string")
    func shouldSuggestLeaguesBasedOnSearchString() async throws {
        // given
        let vm = vm
        
        // when
        try await vm.fetchLeagues()
        vm.searchString = "English"
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 2)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "Scottish"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "German"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "Greek"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "Italian Serie"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "French"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "Spanish"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "Dutch"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
        
        // when
        vm.searchString = "Belgian"

        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(vm.teams.isEmpty)
    }
    
    @Test("Should suggest zero leagues for wrong searchString")
    func shouldSuggestZeroLeaguesForWrongSearchString() async throws {
        // given
        let vm = vm
        
        // when
        try await vm.fetchLeagues()
        vm.searchString = "English French"
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.isEmpty)
        #expect(vm.teams.isEmpty)
    }
    
    @Test("Should load teams for selected searchString")
    func shouldLoadTeamsForSelectedSearchString() async throws {
        // given
        let vm = vm
        
        // when
        try await vm.fetchLeagues()
        vm.searchString = "English Premier League"
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(!vm.teams.isEmpty)
    }
    
    @Test("Should clear suggestions but not teams for empty searchString")
    func shouldClearSuggestionsButNotTeamsForEmptySearchString() async throws {
        // given
        let vm = vm
        
        // when
        try await vm.fetchLeagues()
        vm.searchString = "English Premier League"
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        #expect(!vm.teams.isEmpty)
        
        // when
        vm.searchString = ""
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.isEmpty)
        #expect(!vm.teams.isEmpty)
    }
    
    @Test("Should load teams on new searchString selection")
    func shouldLoadTeamsOnNewSearchStringSelection() async throws {
        // given
        let vm = vm
        
        // when
        try await vm.fetchLeagues()
        vm.searchString = "English Premier League"
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        let eplTeam = vm.teams
        #expect(!eplTeam.isEmpty)
        
        // when
        vm.searchString = "French Ligue 1"
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        #expect(vm.suggestions.count == 1)
        let frTeam = vm.teams
        #expect(!vm.teams.isEmpty)
        
        #expect(eplTeam != frTeam)
    }
}
