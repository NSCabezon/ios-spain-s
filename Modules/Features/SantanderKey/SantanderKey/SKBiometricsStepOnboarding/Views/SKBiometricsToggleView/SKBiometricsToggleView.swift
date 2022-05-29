//
//  SKBiometricsToggleView.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 25/2/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import UIOneComponents

private extension SKBiometricsToggleView {}

final class SKBiometricsToggleView: XibView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var biometricsToggleView: OneToggleView!

    private var subscriptions = Set<AnyCancellable>()
    private var subject = PassthroughSubject<Bool, Never>()
    public lazy var publisher: AnyPublisher<Bool, Never> = {
        return subject.eraseToAnyPublisher()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        bind()
    }

    func configure(_ type: BiometryTypeEntity, enabled: Bool) {
        setupView(type)
        setupSwitch(enabled: enabled)
        setAccessibilityIds(type)
    }
}

private extension SKBiometricsToggleView {
    func setupSwitch(enabled: Bool) {
        biometricsToggleView.isOn = enabled
    }

    func bind() {
        bindSwitchInteractions()
    }

    func bindSwitchInteractions() {
        biometricsToggleView
            .publisher
            .sink { [unowned self] isOn in
                subject.send(isOn)
            }
            .store(in: &subscriptions)
    }

    func setupView(_ type: BiometryTypeEntity) {
        var title = ""
        var subTitle = ""
        switch type {
        case .faceId:
            title = "sanKey_title_faceId"
            subTitle = "sanKey_protectOperationsFaceId"
        case .touchId:
            title = "sanKey_title_touchId"
            subTitle = "sanKey_protectOperationsFingerprint"
        default:
            break
        }
        titleLabel.configureText(withKey: title,
                                 andConfiguration: LocalizedStylableTextConfiguration(
                                     font: .santander(
                                         family: .headline,
                                         type: .bold,
                                         size: 20)))
        subtitleLabel.configureText(withKey: subTitle,
                                    andConfiguration: LocalizedStylableTextConfiguration(
                                        font: .santander(
                                            family: .micro,
                                            type: .regular,
                                            size: 14)))
        biometricsToggleView.oneSize = .big
        biometricsToggleView.isOn = false
    }

    func setAccessibilityIds(_ type: BiometryTypeEntity) {
        view?.accessibilityIdentifier = AccessibilitySKBiometricsToggleView.view
        switch type {
        case .faceId:
            titleLabel.accessibilityIdentifier = AccessibilitySKBiometricsToggleView.titleFaceIdLabel
            subtitleLabel.accessibilityIdentifier = AccessibilitySKBiometricsToggleView.subTitleFaceIdLabel
        case .touchId:
            titleLabel.accessibilityIdentifier = AccessibilitySKBiometricsToggleView.titleTouchIdLabel
            subtitleLabel.accessibilityIdentifier = AccessibilitySKBiometricsToggleView.subTitleTouchIdLabel
        default:
            break
        }
    }
}
