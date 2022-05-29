import UI
import CoreFoundationLib

protocol ClassicCardProductActivateViewDelegate: AnyObject {
    func activateCard(_ card: Any?)
}

final class ClassicCardProductActivateView: DesignableView {
    @IBOutlet private weak var activateLabel: UILabel!
    @IBOutlet private weak var arrowActivateImage: UIImageView!
    
    private var card: Any?
    weak var delegate: ClassicCardProductActivateViewDelegate?

    override func commonInit() {
        super.commonInit()
        setupView()
    }
    
    func setCard(_ card: Any?) {
        self.card = card
    }
}

private extension ClassicCardProductActivateView {
    func setupView() {
        backgroundColor = .clear
        configView()
        setAccsessibilityIdentifiers()
    }
    
    func configView() {
        setActivateLabel()
        setArrowActivateImage()
        addTouchAction()
    }
    
    func setActivateLabel() {
        let labelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .bold, size: 14),
            alignment: .right,
            lineBreakMode: .none
        )
        activateLabel.configureText(
            withLocalizedString: localized("pg_button_startUsing"),
            andConfiguration: labelConfig
        )
        activateLabel.textColor = .darkTorquoise
        activateLabel.numberOfLines = 1
        activateLabel.accessibilityIdentifier = AccessibilityGlobalPosition.btnStartUsing
    }
    
    func setArrowActivateImage() {
        arrowActivateImage.image = Assets.image(named: "icnGoPG")
    }
    
    func addTouchAction() {
        addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(activateButtonDidPressed)
            )
        )
        isUserInteractionEnabled = true
    }
    
    @objc func activateButtonDidPressed() {
        delegate?.activateCard(card)
    }
    
    func setAccsessibilityIdentifiers() {
        activateLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardActivateLabel
        arrowActivateImage.accessibilityIdentifier = AccessibilityGlobalPosition.pgClassicCardActivateArrow
    }
}
