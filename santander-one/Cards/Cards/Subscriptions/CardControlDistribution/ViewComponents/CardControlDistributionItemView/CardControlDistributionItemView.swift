import Foundation
import UI
import CoreFoundationLib

public protocol CardControlDistributionItemViewDelegate: AnyObject {
    func cardControlDistributionItemPressed(_ itemView: CardControlDistributionItemView)
}

public final class CardControlDistributionItemView: XibView {
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var firstSectionView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var secondSectionView: UIView!
    @IBOutlet weak private var secondSectionStackView: UIStackView!
    @IBOutlet weak private var thirdSectionView: UIView!
    @IBOutlet weak private var thirdSectionLabel: UILabel!
    @IBOutlet weak private var thirdSectionImageView: UIImageView!
    @IBOutlet weak private var arrowImage: UIImageView!
    
    private weak var delegate: CardControlDistributionItemViewDelegate?
    var model: CardControlDistributionItemViewModel?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ model: CardControlDistributionItemViewModel, delegate: CardControlDistributionItemViewDelegate) {
        self.model = model
        self.delegate = delegate
        self.titleLabel.text = model.title
        self.descriptionLabel.text = model.description
        self.thirdSectionLabel.text = model.buttonText
        self.imageView.image = Assets.image(named: model.imageName)
        self.removeArrangedSubviewsForStackView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.addViews(model)
        }
    }
    
    func addViews(_ model: CardControlDistributionItemViewModel) {
        model.actions.forEach({ stringAction in
            let view = CardControlDistributionActionView()
            view.configView(stringAction)
            secondSectionStackView.addArrangedSubview(view)
        })
    }
}

private extension CardControlDistributionItemView {
    func setupView() {
        firstSectionSetup()
        secondSectionSetup()
        thirdSectionSetup()
        addTapGesture()
        addBorderAndShadow()
        setAccessibilityIds()
    }
    
    func addBorderAndShadow() {
        contentView.layer.shadowColor = UIColor.lightSanGray.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowRadius = 2
        contentView.drawBorder(cornerRadius: 8, color: .mediumSkyGray, width: 1)
    }
    
    func firstSectionSetup() {
        firstSectionView.backgroundColor = .white
        titleLabelSetup()
        subtitleLabelSetup()
    }
    
    func titleLabelSetup() {
        titleLabel.font = .santander(family: .micro, type: .bold, size: 16)
        titleLabel.textColor = .lisboaGray
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0
    }
    
    func subtitleLabelSetup() {
        descriptionLabel.font = .santander(family: .micro, type: .regular, size: 14)
        descriptionLabel.textColor = .brownishGray
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.numberOfLines = 0
    }
    
    func secondSectionSetup() {
        secondSectionStackView.spacing = 0
        secondSectionStackView.backgroundColor = .clear
        secondSectionView.backgroundColor = .skyGray
    }
    
    func removeArrangedSubviewsForStackView() {
        if !self.secondSectionStackView.arrangedSubviews.isEmpty {
            self.secondSectionStackView.removeAllArrangedSubviews()
        }
    }
    
    func thirdSectionSetup() {
        thirdSectionLabel.textColor = .darkTorquoise
        thirdSectionLabel.font = .santander(family: .text, type: .bold, size: 14)
        thirdSectionLabel.textAlignment = .right
        arrowImage.image = Assets.image(named: "icnArrowTransaction")
    }
    
    func addTapGesture() {
        if let gestureRecognizers = gestureRecognizers,
           !gestureRecognizers.isEmpty {
            self.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        thirdSectionView.addGestureRecognizer(tap)
    }
    
    @objc func didTapItemView() {
        delegate?.cardControlDistributionItemPressed(self)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemBaseView
        self.titleLabel.accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemTitleLabel
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemDescriptionLabel
        self.imageView.accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemImageView
        self.thirdSectionLabel.accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemFooterLabel
        self.thirdSectionImageView.accessibilityIdentifier = AccessibilityCardControlDistribution.distributionItemFooterImageView
    }
}
