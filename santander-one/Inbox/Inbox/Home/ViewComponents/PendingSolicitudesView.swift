//
//  PendingSolicitudesView.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import UIKit
import UI
import CoreFoundationLib

class PendingSolicitudesView: UIView {
    private var view: UIView?
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var buttomLineView: UIView!
    @IBOutlet weak var collectionView: PendingSolicitudesUICollectionView!
    
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
    
    func setViewModels(_ viewModels: [PendingSolicitudeInboxViewModel]) {
        guard !viewModels.isEmpty else {
            self.removeFromSuperview()
            return
        }
        self.collectionView.setViewModels(viewModels)
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
        self.addShadow(to: topLineView, height: 0.1)
        self.addShadow(to: buttomLineView, height: 1)
    }
    
    private func addShadow(to view: UIView, height: CGFloat) {
        view.layer.shadowOffset = CGSize(width: 0, height: height)
        view.layer.shadowOpacity = 0.66
        view.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
    }
}
