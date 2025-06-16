//
//  HomeCoordinator.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import SwiftUI
import Observation

enum Home {
    enum Screen: Hashable, Equatable {
        case searchableLeaguesView
        case teamDetailsView(String)
    }
    
    @Observable @MainActor
    final class Coordinator: CoordinatorProtocol {
        typealias Screen = Home.Screen
        
        let rootView = SearchableLeaguesView.make(.current())
        
        var path = NavigationPath()
        
        private init(){}
        
        static let instance = Coordinator()
    }
}


extension Home.Coordinator: CoordinatorViewBuilderProtocol {
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .searchableLeaguesView:
            rootView
        case .teamDetailsView(let name):
            TeamsDetailsView.make(.current(teamName: name))
        }
    }
}
