//
//  NotificationsViewController.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 04/11/2020.
//

import Foundation
import CoreFoundationLib
import UI
enum NotificationViewControllerState {
    case unknown
    case initial
    case backToForeGround
}
protocol NotificationsViewProtocol: CardBoardingStepView, LoadingViewPresentationCapable, OldDialogViewPresentationCapable {
    func askForSettings()
    func pushNotificationRequestResult(result: Bool)
    func pushNotificationsEnabledResult(result: Bool)
}

final class NotificationsViewController: UIViewController {
    
    @IBOutlet private weak var notificationStackView: UIStackView!
    @IBOutlet private weak var cardBoardingActivationSuccessView: CardBoardingActivationSuccessView!
    @IBOutlet private weak var bottomButtonsView: CardBoardingTabBar!
    @IBOutlet private weak var notificationsView: UIView!
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    @IBOutlet private weak var disabledLabel: UILabel!
    @IBOutlet private weak var thirdLabel: UILabel!
    @IBOutlet private weak var thirdIconImageView: UIImageView!
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var secondIconImageView: UIImageView!
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var firstIconImageView: UIImageView!
    @IBOutlet private weak var alertLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var notificationsLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var notificationsIconImageView: UIImageView!
    let presenter: NotificationsPresenterProtocol
    var isFirstStep: Bool = false
    var viewState: NotificationViewControllerState = .unknown
    var notificationActiveMessageAppeared: Bool = false
    private var timer: Timer?
    init(nibName: String?, bundle: Bundle?, presenter: NotificationsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardBoardingActivationSuccessView.isHidden = true
        self.cardBoardingActivationSuccessView.setDescriptionText("cardBoarding_text_notificationsActivated")
        self.setupView()
        self.setupNotificationView()
        self.setAccesibilityIdentifiers()
        self.setupBottomButtonsView()
        self.registerObservers()
    }
    
    deinit {
        self.unregisterObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notificationActiveMessageAppeared = self.notificationsSwitch.isOn
        self.viewState = .initial
        self.presenter.viewWillAppear()
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectNext() {
        self.presenter.didSelectNext()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.applyGradientBackground(colors: [.white, .skyGray, .white], locations: [0.0, 0.9, 0.2])
        self.notificationsView.drawBorder(cornerRadius: 6, color: .mediumSkyGray, width: 1)
        self.notificationsView.drawShadow(offset: (x: 0, y: 2), opacity: 0.7, color: .lightSanGray, radius: 3)
    }
    
    @IBAction func didTapOnEnableNotifications(_ sender: Any) {
        self.presenter.requestPushNotificationAccess()
    }
}

private extension NotificationsViewController {
    
