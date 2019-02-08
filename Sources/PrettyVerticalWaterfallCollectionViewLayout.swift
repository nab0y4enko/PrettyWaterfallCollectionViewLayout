//
//  PrettyVerticalWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyVerticalWaterfallCollectionViewLayout
open class PrettyVerticalWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout {

    // MARK: - RenderDirection
    public struct RenderDirection: OptionSet {
        public var rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let shortestFirst = RenderDirection(rawValue: 1 << 0)
        public static let leftToRight = RenderDirection(rawValue: 1 << 1)
        public static let rightToLeft = RenderDirection(rawValue: 1 << 2)
    }

    // MARK: - Public Properties
    public var renderDirection: RenderDirection = [.leftToRight]

    // MARK: - UICollectionViewLayout methods overriding
    open override func prepare() {
        super.prepare()

        guard let collectionViewSize = collectionView?.bounds.size, collectionViewSize.width > 0, collectionViewSize.height > 0 else {
            return
        }

        guard let numberOfSections = collectionView?.numberOfSections, numberOfSections > 0 else {
            return
        }

        var contentHeight: CGFloat = 0

        for section in 0..<numberOfSections {

            // Calculate attributes for header
            let headerHeight = self.heightForHeaderInSection(section)
            if headerHeight > 0 {
                let headerInsets = self.insetsForHeaderInSection(section)

                ///Calculate width for header
                let headerWidth = max(collectionViewSize.width - headerInsets.left - headerInsets.right, 0)

                ///indexPath for header
                let headerIndexPath = IndexPath(row: 0, section: section)

                //Save header layout attributes
                let headerLayoutAttributes = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: PrettyVerticalWaterfallCollectionViewLayout.ElementKind.sectionHeader,
                    with: headerIndexPath
                )
                headerLayoutAttributes.frame = CGRect(x: headerInsets.left, y: contentHeight + headerInsets.top, width: headerWidth, height: headerHeight)
                headersLayoutAttributes.append(headerLayoutAttributes)
                allElementsLayoutAttributes.append(headerLayoutAttributes)

                //Calculate new content size
                contentHeight += headerInsets.top + headerHeight + headerInsets.bottom
            }

            // Calculate attributes for section
            let sectionInsets = self.insets(forSection: section)
            let numberOfItems = self.numberOfItems(inSection: section)
            let numberOfColumns = self.numberOfColumns(inSection: section)
            if numberOfItems > 0, numberOfColumns > 0 {
                let sectionWidth = max(collectionViewSize.width - sectionInsets.left - sectionInsets.right, 0)
                let numberOfSpacesBetweenColumns = max(numberOfColumns - 1, 0)
                let columnSpacing = self.columnSpacing(forSection: section)
                let rowSpacing = self.rowSpacing(forSection: section)

                ///Array of height values for each column
                var columnHeights = Array(repeating: CGFloat(0), count: numberOfColumns)

                for item in 0..<numberOfItems {
                    //Identify column number for item
                    let column = self.column(forItem: item, columnHeights: columnHeights, renderDirection: renderDirection)

                    //Add interitem space if need
                    if columnHeights[column] > 0 {
                        columnHeights[column] += rowSpacing
                    }

                    //Calculate width for item
                    let itemWidth = (sectionWidth - (CGFloat(numberOfSpacesBetweenColumns) * columnSpacing)) / CGFloat(numberOfColumns)

                    //Calculate x origin for item
                    let x = sectionInsets.left + (itemWidth + columnSpacing) * CGFloat(column)

                    //Calculate height for item
                    let itemIndexPath = IndexPath(item: item, section: section)

                    let itemReferenceSize = self.referenceSize(forItemAt: itemIndexPath)
                    let itemHeight = itemReferenceSize.width > 0 ? itemReferenceSize.height * itemWidth / itemReferenceSize.width : 0

                    //Calculate x origin for item
                    let y = contentHeight + sectionInsets.top + columnHeights[column]

                    //Save item layout attributes
                    let itemLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
                    itemLayoutAttributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
                    itemsLayoutAttributes.append(itemLayoutAttributes)
                    allElementsLayoutAttributes.append(itemLayoutAttributes)

                    //Increment new height for column
                    columnHeights[column] += itemHeight
                }

                //Calculate new content size
                if let maxColumnHeight = columnHeights.max() {
                    contentHeight += sectionInsets.top + maxColumnHeight + sectionInsets.bottom
                }
            } else {
                contentHeight += sectionInsets.top + sectionInsets.bottom
            }

            /// Calculate attributes for footer
            let footerHeight = self.heightForFooterInSection(section)
            if footerHeight > 0 {
                let footerInsets = self.footerForHeaderInSection(section)

                ///Calculate width for footer
                let footerWidth = max(collectionViewSize.width - footerInsets.left - footerInsets.right, 0)

                ///indexPath for header
                let footerIndexPath = IndexPath(row: 0, section: section)

                //Save footer layout attributes
                let footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PrettyVerticalWaterfallCollectionViewLayout.ElementKind.sectionFooter, with: footerIndexPath)
                footerLayoutAttributes.frame = CGRect(x: footerInsets.left, y: contentHeight + footerInsets.top, width: footerWidth, height: footerHeight)
                footersLayoutAttributes.append(footerLayoutAttributes)
                allElementsLayoutAttributes.append(footerLayoutAttributes)

                //Calculate new content size
                contentHeight += footerInsets.top + footerHeight + footerInsets.bottom
            }
        }

        //Save new content size
        contentSize = CGSize(width: collectionViewSize.width, height: contentHeight)
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldWidth = collectionView?.bounds.width {
            return oldWidth != newBounds.width
        }

        return false
    }
   
    // MARK: - Private Instance Methods
    private func column(forItem item: Int, columnHeights: [CGFloat], renderDirection: RenderDirection) -> Int {
        let numberOfColumns = columnHeights.count

        guard numberOfColumns > 0 else {
            return 0
        }

        if renderDirection.contains(.shortestFirst) == false {
            if renderDirection.contains(.rightToLeft) {
                return numberOfColumns - 1 - item%numberOfColumns
            } else {
                return item%numberOfColumns
            }
        } else {
            //find min height in columns
            let minHeight = columnHeights.min() ?? 0

            //find all columns with min height
            var minHeightIndexes: [Int] = []
            for columnIndex in 0..<numberOfColumns {
                if columnHeights[columnIndex] == minHeight {
                    minHeightIndexes.append(columnIndex)
                }
            }

            if renderDirection.contains(.rightToLeft) {
                return minHeightIndexes.last ?? 0
            } else {
                return minHeightIndexes.first ?? 0
            }
        }
    }
}
