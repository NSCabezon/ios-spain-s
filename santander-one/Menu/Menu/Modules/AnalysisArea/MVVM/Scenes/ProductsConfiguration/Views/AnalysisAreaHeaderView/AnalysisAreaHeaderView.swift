//
//  AnalysisAreaHeaderView.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 16/3/22.
//

import Foundation
import UI
import UIKit
import UIOneComponents
import OpenCombine
import CoreFoundationLib

final class AnalysisAreaHeaderView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notificationView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    private var subject = PassthroughSubject<Void, Never>()
    public var publisher: AnyPublisher<Void, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var oneNotificationView: OneNotificationsView = {
        let view = OneNotificationsView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

extension AnalysisAreaHeaderView {
    func showUpdateError() {
        setupUpdateErrorNotificationView()
        notificationView.isHidden = false
    }
    
    func showNetworkError() {
        setupNetworkErrorNotificationView()
        notificationView.isHidden = false
    }
}

private extension AnalysisAreaHeaderView {
    func setupView() {
        setupLabels()
        bindOneNotificationView()
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setupLabels() {
        titleLabel.font = .typography(fontName: .oneH300Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.text = localized("analysis_label_chooseProducts")
        subtitleLabel.font = .typography(fontName: .oneB300Regular)
        subtitleLabel.textColor = .oneLisboaGray
        subtitleLabel.text = localized("analysis_label_accountsAndCardsConfiguration")
    }
    
    func setupUpdateErrorNotificationView() {
        let oneNotificationViewRepresented = OneNotificationViewRepresented(type: .textAndLink(stringKey: "analysis_label_alertDataOutdated",
                                                                            linkKey: "generic_button_update", linkIsEnabled: true),
                                                                            defaultColor: .onePaleYellow,
                                                                            inactiveColor: nil)
        oneNotificationView.setNotificationView(with: oneNotificationViewRepresented)
        oneNotificationView.removeFromSuperview()
        notificationView.addSubview(oneNotificationView)
        oneNotificationView.fullFit()
        notificationView.isHidden = true
    }
    
    func setupNetworkErrorNotificationView() {
        let oneNotificationViewRepresented = OneNotificationViewRepresented(type: .textOnly(stringKey: "analysis_label_alertConnectionError"),
                                                                            defaultColor: .onePaleYellow,
                                                                            inactiveColor: nil)
        oneNotificationView.setNotificationView(with: oneNotificationViewRepresented)
        oneNotificationView.removeFromSuperview()
        notificationView.addSubview(oneNotificationView)
        oneNotificationView.fullFit()
        notificationView.isHidden = true
    }
    
    func bindOneNotificationView() {
        oneNotificationView
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { _ in
                self.updateProducts()
            }.store(in: &subscriptions)
    }
    
    func updateProducts() {
        self.notificationView.isHidden = true
        self.subject.send()
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.productsConfigurationHeaderTitleLabel
        subtitleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.productsConfigurationHeaderSubtitleLabel
    }
    
    func setAccessibilityInfo() {
        titleLabel.accessibilityLabel = localized("analysis_label_chooseProducts")
        subtitleLabel.accessibilityLabel = localized("voiceover_accountsAndCardsConfiguration")
        accessibilityElements = [titleLabel, notificationView, subtitleLabel].compactMap {$0}
    }
}

extension AnalysisAreaHeaderView: AccessibilityCapable {}

struct OneNotificationViewRepresented: OneNotificationRepresentable {
    var type: OneNotificationType
    var defaultColor: UIColor
    var inactiveColor: UIColor?
    var titleAccessibilityLabel: String?
}
