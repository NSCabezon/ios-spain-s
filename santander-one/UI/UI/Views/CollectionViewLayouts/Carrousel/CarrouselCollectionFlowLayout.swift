//
//  CarrouselCollectionFlowLayout.swift
//  UI
//
//  Created by Hernán Villamil on 31/3/22.
//

import UIKit
import CoreFoundationLib
import OpenCombine
import CoreDomain

public enum CarrouselCollectionState: State {
    case idle
    case minimumLineSpacing(CGFloat)
    case activeDistance(CGFloat)
    case updatedIndexPath(IndexPath)
}

public class CarrouselCollectionFlowLayout: UICollectionViewFlowLayout {
    private let estimatedHeight: CGFloat = 260
    private let estimatedWidth: CGFloat = UIScreen.main.bounds.size.width * 0.80
    private var activeDistance: CGFloat = 200
    private var indexPath: IndexPath?
    private var edgeInsets: UIEdgeInsets?
    private var subscriptions = Set<AnyCancellable>()
    public var state: AnyPublisher<CarrouselCollectionState, Never>
    public let stateSubject = PassthroughSubject<CarrouselCollectionState, Never>()
    
    override public init() {
        state = stateSubject.eraseToAnyPublisher()
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.contentInset.right - collectionView.contentInset.left - itemSize.width) / 2
        let collectionViewInsets = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        sectionInset = edgeInsets ?? collectionViewInsets
        super.prepare()
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                       withScrollingVelocity: velocity) }
        let offsetAdjustment = getOffsetAdjustment(proposedContentOffset: proposedContentOffset,
                                                   collectionView: collectionView)
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)?.compactMap { $0.copy() as? UICollectionViewLayoutAttributes } ?? []
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            attributes.frame.origin = CGPoint(x: attributes.frame.origin.x, y: 0)
            if distance.magnitude < activeDistance {
                indexPath = attributes.indexPath
                guard (self.collectionView?.cellForItem(at: attributes.indexPath) as? CarrouselCollectionRezisableCell) != nil else { continue }
                attributes.frame = getFrameForAttributes(attributes)
            } else {
                if (self.collectionView?.cellForItem(at: attributes.indexPath) as? CarrouselCollectionRezisableCell) != nil {
                    attributes.frame = getFrameForAttributes(attributes)
                }
                collapseItemWithAttributes(attributes)
            }
        }
        return rectAttributes
    }
}

public extension CarrouselCollectionFlowLayout {
    @available(*, deprecated, message: "Please use CarrouselCollectionState.minimumLineSpacing")
    func setMinimumLineSpacing(_ spacing: CGFloat) {
        minimumLineSpacing = spacing
    }
    
    @available(*, deprecated, message: "Please use CarrouselCollectionState.activeDistance")
    func setActiveDistance(_ distance: CGFloat) {
        activeDistance = distance
    }
    
    @available(*, deprecated, message: "Please use CarrouselCollectionState.updatedIndexPath")
    func indexPathForCenterRect() -> IndexPath? {
        return indexPath
    }
}

private extension CarrouselCollectionFlowLayout {
    func commonInit() {
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        setItemSize(CGSize(width: estimatedWidth, height: estimatedHeight))
        bind()
    }
    
    func getOffsetAdjustment(proposedContentOffset: CGPoint, collectionView: UICollectionView) -> CGFloat {
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
        return offsetAdjustment
    }
    
    func getFrameForAttributes(_ attributes: UICollectionViewLayoutAttributes) -> CGRect {
        guard let resizableCell = getResizableCellForAttributes(attributes),
              let collectionView = collectionView else {
                  return CGRect(origin: attributes.frame.origin,
                                size: CGSize(width: estimatedWidth,
                                             height: estimatedHeight))
              }
        let height = (resizableCell as? CarrouselCollectionRezisableCell)?.getCellHeight(resizableCell,
                                                                                         collectionVIew: collectionView) ?? estimatedHeight
        let size = CGSize(width: attributes.frame.width,
                          height: height)
        return CGRect(origin: attributes.frame.origin, size: size)
    }
    
    func getResizableCellForAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewCell? {
        guard let cell = collectionView?.cellForItem(at: attributes.indexPath)
        else { return nil }
        return cell
    }
    
    func setItemSize(_ size: CGSize) {
        itemSize = size
    }
    
    func collapseItemWithAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        guard let resizableDelegate = collectionView?.cellForItem(at: attributes.indexPath) as? ResizableStateDelegate
        else { return }
        resizableDelegate.didStateChange(.colapsed)
    }
}

private extension CarrouselCollectionFlowLayout {
    func bind() {
        bindMinimumLineSpacing()
        bindActiveDistance()
    }
    
    func bindMinimumLineSpacing() {
        state
            .case(CarrouselCollectionState.minimumLineSpacing)
            .sink { [unowned self] spacing in
                self.minimumLineSpacing = spacing
            }.store(in: &subscriptions)
    }
    
    func bindActiveDistance() {
        state
            .case(CarrouselCollectionState.activeDistance)
            .sink { [unowned self] distance in
                self.activeDistance = distance
            }.store(in: &subscriptions)
    }
}
