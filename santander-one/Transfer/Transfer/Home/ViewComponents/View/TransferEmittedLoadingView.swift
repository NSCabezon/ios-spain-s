//
//  TransferEmittedLoadingView.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/23/19.
//

import UIKit
import CoreFoundationLib

final class TransferEmittedLoadingView: UIView {
    
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    private var view: UIView?
    
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
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setAppearance() {
        self.loadingLabel.text = localized("generic_popup_loadingContent")
        self.subtitleLabel.text = localized("loading_label_moment")
        self.loadingLabel.textColor = .lisboaGray
        self.subtitleLabel.textColor = .grafite
    }
    
    func startAnimating() {
        self.loadingImageView.setPointsLoader()
    }
    
    func stopAnimating() {
        self.loadingImageView.removeLoader()
    }
}
