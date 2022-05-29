//

import UIKit
import UI

typealias PersonalManagerStackViewConfig = (imageName: String, title: LocalizedStylableText, subtitle: LocalizedStylableText)

class StackOptionsView: UIView {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setup(withConfig config: PersonalManagerStackViewConfig) {
        Bundle.module?.loadNibNamed("StackOptionsView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 17.7), textAlignment: .center))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoHeavy(size: 14.6), textAlignment: .center))
        image.image = Assets.image(named: config.imageName)
        titleLabel.set(localizedStylableText: config.title)
        subtitleLabel.set(localizedStylableText: config.subtitle)
    }
    
    private func setupViews() {
        
    }
}
