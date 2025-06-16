//
//  ProcessEnvironment+App.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation

/// The environment variables used by the application, as defined by
/// Edit Scheme > Run > Arguments > Environment Variable
///
/// Usage: ENV[.reset]
extension ProcessEnvironment.Variable {
    
    /// If set, the app will log it's requests
    static let curlTrace = ProcessEnvironment.Variable("CURL_TRACE")
    
    /// If set, the app will log it's db
    static let sqlTrace = ProcessEnvironment.Variable("SQL_TRACE")
}
