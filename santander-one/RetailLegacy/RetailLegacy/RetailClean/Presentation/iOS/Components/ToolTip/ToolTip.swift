import UIKit

protocol ToolTipablePresenter: class {
    var toolTipBackView: ToolTipBackView { get }
}

protocol ToolTipBackView: ViewControllerProxy {
}

class ToolTip {
    
    static func displayToolTip(title: LocalizedStylableText?,
                               description: String? = nil,
                               descriptionLocalized: LocalizedStylableText? = nil,
                               sourceView: UIView,
                               sourceRect: CGRect,
                               backView: ToolTipBackView,
                               dissapearAfter: TimeInterval? = nil,
                               forcedDirection: UIPopoverArrowDirection? = nil) {
        ToolTip.displayToolTip(
            title: title,
            description: description,
            descriptionLocalized: descriptionLocalized,
            sourceView: sourceView,
            sourceRect: sourceRect,
            viewController: backView.viewController,
            dissapearAfter: dissapearAfter,
            forcedDirection: forcedDirection
        )
    }
    
    static func displayToolTip(title: LocalizedStylableText?,
                               description: String? = nil,
                               descriptionLocalized: LocalizedStylableText? = nil,
                               identifier: String? = nil,
                               sourceView: UIView,
                               sourceRect: CGRect,
                               viewController: UIViewController,
                               dissapearAfter: TimeInterval? = nil,
                               forcedDirection: UIPopoverArrowDirection? = nil) {
        
        viewController.view.endEditing(true)
        let popoverController = ToolTipViewController(nibName: "ToolTipViewController",
                                                      bundle: .module)
        popoverController.loadView()
        popoverController.viewDidLoad()
        popoverController.maxWidth = viewController.view.bounds.width
        popoverController.popoverTitle = title
        if let localized = descriptionLocalized {
            popoverController.setPopoverDescriptionLocalized(text: localized)
        } else {
            popoverController.popoverDescription = description
        }
        if let identifier = identifier {
            popoverController.setAccessibilityIdentifier(identifier: identifier)
        }
        popoverController.modalPresentationStyle = .popover
        let popover = popoverController.popoverPresentationController
        popover?.sourceView = sourceView
        popover?.sourceRect = sourceRect
        let delegate = ToolTipDelegate.sharedInstance
        if let viewControllerDelegate = viewController as? UIPopoverPresentationControllerDelegate {
            popover?.delegate = viewControllerDelegate
        } else {
            popover?.delegate = delegate
        }
        popover?.permittedArrowDirections = forcedDirection ?? [.up, .down]
        popover?.backgroundColor = .uiWhite
        popoverController.preferredContentSize = popoverController.preferedSize()

        viewController.present(popoverController, animated: true) {
            delegate?.destroy()
            guard let dissapearAfter = dissapearAfter else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + dissapearAfter, execute: {
                popoverController.dismiss(animated: true, completion: nil)
            })
        }
    }
    
}
extension ToolTip {
    class ToolTipDelegate: NSObject, UIPopoverPresentationControllerDelegate {
                
        static var sharedInstance: ToolTipDelegate? {
            if let instance = ToolTipDelegate.strongInstance {
                return instance
            }
            let newInstance = ToolTipDelegate()
            ToolTipDelegate.strongInstance = newInstance
            return newInstance
        }
        
        private static var strongInstance: ToolTipDelegate?
        
        private override init() {}
        
        func adaptivePresentationStyle(for controller: UIPresentationController,
                                       traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
        }
        
        func destroy() {
            ToolTipDelegate.strongInstance = nil
        }
    }
}
