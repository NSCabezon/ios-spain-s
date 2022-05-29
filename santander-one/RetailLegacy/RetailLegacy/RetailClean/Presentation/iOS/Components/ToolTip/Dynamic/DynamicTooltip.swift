import UIKit

protocol DynamicToolTipablePresenterPresenter: class {
    var toolTipBackView: DynamicTooltipBackView { get }
}

protocol DynamicTooltipBackView: ViewControllerProxy {
}

class DynamicTooltip {
    
    weak static var currentTooltip: DynamicTooltipViewController?
    
    static func setTooltipTitleAndDescription(title: LocalizedStylableText, description: String) {
        currentTooltip?.setTooltipTitleAndDescription(title: title, description: description)
        currentTooltip?.showLoading(show: false)
        currentTooltip?.preferredContentSize = currentTooltip?.preferedSize() ?? .zero
    }
    
    static func displayDynamicToolTip(sourceView: UIView, sourceRect: CGRect, viewController: UIViewController, dissapearAfter: TimeInterval? = nil, forcedDirection: UIPopoverArrowDirection? = nil) {
        viewController.view.endEditing(true)
        let popoverController = DynamicTooltipViewController(nibName: "DynamicTooltipViewController", bundle: .module)
        popoverController.loadView()
        popoverController.viewDidLoad()
        popoverController.maxWidth = viewController.view.bounds.width
        popoverController.modalPresentationStyle = .popover
        let delegate = DynamicTooltipDelegate.sharedInstance
        let popover = popoverController.popoverPresentationController
        popover?.sourceView = sourceView
        popover?.sourceRect = sourceRect
        popover?.delegate = delegate
        popover?.permittedArrowDirections = forcedDirection ?? [.up, .down]
        popover?.backgroundColor = .uiWhite
        popoverController.preferredContentSize = CGSize(width: 100, height: 80)
        viewController.present(popoverController, animated: true) {
            delegate?.destroy()
            guard let dissapearAfter = dissapearAfter else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + dissapearAfter, execute: {
                popoverController.dismiss(animated: true, completion: nil)
            })
        }
        currentTooltip = popoverController
    }
}

extension DynamicTooltip {
    class DynamicTooltipDelegate: NSObject, UIPopoverPresentationControllerDelegate {
        
        static var sharedInstance: DynamicTooltipDelegate? {
            if let instance = DynamicTooltipDelegate.strongInstance {
                return instance
            }
            let newInstance = DynamicTooltipDelegate()
            DynamicTooltipDelegate.strongInstance = newInstance
            return newInstance
        }
        
        private static var strongInstance: DynamicTooltipDelegate?
        
        private override init() {}
        
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
        }
        
        func destroy() {
            DynamicTooltipDelegate.strongInstance = nil
        }
    }
}
