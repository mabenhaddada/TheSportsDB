//
//  APIServiceProtocol.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 10/06/2025.
//

import Foundation
import Alamofire

protocol APIServiceProtocol: GlobalActor, Sendable {
    var session: Session { get }
    var decoder: JSONDecoder { get }
}

extension APIServiceProtocol {
    func forgeRequest(
        for baseURL: URL,
        appending path: String = .empty,
        method: Networking.HTTPMethod = .get,
        params: [URLQueryItem] = [],
        headers: [String: String]? = ["Accept": "application/json"]
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        ) else {
            throw Networking.Error.invalidURL(path: path)
        }

        components.queryItems = params

        guard let url = components.url else {
            throw Networking.Error.invalidURL(path: path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        
        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    func performRequest<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let dataTask = await session.request(request)
            .validate()
            .serializingDecodable(T.self, decoder: self.decoder)
            .response
        
        if let error = dataTask.error {
            throw error
        }
        
        let decodeValue: () throws -> T = {
            guard let decoded = dataTask.value else {
                throw Networking.Error.invalidData
            }
            
            return decoded
        }
        
        guard let url = request.url,
              !url.isFileURL else {
            return try decodeValue()
        }
        
        guard let response = dataTask.response else {
            throw Networking.Error.invalidResponse
        }
              
        guard response.statusCode >= 200 && response.statusCode < 300 else {
            throw Networking.Error.invalidHTTPStatus(response.statusCode)
        }
        
        return try decodeValue()
    }
}

enum Networking {
    enum HTTPMethod: String {
        /// The GET Method.
        case get
        /// The POST Method.
        case post
        /// The PUT Method.
        case put
        /// The DELETE Method.
        case delete
    }
    
    enum Error: Swift.Error {
        case invalidURL(path: String)
        case invalidHTTPStatus(Int)
        case invalidResponse
        case invalidData
    }
}
