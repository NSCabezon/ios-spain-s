//  Created by Juan Carlos López Robles on 12/23/19.
//

import UIKit
import CoreFoundationLib

public class EmptyCollectionView: UIView {
    private var view: UIView?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
        self.backgroundImageView.image = Assets.image(named: "imgLeaves")
        self.titleLabel.configureText(withKey: "transfer_title_emptyView_recent")
        self.descriptionLabel.configureText(withKey: "transfer_text_emptyView_notDone")
        self.descriptionLabel.textColor = .lisboaGray
        self.titleLabel.textColor = .lisboaGray
    }
    
    public func setTitle(_ title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: title)
        self.descriptionLabel.configureText(withLocalizedString: subtitle)
    }
}
