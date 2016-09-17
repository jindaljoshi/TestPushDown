//
//  StickyHeaderFlowLayout.swift
//  D2CAccounts
//
//  Created by Robert Nadin on 17/02/2015.
//  Copyright (c) 2015 Mubaloo. All rights reserved.
//

import UIKit

let StickyHeaderParallaxHeader = "StickyHeaderParallaxHeader"

class StickyHeaderFlowLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // 0 = minimized, 1 = fully expanded, > 1 = stretched
    var progressiveness: CGFloat!
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? StickyHeaderFlowLayoutAttributes {
            if object.progressiveness != progressiveness {
                return false
            }
        }
        return super.isEqual(object)
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! StickyHeaderFlowLayoutAttributes
        copy.progressiveness = progressiveness
        return copy
    }
    
}

class StickyHeaderFlowLayout: UICollectionViewFlowLayout {

    var parallaxHeaderReferenceSize: CGSize!
    var parallaxHeaderMinimumReferenceSize: CGSize!
    var parallaxHeaderAlwaysOnTop: Bool = false
    var disableStickyHeaders: Bool = false
    var workWithHidingNavBar : Bool = false
    
    override func prepareLayout() {
        super.prepareLayout()
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind: String, atIndexPath elementIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind, atIndexPath: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        attributes?.frame.origin.y += self.parallaxHeaderReferenceSize.height
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        if attributes == nil && elementKind == StickyHeaderParallaxHeader {
            attributes = StickyHeaderFlowLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        }
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // The rect should compensate the header size
        var adjustedRect = rect
        adjustedRect.origin.y -= self.parallaxHeaderReferenceSize.height
        
        var allItems = super.layoutAttributesForElementsInRect(adjustedRect)?.map { attribute in
            attribute.copy() as! UICollectionViewLayoutAttributes
        }
        
        var headers = [Int: UICollectionViewLayoutAttributes]()
        var lastCells = [Int: UICollectionViewLayoutAttributes]()
        var visibleParallaxHeader = false
        
        for attributes in allItems! {
            attributes.frame.origin.y += self.parallaxHeaderReferenceSize.height
        
            let indexPath = attributes.indexPath
            if attributes.representedElementKind != nil && attributes.representedElementKind == UICollectionElementKindSectionHeader {
                headers[indexPath.section] = attributes
            } else if attributes.representedElementKind != nil && attributes.representedElementKind == UICollectionElementKindSectionFooter {
                // Not implemented
            } else {
                let indexPath = attributes.indexPath
        
                let currentAttribute = lastCells[indexPath.section]
        
                // Get the bottom most cell of that section
                if currentAttribute == nil || indexPath.row > currentAttribute?.indexPath.row {
                    lastCells[indexPath.section] = attributes
                }
            
                if indexPath.item == 0 && indexPath.section == 0 {
                    visibleParallaxHeader = true
                }
            }
        
            // For iOS 7.0, the cell zIndex should be above sticky section header
            attributes.zIndex = 1
        }
        
        // when the visible rect is at top of the screen, make sure we see
        // the parallex header
        if CGRectGetMinY(rect) <= 0 {
            visibleParallaxHeader = true
        }
        
        if self.parallaxHeaderAlwaysOnTop {
            visibleParallaxHeader = true
        }
        
        
        // Create the attributes for the Parallex header
        if visibleParallaxHeader && !CGSizeEqualToSize(CGSizeZero, self.parallaxHeaderReferenceSize) {
            
            let currentAttribute = StickyHeaderFlowLayoutAttributes(forSupplementaryViewOfKind: StickyHeaderParallaxHeader, withIndexPath: NSIndexPath(index: 0))
            let maxHeight = self.parallaxHeaderReferenceSize.height
            let minHeight = self.parallaxHeaderMinimumReferenceSize.height
            var frame = currentAttribute.frame
            frame.size.width = self.parallaxHeaderReferenceSize.width
            frame.size.height = maxHeight
            
            let bounds = self.collectionView!.bounds
            let maxY = CGRectGetMaxY(frame)
            
            var y : CGFloat = 0
            let offsetY = collectionView!.contentOffset.y
            let insetTop = self.collectionView!.contentInset.top
            let statusBarHeight : CGFloat = 20
            
            if (workWithHidingNavBar)
            {
                y = min(maxY - minHeight, bounds.origin.y + statusBarHeight)
            } else {
                y = min(maxY - minHeight, bounds.origin.y + insetTop)
            }
            
            var height = max(0, -y + maxY)
            
            let progressiveness = (height - minHeight)/(maxHeight - minHeight)
            currentAttribute.progressiveness = progressiveness
            
            // if zIndex < 0 would prevents tap from recognized right under navigation bar
            currentAttribute.zIndex = 0
            
            // When parallaxHeaderAlwaysOnTop is enabled, we will check when we should update the y position
            if self.parallaxHeaderAlwaysOnTop && height <= minHeight {
                
                if workWithHidingNavBar {
                    y = offsetY + statusBarHeight
                } else {
                    y = offsetY + insetTop
                }
                
                currentAttribute.zIndex = 2000
            } else if (height >= maxHeight) {
                y = max(0, self.collectionView!.contentOffset.y)
                height = maxHeight
            }
            currentAttribute.frame = CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: height)
        
            allItems?.append(currentAttribute)
        }
        
        if !self.disableStickyHeaders {
            for (_, attributes) in lastCells {
                let indexPath = attributes.indexPath
                let indexPathKey = indexPath.section
                
                var header = headers[indexPathKey]
                // CollectionView automatically removes headers not in bounds
                if header == nil {
                    header = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: indexPath.section))
                    
                    if header != nil {
                        self.updateHeaderAttributes(&header!, lastCellAttributes: lastCells[indexPathKey]!)
                        allItems?.append(header!)
                    }
                } else {
                    self.updateHeaderAttributes(&header!, lastCellAttributes: lastCells[indexPathKey]!)
                }
            }
        }
    
        return allItems
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes
        attributes?.frame.origin.y += self.parallaxHeaderReferenceSize.height
        return attributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        size.height += self.parallaxHeaderReferenceSize.height
        return size
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: Overrides
    
    override class func layoutAttributesClass() -> AnyClass {
        return StickyHeaderFlowLayoutAttributes.self
    }
    
    // MARK: Helper
    
    private func updateHeaderAttributes(inout attributes: UICollectionViewLayoutAttributes, lastCellAttributes: UICollectionViewLayoutAttributes) {
        let currentBounds = self.collectionView!.bounds
        attributes.zIndex = 1024
        attributes.hidden = false
        
        var origin = attributes.frame.origin
        
        let sectionMaxY = CGRectGetMaxY(lastCellAttributes.frame) - attributes.frame.size.height
        var y = CGRectGetMaxY(currentBounds) - currentBounds.size.height + self.collectionView!.contentInset.top
        
        if self.parallaxHeaderAlwaysOnTop {
            y += self.parallaxHeaderMinimumReferenceSize.height
        }
        
        let maxY = min(max(y, attributes.frame.origin.y), sectionMaxY)
        
        origin.y = maxY
        attributes.frame = CGRect(origin: origin, size: attributes.frame.size)
    }

}
