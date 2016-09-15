//
//  String+Localization.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation


extension String {
    var localized:String {
        return NSLocalizedString(self, comment:"")
    }
}