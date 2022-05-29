import UIKit
import UI

protocol AviosBannerContainerDelegate: AnyObject {
    func didTapAvios()
}

final class AviosBannerContainer: DesignableView {
    @IBOutlet private weak var buttonContainerView: AviosBanner!
    weak var delegate: AviosBannerContainerDelegate?
    
    override func commonInit() {
        super.commonInit()
        contentView?.backgroundColor = .lightGray40
        buttonContainerView.drawBorder(cornerRadius: 6, color: .mediumSkyGray, width: 1)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    @objc func didTapView() {
        delegate?.didTapAvios()
    }
}
