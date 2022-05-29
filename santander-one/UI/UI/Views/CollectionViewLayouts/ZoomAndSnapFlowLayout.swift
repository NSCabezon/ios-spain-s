//
//  ZoomFlowLayout.swift
//  UI
//
//  Created by Juan Carlos López Robles on 10/10/19.
//

import UIKit

public class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {
    
    private var activeDistance: CGFloat = 200
    private var zoomFactor: CGFloat = 3
    private var _indexPath: IndexPath?
    private var edgeInsets: UIEdgeInsets?
    public var forceSizeCalculation: Bool = false
    
    override public init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        itemSize = CGSize(width: 100, height: 100)
    }
    
    public func setMinimumLineSpacing(_ spacing: CGFloat) {
        minimumLineSpacing = spacing
    }
    
    public func setItemSize(_ itemSize: CGSize) {
        self.itemSize = itemSize
    }
    
    public func setActiveDistance(_ activeDistance: CGFloat) {
        self.activeDistance = activeDistance
    }
    
    public func setZoom(_ zoom: CGFloat) {
        self.zoomFactor = zoom
    }
    
    public func setEdgeInsets(_ edgeInsets: UIEdgeInsets) {
        self.edgeInsets = edgeInsets
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        
        let verticalInsets = (collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.contentInset.right - collectionView.contentInset.left - itemSize.width) / 2
        let collectionViewInsets = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        sectionInset = self.edgeInsets ?? collectionViewInsets
        
        super.prepare()
    }
 
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)?.compactMap { $0.copy() as? UICollectionViewLayoutAttributes } ?? []
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        
        // Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance
            attributes.frame.origin = CGPoint(x: attributes.frame.origin.x, y: 0)
            
            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
                
                self._indexPath = attributes.indexPath
                
                guard let resizable = self.collectionView?.cellForItem(at: attributes.indexPath) as? Resizable else { continue }
                let size = CGSize(width: attributes.frame.width, height: resizable.getHeightForState())
                attributes.frame = CGRect(origin: attributes.frame.origin, size: size)
            } else {
                if self.forceSizeCalculation, let resizable = self.collectionView?.cellForItem(at: attributes.indexPath) as? Resizable {
                    let size = CGSize(width: attributes.frame.width, height: resizable.getHeightForState())
                    attributes.frame = CGRect(origin: attributes.frame.origin, size: size)
                }
                guard let resizableDelegate = self.collectionView?.cellForItem(at: attributes.indexPath) as? ResizableStateDelegate else { continue }
                resizableDelegate.didStateChange(.colapsed)
            }
        }
        
        return rectAttributes
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        
        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }
    
    override public func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as? UICollectionViewFlowLayoutInvalidationContext
        context?.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context ?? UICollectionViewLayoutInvalidationContext()
    }
    
    public func indexPathForCenterRect() -> IndexPath? {
        return _indexPath
    }
}
