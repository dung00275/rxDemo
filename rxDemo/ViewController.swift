//
//  ViewController.swift
//  rxDemo
//
//  Created by Dung Vu on 8/19/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
//import RxDataSources
import Cell_Rx
import Alamofire

protocol Cell {
}

extension Cell {
    static func identify() -> String {
        return "\(self)"
    }
}

extension Cell where Self: UICollectionViewCell {
    static func createCell(collectionView: UICollectionView, indexPath: NSIndexPath) -> Self {
        return collectionView.dequeueReusableCellWithReuseIdentifier(self.identify(), forIndexPath: indexPath) as! Self
    }
}

extension Cell where Self: UITableViewCell {
    static func createCell(tableView: UITableView) -> Self {
        return tableView.dequeueReusableCellWithIdentifier(self.identify()) as! Self
    }
}

class CellDemo: UICollectionViewCell, Cell {
    @IBOutlet weak var imageView: UIImageView!
    override func prepareForReuse() {
        imageView.image = nil
    }
}

extension CellDemo {
    var rx_setImage: AnyObserver<NSURL?> {

        return UIBindingObserver(UIElement: self, binding: { [weak self](_, url) in
            guard let url = url, weakSelf = self else {
                return
            }

            Network.sharedInstance.getImageFrom(url).bindTo(weakSelf.imageView.rx_imageAnimated(kCATransitionFade)).addDisposableTo(weakSelf.rx_reusableDisposeBag)

        }).asObserver()
    }
}

class ViewController: UIViewController {

//    typealias ItemModelCell = AnimatableSectionModel<String, ItemGag>

    var viewModel = gagViewModel(router: Router(type: .Hot, nextToken: nil))
    let disposeBag = DisposeBag()

    @IBOutlet weak var collectionView: UICollectionView!
    // Create data source

//    let dataSource = RxCollectionViewSectionedAnimatedDataSource<ItemModelCell>()
    let dataSource = gagDataSource<ItemGag>()
    var sections = Variable([ItemGag]())
    var currentRequest: Int = 0
    private let activityTracking = Variable<Bool>(false)

    private lazy var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        setup()
//        requestData()
        
        requestData().subscribeNext { [weak self] in
            self?.sections.value += ($0 ?? [])
            }.addDisposableTo(disposeBag)
    }

    private func setup() {
        // configure cell
        dataSource.configureCell = { _, collectionView, indexPath, model in
            let cell = CellDemo.createCell(collectionView, indexPath: indexPath)
            // setup data for cell
            Observable.just(model.imageItem?.normal).bindTo(cell.rx_setImage).addDisposableTo(cell.rx_reusableDisposeBag)

            return cell
        }

        collectionView.rx_itemSelected.map { [weak self] in self?.dataSource.currentItem[$0.item]
        }.bindTo(rx_showAlertItem).addDisposableTo(disposeBag)

        self.sections.asObservable()
            .bindTo(collectionView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        // Using Refresh
        collectionView.addSubview(refreshControl)

        refreshControl.rx_controlEvent(.ValueChanged).flatMapLatest { [unowned self](_) -> Observable<[ItemGag]?> in
            self.viewModel.router.nextToken = nil
            self.activityTracking.value = true
            self.dataSource.dataSet = false
            return self.requestData()
        }.subscribeNext { [weak self] in
            self?.activityTracking.value = false
            self?.sections.value = ($0 ?? [])
        }.addDisposableTo(disposeBag)

        activityTracking.asObservable().bindTo(refreshControl.rx_refreshing).addDisposableTo(disposeBag)

    }

    func requestData() -> Observable<[ItemGag]?> {
        return viewModel.requestData().map { [weak self] in
            if $0?.next != self?.viewModel.router.nextToken {
                self?.viewModel.router.nextToken = $0?.next
                return ($0?.data ?? [])
            }
            return nil
        }.catchErrorJustReturn(nil)
    }

//    func requestData() {
//        viewModel.requestData().subscribe(onNext: { [weak self] in
//            print("\($0?.next)")
//            if $0?.next != self?.viewModel.router.nextToken {
//                self?.viewModel.router.nextToken = $0?.next
//                self?.sections.value += ($0?.data ?? [])
//            } else {
//                self?.viewModel.router.nextToken = nil
//            }
//            }, onError: { (error) in
//            print(error)
//            }, onCompleted: {
//            print("complete")
//        }) { [weak self] in
//            print("Dispose")
//            if self?.viewModel.router.nextToken != nil {
//                print("Next")
//                self?.currentRequest += 1
//                self?.requestData()
//            }
//
//        }.addDisposableTo(disposeBag)
//    }

//    func requestData() {
//        viewModel.requestData().subscribe(onNext: { [weak self] in
//            print("\($0?.next)")
//            self?.viewModel.router.nextToken = $0?.next
//            let items = $0?.data ?? []
//            self?.sections.value.append(ItemModelCell(model: "Request \(self?.currentRequest ?? 0)", items: items))
//            }, onError: { (error) in
//            print(error)
//            }, onCompleted: { [weak self] in
//            print("Complete request")
//            if self?.viewModel.router.nextToken != nil {
//                print("Next")
//                self?.currentRequest += 1
//                self?.requestData()
//            }
//
//        }) {
//            print("Dispose")
//        }.addDisposableTo(disposeBag)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    // Show alert
    var rx_showAlertItem: AnyObserver<ItemGag?> {
        return UIBindingObserver(UIElement: self, binding: { [weak self](_, item) in
            let alert = UIAlertController(title: "Message Item!!", message: item?.caption, preferredStyle: .Alert)
            let actionOK = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(actionOK)
            self?.presentViewController(alert, animated: true, completion: nil)
        }).asObserver()
    }

}

