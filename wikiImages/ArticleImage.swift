//
//  ArticleImage.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation
import ObjectMapper

class ArticleImage:Mappable {
    var title: String!

    required init?(_ map: Map) {
    }

    func mapping(map: Map) {
        title <- map["title"]
    }
}

extension ArticleImage:Hashable, Equatable {
    var hashValue: Int {
        return title.hash
    }
}

func ==(lhs: ArticleImage, rhs: ArticleImage) -> Bool {
    return lhs.title == rhs.title
}
