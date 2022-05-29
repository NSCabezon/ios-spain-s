//
//  NetworkConnectionError.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/27/19.
//

import Foundation
import CoreFoundationLib
// MARK: - Legacy (is this being used?)
class NetworkConnectionError: UIView {
    @IBOutlet weak var descriptionLabel: UILabel!
    private var view: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.descriptionLabel.text = localized("transaction_label_emptyError")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.descriptionLabel.text = localized("transaction_label_emptyError")
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
}
