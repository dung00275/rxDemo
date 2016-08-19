//
//  Router.swift
//  rxDemo
//
//  Created by Dung Vu on 8/19/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import ObjectMapper

enum TypeSearch: String {
    case Hot = "hot"
    case Trending = "trending"
    case Fresh = "fresh"
}

struct API {
    static let baseURL = NSURL(string: "http://infinigag.k3min.eu")!
}

struct Router: URLRequestConvertible {
    var type: TypeSearch
    var nextToken: String? {
        didSet {
            if nextToken == oldValue {
                nextToken = nil
            }
        }
    }
    var URLRequest: NSMutableURLRequest {
        var params: [String: String] = [:]
        params["next"] = nextToken
        let urlRequest = NSURLRequest(URL: API.baseURL.URLByAppendingPathComponent(type.rawValue))
        return ParameterEncoding.URL.encode(urlRequest, parameters: params).0
    }
}

class Network {
    static let sharedInstance = Network()
    lazy var manager = Manager.sharedInstance
    func requestWith<T: Mappable>(router: Router) -> Observable<T?> {
        return Observable.create({ [weak manager](result) -> Disposable in
            manager?.request(router).responseJSON(completionHandler: { (reponse) in
                if let error = reponse.result.error {
                    result.onError(error)
                } else {
                    let obj = Mapper<T>().map(reponse.result.value)
                    result.onNext(obj)
                    result.onCompleted()
                }
            })
            return NopDisposable.instance
        })
    }

    func getImageFrom(url: NSURL) -> Observable<UIImage?> {
        return Observable.create({ [weak manager](result) -> Disposable in
            manager?.request(NSURLRequest(URL: url)).responseData(completionHandler: { (response) in
                if let error = response.result.error {
                    result.onError(error)
                } else {
                    var image: UIImage?
                    defer {
                        result.onNext(image)
                        result.onCompleted()
                    }
                    guard let data = response.result.value else {
                        return
                    }
                    image = UIImage(data: data)

                }
            })
            return NopDisposable.instance
        })

    }
}