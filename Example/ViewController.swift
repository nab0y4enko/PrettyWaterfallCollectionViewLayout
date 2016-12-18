//
//  ViewController.swift
//  Example
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit
import PrettyWaterfallCollectionViewLayout

class Item {
    // MARK: - Public Properties
    let size: CGSize
    let color: UIColor
    
    init() {
        size = CGSize.random(lower: 120, upper: 600)
        color = UIColor.random()
    }
}

class Section {
    // MARK: - Public Properties
    var numberOfColumns: Int = Int(UInt32.random(lower: 1, upper: 5))
    var headerColor: UIColor = UIColor.random()
    var items: [Item] = Array(repeating: Item(), count: 30)
    var footerColor: UIColor = UIColor.random()
}

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties
    fileprivate lazy var dataSource: [Section] = Array(repeating: Section(), count: 10)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath) as! ColoredCell
        cell.backgroundColor = dataSource[indexPath.section].items[indexPath.row].color
        cell.textLabel.text = String(indexPath.item)
        return cell
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

}
