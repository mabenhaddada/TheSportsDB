//
//  NetworkLogger.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 10/06/2025.
//

import Foundation
import Alamofire
import os.log

final class NetworkLogger {
    
    let logger: OSLog
    
    init(_ logger: OSLog) {
        self.logger = logger
    }
}

extension NetworkLogger: EventMonitor {
    
    func request(_ request: Request, didCreateTask task: URLSessionTask) {
        if ENV.defines(.curlTrace) {  // Edit Scheme > Run > Arguments > Environment
            request.cURLDescription { [weak self] curl in
                guard let self = self else { return }
                os_log(
                    .debug, log: self.logger,
                    "▶️ %{public}@\n%@",
                    request.id.uuidString,
                    curl.replacingOccurrences(of: "\t", with: "  ")
                )
            }
        } else {
            os_log(
                .debug, log: self.logger,
                "▶️ %{public}@ %{public}@ - %{public}@",
                request.request!.method!.rawValue,
                request.request!.url!.path,
                request.id.uuidString
            )
        }
    }
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        var responseRepresentation: Any = ""
        if ENV.defines(.curlTrace) {  // Edit Scheme > Run > Arguments > Environment Variable
            responseRepresentation = response.data.flatMap { String(data: $0, encoding: .utf8) } as Any?
                ?? response.data
                ?? "<no data>"
        }
        
        switch response.result {
        case .success:
            os_log(.debug, log: self.logger,
                   "✅ %{public}@\n%@",
                   request.id.uuidString,
                   String(describing: responseRepresentation)
            )
        case .failure(let error):
            switch error {
            case AFError.explicitlyCancelled:
                os_log(.debug, log: self.logger,
                       "🤷‍♂️ %{public}@",
                       request.id.uuidString
                )
            default:
                if ENV.defines(.curlTrace) {  // Edit Scheme > Run > Arguments > Environment Variable
                    os_log(.error, log: self.logger,
                           "🛑 %{public}@ - %@\n%@",
                           request.id.uuidString,
                           String(describing: error),
                           String(describing: responseRepresentation)
                    )
                } else {
                    os_log(.error, log: self.logger,
                           "🛑 %{public}@ - %@",
                           request.id.uuidString,
                           String(describing: error)
                    )
                }
            }
        }
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        var responseRepresentation: Any = ""
        if ENV.defines(.curlTrace) {  // Edit Scheme > Run > Arguments > Environment Variable
            responseRepresentation = response.data.flatMap { String(data: $0, encoding: .utf8) } as Any?
                ?? response.data
                ?? "<no data>"
        }
        
        switch response.result {
        case .success:
            os_log(.debug, log: self.logger,
                   "✅ %{public}@\n%@",
                   request.id.uuidString,
                   String(describing: responseRepresentation)
            )
        case .failure(let error):
            switch error {
            case AFError.explicitlyCancelled:
                os_log(.debug, log: self.logger,
                       "🤷‍♂️ %{public}@",
                       request.id.uuidString
                )
            default:
                let responseRepresentation = response.data.flatMap { String(data: $0, encoding: .utf8) } as Any?
                    ?? response.data
                    ?? "<no data>"
                os_log(.error, log: self.logger,
                       "🛑 %{public}@ <%@> - %@\n%@",
                       request.id.uuidString,
                       String(describing: Value.self),
                       String(describing: error),
                       String(describing: responseRepresentation)
                )
            }
        }
    }
}
