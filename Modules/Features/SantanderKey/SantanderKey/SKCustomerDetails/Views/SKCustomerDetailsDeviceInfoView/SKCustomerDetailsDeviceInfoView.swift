//
//  SKCustomerDetailsDeviceInfoView.swift
//  SantanderKey
//
//  Created by Angel Abad Perez on 12/4/22.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine
import ESUI
import SANSpainLibrary

protocol ReactiveSKCustomerDetailsDeviceInfoView {
    var publisher: AnyPublisher<SKCustomerDetailsDeviceInfoViewState, Never> { get }
}
public enum SKCustomerDetailsDeviceInfoViewState: State {
    case didTapOnLink
    case didTapOnToggle(Bool)
}

final class SKCustomerDetailsDeviceInfoView: XibView {
    @IBOutlet private weak var deviceInfoView: UIView!
    @IBOutlet private weak var terminalTitleLabel: UILabel!
    @IBOutlet private weak var terminalValueLabel: UILabel!
    @IBOutlet private weak var registerDateTitleLabel: UILabel!
    @IBOutlet private weak var registerDateValueLabel: UILabel!
    @IBOutlet private weak var aliasTitleLabel: UILabel!
    @IBOutlet private weak var aliasValueLabel: UILabel!
    @IBOutlet private weak var modelTitleLabel: UILabel!
    @IBOutlet private weak var modelValueLabel: UILabel!
    @IBOutlet private weak var dottedDivider: DottedLineView!
    @IBOutlet private weak var accessInfoContainerView: UIView!
    @IBOutlet private weak var accessInfoHorizontalStackView: UIStackView!
    @IBOutlet private weak var accessInfoImageView: UIImageView!
    @IBOutlet private weak var accessInfoLabel: UILabel!
    @IBOutlet private weak var linkDeviceButtonContainerView: UIView!
    @IBOutlet private weak var linkDeviceButton: OneFloatingButton!
    public let stateSubject = PassthroughSubject<SKCustomerDetailsDeviceInfoViewState, Never>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        linkDeviceButton.addTarget(self, action: #selector(didTapLink), for: .touchUpInside)
    }
    
    public func configure(customerDetailType: SKCustomerDetailsDeviceInfoType) {
        configureViewsVisibility(customerDetailType: customerDetailType)
        configureAccessInfoImageView(customerDetailType: customerDetailType)
        accessInfoLabel.configureText(withKey: customerDetailType.accessInfoTitleKey ?? "")
        configureLinkDeviceButton(customerDetailType: customerDetailType)
        switch customerDetailType {
        case .clientRegistered(let deviceManu, let creationDate, let deviceAlias, let deviceModel),
                .registeredOtherDevice(let deviceManu, let creationDate, let deviceAlias, let deviceModel),
                .registeredOtherSesion(let deviceManu, let creationDate, let deviceAlias, let deviceModel):
            configureDeviceInfoLabels(deviceManu: deviceManu, creationDate: creationDate, deviceAlias: deviceAlias, deviceModel: deviceModel)
        case .clientNotRegistered1, .clientNotRegistered2:
            configureInfoHorizontalStackView(alignment: .top)
        case .error:
            configureDeviceInfoLabels(deviceManu: "-", creationDate: "-", deviceAlias: "-", deviceModel: "-")
        }
        setAccessibilityIds(customerDetailType: customerDetailType)
    }
}

private extension SKCustomerDetailsDeviceInfoView {
    enum Constants {
        enum Terminal {
            static let titleKey: String = "deviceRegister_label_terminal"
            static let subtitleAccessibilityId: String = "santanderKeyLabelTerminal"
        }
        enum Alias {
            static let titleKey: String = "deviceRegister_label_alias"
            static let subtitleAccessibilityId: String = "sanKeyLabelAlias"
        }
        enum RegisterDate {
            static let titleKey: String = "deviceRegister_label_registrationDate"
            static let subtitleAccessibilityId: String = "santanderKeyLabelRegistrationDate"
        }
        enum Model {
            static let titleKey: String = "deviceRegister_label_modelPhone"
            static let subtitleAccessibilityId: String = "sanKeyLabelModelPhone"
        }
    }
    
    func setupView() {
        setupLabels()
        setupDottedDivider()
        configureInfoHorizontalStackView()
    }
    
