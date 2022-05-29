import UIKit
import UI
import CoreFoundationLib

final class BizumContactDetailView: XibView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet private weak var profileView: UIView! {
        didSet {
            profileView.layer.cornerRadius = profileView.frame.height / 2
        }
    }
    @IBOutlet private weak var thumbnail: UIImageView! {
        didSet {
            thumbnail.layer.cornerRadius = profileView.frame.height / 2
        }
    }
    @IBOutlet private weak var profileLabel: UILabel! {
        didSet {
            profileLabel.textColor = .white
            profileLabel.font = .santander(family: .text, type: .bold, size: 15)
        }
    }
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            self.nameLabel.font = .santander(family: .text, type: .bold, size: 14)
            self.nameLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var mobileLabel: UILabel! {
        didSet {
            self.mobileLabel.font = .santander(family: .text, type: .regular, size: 14)
            self.mobileLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var amountLabel: UILabel! {
        didSet {
            self.amountLabel.font = .santander(family: .text, type: .regular, size: 12)
            self.amountLabel.textColor = .grafite
            self.amountLabel.text = localized("bizum_label_amount")
        }
    }
    @IBOutlet private weak var amountValue: UILabel! {
        didSet {
            self.amountValue.font = .santander(family: .text, type: .regular, size: 20)
            self.amountValue.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var separatorView: PointLine!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension BizumContactDetailView: BizumContactDetailViewProtocol {
    func showNameAndInitials(_ fullName: String, _ initials: String) {
        self.nameLabel.text = fullName
        self.profileLabel.text = initials
    }

    func hideFullName() {
        self.nameLabel.isHidden = true
    }

    func showMobile(_ mobile: String) {
        self.mobileLabel.text = mobile
    }

    func hideMobile() {
        self.mobileLabel.isHidden = true
    }

    func showAmount(_ amount: NSAttributedString) {
        self.amountValue.attributedText = amount
    }

    func showColorModel(_ colorModel: ColorsByNameViewModel) {
        self.profileView.backgroundColor = colorModel.color
    }

    func hideSeparator() {
        self.separatorView.isHidden = true
    }
    
    func showContactThumbnailData(_ data: Data) {
        self.profileLabel.isHidden = true
        self.thumbnail.image = UIImage(data: data)
    }
}
