//
//  NetworkController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/9/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class NetworkController {
    
    enum HTTPMethod: String {
        case Get = "GET"
        case Put = "PUT"
        case Post = "POST"
        case Patch = "PATCH"
        case Delete = "DELETE"
    }
    
    static func performRequestForURL(url: URL, httpMethod: HTTPMethod, urlParameters: [String: String]? = nil, body: Data? = nil, completion: ((_ data: Data?, _ error: Error?) -> Void)?) {
        let requestURL = urlFromURLParameters(url: url, urlParameters: urlParameters)
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            if let completion = completion {
                completion(data, error)
            }
        }
        
        dataTask.resume()
    }
    
    static func urlFromURLParameters(url: URL, urlParameters: [String: String]?) -> URL {
        
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = urlParameters?.flatMap({URLQueryItem(name: $0.0, value: $0.1)})
        
        if let url = components?.url {
            return url
        } else {
            fatalError("URL optional is nil")
        }
    }
}
