//
//  TransactionDetailView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/27/19.
//

import Foundation
import CoreFoundationLib

class TransactionDetailView: UIView {
    
    @IBOutlet weak var anotationStack: UIStackView!
    @IBOutlet weak var anotationDescriptionLabel: UILabel!
    @IBOutlet weak var anotationLabel: UILabel!
    @IBOutlet weak var retensionStack: UIStackView!
    @IBOutlet weak var retensionDescriptionLabel: UILabel!
    @IBOutlet weak var retensionAmountLabel: UILabel!
    var view: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.xibSetup()
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
    
    public func setConfiguration(_ config: CardTransactionDetailViewConfiguration) {
        anotationDescriptionLabel.text = config.left?.title
        anotationLabel.attributedText = config.left?.value
        retensionDescriptionLabel.text = config.right?.title
        retensionAmountLabel.attributedText = config.right?.value
    }
}
