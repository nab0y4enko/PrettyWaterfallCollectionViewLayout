//
//  PrettyWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 12/8/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import Foundation
import CoreGraphics

@objc public protocol PrettyWaterfallCollectionViewLayoutDelegate: UICollectionViewDelegate {
    
    /// Configure Sections
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForItemAt indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumColumnSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAt section: Int) -> UIEdgeInsets
    
    /// Configure Headers
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForHeaderAt section: Int) -> UIEdgeInsets
    
    /// Configure Footers
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForFooterAt section: Int) -> UIEdgeInsets
}

public let PrettyWaterfallCollectionElementKindSectionHeader = "PrettyWaterfallCollectionElementKindSectionHeader"
public let PrettyWaterfallCollectionElementKindSectionFooter = "PrettyWaterfallCollectionElementKindSectionFooter"

public struct PrettyWaterfallCollectionViewLayoutOptionSet: OptionSet {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let shortestFirst = PrettyWaterfallCollectionViewLayoutOptionSet(rawValue: 1 << 0)
    public static let leftToRight = PrettyWaterfallCollectionViewLayoutOptionSet(rawValue: 1 << 1)      //in prior
    public static let rightToLeft = PrettyWaterfallCollectionViewLayoutOptionSet(rawValue: 1 << 2)
}

