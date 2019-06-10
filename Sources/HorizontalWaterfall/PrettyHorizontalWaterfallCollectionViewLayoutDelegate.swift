//
//  PrettyHorizontalWaterfallCollectionViewLayoutDelegate.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 6/7/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyHorizontalWaterfallCollectionViewLayoutDelegate
@objc public protocol PrettyHorizontalWaterfallCollectionViewLayoutDelegate: UICollectionViewDelegate {
    
    /// Main Parameters
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
    
    @objc optional func prettyWaterfallCollectionViewLayoutDelegate(_ layout: UICollectionViewLayout, finishCalculateContentSize contentSize: CGSize)
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize

    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int

    /// Configure Leader
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, widthForLeaderInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, insetsForLeaderInSection section: Int) -> UIEdgeInsets
    
    /// Configure Trailer
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, widthForTrailerInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: UICollectionViewLayout, insetsForTrailerInSection section: Int) -> UIEdgeInsets
}
