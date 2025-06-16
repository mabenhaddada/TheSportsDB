//
//  PreviewModifiers.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 12/06/2025.
//

import Foundation
import SwiftUI

struct TabPreviewModifier<Coordinator: CoordinatorProtocol>: PreviewModifier {
    static func makeSharedContext() async throws -> Coordinator {
        .instance
    }
    
    func body(content: Content, context: Coordinator) -> some View {
        NavigationStack(path: Binding(get: { context.path }, set: { context.path = $0 })) {
            content
        }.environment(context)
    }
}
