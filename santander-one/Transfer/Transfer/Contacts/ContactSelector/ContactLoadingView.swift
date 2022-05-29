//
//  ContactLoadingView.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 06/02/2020.
//

import Foundation

import UIKit
import CoreFoundationLib

class ContactLoadingView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
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
    }
    
    func startAnimating() {
        self.loadingImageView.setPointsLoader()
    }
    
    func stopAnimating() {
        self.loadingImageView.removeLoader()
    }
}
