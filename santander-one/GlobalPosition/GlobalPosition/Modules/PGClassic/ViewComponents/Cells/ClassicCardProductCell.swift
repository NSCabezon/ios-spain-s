import UIKit
import UI
import CoreFoundationLib

final class ClassicCardProductCell: UITableViewCell, GeneralPGCellProtocol {
    @IBOutlet private weak var frameView: RoundedView!
    @IBOutlet private weak var disabledCourtine: UIView!
    @IBOutlet private weak var disabledCourtineTrailing: NSLayoutConstraint!
    @IBOutlet private weak var cardImg: UIImageView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var separationView: DottedLineView!

    private var currentTask: CancelableTask?
    private var card: Any?
    private var discreteMode: Bool = false
    weak var delegate: CardProductTableViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGCardCellViewModel else {
            return
        }
        setData(info)
        setStackView(info)
        showDisabledCourtineIfNeeded(info)
        setAccessibilityIdentifiers(info: info)
    }
}

private extension ClassicCardProductCell {
    // MARK: Private methods
    func commonInit() {
        configureView()
        configureImage()
    }
    
    func configureView() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.skyGray
        frameView.backgroundColor = UIColor.clear
        frameView.frameBackgroundColor = UIColor.white.cgColor
        frameView.frameCornerRadious = 6.0
        frameView.layer.borderWidth = 0.0
        frameView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        onlySideFrame()
        separationView.strokeColor = .mediumSkyGray
    }
    
    func configureImage() {
        cardImg.contentMode = .scaleAspectFill
        cardImg.layer.cornerRadius = 5.0
        cardImg.backgroundColor = UIColor.clear
        cardImg.isAccessibilityElement = true
        setAccessibility { self.cardImg.isAccessibilityElement = false }
    }
    
    func reset() {
        cardImg?.image = nil
        card = nil
        currentTask?.cancel()
        separationView?.isHidden = false
        discreteMode = false
        onlySideFrame()
    }
    
    func setCurrentTask(_ info: PGCardCellViewModel) {
        let task = cardImg?.loadImage(
            urlString: info.imgURL,
            placeholder: info.customFallbackImage ?? Assets.image(named: "defaultCard")
        )
        currentTask = task
    }
    
    func setData(_ info: PGCardCellViewModel) {
        self.card = info.elem
        setCurrentTask(info)
    }
    
    func showDisabledCourtineIfNeeded(_ info: PGCardCellViewModel) {
        disabledCourtine.isHidden = !info.disabled && !info.toActivate
        disabledCourtine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        if info.disabled && info.toActivate {
            guard (disabledCourtineTrailing != nil) else { return }
            disabledCourtineTrailing.isActive = false
            let newCourtineTrailing = NSLayoutConstraint(item: disabledCourtine!, attribute: .trailing, relatedBy: .equal, toItem: stackView.arrangedSubviews.last, attribute: .leading, multiplier: 1, constant: 0)
            self.contentView.addConstraint(newCourtineTrailing)
        }
    }
    
    func removeArrangedSubviewsIfNeeded() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    // MARK: Config Card StackView
    func setStackLeftView(_ info: PGCardCellViewModel) -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.contentMode = .scaleToFill
        let cardNameLabel = setCardNameLabel(info)
        stackView.addArrangedSubview(cardNameLabel)
        let cardNumLabel = setCardNumLabel(info)
        stackView.addArrangedSubview(cardNumLabel)
        guard let movCount = info.notification,
              movCount > 0 else {
            return stackView
        }
        let unreadMovementsView = ClassicCardProductUnreadMovementsView()
        unreadMovementsView.configView(info as PGGeneralCellViewModelProtocol)
        stackView.addArrangedSubview(unreadMovementsView)
        return stackView
    }
    
    func setStackRightView(_ info: PGCardCellViewModel) -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.contentMode = .scaleToFill
        guard info.toActivate else {
            let cardValueView = ClassicCardProductValueView()
            cardValueView.configView(
                info: info,
                discreteMode: discreteMode
            )
            stackView.addArrangedSubview(cardValueView)
            return stackView
        }
        let cardActivateView = ClassicCardProductActivateView()
        cardActivateView.delegate = self
        cardActivateView.setCard(info.elem)
        stackView.addArrangedSubview(cardActivateView)
        return stackView
    }
    
    // MARK: Stack Arranged Subviews config
    func setCardNameLabel(_ info: PGCardCellViewModel) -> UILabel {
        let cardNameLabel = UILabel()
        cardNameLabel.textColor = .lisboaGray
        cardNameLabel.numberOfLines = 2
        let cardNameLabelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .bold, size: 18),
            alignment: .left,
            lineHeightMultiple: 0.75,
            lineBreakMode: .none
        )
        cardNameLabel.configureText(
            withKey: info.title ?? "",
            andConfiguration: cardNameLabelConfig
        )
        cardNameLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardName
        return cardNameLabel
    }
    
    func setCardNumLabel(_ info: PGCardCellViewModel) -> UILabel {
        let cardNumLabel = UILabel()
        cardNumLabel.isHidden = info.subtitle == nil
        cardNumLabel.textColor = .lisboaGray
        cardNumLabel.numberOfLines = 1
        let cardNumLabelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 14),
            alignment: .left,
            lineBreakMode: .none
        )
        if let subtitle = info.subtitle {
            cardNumLabel.configureText(
                withKey: subtitle,
                andConfiguration: cardNumLabelConfig
            )
        }
        cardNumLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardNum
        return cardNumLabel
    }
    
    func setStackView(_ info: PGCardCellViewModel) {
        removeArrangedSubviewsIfNeeded()
        let leftStackView = setStackLeftView(info)
        stackView.addArrangedSubview(leftStackView)
        let view = UIView()
        view.backgroundColor = .clear
        stackView.addArrangedSubview(view)
        let rightStackView = setStackRightView(info)
        stackView.addArrangedSubview(rightStackView)
    }
    
    func setAccessibilityIdentifiers(info: PGCardCellViewModel) {
        cardImg.accessibilityIdentifier = "pgClassic_\(info.cardType)_card_image"
        self.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardView
    }
}

extension ClassicCardProductCell: ClassicCardProductActivateViewDelegate {
    func activateCard(_ card: Any?) {
        delegate?.activateCard(card)
    }
}

extension ClassicCardProductCell: CardProductTableViewCellProtocol {
    func setCellDelegate(_ delegate: CardProductTableViewCellDelegate?) {
        self.delegate = delegate
    }
}

extension ClassicCardProductCell: SeparatorCellProtocol {
    func hideSeparator(_ hide: Bool) {
        separationView.isHidden = hide
    }
}

extension ClassicCardProductCell: DiscretePGCellProtocol {
    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
    }
}

extension ClassicCardProductCell: RoundedCellProtocol {
    func roundCorners() {
        frameView.roundAllCorners()
    }
    
    func roundTopCorners() {
        frameView.roundTopCorners()
    }
    
    func roundBottomCorners() {
        frameView.roundBottomCorners()
    }
    
    func removeCorners() {
        frameView.removeCorners()
    }
    
    func onlySideFrame() {
        frameView.onlySideFrame()
    }
}

extension ClassicCardProductCell: AccessibilityCapable { }
