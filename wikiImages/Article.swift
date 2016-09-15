//
//  Article.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation
import ObjectMapper

class Article:Mappable {
    var pageid:NSNumber!
    var images: [ArticleImage]?

    required init?(_ map: Map) {
    }

    func mapping(map: Map) {
        pageid <- map["pageid"]
        images <- map["images"]
    }
}