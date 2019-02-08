//
//  PrettyHorizontalWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 2/7/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyHorizontalWaterfallCollectionViewLayout
open class PrettyHorizontalWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout {

    // MARK: - RenderDirection
    public struct RenderDirection: OptionSet {
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let shortestFirst = RenderDirection(rawValue: 1 << 0)
        public static let topToBottom = RenderDirection(rawValue: 1 << 1)
        public static let bottomToTop = RenderDirection(rawValue: 1 << 2)
    }

    // MARK: - Public Properties
    public var renderDirection: RenderDirection = [.topToBottom]

    // MARK: - UICollectionViewLayout methods overriding
    open override func prepare() {
        super.prepare()
                
        guard let collectionViewSize = collectionView?.bounds.size, collectionViewSize.width > 0, collectionViewSize.height > 0 else {
            return
        }
        
        guard let numberOfSections = collectionView?.numberOfSections, numberOfSections > 0 else {
            return
        }
        
        var contentWidth: CGFloat = 0
        
        for section in 0..<numberOfSections {
            
            // Calculate attributes for leader
            let leaderWidth = self.widthForLeaderInSection(section)
            if leaderWidth > 0 {
                let leaderInsets = self.insetsForLeaderInSection(section)
                
                ///Calculate height for leader
                let leaderHeight = max(collectionViewSize.height - leaderInsets.top - leaderInsets.bottom, 0)
                
                ///IndexPath for leader
                let leaderIndexPath = IndexPath(row: 0, section: section)
                
                //Save leader layout attributes
                let leaderLayoutAttributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: PrettyHorizontalWaterfallCollectionViewLayout.ElementKind.sectionLeader,
                    with: leaderIndexPath
                )
                leaderLayoutAttributes.frame = CGRect(x: contentWidth + leaderInsets.left, y: leaderInsets.top, width: leaderWidth, height: leaderHeight)
                leadersLayoutAttributes.append(leaderLayoutAttributes)
                allElementsLayoutAttributes.append(leaderLayoutAttributes)
                
                //Calculate new content size
                contentWidth += leaderInsets.right + leaderWidth + leaderInsets.left
            }
            
            // Calculate attributes for section
            let sectionInsets = self.insets(forSection: section)
            let numberOfItems = self.numberOfItems(inSection: section)
            let numberOfRows = self.numberOfRows(inSection: section)
            if numberOfItems > 0, numberOfRows > 0 {
                let sectionHeight = max(collectionViewSize.height - sectionInsets.top - sectionInsets.bottom, 0)
                let numberOfSpacesBetweenRows = max(numberOfRows - 1, 0)
                let rowSpacing = self.rowSpacing(forSection: section)
                let columnSpacing = self.columnSpacing(forSection: section)
                
                ///Array of height values for each row
                var rowWidths = Array(repeating: CGFloat(0), count: numberOfRows)
                
                for item in 0..<numberOfItems {
                    //Identify row number for item
                    let row = self.row(forItem: item, rowWidths: rowWidths)
                    
                    //Add interitem space if need
                    if rowWidths[row] > 0 {
                        rowWidths[row] += columnSpacing
                    }
                    
                    //Calculate height for item
                    let itemHeight = (sectionHeight - (CGFloat(numberOfSpacesBetweenRows) * rowSpacing)) / CGFloat(numberOfRows)
                    
                    //Calculate y origin for item
                    let y = sectionInsets.top + (itemHeight + rowSpacing) * CGFloat(row)

                    //Calculate height for item
                    let itemIndexPath = IndexPath(item: item, section: section)
                    
                    let itemReferenceSize = self.referenceSize(forItemAt: itemIndexPath)
                    let itemWidth = itemReferenceSize.height > 0 ? itemReferenceSize.width * itemHeight / itemReferenceSize.height : 0
                    
                    //Calculate x origin for item
                    let x = rowWidths[row] + sectionInsets.right + contentWidth
                    
                    //Save item layout attributes
                    let itemLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
                    itemLayoutAttributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
                    itemsLayoutAttributes.append(itemLayoutAttributes)
                    allElementsLayoutAttributes.append(itemLayoutAttributes)
                    
                    //Increment new height for row
                    rowWidths[row] += itemWidth
                }
                
                //Calculate new content size
                if let maxRowWidth = rowWidths.max() {
                    contentWidth += sectionInsets.right + maxRowWidth + sectionInsets.left
                }
            } else {
                contentWidth += sectionInsets.right + sectionInsets.left
            }
            
            /// Calculate attributes for trailer
            let trailerWidth = self.widthForTrailerInSection(section)
            if trailerWidth > 0 {
                let trailerInsets = self.insetsForTrailerInSection(section)
                
                ///Calculate width for trailer
                let trailerHeight = max(collectionViewSize.height - trailerInsets.top - trailerInsets.bottom, 0)
                
                ///IndexPath for trailer
                let trailerIndexPath = IndexPath(row: 0, section: section)
                
                //Save trailer layout attributes
                let trailerLayoutAttributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: PrettyHorizontalWaterfallCollectionViewLayout.ElementKind.sectionTrailer,
                    with: trailerIndexPath
                )
                trailerLayoutAttributes.frame = CGRect(x: contentWidth + trailerInsets.left, y: trailerInsets.top, width: trailerWidth, height: trailerHeight)
                trailersLayoutAttributes.append(trailerLayoutAttributes)
                allElementsLayoutAttributes.append(trailerLayoutAttributes)
                
                //Calculate new content size
                contentWidth += trailerInsets.right + trailerWidth + trailerInsets.left
            }
        }
        
        //Save new content size
        contentSize = CGSize(width: contentWidth, height: collectionViewSize.height)
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldWidth = collectionView?.bounds.height {
            return oldWidth != newBounds.height
        }
        
        return false
    }
    
    // MARK: - Private Instance Methods
    private func row(forItem item: Int, rowWidths: [CGFloat]) -> Int {
        let numberOfRows = rowWidths.count

        guard numberOfRows > 0 else {
            return 0
        }
    
        if renderDirection.contains(.shortestFirst) == false {
            if renderDirection.contains(.bottomToTop) {
                return numberOfRows - 1 - item%numberOfRows
            } else {
                return item%numberOfRows
            }
        } else {
            //find min width in row
            let minHeight = rowWidths.min() ?? 0
            
            //find all rows with min width
            var minWidthIndexes: [Int] = []
            for columnIndex in 0..<numberOfRows {
                if rowWidths[columnIndex] == minHeight {
                    minWidthIndexes.append(columnIndex)
                }
            }
            
            if renderDirection.contains(.bottomToTop) {
                return minWidthIndexes.last ?? 0
            } else {
                return minWidthIndexes.first ?? 0
            }
        }
    }
}
