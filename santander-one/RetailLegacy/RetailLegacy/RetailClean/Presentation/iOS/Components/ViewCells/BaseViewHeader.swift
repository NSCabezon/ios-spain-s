import UIKit

protocol BaseViewHeaderDelegate: class {
    func didTapHeader()
}

class BaseViewHeader: UITableViewHeaderFooterView {

    weak var mDelegate: BaseViewHeaderDelegate?
    var collapsed: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickHeader))
        if let containerView = getContainerView() {
            containerView.addGestureRecognizer(tapRecognizer)
        }
        configureStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureStyle()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        draw()
    }
    
    func configureStyle() {}
    
    func setCollapsed(collapsed: Bool) {
       self.collapsed = collapsed
    }
    
    func draw() {
        fatalError()
    }    
    
    func getContainerView() -> UIView? {
        fatalError()
    }
    
    @objc func onClickHeader(_ sender: UITapGestureRecognizer) {
        if let mDelegate = mDelegate {
            mDelegate.didTapHeader()
        }
    }
    
    func setBaseViewHeaderDelegate(mDelegate: BaseViewHeaderDelegate) {
        self.mDelegate = mDelegate
    }
}
