//
//  gagViewModel.swift
//  rxDemo
//
//  Created by Dung Vu on 8/19/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import RxSwift

class gagViewModel {

    var router: Router

    init(router: Router) {
        self.router = router
    }

    func requestData() -> Observable<DataResponse?> {
        return Network.sharedInstance.requestWith(router)
    }
}