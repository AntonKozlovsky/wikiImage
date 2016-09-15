//
//  ApiEndpoint.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation
import Alamofire

class ApiEndpoint {
    static let frontend = ApiEndpoint()

    private var manager:Manager

    private static var serverBaseUrl: String {
        return "https://en.wikipedia.org/w/api.php"
    }

    private init() {
        let hostName = ApiEndpoint.serverBaseUrl
        let policies = [hostName: ServerTrustPolicy.DisableEvaluation]
        manager = Manager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies))
    }

    func request(parameters:[String: AnyObject], completionHandler:Result<[String: AnyObject], NSError> -> Void) -> NSURLSessionTask? {
        var requestParameterts: [String: AnyObject] = ["format":"json"]
        for (param, val) in parameters {
            requestParameterts[param] = val
        }

        let request = manager.request(.GET, ApiEndpoint.serverBaseUrl, parameters: requestParameterts, encoding: .URL, headers: nil)
        request.responseJSON { response in
            switch response.result {
            case .Success(let value):
                guard let responseDict = value as? [String: AnyObject] else {
                    completionHandler(Result.Failure(NSError.configureResponseParametersError()))
                    return
                }
                completionHandler(Result.Success(responseDict))
            case .Failure(let error):
                if error.domain == NSURLErrorDomain {
                    switch error.code {
                    case NSURLErrorCancelled:
                        break
                    case NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
                        completionHandler(Result.Failure(NSError.configureNetworkLostError()))
                    case NSURLErrorTimedOut:
                        completionHandler(Result.Failure(error))
                    default:
                        completionHandler(Result.Failure(NSError.configureGeneralServerError()))
                    }
                } else {
                    completionHandler(Result.Failure(NSError.configureGeneralServerError()))
                }
            }
        }
        return request.task
    }
}