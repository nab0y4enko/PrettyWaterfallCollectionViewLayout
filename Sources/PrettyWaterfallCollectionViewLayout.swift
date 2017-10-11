//
//  PrettyWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyWaterfallCollectionViewLayoutDelegate
@objc public protocol PrettyWaterfallCollectionViewLayoutDelegate: class {

    /// Configure Sections
    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, columnSpacingForSection section: Int) -> CGFloat

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets

    /// Configure Headers
    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, headerHeightForSection section: Int) -> CGFloat

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, headerInsetsForSection section: Int) -> UIEdgeInsets

    /// Configure Footers
    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, footerHeightForSection section: Int) -> CGFloat

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, footerInsetsForSection section: Int) -> UIEdgeInsets

    @objc optional func prettyWaterfallCollectionViewLayout(_ prettyWaterfallCollectionViewLayout: PrettyWaterfallCollectionViewLayout, didCalculate contentSize: CGSize)
}

// MARK: - PrettyWaterfallCollectionViewLayout
open class PrettyWaterfallCollectionViewLayout: UICollectionViewLayout {

    // MARK: - ElementKind
    public struct ElementKind {
        public static let sectionHeader = "PrettyWaterfallCollectionElementKindSectionHeader"
        public static let sectionFooter = "PrettyWaterfallCollectionElementKindSectionFooter"
    }

    // MARK: - RenderDirection
    public struct RenderDirection: OptionSet {
        public var rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let shortestFirst = RenderDirection(rawValue: 1 << 0)
        public static let leftToRight = RenderDirection(rawValue: 1 << 1)   //by default
        public static let rightToLeft = RenderDirection(rawValue: 1 << 2)
    }

    // MARK: - Public Properties
    public var renderDirection: RenderDirection = [.shortestFirst]

    @IBInspectable public var itemReferenceSize: CGSize = CGSize(width: 1, height: 1)

    @IBInspectable public var numberOfColumns: Int = 1

    @IBInspectable public var columnSpacing: CGFloat = 0

    @IBInspectable public var interitemSpacing: CGFloat = 0

    public var sectionInsets: UIEdgeInsets = UIEdgeInsets()

    @IBInspectable public var headerHeight: CGFloat = 0

    public var headerInsets: UIEdgeInsets = UIEdgeInsets()

    @IBInspectable public var footerHeight: CGFloat = 0

    public var footerInsets: UIEdgeInsets = UIEdgeInsets()

