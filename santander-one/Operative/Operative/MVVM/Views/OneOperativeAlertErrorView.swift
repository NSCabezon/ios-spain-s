//
//  OneOperativeAlertErrorView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 22/12/21.
//

import UIOneComponents
import UI
import CoreFoundationLib
import OpenCombine

public struct OneOperativeAlertErrorViewData {
    let iconName: String?
    let alertTitle: String?
    let alertDescription: String
    let floatingButtonText: LocalizedStylableText
    public var floatingButtonAction: (() -> Void)?
    public let typeBottomSheet: BottomSheetComponent
    let viewAccessibilityIdentifier: String
    
    public init(iconName: String? = nil, alertTitle: String? = nil, alertDescription: String, floatingButtonText: LocalizedStylableText, floatingButtonAction: (() -> Void)? = nil, typeBottomSheet: BottomSheetComponent = .all, viewAccessibilityIdentifier: String) {
        self.iconName = iconName
        self.alertTitle = alertTitle
        self.alertDescription = alertDescription
        self.floatingButtonText = floatingButtonText
        self.floatingButtonAction = floatingButtonAction
        self.typeBottomSheet = typeBottomSheet
        self.viewAccessibilityIdentifier = viewAccessibilityIdentifier
    }
}

// Reactive
public protocol ReactiveOneOperativeAlertErrorView {
    var publisher: AnyPublisher<ReactiveOneOperativeAlertErrorViewState, Never> { get }
}

public enum ReactiveOneOperativeAlertErrorViewState: State {
    case didTapAcceptButton(action: (() -> Void)?)
}

public final class OneOperativeAlertErrorView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconContainerView: UIView!
    @IBOutlet private weak var alertTitle: UILabel!
    @IBOutlet private weak var alertDescription: UILabel!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    
    private var floatingButtonAction: (() -> Void)?
    
    // Reactive
    private let stateSubject = PassthroughSubject<ReactiveOneOperativeAlertErrorViewState, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setData(_ data: OneOperativeAlertErrorViewData) {
        self.setIconImage(iconName: data.iconName)
        self.setLabelsText(data)
        self.setFloatingButtonTitle(title: data.floatingButtonText)
        self.floatingButtonAction = data.floatingButtonAction
        self.setAccessibilityIdentifiers(data)
    }
}

private extension OneOperativeAlertErrorView {
    func setupView() {
        self.configureLabels()
        self.configureButton()
    }
    
    func configureLabels() {
        self.alertTitle.font = .typography(fontName: .oneH300Bold)
        self.alertTitle.textColor = .oneLisboaGray
        self.alertDescription.font = .typography(fontName: .oneB400Regular)
        self.alertDescription.textColor = .oneLisboaGray
    }
    
    func configureButton() {
        self.floatingButton.isEnabled = true
        self.floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
    }
    
    func setLabelsText(_ data: OneOperativeAlertErrorViewData) {
        self.alertTitle.isHidden = data.alertTitle == nil
        if let title = data.alertTitle {
            self.alertTitle.configureText(withKey: title)
        }
        self.alertDescription.configureText(withKey: data.alertDescription)
    }
    
    func setIconImage(iconName: String?) {
        self.iconContainerView.isHidden = iconName == nil
        guard let iconName = iconName else {
            return
        }
        self.iconImageView.image = Assets.image(named: iconName)
    }
    
    func setFloatingButtonTitle(title: LocalizedStylableText) {
        self.floatingButton.configureWith(type: .primary,
                                          size: .medium(
                                            OneFloatingButton.ButtonSize.MediumButtonConfig(
                                                title: title.text,
                                                icons: .none,
                                                fullWidth: false
                                            )
                                          ),
                                          status: .ready)
    }
    
    func setAccessibilityIdentifiers(_ data: OneOperativeAlertErrorViewData) {
        self.view?.accessibilityIdentifier = data.viewAccessibilityIdentifier
        self.iconImageView.accessibilityIdentifier = data.iconName
        self.alertTitle.accessibilityIdentifier = data.viewAccessibilityIdentifier + "Title"
        self.alertDescription.accessibilityIdentifier = data.viewAccessibilityIdentifier + "Description"
    }
    
    @objc func didTapFloatingButton() {
        stateSubject.send(.didTapAcceptButton(action: self.floatingButtonAction))
    }
}

// Reactive
extension OneOperativeAlertErrorView: ReactiveOneOperativeAlertErrorView {

    public var publisher: AnyPublisher<ReactiveOneOperativeAlertErrorViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
