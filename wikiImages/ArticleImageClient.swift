//
//  ArticleImageClient.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation

class ArticleImageClient {

    func loadImages(forArticleIdList articleIdList:[NSNumber], success: (articlesImagesData: [String : [String : AnyObject]])-> (), failure: (error:NSError) -> ()) -> NSURLSessionTask? {

        var pageIdList = ""
        for pageid in articleIdList {
            pageIdList += "\(pageid.integerValue)|"
        }

        let parameters = ["pageids":pageIdList,
                          "prop":"images",
                          "action":"query"]

        return ApiEndpoint.frontend.request(parameters, completionHandler: { result in
            switch result {
            case .Success(let value):
                guard let qyearyResult = value["query"] as? [String: AnyObject], let pages = qyearyResult["pages"] as? [String : [String : AnyObject]] else {
                    failure(error: NSError.configureResponseParametersError())
                    return
                }
                success(articlesImagesData: pages)
            case .Failure(let error):
                failure(error: error)
            }
        })
    }
    
}
