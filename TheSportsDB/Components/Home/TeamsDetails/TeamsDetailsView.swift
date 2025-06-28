//
//  LeaguesListView.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import SwiftUI
import NukeUI

struct TeamsDetailsView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    @State private var loadingState: BasicLoadingState<Team?> = .idle
    
    @State private var viewModel: TeamsDetailsViewModel
    
    static func make(_ vm: TeamsDetailsViewModel) -> Self {
        TeamsDetailsView(viewModel: vm)
    }
    
    private init(viewModel: TeamsDetailsViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        #if DEBUG
                Self._printChanges()
        #endif
        
        return BasicStateView(
            state: $loadingState,
            dataContent: { team in
                ScrollView(content: {
                    VStack(alignment: .leading) {
                        if let team = viewModel.team {
                            TeamCardView(team: team)
                                .animation(.easeIn, value: team)
                                .navigationTitle(team.name)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                })
                .scrollIndicators(.hidden)
            },
            fetchData: { try await viewModel.searchTeams() }
        )
    }
}

struct TeamCardView: View {
    let team: Team

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                LazyImage(url: team.banner) { state in
                    if state.isLoading {
                        ProgressView()
                    } else if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 80)
                    } else {
                        ContentUnavailableView(String.empty, systemImage: "exclamationmark.circle")
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading) {
                Text(team.country)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text(team.name)
                    .font(.title)
                    .fontWeight(.bold)

                if let description = team.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

#Preview(traits: .modifier(TabPreviewModifier<Home.Coordinator>())) {
    @Previewable
    @Environment(Home.Coordinator.self) var coordinator
    
    coordinator.build(.teamDetailsView(""))
        .navigationDestination(for: Home.Screen.self) { screen in
            coordinator.build(screen)
        }
}
