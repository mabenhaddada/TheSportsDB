//
//  LeaguesListView.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import SwiftUI
import NukeUI
import Dependencies

struct SearchableLeaguesView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    @State private var loadingState: BasicLoadingState<([League])> = .idle
    
    @State private var viewModel: SearchableLeaguesViewModel
    
    static func make(_ vm: SearchableLeaguesViewModel) -> Self {
        SearchableLeaguesView(viewModel: vm)
    }
    
    private init(viewModel: SearchableLeaguesViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        #if DEBUG
                Self._printChanges()
        #endif
        
        return BasicStateView(
            state: $loadingState,
            dataContent: { _ in
                SearchableTeamsGridView(teams: viewModel.teams)
                    .navigationTitle(.searchableLeaguesViewTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .scrollIndicators(.hidden)
                    .searchable(
                        text: $viewModel.searchString,
                        placement: .automatic,
                        prompt: .searchableLeaguesViewSearchablePrompt
                    )
                    .searchSuggestions({
                        ForEach(viewModel.suggestions.map(\.name), id: \.self) { league in
                            Text(league)
                                .font(.headline)
                                .searchCompletion(league)
                        }
                    })
            },
            fetchData: { try await viewModel.fetchLeagues() }
        )
    }
}

fileprivate struct SearchableTeamsGridView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    private let teams: [Team]
    
    init(teams: [Team]) {
        self.teams = teams
    }
    
    private let columns: [GridItem] = .init(
        repeating: .init(.flexible()),
        count: 2
    )

    var body: some View {
        #if DEBUG
                Self._printChanges()
        #endif
        
        return ScrollView {
            ZStack {
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(teams, id: \.id) { team in
                        TeamView(team: team)
                    }
                }.padding()
            }
        }
    }
}

fileprivate struct TeamView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    private let team: Team
    
    init(team: Team) {
        self.team = team
    }
    
    var body: some View {
        #if DEBUG
                Self._printChanges()
        #endif

        return ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            Button(action: {
                coordinator.push(.teamDetailsView(team.name))
            }, label: {
                LazyImage(url: team.badge) { state in
                    if state.isLoading {
                        ProgressView()
                            .clipShape(Rectangle())
                    } else if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Rectangle())
                    } else {
                        ContentUnavailableView(String.empty, systemImage: "exclamationmark.circle")
                    }
                }
            })
            .padding()
        }.transition(.scale.combined(with: .opacity).animation(.easeOut(duration: 0.3)))
    }
}


#Preview(traits: .modifier(TabPreviewModifier<Home.Coordinator>())) {
    @Previewable
    @Environment(Home.Coordinator.self) var coordinator
    
    coordinator.build(.searchableLeaguesView)
        .navigationDestination(for: Home.Screen.self) { screen in
            coordinator.build(screen)
        }
}
