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
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, finishCalculateContentSize contentSize: CGSize)
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize

    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, numberOfRowsInSection section: Int) -> Int

    /// Configure Leader
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, widthForLeaderInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, insetsForLeaderInSection section: Int) -> UIEdgeInsets
    
    /// Configure Trailer
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, widthForTrailerInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView?, layout: PrettyHorizontalWaterfallCollectionViewLayout, insetsForTrailerInSection section: Int) -> UIEdgeInsets
}
