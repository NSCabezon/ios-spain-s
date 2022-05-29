import UIKit

class GenericHeaderView: BaseViewHeader {
    
    @IBOutlet weak var containerView: UIView!

    func setView(_ view: UIView) {
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        containerView.addSubview(view)
        view.embedInto(container: containerView)
        layoutIfNeeded()
    }
    
    override func getContainerView() -> UIView? {
        return containerView
    }
    
    override func draw() {
    }
    
}
