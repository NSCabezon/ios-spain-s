//

import UIKit

class PillPageControl: UIView {
    
    // MARK: - PageControl
    var pageCount: Int = 0 {
        didSet {
            updateNumberOfPages(pageCount)
        }
    }
    var progress: CGFloat = 0 {
        didSet {
            layoutActivePageIndicator(progress)
        }
    }
    
    var currentPage: Int {
        return Int(round(progress))
    }
    
    private lazy var defaultWidht: CGFloat = {
        return frame.size.width / 2
    }()
    
    // MARK: - Appearance
    var pillSize = CGSize(width: 2, height: 3) {
        didSet {
            activeLayer.frame = CGRect(origin: CGPoint.zero,
                                       size: CGSize(width: pillSize.width, height: pillSize.height))
        }
    }
    var activeLayerCornerRadius: CGFloat = 0
    var inactiveLayerCornerRadius: CGFloat = 0
    
    var activeTint = UIColor.uiWhite {
        didSet {
            activeLayer.backgroundColor = activeTint.cgColor
            
        }
    }
    
    var inactiveTint = UIColor.uiBlack.withAlphaComponent(0.3) {
        didSet {
            inactiveLayers.forEach { $0.backgroundColor = inactiveTint.cgColor }
        }
    }
    
    var indicatorPadding: CGFloat = 7 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }
    
    fileprivate var inactiveLayers = [CALayer]()
    fileprivate lazy var activeLayer: CALayer = { [unowned self] in
        let layer = CALayer()
        layer.backgroundColor = self.activeTint.cgColor
        layer.cornerRadius = activeLayerCornerRadius
        layer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()]
        return layer
        }()
    
    // MARK: - State Update
    
    fileprivate func updateNumberOfPages(_ count: Int) {
        // no need to update
        guard count != inactiveLayers.count else { return }
        // reset current layout
        inactiveLayers.forEach { $0.removeFromSuperlayer() }
        inactiveLayers = [CALayer]()
        // add layers for new page count
        inactiveLayers = stride(from: 0, to: count, by: 1).map { _ in
            let layer = CALayer()
            layer.backgroundColor = self.inactiveTint.cgColor
            self.layer.addSublayer(layer)
            return layer
        }
        layoutInactivePageIndicators(inactiveLayers)
        // ensure active page indicator is on top
        self.layer.addSublayer(activeLayer)
        layoutActivePageIndicator(progress)
        self.invalidateIntrinsicContentSize()
    }
    
    // MARK: - Layout
    
    fileprivate func layoutActivePageIndicator(_ progress: CGFloat) {
        // ignore if progress is outside of page indicators' bounds
        guard progress >= 0 && progress <= CGFloat(pageCount - 1) else { return }
        let denormalizedProgress = progress * (pillSize.width + indicatorPadding)
        activeLayer.frame.origin.x = denormalizedProgress
    }
    
    func layoutPageIndicator(_ position: Int) {
        guard position >= 0 && position <= pageCount - 1 else { return }
        let denormalizedProgress = CGFloat(position) * (pillSize.width + indicatorPadding)
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.activeLayer.transform = CATransform3DMakeTranslation(denormalizedProgress, 0, 0)
        })
    }
    
    fileprivate func layoutInactivePageIndicators(_ layers: [CALayer]) {
        var layerFrame = CGRect(origin: CGPoint.zero, size: pillSize)
        layers.forEach { layer in
            layer.cornerRadius = inactiveLayerCornerRadius
            layer.frame = layerFrame
            layerFrame.origin.x += layerFrame.width + indicatorPadding
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactiveLayers.count) * pillSize.width + CGFloat(inactiveLayers.count - 1) * indicatorPadding,
                      height: pillSize.height)
    }
}
