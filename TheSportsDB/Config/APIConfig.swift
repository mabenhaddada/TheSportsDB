//
//  Config.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation
import Alamofire

enum APIConfig: CaseIterable {
    case theSportsDB
    
    var baseURL: URL {
        switch self {
        case .theSportsDB: 
            guard let url = URL(string: "https://www.thesportsdb.com/api/v1/json") else {
                preconditionFailure("Invalid base URL")
            }
            return url
        }
    }
    
    var apiKey: String {
        switch self {
        case .theSportsDB:
            guard let apiKey = Bundle.main.infoDictionary?["THESPORTSDB_API_KEY"] as? String else {
                preconditionFailure("Set an THESPORTSDB_API_KEY value in corresponding Config.xcconfig")
            }
            return apiKey
        }
    }
    
    var serverTrustEvaluator: ServerTrustEvaluating? {
        switch self {
        case .theSportsDB:
            return PinnedCertificatesTrustEvaluator(
                certificates: Bundle.main.af.certificates,
                acceptSelfSignedCertificates: false, // true only if using self-signed cert
                performDefaultValidation: true,      // do hostname + expiry checks
                validateHost: true                   // ensure hostname matches
            )
        }
    }
}
