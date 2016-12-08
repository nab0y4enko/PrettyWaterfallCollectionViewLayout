//
//  ViewController.swift
//  Example
//
//  Created by Oleksii Naboichenko on 12/7/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit

fileprivate typealias SizeAndColor = (size: CGSize, color: UIColor)

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Private Properties
    fileprivate lazy var data: [SizeAndColor] = {
        var data: [SizeAndColor] = []
        (0..<1000).forEach({ (_) in
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
        
        collectionView.collectionViewLayout = Prettt
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath)
        cell.backgroundColor = data[indexPath.row].color
        return cell
    }
}
