import UIKit
import UI

final class MenuFeaturedItemTableViewCell: BaseViewCell {
    var titleText: LocalizedStylableText? {
        didSet {
            if let text = titleText {
                titleLabel.set(localizedStylableText: text)
                labelSubtitle.text = text.text
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var descriptionText: String? {
        didSet {
            extraMessageLabel.text = descriptionText
            extraMessageLabel.isHidden = descriptionText == nil
        }
    }
    
    var newText: LocalizedStylableText? {
        didSet {
            if let text = newText {
                newLabel.set(localizedStylableText: text.uppercased())
                newContentView.isHidden = false
                messagesStackBottomConstraint.constant = 8
            } else {
                newLabel.text = nil
                messagesStackBottomConstraint.constant = 4
                newContentView.isHidden = true
            }
        }
    }
    
    var isFeaturedCell = false
    var isHighlightedCell = false

    @IBOutlet private weak var featuredContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var extraMessageLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet private weak var newContentView: UIView!
    @IBOutlet private weak var newLabel: UILabel!
    @IBOutlet private weak var messagesStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var submenuArrow: UIImageView!
    @IBOutlet private weak var highlightedView: UIView!
    @IBOutlet private weak var labelSubtitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        commonInit()
    }

    private func commonInit() {
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        titleLabel.textColor = UIColor.lisboaGrayNew
        labelSubtitle.font = UIFont.santanderTextBold(size: 13)
        labelSubtitle.textColor = UIColor.deepSanGrey
        setSubTitle(false)
        setSelectionStyle()
    }

    private func setSelectionStyle() {
        selectionStyle = .none
        submenuArrow.image = Assets.image(named: "icnArrowRightSmall")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isFeaturedCell {
            featuredContentView.backgroundColor = .lightSky
            featuredContentView.layer.cornerRadius = 2
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isFeaturedCell {
            featuredContentView.backgroundColor = .whitesmokes
            featuredContentView.layer.cornerRadius = 4
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if isFeaturedCell {
            featuredContentView.backgroundColor = .whitesmokes
            featuredContentView.layer.cornerRadius = 4
        }
    }
    
    func setFeaturedCell(isFeatured: Bool) {
        isFeatured ? self.setFeaturedStyle() : self.hideFeaturedStyle()
    }
    
    func setFeaturedStyle() {
        extraMessageLabel.isHidden = false
        extraMessageLabel.font = UIFont.santanderTextRegular(size: 13)
        extraMessageLabel.textColor = UIColor.lisboaGrayNew
        extraMessageLabel.set(lineHeightMultiple: 0.75)
        
        featuredContentView.backgroundColor = .whitesmokes
        featuredContentView.layer.cornerRadius = 4
        
        newContentView.isHidden = false
        newLabel.isHidden = false
        newContentView.backgroundColor = .darkTorquoise
        newContentView.layer.cornerRadius = 2
        newLabel.font = UIFont.santanderTextBold(size: 10)
        newLabel.textColor = .white
    }
    
    func hideFeaturedStyle() {
        newContentView.isHidden = true
        newLabel.isHidden = true
        extraMessageLabel.isHidden = true
        newContentView.backgroundColor = .white
        featuredContentView.backgroundColor = .white
    }
    
    func setHighlightedCell(isHighlight: Bool) {
        isHighlight ? setHighlightedStyle() : resetHighlightedStyle()
    }
    
    func setHighlightedStyle() {
        titleLabel.font = UIFont.santanderTextRegular(size: 18)
        titleLabel.textColor = UIColor.santanderRed
        highlightedView.backgroundColor = .botonRedLight
    }
    
    func resetHighlightedStyle() {
        titleLabel.font = UIFont.santanderTextRegular(size: 18)
        titleLabel.textColor = UIColor.lisboaGrayNew
        highlightedView.backgroundColor = .clear
    }
    
    func setImage(named name: String) {
        iconImageView.image = Assets.image(named: name)?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = .botonRedLight
    }
    
    func hideImage() {
        iconImageView.isHidden = true
    }
    
    func animateViewCell() {
        self.featuredContentView.backgroundColor = .white
        self.newContentView.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: { [weak self] in
            self?.featuredContentView.backgroundColor = .whitesmokes
            self?.newContentView.alpha = 1.0
        }, completion: nil)
    }
    
    func resetAnimationCell() {
        self.featuredContentView.backgroundColor = .white
        self.newContentView.alpha = 1.0
    }

    func showSubmenuArrow(showArrow: Bool) {
        submenuArrow.isHidden = !showArrow
    }

    func setSubTitle(_ enabled: Bool) {
        titleLabel.isHidden = enabled
        extraMessageLabel.isHidden = enabled
        iconImageView.isHidden = enabled
        newContentView.isHidden = enabled
        newLabel.isHidden = enabled
        submenuArrow.isHidden = enabled
        highlightedView.isHidden = enabled
        labelSubtitle.isHidden = !enabled
    }
}
