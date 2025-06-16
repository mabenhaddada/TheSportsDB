//
//  Coordinator.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation

import SwiftUI
import Combine

@MainActor
protocol CoordinatorProtocol: AnyObject, Observable {
    associatedtype Screen: Hashable, Equatable
    associatedtype Root: View
    
    var rootView: Root { get }
    
    var path: NavigationPath { get set }
    
    static var instance: Self { get }
}

extension CoordinatorProtocol {
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func pop() {
        path.removeLast()
    }
}

protocol CoordinatorViewBuilderProtocol: CoordinatorProtocol {
    associatedtype Body: View
    
    @ViewBuilder @MainActor
    func build(_ screen: Self.Screen) -> Self.Body
}
