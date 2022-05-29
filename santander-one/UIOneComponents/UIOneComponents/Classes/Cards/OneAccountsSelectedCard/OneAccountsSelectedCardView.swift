//
//  OneAccountsSelectedCardView.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 31/08/2021.
//

import UI
import CoreFoundationLib
import OpenCombine

public protocol OneAccountsSelectedCardDelegate: AnyObject {
    func didSelectOriginButton()
    func didSelectDestinationButton()
}

//Reactive
public enum ReactiveOneAccountsSelectedState: State {
    case didSelectOrigin
    case didSelectDestination
}
public protocol ReactiveOneAccountsSelectedCard {
    var publisher: AnyPublisher<ReactiveOneAccountsSelectedState, Never> { get }
}

public final class OneAccountsSelectedCardView: XibView {
    @IBOutlet private weak var containerView: UIStackView!
    @IBOutlet private weak var originTitleLabel: UILabel!
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var originExtraImageView: UIImageView!
    @IBOutlet private weak var originDescriptionLabel: UILabel!
    @IBOutlet private weak var originChangeButton: UIButton!
    @IBOutlet private weak var originAmountLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var destinationView: UIView!
    @IBOutlet private weak var destinationTitleLabel: UILabel!
    @IBOutlet private weak var destinationExtraImageView: UIImageView!
    @IBOutlet private weak var destinationDescriptionLabel: UILabel!
    @IBOutlet private weak var destinationChangeButton: UIButton!
    @IBOutlet private weak var destinationCountryLabel: UILabel!
    @IBOutlet private weak var destinationImageContainer: UIView!
    @IBOutlet private weak var trailingStackViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerImageView: UIView!
    @IBOutlet private weak var arrowContainerView: UIView!

    private var viewModel: OneAccountsSelectedCardViewModel?
    public weak var delegate: OneAccountsSelectedCardDelegate?
    private let changeText = "generic_button_change"
    
    //Reactive
    private let stateSubject = PassthroughSubject<ReactiveOneAccountsSelectedState, Never>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setupAccountViewModel(_ viewModel: OneAccountsSelectedCardViewModel) {
        self.viewModel = viewModel
        self.configureByStatus(viewModel.statusCard)
        self.setLabelText()
        self.configureImageViews(viewModel)
        self.setAccessibility {
            self.setAccessibilityInfo()
        }
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawArrow(rect)
    }
}

private extension OneAccountsSelectedCardView {
    func configureView() {
        self.configureViews()
        self.configureLabels()
        self.configureButtons()
        self.setAccessibilityIdentifiers()
    }
    
    func configureViews() {
        self.setOneCornerRadius(type: .oneShRadius8)
        self.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.layer.borderWidth = 1
        self.arrowImageView.image = Assets.image(named: "icnArrowRight")?.withRenderingMode(.alwaysTemplate)
        self.arrowImageView.tintColor = UIColor.mediumSkyGray
        self.arrowContainerView.setOneCornerRadius(type: .oneShRadiusCircle)
        self.arrowContainerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.arrowContainerView.layer.borderWidth = 1
    }
    
    func configureLabels() {
        self.originTitleLabel.font = .typography(fontName: .oneB200Bold)
        self.originDescriptionLabel.font = .typography(fontName: .oneB200Regular)
        self.originAmountLabel.font = .typography(fontName: .oneB200Regular)
        self.destinationTitleLabel.font = .typography(fontName: .oneB200Bold)
        self.destinationDescriptionLabel.font = .typography(fontName: .oneB200Regular)
        self.destinationCountryLabel.font = .typography(fontName: .oneB200Regular)
    }
    