    func setupView() {
        let titleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 38),
        lineHeightMultiple: 0.80)
        let subtitleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20),
        lineHeightMultiple: 0.80)
        self.titleLabel.configureText(withKey: "cardBoarding_title_notifications",
        andConfiguration: titleConfiguration)
        self.subtitleLabel.configureText(withKey: "cardBoarding_text_descriptionNotifications",
        andConfiguration: subtitleConfiguration)
        self.titleLabel.textColor = .black
        self.subtitleLabel.textColor = .lisboaGray
        self.disabledLabel.textColor = .lisboaGray
        self.disabledLabel.configureText(withKey: "onboarding_label_disabled",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 17)))
    }
    
    func setupNotificationView() {
        let middleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16),
        lineHeightMultiple: 0.90)
        self.notificationsIconImageView.image = Assets.image(named: "icnBell")
        self.notificationsLabel.textColor = .lisboaGray
        self.notificationsLabel.configureText(withKey: "onboarding_label_notifications",
                                              andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 20)))
        self.descriptionLabel.configureText(withKey: "cardBoarding_text_activateNotifications",
        andConfiguration: middleConfiguration)
        self.descriptionLabel.textColor = .lisboaGray
        self.alertLabel.textColor = .lisboaGray
        self.alertLabel.configureText(withKey: "cardBoarding_label_alerts",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16)))
        self.firstIconImageView.image = Assets.image(named: "icnShorpping")
        self.secondIconImageView.image = Assets.image(named: "icnSecurityCards")
        self.thirdIconImageView.image = Assets.image(named: "icnBonuses")
        self.firstLabel.textColor = .lisboaGray
        self.firstLabel.configureText(withKey: "cardBoarding_label_shopping",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16)))
        self.secondLabel.textColor = .lisboaGray
        self.secondLabel.configureText(withKey: "cardBoarding_label_security",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16)))
        self.thirdLabel.textColor = .lisboaGray
        self.thirdLabel.configureText(withKey: "cardBoarding_label_bonuses",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16)))
    }
    
    func setAccesibilityIdentifiers() {
        self.alertLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.alert
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.title
        self.subtitleLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.subtitle
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.middle
        self.notificationsLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.notifications
        self.firstLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.labelOne
        self.secondLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.labelTwo
        self.thirdLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.labelThree
        self.firstIconImageView.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.icnOne
        self.secondIconImageView.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.icnTwo
        self.thirdIconImageView.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.icnThree
        self.disabledLabel.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.disabled
        self.notificationsView.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.cardBoardingViewNotifications
        self.bottomButtonsView.nextButton.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.continueNotifications
        self.bottomButtonsView.backButton.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.back
        self.notificationsSwitch.accessibilityIdentifier = AccessibilityCardBoarding.Notifications.switchNotification
    }
    
    func setupBottomButtonsView() {
        self.bottomButtonsView.backButton.isHidden = self.isFirstStep
        self.bottomButtonsView.fitOnBottomWithHeight(72, andBottomSpace: 0)
        self.bottomButtonsView.addBackAction(target: self, selector: #selector(didSelectBack))
        self.bottomButtonsView.addNextAction(target: self, selector: #selector(didSelectNext))
        self.bottomButtonsView.nextButton.set(localizedStylableText: localized("cardBoarding_button_next"), state: .normal)
     }
    
    func showCardBoardingActivationSuccessView() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.cardBoardingActivationSuccessView.isHidden = false
            }, completion: { [weak self] _ in
                let time = TimeInterval(2)
                self?.startTimer(withTime: time)
            })
    }
    
    func hideCardBoardingActivationSuccessView() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.cardBoardingActivationSuccessView.isHidden = true
            })
    }
    
    func startTimer(withTime time: TimeInterval) {
            self.timer = Timer.scheduledTimer(timeInterval: time,
                                              target: self,
                                              selector: #selector(closeActivatedViewInTime),
                                              userInfo: nil,
                                              repeats: false)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func closeActivatedViewInTime() {
        self.hideCardBoardingActivationSuccessView()
    }
    
    @objc func appDidBecomeActive() {
        self.viewState = .backToForeGround
        self.presenter.viewWillAppear()
    }
    
    @objc func openSettings() {
        self.presenter.openSettings()
    }
    
    @objc func canceledOpenSettings() {
        let currentState = self.notificationsSwitch.isOn
        self.notificationsSwitch.isOn = !currentState
    }

    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func unregisterObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func showDialogPermission() {
        let okAction = DialogButtonComponents(titled: localized("genericAlert_buttom_settings"),
                                                      does: self.openSettings)
        let cancelAction = DialogButtonComponents(titled: localized("generic_button_cancel"),
                                                      does: self.canceledOpenSettings)
        self.showOldDialog(title: nil, description: localized("onboarding_alert_text_permissionActivation"), acceptAction: okAction, cancelAction: cancelAction, isCloseOptionAvailable: false)
    }
    
    func handleUIforNotificationState(active: Bool) {        
        if active && viewState == .backToForeGround && !self.notificationActiveMessageAppeared {
            self.showCardBoardingActivationSuccessView()
            self.notificationActiveMessageAppeared = true
        } else if !active {
            self.notificationActiveMessageAppeared = false
        }
        self.changeUIStatus(enabled: active)
    }
    
    func changeUIStatus(enabled: Bool) {
        self.notificationsSwitch.isOn = enabled
        if enabled {
            self.disabledLabel.configureText(withKey: "onboarding_label_enabled")
        } else {
            self.disabledLabel.configureText(withKey: "onboarding_label_disabled")
        }
    }
}

extension NotificationsViewController: NotificationsViewProtocol {
    func askForSettings() {
        self.showDialogPermission()
    }
    
    func pushNotificationRequestResult(result: Bool) {
        if result {
            self.showCardBoardingActivationSuccessView()
        }
        self.changeUIStatus(enabled: result)
    }
    
    func pushNotificationsEnabledResult(result: Bool) {
        self.handleUIforNotificationState(active: result)
    }
}
