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
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
    
    @objc optional func prettyWaterfallCollectionViewLayoutDelegate(_ layout: UICollectionViewLayout, finishCalculateContentSize contentSize: CGSize)
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize

    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
    
    /// Configure Headers
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, insetsForHeaderInSection section: Int) -> UIEdgeInsets
    
    /// Configure Footers
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, insetsForFooterInSection section: Int) -> UIEdgeInsets
}
