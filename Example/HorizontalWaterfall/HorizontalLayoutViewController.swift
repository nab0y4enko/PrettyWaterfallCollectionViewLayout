//
//  HorizontalLayoutViewController.swift
//  Example
//
//  Created by Oleksii Naboichenko on 2/7/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit
import PrettyWaterfallCollectionViewLayout
import PrettyExtensionsKit

// MARK: - HorizontalLayoutViewController
final class HorizontalLayoutViewController: UIViewController {
    
    // MARK: - Item
    final class Item {
        
        // MARK: - Public Properties
        let size: CGSize
        let color: UIColor
        
        init() {
            size = CGSize(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
            color = UIColor.random
        }
    }
    
    // MARK: - Section
    final class Section {
        
        // MARK: - Public Properties
        var numberOfColumns: Int = Int.random(in: 2...4)
        var headerColor: UIColor = UIColor.random
        var items: [Item] = {
            var items: [Item] = []
            (0..<15).forEach({ (_) in
                items.append(Item())
            })
            return items
        }()
        var footerColor: UIColor = UIColor.random
    }

    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            //Register Headers and Footers nibs
            let headerNib = UINib(nibName: "ExampleHeaderOrLeaderCollectionReusableView", bundle: nil)
            collectionView.register(headerNib, forSupplementaryViewOfKind: PrettyHorizontalWaterfallCollectionViewLayout.ElementKind.sectionLeader, withReuseIdentifier: "ExampleLeader")
            
            let footerNib = UINib(nibName: "ExampleFooterOrTrailerCollectionReusableView", bundle: nil)
            collectionView.register(footerNib, forSupplementaryViewOfKind: PrettyHorizontalWaterfallCollectionViewLayout.ElementKind.sectionTrailer, withReuseIdentifier: "ExampleTrailer")
        }
    }
    
    // MARK: - Private Properties
    fileprivate lazy var dataSource: [Section] = {
        var dataSource: [Section] = []
        (0..<10).forEach({ (_) in
            dataSource.append(Section())
        })
        return dataSource
    }()
}

// MARK: - HorizontalLayoutViewController + UICollectionViewDataSource
extension HorizontalLayoutViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath) as! ExampleCollectionViewCell
        cell.backgroundColor = dataSource[indexPath.section].items[indexPath.row].color
        cell.textLabel.text = String(indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case PrettyHorizontalWaterfallCollectionViewLayout.ElementKind.sectionLeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleLeader", for: indexPath)
        case PrettyHorizontalWaterfallCollectionViewLayout.ElementKind.sectionTrailer:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleTrailer", for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - HorizontalLayoutViewController + PrettyHorizontalWaterfallCollectionViewLayoutDelegate
extension HorizontalLayoutViewController: PrettyHorizontalWaterfallCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource[indexPath.section].items[indexPath.row].size
    }

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].numberOfColumns
    }

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    /// Configure Leader
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, widthForLeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, insetsForLeaderInSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 70, left: 10, bottom: 70, right: 10)
    }

    /// Configure Trailer
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, widthForTrailerInSection section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, insetsForTrailerInSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 10, bottom: 50, right: 10)
    }

    /// Finished some actions
    func prettyWaterfallCollectionViewLayoutDelegate(_ layout: PrettyHorizontalWaterfallCollectionViewLayout, finishCalculateContentSize contentSize: CGSize) {
        print("contentSize: \(contentSize)")
    }
}
