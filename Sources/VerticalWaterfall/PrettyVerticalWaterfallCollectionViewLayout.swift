//
//  PrettyVerticalWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyVerticalWaterfallCollectionViewLayout
open class PrettyVerticalWaterfallCollectionViewLayout: UICollectionViewLayout {

    public struct ElementKind {
        public static let sectionHeader = "PrettyWaterfallCollectionViewLayoutElementKindSectionHeader"
        public static let sectionFooter = "PrettyWaterfallCollectionViewLayoutElementKindSectionFooter"
    }
    
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

    @IBInspectable public var itemReferenceSize: CGSize = CGSize(width: 1, height: 1)
        
    @IBInspectable public var numberOfColumns: Int = 1
    
    @IBInspectable public var spacingBetweenRows: CGFloat = 0
    
    @IBInspectable public var spacingBetweenColumns: CGFloat = 0
    
    public var sectionInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var headerHeight: CGFloat = 0
    
    public var headerInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var footerHeight: CGFloat = 0
    
    public var footerInsets: UIEdgeInsets = UIEdgeInsets()
    
    var contentSize: CGSize = CGSize() {
        didSet {
            if contentSize != oldValue {
                delegate?.collectionView?(collectionView, layout: self, finishCalculateContentSize: contentSize)
            }
        }
    }
    
    // MARK: - Private Properties
    var delegate: PrettyVerticalWaterfallCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? PrettyVerticalWaterfallCollectionViewLayoutDelegate
    }
    
    private var allElementsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var headersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var footersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    // MARK: - Deinitializer
    deinit {
        cleanCalculatedInfo()
    }
    
    // MARK: - UICollectionViewLayout methods overriding
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.bounds.width != newBounds.width
    }
    
    open override func invalidateLayout() {
        super.invalidateLayout()
        
        cleanCalculatedInfo()
    }
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        cleanCalculatedInfo()
    }
    
    open override func prepare() {
        super.prepare()

        cleanCalculatedInfo()
        
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

    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return allElementsLayoutAttributes.filter {
            $0.frame.intersects(rect)
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemsLayoutAttributes.first {
            $0.indexPath == indexPath
        }
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case ElementKind.sectionHeader:
            return headersLayoutAttributes[indexPath.section]
        case ElementKind.sectionFooter:
            return footersLayoutAttributes[indexPath.section]
        default:
            print("Indefinite name of kind")
            return nil
        }
    }
    
    // MARK: - Private Methods
    private func cleanCalculatedInfo() {
        allElementsLayoutAttributes.removeAll()
        itemsLayoutAttributes.removeAll()
        headersLayoutAttributes.removeAll()
        footersLayoutAttributes.removeAll()
        contentSize = .zero
    }
    
    /// Sections data
    private func insets(forSection section: Int) -> UIEdgeInsets {
        return delegate?.collectionView?(collectionView, layout: self, insetsForSection: section) ?? sectionInsets
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView?.numberOfItems(inSection: section) ?? 0
    }
    
    private func numberOfColumns(inSection section: Int) -> Int {
        return delegate?.collectionView?(collectionView, layout: self, numberOfColumnsInSection: section) ?? numberOfColumns
    }
    
    private func rowSpacing(forSection section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView, layout: self, spacingBetweenRowsInSection: section) ?? spacingBetweenRows
    }
    
    private func columnSpacing(forSection section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView, layout: self, spacingBetweenColumnsInSection: section) ?? spacingBetweenColumns
    }
    
    private func referenceSize(forItemAt indexPath: IndexPath) -> CGSize {
        return delegate?.collectionView?(collectionView, layout: self, referenceSizeForItemAt: indexPath) ?? itemReferenceSize
    }
    
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
    
    /// Headers data
    private func heightForHeaderInSection(_ section: Int) -> CGFloat {
        if let headerHeight = delegate?.collectionView?(collectionView, layout: self, heightForHeaderInSection: section) {
            return headerHeight
        }
        
        return headerHeight
    }
    
    private func insetsForHeaderInSection(_ section: Int) -> UIEdgeInsets {
        if let headerInsets = delegate?.collectionView?(collectionView, layout: self, insetsForHeaderInSection: section) {
            return headerInsets
        }
        
        return headerInsets
    }
    
    /// Footers data
    private func heightForFooterInSection(_ section: Int) -> CGFloat {
        if let footerHeight = delegate?.collectionView?(collectionView, layout: self, heightForFooterInSection: section) {
            return footerHeight
        }
        
        return footerHeight
    }
    
    private func footerForHeaderInSection(_ section: Int) -> UIEdgeInsets {
        if let footerInsets = delegate?.collectionView?(collectionView, layout: self, insetsForFooterInSection: section) {
            return footerInsets
        }
        
        return footerInsets
    }
    
}
