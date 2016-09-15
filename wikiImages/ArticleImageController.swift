//
//  ArticleImageController.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

enum LoadingStatus {
    case Idle, Loading, Loaded, Error(NSError)
}

class ArticleImageController {
    
    private(set) var groupList: [ImageGroup]?
    
    private let articleClient = ArticleClient()
    private let articleImageClient = ArticleImageClient()
    
    enum Notification:String {
        case StateDidChange = "StateDidChange"
    }
    
    private(set) var loadingState = LoadingStatus.Idle {
        didSet {
            postNotification(Notification.StateDidChange)
        }
    }
    
    func loadArticles(forCoordinates coordinates: CLLocationCoordinate2D) {
        switch loadingState {
        case .Loading:
            return
        default:break
        }
        
        groupList = nil
        loadingState = .Loading
        
        articleClient.loadArticles(forLocation: coordinates,
        success: { articleDataList in
            guard let data = articleDataList else {
                return
            }

            let articleList = Mapper<Article>().mapArray(data)
            self.loadImages(forArticles: articleList!)

        },
        failure: { error in
            self.loadingState = .Error(error)
        })
    }

    private func loadImages(forArticles articles:[Article]) {
        var articleIdList = [NSNumber]()

        for article in articles {
            articleIdList.append(article.pageid)
        }

        articleImageClient.loadImages(forArticleIdList: articleIdList,
        success: { articlesImagesData in
            let pagesDictionary = Mapper<Article>().mapDictionary(articlesImagesData)!
            self.handleArticleImageLoaded(withArticlesDictionary: pagesDictionary)
        },
        failure: { error in
            self.loadingState = .Error(error)
        })
    }


    private func handleArticleImageLoaded(withArticlesDictionary articlesDictionary: [String:Article]) {
        var imageList = [ArticleImage]()

        for (_, article) in articlesDictionary {
            if let images = article.images {
                imageList.appendContentsOf(images)
            }
        }

        let imageGroupAlg = ImageGroupAlgorithm(imageList: imageList)
        imageGroupAlg.getGroups { groupList in
            self.groupList = groupList
            self.loadingState = .Loaded
        }
    }
    
    //MARK: Notifications
    private func postNotification(notif: Notification) {
        NSNotificationCenter.defaultCenter().postNotificationName(notif.rawValue, object: self)
    }
}