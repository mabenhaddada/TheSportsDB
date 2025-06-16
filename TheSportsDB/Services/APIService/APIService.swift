//
//  APIService.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 10/06/2025.
//

import Foundation
import os.log
import Alamofire

@globalActor
final actor APILiveService: APIServiceProtocol {
    
    static let shared = APILiveService()
    
    private init() {
        self.session = Self.makeSession()
    }
    
    let session: Session
    let decoder = JSONDecoder()
    
    // Generate public certificate for host:port
    // openssl s_client -connect host:port -showcerts </dev/null 2>/dev/null | openssl x509 -outform DER > domain.cer
    
    private static func makeSession() -> Session {
        Session(
            serverTrustManager: .init(evaluators: APIConfig.allCases.reduce(into: [String: any ServerTrustEvaluating](), {
                if let host = $1.baseURL.host(),
                   let serverTrustEvaluator = $1.serverTrustEvaluator {
                    $0[host] = serverTrustEvaluator
                }
            })),
            cachedResponseHandler: ResponseCacher(behavior: .cache),
            eventMonitors: [NetworkLogger(liveLogger)]
        )
    }
}

#if DEBUG
// MARK: Mocked Implementation of the service

@globalActor
final actor APIMockService: APIServiceProtocol {
    
    static let shared = APIMockService()
    
    private init() {
        self.session = Self.makeSession()
    }
    
    let session: Session
    let decoder = JSONDecoder()
    
    private static func makeSession() -> Session {
        Session(
            configuration: .ephemeral,
            cachedResponseHandler: ResponseCacher(behavior: .doNotCache),
            eventMonitors: [NetworkLogger(mockLogger)]
        )
    }
}

// MARK: Unimplemented

@globalActor
final actor APIUnimplementedService: APIServiceProtocol {
    
    static let shared = APIUnimplementedService()
    
    private init() {
        self.session = .default
    }
    
    let session: Session
    let decoder = JSONDecoder()
}
#endif

fileprivate let liveLogger = OSLog(category: "APILiveService")
fileprivate let mockLogger = OSLog(category: "APIMockService")

// MARK: Dependencies setup

import Dependencies

private enum APIServiceKey: DependencyKey {
    static let liveValue: any APIServiceProtocol = APILiveService.shared
    
    #if DEBUG
    static let previewValue: any APIServiceProtocol = APIMockService.shared
    static let testValue: any APIServiceProtocol = APIUnimplementedService.shared
    #endif
}

extension DependencyValues {
  var apiService: any APIServiceProtocol {
    get { self[APIServiceKey.self] }
    set { self[APIServiceKey.self] = newValue }
  }
}
