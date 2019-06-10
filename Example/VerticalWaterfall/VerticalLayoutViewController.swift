//
//  VerticalLayoutViewController.swift
//  Example
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit
import PrettyWaterfallCollectionViewLayout
import PrettyExtensionsKit

// MARK: - VerticalLayoutViewController
final class VerticalLayoutViewController: UIViewController {
    
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
            collectionView.register(headerNib, forSupplementaryViewOfKind: PrettyVerticalWaterfallCollectionViewLayout.ElementKind.sectionHeader, withReuseIdentifier: "ExampleHeader")
            
            let footerNib = UINib(nibName: "ExampleFooterOrTrailerCollectionReusableView", bundle: nil)
            collectionView.register(footerNib, forSupplementaryViewOfKind: PrettyVerticalWaterfallCollectionViewLayout.ElementKind.sectionFooter, withReuseIdentifier: "ExampleFooter")
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

// MARK: - VerticalLayoutViewController + UICollectionViewDataSource
extension VerticalLayoutViewController: UICollectionViewDataSource {
    
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
        case PrettyVerticalWaterfallCollectionViewLayout.ElementKind.sectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleHeader", for: indexPath)
        case PrettyVerticalWaterfallCollectionViewLayout.ElementKind.sectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleFooter", for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - VerticalLayoutViewController + PrettyHorizontalWaterfallCollectionViewLayoutDelegate
extension VerticalLayoutViewController: PrettyVerticalWaterfallCollectionViewLayoutDelegate {
        
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource[indexPath.section].items[indexPath.row].size
    }
    
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int {
        return dataSource[section].numberOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    /// Configure Headers
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, insetsForHeaderInSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    /// Configure Footers
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, insetsForFooterInSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