    // MARK: - Private Computed Properties
    private var delegate: PrettyWaterfallCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? PrettyWaterfallCollectionViewLayoutDelegate
    }

    // MARK: - Private Properties
    private var allElementsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var headersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var footersLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    private var contentSize: CGSize = CGSize()

    // MARK: - Deinitializer
    deinit {
        cleanCalculatedInfo()
    }

    // MARK: - UICollectionViewLayout
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
            let headerHeight = self.headerHeight(forSection: section)
            if headerHeight > 0 {
                let headerInsets = self.headerInsets(forSection: section)

                ///Calculated width for header
                let headerWidth = max(collectionViewSize.width - headerInsets.left - headerInsets.right, 0)

                ///indexPath for header
                let headerIndexPath = IndexPath(row: 0, section: section)

                //Save header layout attributes
                let headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PrettyWaterfallCollectionViewLayout.ElementKind.sectionHeader, with: headerIndexPath)
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
                let interitemSpacing = self.interitemSpacing(forSection: section)

                ///Array of height values for each column
                var columnHeights = Array(repeating: CGFloat(0), count: numberOfColumns)

                for item in 0..<numberOfItems {
                    //Identify column number for item
                    let column = self.column(forItem: item, columnHeights: columnHeights, renderDirection: renderDirection)

                    //Add interitem space if need
                    if columnHeights[column] > 0 {
                        columnHeights[column] += interitemSpacing
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
            let footerHeight = self.footerHeight(forSection: section)
            if footerHeight > 0 {
                let footerInsets = self.footerInsets(forSection: section)

                ///Calculated width for header
                let footerWidth = max(collectionViewSize.width - footerInsets.left - footerInsets.right, 0)

                ///indexPath for header
                let footerIndexPath = IndexPath(row: 0, section: section)

                //Save header layout attributes
                let footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PrettyWaterfallCollectionViewLayout.ElementKind.sectionFooter, with: footerIndexPath)
                footerLayoutAttributes.frame = CGRect(x: footerInsets.left, y: contentHeight + footerInsets.top, width: footerWidth, height: footerHeight)
                footersLayoutAttributes.append(footerLayoutAttributes)
                allElementsLayoutAttributes.append(footerLayoutAttributes)

                //Calculate new content size
                contentHeight += footerInsets.top + footerHeight + footerInsets.bottom
            }
        }

        //Save new content size
        contentSize = CGSize(width: collectionViewSize.width, height: contentHeight)

        //Notify delegate for end calculating
        delegate?.prettyWaterfallCollectionViewLayout?(self, didCalculate: contentSize)
    }

    open override var collectionViewContentSize: CGSize {
        return contentSize
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let elementsLayoutAttributes = allElementsLayoutAttributes.filter { (elementLayoutAttributes) -> Bool in
            return elementLayoutAttributes.frame.intersects(rect)
        }
        return elementsLayoutAttributes
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemLayoutAttributes = itemsLayoutAttributes.first(where: { (itemLayoutAttributes) -> Bool in
            itemLayoutAttributes.indexPath == indexPath
        })
        return itemLayoutAttributes
    }

    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case PrettyWaterfallCollectionViewLayout.ElementKind.sectionHeader:
            return headersLayoutAttributes[indexPath.section]
        case PrettyWaterfallCollectionViewLayout.ElementKind.sectionFooter:
            return footersLayoutAttributes[indexPath.section]
        default:
            print("Indefinite name of kind")
            return nil
        }
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldWidth = collectionView?.bounds.width {
            return oldWidth != newBounds.width
        }

        return false
    }

    // MARK: - Private Instance Methods
    private func cleanCalculatedInfo() {
        allElementsLayoutAttributes.removeAll()
        headersLayoutAttributes.removeAll()
        itemsLayoutAttributes.removeAll()
        footersLayoutAttributes.removeAll()
        contentSize = CGSize()
    }

    // MARK: - Sections data
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView?.numberOfItems(inSection: section) ?? 0
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

    private func numberOfColumns(inSection section: Int) -> Int {
        if let numberOfColumns = delegate?.prettyWaterfallCollectionViewLayout?(self, numberOfColumnsInSection: section) {
            return numberOfColumns
        }

        return numberOfColumns
    }

    private func referenceSize(forItemAt indexPath: IndexPath) -> CGSize {
        if let itemReferenceSize = delegate?.prettyWaterfallCollectionViewLayout?(self, referenceSizeForItemAt: indexPath) {
            return itemReferenceSize
        }

        return itemReferenceSize
    }

    private func columnSpacing(forSection section: Int) -> CGFloat {
        if let columnSpacing = delegate?.prettyWaterfallCollectionViewLayout?(self, columnSpacingForSection: section) {
            return columnSpacing
        }

        return columnSpacing
    }

    private func interitemSpacing(forSection section: Int) -> CGFloat {
        if let interitemSpacing = delegate?.prettyWaterfallCollectionViewLayout?(self, interitemSpacingForSection: section) {
            return interitemSpacing
        }

        return interitemSpacing
    }

    private func insets(forSection section: Int) -> UIEdgeInsets {
        if let sectionInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, insetsForSection: section) {
            return sectionInsets
        }

        return sectionInsets
    }

    // MARK: - Headers data
    fileprivate func headerHeight(forSection section: Int) -> CGFloat {
        if let headerHeight = delegate?.prettyWaterfallCollectionViewLayout?(self, headerHeightForSection: section) {
            return headerHeight
        }

        return headerHeight
    }

    fileprivate func headerInsets(forSection section: Int) -> UIEdgeInsets {
        if let headerInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, headerInsetsForSection: section) {
            return headerInsets
        }

        return headerInsets
    }

    // MARK: - Footers data
    fileprivate func footerHeight(forSection section: Int) -> CGFloat {
        if let footerHeight = delegate?.prettyWaterfallCollectionViewLayout?(self, footerHeightForSection: section) {
            return footerHeight
        }

        return footerHeight
    }

    fileprivate func footerInsets(forSection section: Int) -> UIEdgeInsets {
        if let footerInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, footerInsetsForSection: section) {
            return footerInsets
        }

        return footerInsets
    }
}
