//
//  ViewController.swift
//  Example
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit
import PrettyWaterfallCollectionViewLayout

fileprivate typealias SizeAndColor = (size: CGSize, color: UIColor)

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties
    fileprivate lazy var data: [SizeAndColor] = {
        var data: [SizeAndColor] = []
        (0..<100).forEach({ (_) in
            let randomSize = CGSize.random(lower: 120, upper: 600)
            let randomColor = UIColor.random()
            let sizeAndColor = SizeAndColor(size: randomSize, color: randomColor)
            data.append(sizeAndColor)
        })
        return data
    }()
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath) as! ColoredCell
        cell.backgroundColor = data[indexPath.row].color
        cell.textLabel.text = String(indexPath.item)
        return cell
    }
}

extension ViewController: PrettyWaterfallCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize {
        return data[indexPath.row].size
    }

}
