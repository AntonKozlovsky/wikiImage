//
//  NSError.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation

let WikiImageErrorDomain = "WikiImage"

enum WikiImageError: Int {
    case InconsistentResponse = 1
    case ServerError = 2
    case ConnectionError = 3
}

extension NSError {
    static func configureResponseParametersError() -> NSError {
        return NSError(domain: WikiImageErrorDomain, code: WikiImageError.InconsistentResponse.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "Server error".localized
            ])
    }

    static func configureGeneralServerError() -> NSError {
        return NSError(domain: WikiImageErrorDomain, code: WikiImageError.ServerError.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "Server error".localized
            ])
    }

    static func configureNetworkLostError() -> NSError {
        return NSError(domain: WikiImageErrorDomain, code: WikiImageError.ConnectionError.rawValue, userInfo: [
            NSLocalizedDescriptionKey: "Connection lost".localized
            ])
    }
}