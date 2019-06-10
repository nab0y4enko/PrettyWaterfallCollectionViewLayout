//
//  PrettyHorizontalWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 2/7/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyHorizontalWaterfallCollectionViewLayout
open class PrettyHorizontalWaterfallCollectionViewLayout: UICollectionViewLayout {

    public struct ElementKind {
        public static let sectionLeader = "PrettyHorizontalWaterfallCollectionViewLayoutElementKindSectionLeader"
        public static let sectionTrailer = "PrettyHorizontalWaterfallCollectionViewLayoutElementKindSectionTrailer"
    }
    
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

    @IBInspectable public var itemReferenceSize: CGSize = CGSize(width: 1, height: 1)
    
    @IBInspectable public var numberOfRows: Int = 1
    
    @IBInspectable public var spacingBetweenRows: CGFloat = 0
    
    @IBInspectable public var spacingBetweenColumns: CGFloat = 0
    
    public var sectionInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var leaderWidth: CGFloat = 0
    
    public var leaderInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var trailerWidth: CGFloat = 0
    
    public var trailerInsets: UIEdgeInsets = UIEdgeInsets()
    
    public var contentSize: CGSize = CGSize() {
        didSet {
            if contentSize != oldValue {
                delegate?.collectionView?(collectionView, layout: self, finishCalculateContentSize: contentSize)
            }
        }
    }
    
    // MARK: - Private Properties
    private var delegate: PrettyHorizontalWaterfallCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? PrettyHorizontalWaterfallCollectionViewLayoutDelegate
    }
    
    private var allElementsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var leadersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var trailersLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    // MARK: - Deinitializer
    deinit {
        cleanCalculatedInfo()
    }
    
    // MARK: - UICollectionViewLayout methods overriding
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.bounds.height != newBounds.height
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
        case ElementKind.sectionLeader:
            return leadersLayoutAttributes[indexPath.section]
        case ElementKind.sectionTrailer:
            return trailersLayoutAttributes[indexPath.section]
        default:
            print("Indefinite name of kind")
            return nil
        }
    }
    
    // MARK: - Private Methods
    private func cleanCalculatedInfo() {
        allElementsLayoutAttributes.removeAll()
        itemsLayoutAttributes.removeAll()
        leadersLayoutAttributes.removeAll()
        trailersLayoutAttributes.removeAll()
        contentSize = .zero
    }
    
    private func insets(forSection section: Int) -> UIEdgeInsets {
        return delegate?.collectionView?(collectionView, layout: self, insetsForSection: section) ?? sectionInsets
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView?.numberOfItems(inSection: section) ?? 0
    }
    
    private func numberOfRows(inSection section: Int) -> Int {
        return delegate?.collectionView?(collectionView, layout: self, numberOfRowsInSection: section) ?? numberOfRows
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
    
    // MARK: - Leadings data
    private func widthForLeaderInSection(_ section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView, layout: self, widthForLeaderInSection: section) ?? leaderWidth
    }
    
    private func insetsForLeaderInSection(_ section: Int) -> UIEdgeInsets {
        return delegate?.collectionView?(collectionView, layout: self, insetsForLeaderInSection: section) ?? leaderInsets
    }
    
    // MARK: - Trailers data
    private func widthForTrailerInSection(_ section: Int) -> CGFloat {
        return delegate?.collectionView?(collectionView, layout: self, widthForTrailerInSection: section) ?? trailerWidth
    }
    
    private func insetsForTrailerInSection(_ section: Int) -> UIEdgeInsets {
        return delegate?.collectionView?(collectionView, layout: self, insetsForTrailerInSection: section) ?? trailerInsets
    }
}
