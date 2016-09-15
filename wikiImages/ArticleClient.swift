//
//  ArticleClient.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

class ArticleClient {

    func loadArticles(forLocation location:CLLocationCoordinate2D, success: (articleDataList:[[String: AnyObject]]?)-> (), failure: (error:NSError) -> ()) -> NSURLSessionTask? {

        var parameters:[String: AnyObject] = ["action":"query",
                                              "list":"geosearch"]
        
        parameters["gscoord"] = "\(location.latitude)|\(location.longitude)"
        parameters["gsradius"] = 1000
        parameters["gslimit"] = 50

        return ApiEndpoint.frontend.request(parameters, completionHandler: { result in
            switch result {
            case .Success(let value):
                guard let qyearyResult = value["query"] as? [String: AnyObject], let geosearch = qyearyResult["geosearch"] as? [[String: AnyObject]] else {
                    failure(error: NSError.configureResponseParametersError())
                    return
                }
                success(articleDataList: geosearch)
            case .Failure(let error):
                failure(error: error)
            }
        })
    }
}