//
//  gagDataSource.swift
//  rxDemo
//
//  Created by Dung Vu on 8/22/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class gagDataSource<S: Comparable>: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource {
    // Type for array
    typealias Element = [S]

    // Variable for first time
    var dataSet = false {
        didSet {
            if dataSet == false {
                self.currentItem.removeAll()
            }
        }
    }
    typealias CellFactory = (gagDataSource<S>, UICollectionView, NSIndexPath, S) -> UICollectionViewCell

    // Using for configure cell
    var configureCell: CellFactory! = nil
    var currentItem = Element()

    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver<gagDataSource<S>, [S]>(UIElement: self) { (dataSource, section) in
            if !self.dataSet {
                self.currentItem += section
                collectionView.reloadData()
                self.dataSet = true
            } else {
                let oldValue = self.currentItem.count
                self.currentItem += section
                let newValue = self.currentItem.count
                collectionView.performBatchUpdates({
                    collectionView.insertItemsAtIndexPaths((oldValue..<newValue).toIndexPath(), animationStyle: .Automatic)
                    }, completion: nil)

            }
        }.on(observedEvent)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return configureCell(self, collectionView, indexPath, currentItem[indexPath.item])
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentItem.count
    }
}

extension Range {
    func toIndexPath(inSection section: Int = 0) -> [NSIndexPath] {
        var result = [NSIndexPath]()

        forEach {
            if let index = $0 as? Int {
                result.append(NSIndexPath(forRow: index, inSection: section))
            }
        }

        return result

    }
}