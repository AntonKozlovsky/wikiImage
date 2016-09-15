//
//  ImageGroup.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import Foundation

class ImageGroupAlgorithm {
    private let imageList:[ArticleImage]
    private var imageToParts = [ArticleImage: [String]]()
    private var similarityTrashold = 0.9
    private var completionhandler: (([ImageGroup])->())?
    
    init(imageList:[ArticleImage]) {
        self.imageList = imageList
    }
    
    func getGroups(completionHandler:([ImageGroup])->())  {
        self.completionhandler = completionHandler
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.beginGroupProcess()
        }
    }
    
    private func beginGroupProcess() {
        prepareImageNameParts()
        var groupList = getGroupsForCurrentTrashold()
        
        while (groupList.count - imageList.count) < 2 && similarityTrashold > 0.1 {
            similarityTrashold = max(0.1, similarityTrashold-0.3)
            groupList = getGroupsForCurrentTrashold()
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.completionhandler?(groupList)
        }
    }
    
    private func getGroupsForCurrentTrashold() -> [ImageGroup] {
        var groupList = [ImageGroup]()
        
        for image in imageList {
            var imageAddedToGroup = false
            
            for group in groupList {
                if add(image, toGroup: group) {
                    imageAddedToGroup = true
                    break
                }
            }
            
            if !imageAddedToGroup {
                let group = ImageGroup(withImage: image, parts: imageToParts[image]!)
                groupList.append(group)
            }
        }
        return groupList
    }
    
    private func prepareImageNameParts() {
        for image in imageList {
            let title = (image.title as NSString).stringByDeletingPathExtension
            imageToParts[image] =
            title.componentsSeparatedByString(" ").filter{ element -> Bool in
                return element.characters.count > 2
            }.map{ str -> String in
                return str.stringByReplacingOccurrencesOfString("(", withString: "")
                          .stringByReplacingOccurrencesOfString(")", withString: "")
                          .stringByReplacingOccurrencesOfString("File:", withString: "")
            }
        }
    }
    
    private func add(imageToAdd:ArticleImage, toGroup group: ImageGroup) -> Bool {
        let similarity = image(imageToAdd, similarityToGroup: group)
        
        if similarity >= similarityTrashold {
            group.imageList.append(imageToAdd)
            return true
        }
        
        return false
    }
    
    private func image(image:ArticleImage, similarityToGroup group: ImageGroup) -> Double {
        var similarParts = 0
        let parts = imageToParts[image]!
        for part in parts {
            if group.groupNameParts.contains(part) {
                similarParts += 1
            }
        }
        
        let similarity = Double(similarParts)/Double(group.groupNameParts.count)
        return similarity
    }
}

class ImageGroup {
    let groupNameParts: [String]!
    var imageList:[ArticleImage]!
    var title: String {
        return groupNameParts.joinWithSeparator(" ")
    }
    
    init(withImage image:ArticleImage, parts:[String]) {
        imageList = [image]
        groupNameParts = parts
    }
}