public final class PrettyWaterfallCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: - Public Properties
    public var itemRenderDirectionOptions: PrettyWaterfallCollectionViewLayoutOptionSet = []
    
    @IBInspectable public var numberOfColumns: Int = 1
    
    @IBInspectable public var itemReferenceSize: CGSize = CGSize(width: 1, height: 1)
    
    @IBInspectable public var minimumColumnSpacing: CGFloat = 0
    
    @IBInspectable public var minimumInteritemSpacing: CGFloat = 0
    
    public var sectionInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var headerReferenceSize: CGSize = CGSize()
    
    public var headerInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var footerReferenceSize: CGSize = CGSize()
    
    public var footerInsets: UIEdgeInsets = UIEdgeInsets()
    
    // MARK: - Private Computed Properties
    fileprivate weak var delegate: PrettyWaterfallCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? PrettyWaterfallCollectionViewLayoutDelegate
    }
    
    private var numberOfSections: Int {
        return collectionView?.numberOfSections ?? 0
    }
    
    // MARK: - Private Properties
    ///Calculated Layout Attributes
    private var allElementsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var headersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var footersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    ///Calculated content size
    private var contentSize: CGSize?
    
    // MARK: - Deinitializer
    deinit {
        clearCalculatedInfo()
    }
    
    // MARK: - UICollectionViewLayout
    public override func invalidateLayout() {
        super.invalidateLayout()
        
        clearCalculatedInfo()
    }
    
    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        clearCalculatedInfo()
    }
    
    public override func prepare() {
        super.prepare()
        
        clearCalculatedInfo()
        
        guard let collectionView = collectionView, numberOfSections > 0 else {
            return
        }
        
        var contentHeight: CGFloat = 0
        
        for section in 0..<numberOfSections {
            
            // Calculate attributes for header
            let headerSize = referenceSize(forHeaderAt: section)
            if headerSize.height > 0 {
                let insets = self.insets(forHeaderAt: section)
                
                ///Calculated width for header
                let width = max(collectionView.bounds.size.width - insets.left - insets.right, 0)
                
                ///indexPath for header
                let indexPath = IndexPath(row: 0, section: section)
                
                //Save header layout attributes
                let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PrettyWaterfallCollectionElementKindSectionHeader, with: indexPath)
                layoutAttributes.frame = CGRect(x: insets.left, y: contentHeight + insets.top, width: width, height: headerSize.height)
                headersLayoutAttributes.append(layoutAttributes)
                allElementsLayoutAttributes.append(layoutAttributes)
                
                //Calculate new content size
                contentHeight += insets.top + headerSize.height + insets.bottom
            }
            
            // Calculate attributes for section
            let numberOfItems = self.numberOfItems(inSection: section)
            if numberOfItems > 0 {
                let sectionInsets = self.insets(forSectionAt: section)
                let sectionWidth = max(collectionView.bounds.size.width - sectionInsets.left - sectionInsets.right, 0)
                let numberOfColumns = self.numberOfColumns(inSection: section)
                let numberOfSpacesBetweenColumns = max(numberOfColumns - 1, 0)
                let minimumColumnSpacing = self.minimumColumnSpacing(forSectionAt: section)
                let minimumInteritemSpacing = self.minimumInteritemSpacing(forSectionAt: section)
                
                ///Array of height values for each column
                var columnHeights = Array(repeating: CGFloat(0), count: numberOfColumns)
                
                for item in 0..<numberOfItems {
                    //indexPath for item
                    let indexPath = IndexPath(item: item, section: section)
                    
                    //Identify column number for item
                    let column = self.column(forItemAt: item, columnHeights: columnHeights, options: itemRenderDirectionOptions)
                    
                    //Add interitem space if need
                    if columnHeights[column] > 0.0 {
                        columnHeights[column] += minimumInteritemSpacing
                    }
                    
                    //Calculate width for item
                    let width = (sectionWidth - (CGFloat(numberOfSpacesBetweenColumns) * minimumColumnSpacing)) / CGFloat(numberOfColumns)
                    
                    //Calculate x origin for item
                    let x = sectionInsets.left + (width + minimumColumnSpacing) * CGFloat(column)
                    
                    //Calculate height for item
                    let referenceSize = self.referenceSize(forItemAt: indexPath)
                    let height = referenceSize.width > 0 ? referenceSize.height * width / referenceSize.width : 0.0
                    
                    //Calculate x origin for item
                    let y = contentHeight + sectionInsets.top + columnHeights[column]
                    
                    //Save item layout attributes
                    let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    layoutAttributes.frame = CGRect(x: x, y: y, width: width, height: height)
                    itemsLayoutAttributes.append(layoutAttributes)
                    allElementsLayoutAttributes.append(layoutAttributes)
                    
                    //Increment new height for column
                    columnHeights[column] += height
                }
                
                //Calculate new content size
                if let maxColumnHeight = columnHeights.max() {
                    contentHeight += sectionInsets.top + maxColumnHeight + sectionInsets.bottom
                }
            }
            
            /// Calculate attributes for footer
            let footerSize = referenceSize(forFooterAt: section)
            if footerSize.height > 0 {
                let insets = self.insets(forFooterAt: section)
                
                //Calculate width for footer
                let width = max(collectionView.bounds.size.width - insets.left - insets.right, 0)
                
                //indexPath for footer
                let indexPath = IndexPath(row: 0, section: section)
                
                //Save footer layout attributes
                let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PrettyWaterfallCollectionElementKindSectionFooter, with: indexPath)
                layoutAttributes.frame = CGRect(x: insets.left, y: contentHeight + insets.top, width: width, height: footerSize.height)
                footersLayoutAttributes.append(layoutAttributes)
                allElementsLayoutAttributes.append(layoutAttributes)
                
                //Calculate new content size
                contentHeight += insets.top + footerSize.height + insets.bottom
            }
        }
        
        //Save new content size
        contentSize = CGSize(width: collectionView.bounds.width, height: contentHeight)
    }
    
    public override var collectionViewContentSize: CGSize {
        return contentSize ?? CGSize()
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let elementsLayoutAttributes = allElementsLayoutAttributes.filter { (elementLayoutAttributes) -> Bool in
            return elementLayoutAttributes.frame.intersects(rect)
        }
        return elementsLayoutAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemLayoutAttributes = itemsLayoutAttributes.first(where: { (itemLayoutAttributes) -> Bool in
            itemLayoutAttributes.indexPath == indexPath
        })
        return itemLayoutAttributes
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case PrettyWaterfallCollectionElementKindSectionHeader:
            return headersLayoutAttributes[indexPath.section]
        case PrettyWaterfallCollectionElementKindSectionFooter:
            return headersLayoutAttributes[indexPath.section]
        default:
            print("indefinite name of kind")
            return nil
        }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldWidth = collectionView?.bounds.width {
            return oldWidth != newBounds.width
        }
        
        return false
    }
    
    // MARK: - Private Instance Methods
    private func clearCalculatedInfo() {
        allElementsLayoutAttributes.removeAll()
        headersLayoutAttributes.removeAll()
        itemsLayoutAttributes.removeAll()
        footersLayoutAttributes.removeAll()
        contentSize = nil
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView?.numberOfItems(inSection: section) ?? 0
    }
    
    private func column(forItemAt item: Int, columnHeights: [CGFloat], options: PrettyWaterfallCollectionViewLayoutOptionSet) -> Int {
        let numberOfColumns = columnHeights.count
        
        guard numberOfColumns > 0 else {
            return 0
        }
        
        if itemRenderDirectionOptions.contains(.shortestFirst) == false {
            if itemRenderDirectionOptions.contains(.rightToLeft) {
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
            
            if itemRenderDirectionOptions.contains(.rightToLeft) {
                return minHeightIndexes.last ?? 0
            } else {
                return minHeightIndexes.first ?? 0
            }
        }
    }
}

