//
//  LeaguesListView.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import SwiftUI

struct TeamsDetailsView: View {
    @Environment(Home.Coordinator.self) private var coordinator
    
    @State var loadingState: BasicLoadingState<Team?> = .idle
    
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
                AsyncImage(url: team.banner) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 80)
                } placeholder: {
                    ProgressView()
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
