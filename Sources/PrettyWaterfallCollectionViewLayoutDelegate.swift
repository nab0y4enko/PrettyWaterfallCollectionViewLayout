//
//  PrettyWaterfallCollectionViewLayoutDelegate.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 2/8/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyWaterfallCollectionViewLayoutDelegate
@objc public protocol PrettyWaterfallCollectionViewLayoutDelegate: AnyObject {
    
    /// Configure Sections
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, numberOfRowsInSection section: Int) -> Int
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, spacingBetweenRowsInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, spacingBetweenColumnsInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
    
    /// Configure Headers
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, heightForHeaderInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, insetsForHeaderInSection section: Int) -> UIEdgeInsets
    
    /// Configure Footers
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, heightForFooterInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, insetsForFooterInSection section: Int) -> UIEdgeInsets
    
    /// Configure Leader
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, widthForLeaderInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, insetsForLeaderInSection section: Int) -> UIEdgeInsets
    
    /// Configure Trailer
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, widthForTrailerInSection section: Int) -> CGFloat
    
    @objc optional func prettyWaterfallCollectionViewLayout(_ layout: PrettyWaterfallCollectionViewLayout, insetsForTrailerInSection section: Int) -> UIEdgeInsets
    
    /// Finished some actions
    @objc optional func prettyWaterfallCollectionViewLayoutDelegate(_ layout: PrettyWaterfallCollectionViewLayout, finishCalculateContentSize contentSize: CGSize)
}
