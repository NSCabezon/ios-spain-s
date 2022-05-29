import UIKit
import UI
import CoreFoundationLib

public final class ExperiencesCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var imageTipView: UIImageView!
    @IBOutlet weak private var viewContainer: UIView!
    @IBOutlet weak private var descriptionView: UIView!
    
    // MARK: - awakeFromNib
    override public func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    public func setViewModel(_ viewModel: ExperiencesViewModel) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 18.0)
        self.descriptionLabel.configureText(withLocalizedString: viewModel.description)
        if let imageUrl = viewModel.tipImageUrl {
            self.imageTipView.loadImage(urlString: imageUrl)
        } else {
            self.imageTipView.image = nil
        }
    }
    
    // MARK: - Private Methods
    private func configureCell() {
        self.contentView.backgroundColor = UIColor.blueAnthracita
        self.viewContainer.layer.cornerRadius = 5
        self.imageTipView.layer.cornerRadius = 5
        self.titleLabel.font = .santander(family: .headline, type: .bold, size: 10.0)
        titleLabel.textColor = .mediumSanGray
        titleLabel.textAlignment = .left
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 18.0)
        self.descriptionLabel.textAlignment = .left
        self.descriptionLabel.lineBreakMode = .byTruncatingTail
        self.descriptionLabel.adjustsFontSizeToFitWidth = false
        self.descriptionView.roundCorners(corners: [.bottomRight, .bottomLeft], radius: 5.0)
        self.viewContainer.clipsToBounds = true
    }
}

public struct ExperiencesViewModel {
    let title: LocalizedStylableText
    let description: LocalizedStylableText
    public let offer: OfferEntity?
    let baseUrl: String?
    let entity: PullOfferTipEntity
    
    public init(_ entity: PullOfferTipEntity, baseUrl: String?) {
        self.title = localized(entity.title ?? "")
        self.description = localized(entity.description ?? "")
        self.offer = entity.offer
        self.baseUrl = baseUrl
        self.entity = entity
    }
    
    var tipImageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        guard let icon = self.entity.icon else { return nil }
        return String(format: "%@%@", baseUrl, icon)
    }
}
