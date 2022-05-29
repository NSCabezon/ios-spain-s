//
//  MoreTransferActionHeader.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/26/19.
//

import Foundation
import UI
import CoreFoundationLib

protocol NewShipmentHeaderDelegate: AnyObject {
    func didSelectClose()
}

final class NewShipmentHeader: UIView {
    private var view: UIView?
    weak var delegate: NewShipmentHeaderDelegate?
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var separationView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var topShadow: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
        self.setAppearance()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
        self.closeButton.accessibilityIdentifier = AccessibilityOthers.btnClose.rawValue
        self.separationView.backgroundColor = .lightSanGray
        self.separationView.layer.cornerRadius = self.separationView.bounds.height / 2.0
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setAppearance() {
        self.titleLabel.text = localized("transfer_button_newSend")
        self.closeImageView.image = Assets.image(named: "icnCloseGray")
        self.containerView.backgroundColor = UIColor.white
    }
    
    private func addTopShadow() {
        self.topShadow.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.topShadow.layer.shadowOpacity = 0.59
        self.topShadow.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        self.topShadow.layer.shadowRadius = 0.0
        self.topShadow.layer.masksToBounds = false
        self.topShadow.clipsToBounds = false
    }
    
    @IBAction func didTapOnClose(_ sender: Any) {
        self.delegate?.didSelectClose()
    }
}
