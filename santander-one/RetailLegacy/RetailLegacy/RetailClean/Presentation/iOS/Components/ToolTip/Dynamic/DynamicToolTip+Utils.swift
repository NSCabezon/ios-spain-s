import UIKit

protocol DynamicToolTipCompatible: class {
    var dynamicToolTipDelegate: DynamicToolTipDisplayer? { get set }
}

protocol DynamicToolTipDisplayer: class {
    
    func displayDynamicPermanentToolTip(inView view: UIView,
                                        withSourceRect sourceRect: CGRect,
                                        forcedDirection: UIPopoverArrowDirection?)
    
    func setTooltipTitleAndDescription(title: LocalizedStylableText, description: String)
}

extension DynamicToolTipDisplayer where Self: UIViewController {
    func displayDynamicPermanentToolTip(inView view: UIView,
                                        withSourceRect sourceRect: CGRect,
                                        forcedDirection: UIPopoverArrowDirection?) {
        DynamicTooltip.displayDynamicToolTip(sourceView: view, sourceRect: sourceRect, viewController: self, forcedDirection: forcedDirection)
    }
    
    func setTooltipTitleAndDescription(title: LocalizedStylableText, description: String) {
        DynamicTooltip.setTooltipTitleAndDescription(title: title, description: description)
    }
}
