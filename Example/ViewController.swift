//
//  ViewController.swift
//  Example
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit
import PrettyWaterfallCollectionViewLayout
import PrettyExtensionsKit

class Item {
    // MARK: - Public Properties
    let size: CGSize
    let color: UIColor
    
    init() {
        size = CGSize(width: CGFloat.random(1...5), height: CGFloat.random(1...5))
        color = UIColor.random
    }
}

class Section {
    
    // MARK: - Public Properties
    var numberOfColumns: Int = Int.random(1...4)
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

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            //Register Headers and Footers nibs
            let headerNib = UINib(nibName: "ExampleHeaderCollectionReusableView", bundle: nil)
            collectionView.register(headerNib, forSupplementaryViewOfKind: PrettyWaterfallCollectionElementKindSectionHeader, withReuseIdentifier: "ExampleHeader")
            
            let footerNib = UINib(nibName: "ExampleFooterCollectionReusableView", bundle: nil)
            collectionView.register(footerNib, forSupplementaryViewOfKind: PrettyWaterfallCollectionElementKindSectionFooter, withReuseIdentifier: "ExampleFooter")
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

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
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
        case PrettyWaterfallCollectionElementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleHeader", for: indexPath)
        case PrettyWaterfallCollectionElementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExampleFooter", for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - PrettyWaterfallCollectionViewLayoutDelegate
extension ViewController: PrettyWaterfallCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource[indexPath.section].items[indexPath.row].size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int {
        return dataSource[section].numberOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
}