    func setupLabels() {
        configureLabels([terminalTitleLabel, registerDateTitleLabel, aliasTitleLabel, modelTitleLabel],
                        fontName: .oneB200Regular,
                        textColor: .oneBrownishGray)
        configureLabels([terminalValueLabel, registerDateValueLabel, aliasValueLabel, modelValueLabel],
                        fontName: .oneB300Regular,
                        textColor: .oneLisboaGray)
        configureLabels([accessInfoLabel],
                        fontName: .oneB300Regular,
                        textColor: .oneBrownishGray)
        terminalTitleLabel.configureText(withKey: Constants.Terminal.titleKey)
        registerDateTitleLabel.configureText(withKey: Constants.RegisterDate.titleKey)
        aliasTitleLabel.configureText(withKey: Constants.Alias.titleKey)
        modelTitleLabel.configureText(withKey: Constants.Model.titleKey)
    }
    
    func setupDottedDivider() {
        dottedDivider.strokeColor = .oneMediumSkyGray
    }
    
    func configureLabels(_ labels: [UILabel], fontName: FontName, textColor: UIColor) {
        labels.forEach {
            $0.font = .typography(fontName: fontName)
            $0.textColor = textColor
        }
    }
    
    func configureViewsVisibility(customerDetailType: SKCustomerDetailsDeviceInfoType) {
        deviceInfoView.isHidden = customerDetailType.hidesInfoView
        linkDeviceButtonContainerView.isHidden = customerDetailType.hidesLinkView
    }
    
    func configureAccessInfoImageView(customerDetailType: SKCustomerDetailsDeviceInfoType) {
        accessInfoImageView.image = ESAssets.image(named: customerDetailType.accessInfoImage)
        accessInfoContainerView.isHidden = customerDetailType.hidesContainer
    }
    
    func configureInfoHorizontalStackView(alignment: UIStackView.Alignment = .center) {
        accessInfoHorizontalStackView.alignment = alignment
    }
    
    func configureDeviceInfoLabels(deviceManu: String?, creationDate: String?, deviceAlias: String?, deviceModel: String?) {
        terminalValueLabel.text = deviceManu
        registerDateValueLabel.text = creationDate
        aliasValueLabel.text = deviceAlias
        modelValueLabel.text = deviceModel
    }
    
    func configureLinkDeviceButton(customerDetailType: SKCustomerDetailsDeviceInfoType) {
        guard let linkDeviceButtonTitle = customerDetailType.linkDeviceButtonTitle else { return }
        linkDeviceButton.configureWith(type: .secondary,
                                       size: .medium(
                                        OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized(linkDeviceButtonTitle),
                                                                                        icons: .none,
                                                                                        fullWidth: false)),
                                       status: .ready)
    }
    
    func setAccessibilityIds(customerDetailType: SKCustomerDetailsDeviceInfoType) {
        terminalTitleLabel.accessibilityIdentifier = Constants.Terminal.titleKey
        terminalValueLabel.accessibilityIdentifier = Constants.Terminal.subtitleAccessibilityId
        aliasTitleLabel.accessibilityIdentifier = Constants.Alias.titleKey
        aliasValueLabel.accessibilityIdentifier = Constants.Alias.subtitleAccessibilityId
        registerDateTitleLabel.accessibilityIdentifier = Constants.RegisterDate.titleKey
        registerDateValueLabel.accessibilityIdentifier = Constants.RegisterDate.subtitleAccessibilityId
        modelTitleLabel.accessibilityIdentifier = Constants.Model.titleKey
        modelValueLabel.accessibilityIdentifier = Constants.Model.subtitleAccessibilityId
        accessInfoImageView.accessibilityIdentifier = customerDetailType.accessInfoImage
        accessInfoLabel.accessibilityIdentifier = customerDetailType.accessInfoTitleKey
        linkDeviceButton.accessibilityIdentifier = customerDetailType.linkDeviceButtonTitle
    }
    
    @objc func didTapLink() {
        stateSubject.send(.didTapOnLink)
    }
}

extension SKCustomerDetailsDeviceInfoView: ReactiveSKCustomerDetailsDeviceInfoView {
    var publisher: AnyPublisher<SKCustomerDetailsDeviceInfoViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
