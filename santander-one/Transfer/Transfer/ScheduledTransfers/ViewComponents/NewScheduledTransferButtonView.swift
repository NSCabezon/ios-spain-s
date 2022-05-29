//
//  NewScheduledTransferButtonView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 05/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol NewScheduledTransferButtonDelegate: AnyObject {
    func didSelectNewShipment()
}

class NewScheduledTransferButtonView: UIView {
    @IBOutlet weak var newTransferButton: RedLisboaButton!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: NewScheduledTransferButtonDelegate?
    var view: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.xibSetup()
        self.configureView()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func configureView() {
        self.newTransferButton.setTitle(localized("onePay_button_newScheduledTransfer"), for: .normal)
        self.newTransferButton.addSelectorAction(target: self, #selector(didSelectNewShipment))
        self.drawShadowTop(offset: -2, opaticity: 0.2, color: .lisboaGray, radius: 1)
        self.newTransferButton.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersBtnNewTrasfers
    }
    
    private func drawShadowTop(offset: CGFloat = 3.0, opaticity: Float = 1.0, color: UIColor, radius: CGFloat = 0.0) {
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: offset)
        self.contentView.layer.shadowOpacity = opaticity
        self.contentView.layer.shadowColor = color.cgColor
        self.contentView.layer.shadowRadius = radius
    }
    
    @objc private func didSelectNewShipment() {
        self.delegate?.didSelectNewShipment()
    }
}
