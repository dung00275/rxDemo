//
//  9GagModel.swift
//  rxDemo
//
//  Created by Dung Vu on 8/19/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import ObjectMapper
import RxDataSources

struct ImageItem: Mappable {
    var small: NSURL?
    var cover: NSURL?
    var normal: NSURL?
    var large: NSURL?
    init?(_ map: Map) {

    }

    mutating func mapping(map: Map) {
        small <- (map["small"], URLTransform())
        cover <- (map["cover"], URLTransform())
        normal <- (map["normal"], URLTransform())
        large <- (map["large"], URLTransform())
    }
}

struct Media: Mappable {
    var mp4: NSURL?
    var webm: NSURL?
    init?(_ map: Map) {

    }

    mutating func mapping(map: Map) {
        mp4 <- (map["mp4"], URLTransform())
        webm <- (map["webm"], URLTransform())
    }
}

//struct ItemGag: Mappable, IdentifiableType, Equatable {
//    var identifier: String?
//    var caption: String?
//    var imageItem: ImageItem?
//    var link: NSURL?
//    var media: Media?
//    var numberVotes: Int?
//    var numberComments: Int?
//    var identity: Int {
//        return Int(identifier ?? "0") ?? 0
//    }
//
//    init?(_ map: Map) {
//
//    }
//
//    mutating func mapping(map: Map) {
//        identifier <- map["id"]
//        caption <- map["caption"]
//        imageItem <- map["images"]
//        media <- map["media"]
//        link <- (map["link"], URLTransform())
//        numberVotes <- map["votes.count"]
//        numberComments <- map["comments.count"]
//    }
//}

struct ItemGag: Mappable, Comparable {
    var identifier: String?
    var caption: String?
    var imageItem: ImageItem?
    var link: NSURL?
    var media: Media?
    var numberVotes: Int?
    var numberComments: Int?

    init?(_ map: Map) {

    }

    mutating func mapping(map: Map) {
        identifier <- map["id"]
        caption <- map["caption"]
        imageItem <- map["images"]
        media <- map["media"]
        link <- (map["link"], URLTransform())
        numberVotes <- map["votes.count"]
        numberComments <- map["comments.count"]
    }
}

func == (left: ItemGag, right: ItemGag) -> Bool {
    return left.identifier == right.identifier
}

func >= (left: ItemGag, right: ItemGag) -> Bool {
    return left.numberVotes >= right.numberVotes
}

func < (left: ItemGag, right: ItemGag) -> Bool {
    return left.numberVotes < right.numberVotes
}

struct DataResponse: Mappable {
    var status: Int?
    var message: String?
    var data: [ItemGag]?
    var next: String?

//    var hashValue: Int {
//        return self.hash
//    }

    init?(_ map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
        next <- map["paging.next"]
    }
}

