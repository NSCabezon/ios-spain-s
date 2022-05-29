//
//  InboxAlertView.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/22/20.
//

import UIKit
import UI
import CoreFoundationLib

class InboxAlertView: UIView {
    private var view: UIView?
    @IBOutlet weak var solicitudeView: UIView!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertSubtitleLabel: UILabel!
    
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
        self.solicitudeView.backgroundColor = UIColor.white
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 0.59
        self.layer.shadowRadius = 4
        self.layer.shadowColor = UIColor.silverDark.cgColor
        self.solicitudeView.drawBorder(cornerRadius: 4, color: .lightSkyBlue, width: 1)
    }
    
    func setViewModel(_ solicitude: PendingSolicitudeInboxViewModel) {
        self.alertImageView.image = Assets.image(named: "icnDangerGreen")
        self.alertTitleLabel.text = localized("contracts_label_pending")
        self.alertSubtitleLabel.text = solicitude.name
    }
}
