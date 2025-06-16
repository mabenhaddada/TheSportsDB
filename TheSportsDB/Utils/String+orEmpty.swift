//
//  String+orEmpty.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 10/06/2025.
//

import Foundation

extension Optional where Wrapped: StringProtocol {
    var orEmpty: Wrapped {
        switch self {
        case .none:
            return ""
        case .some(let text):
            return text
        }
    }
}
