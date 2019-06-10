//
//  PrettyVerticalWaterfallCollectionViewLayoutDelegate.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 6/7/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyVerticalWaterfallCollectionViewLayoutDelegate
@objc public protocol PrettyVerticalWaterfallCollectionViewLayoutDelegate: UICollectionViewDelegate {
   
    /// Main Parameters
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, finishCalculateContentSize contentSize: CGSize)
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize

    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
    
    /// Configure Headers
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, insetsForHeaderInSection section: Int) -> UIEdgeInsets
    
    /// Configure Footers
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyVerticalWaterfallCollectionViewLayout, insetsForFooterInSection section: Int) -> UIEdgeInsets
}
