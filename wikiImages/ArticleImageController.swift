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

class ArticleImageController {
    //let articleList = Mapper<Article>().mapArray(geosearch)

    private let articleClient = ArticleClient()
    private let articleImageClient = ArticleImageClient()

    func loadArticles(forCoordinates coordinates: CLLocationCoordinate2D) {
        articleClient.loadArticles(forLocation: coordinates,
        success: { articleDataList in
            guard let data = articleDataList else {
                return
            }

            let articleList = Mapper<Article>().mapArray(data)
            self.loadImages(forArticles: articleList!)

        },
        failure: { error in
                //TODO: Show error
                print(error)
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
            //TODO: Show error
            print(error)
        })
    }


    private func handleArticleImageLoaded(withArticlesDictionary articlesDictionary: [String:Article]) {
        var imageList = [ArticleImage]()

        for (_, article) in articlesDictionary {
            if let images = article.images {
                imageList.appendContentsOf(images)
            }
        }

        let imageGroup = ImageGroup(imageList: imageList)
    }
}