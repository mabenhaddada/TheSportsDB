//
//  LeaguesListView.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import SwiftUI
import Dependencies

struct SearchableLeaguesView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    @State var loadingState: BasicLoadingState<([League])> = .idle
    
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
                    .animation(.easeIn, value: viewModel.searchString)
                    .navigationTitle("SearchableLeaguesView.Title")
                    .navigationBarTitleDisplayMode(.inline)
                    .scrollIndicators(.hidden)
                    .searchable(text: $viewModel.searchString, placement: .automatic, prompt: "SearchableLeaguesView.SearchablePrompt")
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
    private let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 80, maximum: 180)), count: 2)
    
    init(teams: [Team]) {
        self.teams = teams
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center) {
                ForEach(teams) { team in
                    TeamView(team)
                }
            }
        }
    }
}

fileprivate struct TeamView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    private let team: Team
    
    init(_ team: Team) {
        self.team = team
    }
    
    var body: some View {
        Button(action: {
            coordinator.push(.teamDetailsView(team.name))
        }, label: {
            AsyncImage(url: team.badge) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Rectangle())
            } placeholder: {
                ProgressView()
                    .clipShape(Rectangle())
            }
            .padding()
        })
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
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