    func configureButtons() {
        self.originChangeButton.tintColor = UIColor.darkTorquoise
        self.originChangeButton.titleLabel?.font = .typography(fontName: .oneB200Bold)
        self.originChangeButton.addTarget(self, action:  #selector(didSelectOriginButton), for: .touchUpInside)
        self.destinationChangeButton.tintColor = UIColor.darkTorquoise
        self.destinationChangeButton.titleLabel?.font = .typography(fontName: .oneB200Bold)
        self.destinationChangeButton.addTarget(self, action:  #selector(didSelectDestinationButton), for: .touchUpInside)
    }
    
    func configureImageViews(_ viewModel: OneAccountsSelectedCardViewModel) {
        self.originExtraImageView.image = Assets.image(named: viewModel.originImage ?? "")?.withRenderingMode(.alwaysTemplate)
        self.originExtraImageView.tintColor = UIColor.darkTorquoise
        self.destinationExtraImageView.image = Assets.image(named: viewModel.destinationImage ?? "")
        self.imageContainer.isHidden = self.originExtraImageView.image == nil
        self.destinationImageContainer.isHidden = self.destinationExtraImageView.image == nil
    }
    
    func configureByStatus(_ status: OneAccountsSelectedCardViewModel.StatusCard) {
        self.centerImageView.isHidden = status == .contracted
        self.destinationView.isHidden = status == .contracted
        self.destinationExtraImageView.isHidden = status == .contracted
        self.trailingStackViewConstraint.isActive = status == .contracted
        self.destinationTitleLabel.isHidden = status == .contracted
        self.destinationDescriptionLabel.isHidden = status == .contracted
    }
    
    func setLabelText() {
        self.originTitleLabel.text = self.viewModel?.originTitle
        self.originAmountLabel.text = self.viewModel?.formattedAmount
        self.originDescriptionLabel.text = self.viewModel?.originDescription
        self.destinationTitleLabel.text = self.viewModel?.destinationTitle
        self.destinationDescriptionLabel.text = self.viewModel?.destinationDescription
        self.destinationCountryLabel.text = self.viewModel?.destinationCountry
        self.originChangeButton.setTitle(localized(self.changeText), for: .normal)
        self.destinationChangeButton.setTitle(localized(self.changeText), for: .normal)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.containerView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedCardView + (suffix ?? "")
        self.originTitleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedOriginTitle + (suffix ?? "")
        self.originExtraImageView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedOriginIcn + (suffix ?? "")
        self.originDescriptionLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedOriginDescription + (suffix ?? "")
        self.originChangeButton.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedBtnChangeOrigin + (suffix ?? "")
        self.originAmountLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedAmount + (suffix ?? "")
        self.arrowImageView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedSeparatorIcn + (suffix ?? "")
        self.destinationTitleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedDestinationTitle + (suffix ?? "")
        self.destinationDescriptionLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedDestinationDescription + (suffix ?? "")
        self.destinationExtraImageView.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedDestinationIcn + (suffix ?? "")
        self.destinationChangeButton.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedBtnChangeDestination + (suffix ?? "")
        self.destinationCountryLabel.accessibilityIdentifier = AccessibilityOneComponents.oneAccountsSelectedDestinationCountry + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.view?.isAccessibilityElement = (self.viewModel?.statusCard ?? .contracted) != .contracted
        self.view?.accessibilityLabel = localized("voiceover_summarySourceRecipientAccounts")
        self.originTitleLabel.accessibilityLabel = "\(localized("voiceover_sourceAccount").text) \(self.originTitleLabel.text ?? "")"
        let originDescriptionNumber = (self.originDescriptionLabel.text?.dropFirst() ?? "").map { String($0) + " " }.joined()
        self.originDescriptionLabel.accessibilityLabel = "\(localized("voiceover_accountEnds").text) \(originDescriptionNumber)"
        self.originChangeButton.accessibilityLabel = "\(localized("voiceover_changeAccount"))"
        self.originAmountLabel.accessibilityLabel = self.viewModel?.originAmount?.getAccessibilityAmountText()
        self.destinationTitleLabel.accessibilityLabel = "\(localized("voiceover_recipientName")) \(self.destinationTitleLabel.text ?? "")"
        let destinationDescriptionNumber = (self.destinationDescriptionLabel.text?.dropFirst() ?? "").map { String($0) + " " }.joined()
        self.destinationDescriptionLabel.accessibilityLabel = "\(localized("voiceover_accountEnds")) \(destinationDescriptionNumber)"
        self.destinationChangeButton.accessibilityLabel = "\(localized("voiceover_changeRecipientAccount"))"
        self.accessibilityElements = [self.originTitleLabel, self.originDescriptionLabel, self.originAmountLabel, self.originChangeButton, self.destinationTitleLabel, self.destinationDescriptionLabel, self.destinationCountryLabel, self.destinationChangeButton].compactMap{$0}
        self.viewModel?.statusCard != .contracted ? self.accessibilityElements?.insert((self.view ?? UIView()), at: 0) : nil
    }
    
    func drawArrow(_ rect: CGRect) {
        let path = UIBezierPath()
        let start = CGPoint(x: self.centerImageView.frame.width, y: 0)
        let end = CGPoint(x: 0, y: self.centerImageView.frame.maxY)
        path.move(to: start)
        path.addLine(to: end)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.mediumSkyGray.cgColor
        shapeLayer.lineWidth = 1.0
        self.centerImageView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    @objc func didSelectOriginButton() {
        self.delegate?.didSelectOriginButton()
        self.stateSubject.send(.didSelectOrigin)
    }
    
    @objc func didSelectDestinationButton() {
        self.delegate?.didSelectDestinationButton()
        self.stateSubject.send(.didSelectDestination)
    }
}

extension OneAccountsSelectedCardView: AccessibilityCapable {}

extension OneAccountsSelectedCardView: ReactiveOneAccountsSelectedCard {
    
    public var publisher: AnyPublisher<ReactiveOneAccountsSelectedState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}

