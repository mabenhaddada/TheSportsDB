//
//  TheSportsDBApp.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 05/06/2025.
//

import SwiftUI

@main
struct TheSportsDBApp: App {
    @State private var homeCordinator: Home.Coordinator = .instance
    
    var body: some Scene {
        WindowGroup("TheSportsDB", id: "TheSportsDB-id")  {
            HomeView(coordinator: homeCordinator)
        }
    }
}

extension TheSportsDBApp {
    struct HomeView: View {
        @Bindable var coordinator: Home.Coordinator
        
        var body: some View {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(.searchableLeaguesView)
                    .navigationDestination(for: Home.Screen.self) { screen in
                        coordinator.build(screen)
                    }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                    coordinator.pop()
                }, label: {
                    Image(systemName: "arrow.left")
                })
            )
            .environment(coordinator)
        }
    }
}
