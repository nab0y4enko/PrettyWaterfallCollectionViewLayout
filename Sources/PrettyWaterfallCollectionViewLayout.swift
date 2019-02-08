//
//  PrettyWaterfallCollectionViewLayout.swift
//  PrettyWaterfallCollectionViewLayout
//
//  Created by Oleksii Naboichenko on 2/8/19.
//  Copyright © 2019 Oleksii Naboichenko. All rights reserved.
//

import UIKit

// MARK: - PrettyWaterfallCollectionViewLayout
open class PrettyWaterfallCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: - PrettyWaterfallCollectionViewLayoutElementKind
    public struct ElementKind {
        public static let sectionHeader = "PrettyWaterfallCollectionViewLayoutElementKindSectionHeader"
        public static let sectionFooter = "PrettyWaterfallCollectionViewLayoutElementKindSectionFooter"
        public static let sectionLeader = "PrettyWaterfallCollectionViewLayoutElementKindSectionLeader"
        public static let sectionTrailer = "PrettyWaterfallCollectionViewLayoutElementKindSectionTrailer"
    }

    // MARK: - Public Properties
    // Layout properties
    @IBInspectable public var itemReferenceSize: CGSize = CGSize(width: 1, height: 1)
    
    @IBInspectable public var numberOfRows: Int = 1
    
    @IBInspectable public var numberOfColumns: Int = 1
    
    @IBInspectable public var rowSpacing: CGFloat = 0
    
    @IBInspectable public var columnSpacing: CGFloat = 0
    
    public var sectionInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var headerHeight: CGFloat = 0
    
    public var headerInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var footerHeight: CGFloat = 0
    
    public var footerInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var leaderHeight: CGFloat = 0
    
    public var leaderInsets: UIEdgeInsets = UIEdgeInsets()
    
    @IBInspectable public var trailerHeight: CGFloat = 0
    
    public var trailerInsets: UIEdgeInsets = UIEdgeInsets()

    
    // Calculated data
    var allElementsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    var itemsLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    var headersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    var footersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    var leadersLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    var trailersLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    var contentSize: CGSize = CGSize() {
        didSet {
            if contentSize != oldValue {
                delegate?.prettyWaterfallCollectionViewLayoutDelegate?(self, finishCalculateContentSize: contentSize)
            }
        }
    }
    
    // MARK: - Private Computed Properties
    var delegate: PrettyWaterfallCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? PrettyWaterfallCollectionViewLayoutDelegate
    }
    
    // MARK: - UICollectionViewLayout methods overriding
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
        case PrettyWaterfallCollectionViewLayout.ElementKind.sectionLeader:
            return leadersLayoutAttributes[indexPath.section]
        case PrettyWaterfallCollectionViewLayout.ElementKind.sectionTrailer:
            return trailersLayoutAttributes[indexPath.section]
        default:
            print("Indefinite name of kind")
            return nil
        }
    }
    
    // MARK: - Deinitializer
    deinit {
        cleanCalculatedInfo()
    }
    
    // MARK: - Public Instance Methods
    func numberOfItems(inSection section: Int) -> Int {
        return collectionView?.numberOfItems(inSection: section) ?? 0
    }
    
    func referenceSize(forItemAt indexPath: IndexPath) -> CGSize {
        if let itemReferenceSize = delegate?.prettyWaterfallCollectionViewLayout?(self, referenceSizeForItemAt: indexPath) {
            return itemReferenceSize
        }
        
        return itemReferenceSize
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        if let numberOfRows = delegate?.prettyWaterfallCollectionViewLayout?(self, numberOfRowsInSection: section) {
            return numberOfRows
        }
        
        return numberOfRows
    }
    
    func numberOfColumns(inSection section: Int) -> Int {
        if let numberOfColumns = delegate?.prettyWaterfallCollectionViewLayout?(self, numberOfColumnsInSection: section) {
            return numberOfColumns
        }
        
        return numberOfColumns
    }
    
    func rowSpacing(forSection section: Int) -> CGFloat {
        if let rowSpacing = delegate?.prettyWaterfallCollectionViewLayout?(self, spacingBetweenRowsInSection: section) {
            return rowSpacing
        }
        
        return rowSpacing
    }
    
    func columnSpacing(forSection section: Int) -> CGFloat {
        if let interitemSpacing = delegate?.prettyWaterfallCollectionViewLayout?(self, spacingBetweenColumnsInSection: section) {
            return interitemSpacing
        }
        
        return columnSpacing
    }
    
    func insets(forSection section: Int) -> UIEdgeInsets {
        if let sectionInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, insetsForSection: section) {
            return sectionInsets
        }
        
        return sectionInsets
    }
    
    // MARK: - Headers data
    func heightForHeaderInSection(_ section: Int) -> CGFloat {
        if let headerHeight = delegate?.prettyWaterfallCollectionViewLayout?(self, heightForHeaderInSection: section) {
            return headerHeight
        }
        
        return headerHeight
    }
    
    func insetsForHeaderInSection(_ section: Int) -> UIEdgeInsets {
        if let headerInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, insetsForHeaderInSection: section) {
            return headerInsets
        }
        
        return headerInsets
    }
    
    // MARK: - Footers data
    func heightForFooterInSection(_ section: Int) -> CGFloat {
        if let footerHeight = delegate?.prettyWaterfallCollectionViewLayout?(self, heightForFooterInSection: section) {
            return footerHeight
        }
        
        return footerHeight
    }
    
    func footerForHeaderInSection(_ section: Int) -> UIEdgeInsets {
        if let footerInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, insetsForFooterInSection: section) {
            return footerInsets
        }
        
        return footerInsets
    }
    
    // MARK: - Leader data
    func widthForLeaderInSection(_ section: Int) -> CGFloat {
        if let headerHeight = delegate?.prettyWaterfallCollectionViewLayout?(self, widthForLeaderInSection: section) {
            return headerHeight
        }
        
        return headerHeight
    }
    
    func insetsForLeaderInSection(_ section: Int) -> UIEdgeInsets {
        if let headerInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, insetsForLeaderInSection: section) {
            return headerInsets
        }
        
        return headerInsets
    }
    
    // MARK: - Trailers data
    func widthForTrailerInSection(_ section: Int) -> CGFloat {
        if let footerHeight = delegate?.prettyWaterfallCollectionViewLayout?(self, widthForTrailerInSection: section) {
            return footerHeight
        }
        
        return footerHeight
    }
    
    func insetsForTrailerInSection(_ section: Int) -> UIEdgeInsets {
        if let footerInsets = delegate?.prettyWaterfallCollectionViewLayout?(self, insetsForTrailerInSection: section) {
            return footerInsets
        }
        
        return footerInsets
    }
    
    // MARK: - Private Instance Methods
    private func cleanCalculatedInfo() {
        allElementsLayoutAttributes.removeAll()
        itemsLayoutAttributes.removeAll()
        headersLayoutAttributes.removeAll()
        footersLayoutAttributes.removeAll()
        leadersLayoutAttributes.removeAll()
        trailersLayoutAttributes.removeAll()
        contentSize = CGSize()
    }
}
