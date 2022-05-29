import UIKit

protocol ToolTipCompatible: class {
    var toolTipDelegate: ToolTipDisplayer? { get set }
}

protocol ToolTipDisplayer: class {
    func displayToolTip(with Title: LocalizedStylableText?, description: String?, inView view: UIView, withSourceRect sourceRect: CGRect)
    func displayToolTip(with Title: LocalizedStylableText?, descriptionLocalized: LocalizedStylableText?, inView view: UIView, withSourceRect sourceRect: CGRect)
    func displayPermanentToolTip(with Title: LocalizedStylableText?, descriptionLocalized: LocalizedStylableText?, inView view: UIView, withSourceRect sourceRect: CGRect, forcedDirection: UIPopoverArrowDirection?)
    func displayPermanentToolTip(with Title: LocalizedStylableText?, descriptionLocalized: LocalizedStylableText?, identifier: String?, inView view: UIView, withSourceRect sourceRect: CGRect, forcedDirection: UIPopoverArrowDirection?)
}

extension ToolTipDisplayer where Self: UIViewController {
    func displayToolTip(with Title: LocalizedStylableText?, description: String?, inView view: UIView, withSourceRect sourceRect: CGRect) {
        ToolTip.displayToolTip(title: Title, description: description, sourceView: view, sourceRect: sourceRect, viewController: self, dissapearAfter: 2.0)
    }
    
    func displayToolTip(with Title: LocalizedStylableText?, descriptionLocalized: LocalizedStylableText?, inView view: UIView, withSourceRect sourceRect: CGRect) {
        ToolTip.displayToolTip(title: Title, descriptionLocalized: descriptionLocalized, sourceView: view, sourceRect: sourceRect, viewController: self, dissapearAfter: 2.0)
    }
    
    func displayPermanentToolTip(with Title: LocalizedStylableText?, descriptionLocalized: LocalizedStylableText?, inView view: UIView, withSourceRect sourceRect: CGRect, forcedDirection: UIPopoverArrowDirection?) {
        ToolTip.displayToolTip(title: Title, descriptionLocalized: descriptionLocalized, sourceView: view, sourceRect: sourceRect, viewController: self, forcedDirection: forcedDirection)
    }
    
    func displayPermanentToolTip(with Title: LocalizedStylableText?, descriptionLocalized: LocalizedStylableText?, identifier: String? = nil, inView view: UIView, withSourceRect sourceRect: CGRect, forcedDirection: UIPopoverArrowDirection?) {
        ToolTip.displayToolTip(title: Title, descriptionLocalized: descriptionLocalized, identifier: identifier, sourceView: view, sourceRect: sourceRect, viewController: self, forcedDirection: forcedDirection)
    }
}
