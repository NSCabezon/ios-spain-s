//
//  SKCustomerDetailsBodyView.swift
//  SantanderKey
//
//  Created by Angel Abad Perez on 11/4/22.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine
import ESUI
import SANSpainLibrary

final class SKCustomerDetailsBodyView: XibView {
    @IBOutlet private weak var gradientView: OneGradientView!
    @IBOutlet private weak var biometricsToggleView: SKBiometricsToggleView!
    @IBOutlet private weak var linkedDeviceLabel: UILabel!
    @IBOutlet private weak var detailsDeviceInfoView: SKCustomerDetailsDeviceInfoView!
    
    private var subscriptions = Set<AnyCancellable>()
    private var subject: PassthroughSubject<SKCustomerDetailsDeviceInfoViewState, Never> {
        return detailsDeviceInfoView.stateSubject
    }
    
    var publisher: AnyPublisher<SKCustomerDetailsDeviceInfoViewState, Never> {
        detailsDeviceInfoView.publisher
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindToggle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bindToggle()
    }
    
    public func configure(biometryType: BiometryTypeEntity, biometryEnabled: Bool, customerDetailType: SKCustomerDetailsDeviceInfoType) {
        configureBiometricsToggleView(type: biometryType, enabled: biometryEnabled)
        configureDeviceInfoView(customerDetailType: customerDetailType)
    }
}

private extension SKCustomerDetailsBodyView {
    enum Constants {
        enum View {
            static let accessibilityId: String = "santanderKeyViewAuthenticationSystem"
        }
        enum LinkedDeviceLabel {
            static let key: String = "santanderKey_label_linkedDevice"
        }
    }
    
    func setupView() {
        setupGradient()
        setupLabels()
        setAccessibilityIds()
    }
    
    func setupGradient() {
        gradientView.setupType(.oneGrayGradient(direction: GradientDirection.topToBottom))
    }
    
    func setupLabels() {
        linkedDeviceLabel.font = .typography(fontName: .oneH200Bold)
        linkedDeviceLabel.textColor = .oneLisboaGray
        linkedDeviceLabel.configureText(withKey: Constants.LinkedDeviceLabel.key)
    }
    
    func configureBiometricsToggleView(type: BiometryTypeEntity, enabled: Bool) {
        biometricsToggleView.configure(type, enabled: enabled)
    }
    
    func configureDeviceInfoView(customerDetailType: SKCustomerDetailsDeviceInfoType) {
        detailsDeviceInfoView.configure(customerDetailType: customerDetailType)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = Constants.View.accessibilityId
        linkedDeviceLabel.accessibilityIdentifier = Constants.LinkedDeviceLabel.key
    }
    
    func bindToggle() {
        biometricsToggleView
            .publisher
            .sink { [unowned self] isOn in
                subject.send(.didTapOnToggle(isOn))
            }
            .store(in: &subscriptions)
    }
}