extension PrettyWaterfallCollectionViewLayout {
    
    // MARK: - Sections data
    
    fileprivate func numberOfColumns(inSection section: Int) -> Int {
        if let collectionView = collectionView, let delegate = delegate {
            if let numberOfColumns = delegate.collectionView?(collectionView, layout: self, numberOfColumnsInSection: section) {
                return max(numberOfColumns, 0)
            }
        }
        
        return numberOfColumns
    }

    fileprivate func referenceSize(forItemAt indexPath: IndexPath) -> CGSize {
        if let collectionView = collectionView, let delegate = delegate {
            if let itemReferenceSize = delegate.collectionView?(collectionView, layout: self, referenceSizeForItemAt: indexPath) {
                return itemReferenceSize
            }
        }
        
        return itemReferenceSize
    }
    
    fileprivate func minimumColumnSpacing(forSectionAt section: Int) -> CGFloat {
        if let collectionView = collectionView, let delegate = delegate {
            if let minimumColumnSpacing = delegate.collectionView?(collectionView, layout: self, minimumColumnSpacingForSectionAt: section) {
                return minimumColumnSpacing
            }
        }
        
        return minimumColumnSpacing
    }
    
    fileprivate func minimumInteritemSpacing(forSectionAt section: Int) -> CGFloat {
        if let collectionView = collectionView, let delegate = delegate {
            if let minimumInteritemSpacing = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
                return minimumInteritemSpacing
            }
        }
        
        return minimumInteritemSpacing
    }
    
    fileprivate func insets(forSectionAt section: Int) -> UIEdgeInsets {
        if let collectionView = collectionView, let delegate = delegate {
            if let sectionInsets = delegate.collectionView?(collectionView, layout: self, insetsForSectionAt: section) {
                return sectionInsets
            }
        }
        
        return sectionInsets
    }
}

extension PrettyWaterfallCollectionViewLayout {
    
    // MARK: - Headers data
    fileprivate func referenceSize(forHeaderAt section: Int) -> CGSize {
        if let collectionView = collectionView, let delegate = delegate {
            if let headerSize = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
                return headerSize
            }
        }
        
        return headerReferenceSize
    }
    
    fileprivate func insets(forHeaderAt section: Int) -> UIEdgeInsets {
        if let collectionView = collectionView, let delegate = delegate {
            if let headerInsets = delegate.collectionView?(collectionView, layout: self, insetsForHeaderAt: section) {
                return headerInsets
            }
        }
        
        return headerInsets
    }
}

extension PrettyWaterfallCollectionViewLayout {
    
    // MARK: - Footers data
    fileprivate func referenceSize(forFooterAt section: Int) -> CGSize {
        if let collectionView = collectionView, let delegate = delegate {
            if let footerSize = delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
                return footerSize
            }
        }
        
        return footerReferenceSize
    }
    
    fileprivate func insets(forFooterAt section: Int) -> UIEdgeInsets {
        if let collectionView = collectionView, let delegate = delegate {
            if let footerInsets = delegate.collectionView?(collectionView, layout: self, insetsForFooterAt: section) {
                return footerInsets
            }
        }
        
        return footerInsets
    }
}
