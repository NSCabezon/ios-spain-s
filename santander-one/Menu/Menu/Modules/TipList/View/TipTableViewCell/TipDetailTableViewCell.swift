import UIKit
import UI
import CoreFoundationLib

class TipDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

private extension TipDetailTableViewCell {
    func configureCell() {
        self.selectionStyle = .none
        self.containerView.backgroundColor = .white
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.masksToBounds = true
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.titleLabel.textColor = .darkTorquoise
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.descriptionLabel.textColor = .darkGray
        self.tagLabel.font = .santander(family: .text, type: .bold, size: 10)
        self.tagLabel.textColor = .white
        self.tagView.isHidden = true
        self.tagView.backgroundColor = .darkTorquoise
        self.tagView.layer.cornerRadius = 2
        self.customImageView.image = nil
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "tipDetail_view"
        titleLabel.accessibilityIdentifier = "tipDetail_title"
        descriptionLabel.accessibilityIdentifier = "tipDetail_desc"
        customImageView.isAccessibilityElement = true
        setAccessibility { self.customImageView.isAccessibilityElement = true }
        customImageView.accessibilityIdentifier = "tipDetail_image"
        tagLabel.accessibilityIdentifier = "tipDetail_tag"
    }
}

extension TipDetailTableViewCell: TipDetailViewModelProtocol {
    func setTitle(_ value: LocalizedStylableText) {
        titleLabel.configureText(withLocalizedString: value)
    }

    func setDescription(_ value: LocalizedStylableText) {
        descriptionLabel.configureText(withLocalizedString: value)
    }

    func loadImage(_ value: String) {        
        self.customImageView.loadImage(urlString: value)
    }

    func showTag(_ value: LocalizedStylableText) {
        tagLabel.configureText(withLocalizedString: value.uppercased())
        tagView.isHidden = false
    }

    func hideTag() {
        tagView.isHidden = true
    }
}

extension TipDetailTableViewCell: AccessibilityCapable { }
