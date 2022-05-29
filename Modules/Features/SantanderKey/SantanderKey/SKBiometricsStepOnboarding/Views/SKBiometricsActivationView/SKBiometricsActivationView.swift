//
//  SKBiometricsActivationView.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 24/2/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import ESUI
import UIOneComponents

private extension SKBiometricsActivationView {}

final class SKBiometricsActivationView: XibView {
    @IBOutlet private weak var oneGradientView: OneGradientView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var biometricsToggleView: SKBiometricsToggleView!
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
        setupView(type, enabled: enabled)
        setAccessibilityIds(type)
    }
}

private extension SKBiometricsActivationView {
    func bind() {
        bindToggle()
    }

    func bindToggle() {
        biometricsToggleView
            .publisher
            .sink { [unowned self] isOn in
                self.subject.send(isOn)
            }
            .store(in: &subscriptions)
    }
    
    func setupView(_ type: BiometryTypeEntity, enabled: Bool) {
        var title = ""
        var subTitle = ""
        switch type {
        case .faceId:
            title = "sanKey_title_wantActivateFaceID"
            subTitle = "sanKey_text_activateFaceID"
        case .touchId:
            title = "sanKey_title_wantActivateTouchID"
            subTitle = "sanKey_text_activateTouchID"
        default:
            break
        }
        oneGradientView.setupType(.oneGrayGradient(direction: .topToBottom))
        biometricsToggleView.configure(type, enabled: enabled)
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
    }
    
    func setAccessibilityIds(_ type: BiometryTypeEntity) {
        self.view?.accessibilityIdentifier = AccessibilitySKBiometricsActivationView.view
        switch type {
        case .faceId:
            self.titleLabel.accessibilityIdentifier = AccessibilitySKBiometricsActivationView.titleFaceIdLabel
            self.subtitleLabel.accessibilityIdentifier = AccessibilitySKBiometricsActivationView.subTitleFaceIdLabel
        case .touchId:
            self.titleLabel.accessibilityIdentifier = AccessibilitySKBiometricsActivationView.titleTouchIdLabel
            self.subtitleLabel.accessibilityIdentifier = AccessibilitySKBiometricsActivationView.subTitleTouchIdLabel
        default:
            break
        }
    }
}
