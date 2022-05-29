//
//  AppPermissionsViewController.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 27/04/2020.
//

import UI
import CoreFoundationLib

protocol AppPermissionsViewProtocol: UIViewController {
    var presenter: AppPermissionsPresenterProtocol { get set }
    func setPermissions(permission: PermissionsViewModel)
    func showComingSoonToast()
    func turnOffNotificationsSwitch()
}

final class AppPermissionsViewController: UIViewController {
    var presenter: AppPermissionsPresenterProtocol
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var iconHeaderimageView: UIImageView!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var localizationTitleLabel: UILabel!
    @IBOutlet private weak var localizationTextLabel: UILabel!
    @IBOutlet private weak var locationSwitch: UISwitch!
    @IBOutlet private weak var contactsTitleLabel: UILabel!
    @IBOutlet private weak var contactsTextLabel: UILabel!
    @IBOutlet private weak var contactsSwitch: UISwitch!
    @IBOutlet private weak var photosTitleLabel: UILabel!
    @IBOutlet private weak var photosTextLabel: UILabel!
    @IBOutlet private weak var photosSwitch: UISwitch!
    @IBOutlet private weak var cameraTitleLabel: UILabel!
    @IBOutlet private weak var cameraTextLabel: UILabel!
    @IBOutlet private weak var cameraSwitch: UISwitch!
    @IBOutlet private weak var notificationsTitleLabel: UILabel!
    @IBOutlet private weak var notificationsTextLabel: UILabel!
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    @IBOutlet private var switchCollection: [UISwitch]!
    
    init(presenter: AppPermissionsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "AppPermissionsViewController", bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(becomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @IBAction private func locationSwitchTapped(_ sender: Any) {
        self.presenter.setLocationPermissions()
    }
    
    @IBAction private func contactsSwitchTapped(_ sender: Any) {
        self.presenter.setContactsPermissions()
    }
    
    @IBAction private func photosSwitchTapped(_ sender: Any) {
        self.presenter.setPhotosPermissions()
    }
    
    @IBAction private func cameraSwitchTapped(_ sender: Any) {
        self.presenter.setCameraPermissions()
    }
    
    @IBAction private func notificationsSwitchTapped(_ sender: Any) {
        self.presenter.setNotificationPermissions()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: self)
    }
}

private extension AppPermissionsViewController {
    @objc func becomeActive() {
        self.presenter.viewBecomeActive()
    }
    
    func commonInit() {
        self.configureView()
        self.configureTexts()
        self.setAccessibilityIdentifiers()
    }
    
    func configureView() {
        self.headerView?.backgroundColor = .skyGray
        self.view.backgroundColor = .skyGray
        self.iconHeaderimageView.image = Assets.image(named: "icnArrowPhone")
    }

    func configureTexts() {
        self.setHeaderText()
        self.setLocalizationTexts()
        self.setContactsTexts()
        self.setPhotosTexts()
        self.setCameraTexts()
        self.setNotificationsTexts()
    }
    
    func setHeaderText() {
        self.headerTitleLabel.text = localized("managementPermission_label_changePermission")
        self.headerTitleLabel.setSantanderTextFont(type: .regular, size: 15.0, color: .lisboaGray)
    }
    
    func setLocalizationTexts() {
        self.localizationTitleLabel.text = localized("managementPermission_label_location")
        self.localizationTitleLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.localizationTextLabel.text = localized("managementPermission_label_locationPermission")
        self.localizationTextLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
    }
    
    func setContactsTexts() {
        self.contactsTitleLabel.text = localized("managementPermission_label_contact")
        self.contactsTitleLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.contactsTextLabel.text = localized("managementPermission_label_readContacts")
        self.contactsTextLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
    }
    
    func setPhotosTexts() {
        self.photosTitleLabel.text = localized("managementPermission_label_photos")
        self.photosTitleLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.photosTextLabel.text = localized("managementPermission_label_photosPermission")
        self.photosTextLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
    }
    
    func setCameraTexts() {
        self.cameraTitleLabel.text = localized("managementPermission_label_camera")
        self.cameraTitleLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.cameraTextLabel.text = localized("managementPermission_label_cameraPermission")
        self.cameraTextLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
    }
    
    func setNotificationsTexts() {
        self.notificationsTitleLabel.text = localized("managementPermission_label_notifications")
        self.notificationsTitleLabel.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        self.notificationsTextLabel.text = localized("managementPermission_label_notificationsPermission")
        self.notificationsTextLabel.setSantanderTextFont(type: .light, size: 14.0, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        self.setHeaderAccessibilityIdentifiers()
        self.setLocalizationAccessibilityIdentifiers()
        self.setContactsAccessibilityIdentifiers()
        self.setPhotosAccessibilityIdentifiers()
        self.setCameraAccessibilityIdentifiers()
        self.setNotificationsAccessibilityIdentifiers()
    }
    
    func setHeaderAccessibilityIdentifiers() {
        self.headerTitleLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.headerTitle
        self.iconHeaderimageView.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.iconHeaderImage
    }
    
    func setLocalizationAccessibilityIdentifiers() {
        self.localizationTitleLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.localizationTitle
        self.localizationTextLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.localizationText
        self.locationSwitch.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.localizationSwitch
    }
    
    func setContactsAccessibilityIdentifiers() {
        self.contactsTitleLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.contactsTitle
        self.contactsTextLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.contactsText
        self.contactsSwitch.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.contactsSwitch
    }
    
    func setPhotosAccessibilityIdentifiers() {
        self.photosTitleLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.photosTitle
        self.photosTextLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.photosText
        self.photosSwitch.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.photosSwitch
    }
    
    func setCameraAccessibilityIdentifiers() {
        self.cameraTitleLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.cameraTitle
        self.cameraTextLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.cameraText
        self.cameraSwitch.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.cameraSwitch
    }
    
    func setNotificationsAccessibilityIdentifiers() {
        self.notificationsTitleLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.notificationsTitle
        self.notificationsTextLabel.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.notificationsText
        self.notificationsSwitch.accessibilityIdentifier = AccessibilityAppPermissionsPersonalArea.notificationSwitch
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_permissionManagement")
        )
        builder.setLeftAction(.back(action: #selector(backDidPress)))
        builder.setRightActions(.close(action: #selector(closeDidPress)))
        builder.build(on: self, with: nil)
    }
    
    @objc func backDidPress() {
        self.presenter.backDidPress()
    }
    
    @objc private func closeDidPress() {
        self.presenter.closeDidPress()
    }
}

extension AppPermissionsViewController: AppPermissionsViewProtocol {
    func setPermissions(permission: PermissionsViewModel) {
        self.locationSwitch.isOn = permission.isLocationEnabled
        self.contactsSwitch.isOn = permission.isContactEnabled
        self.photosSwitch.isOn = permission.isPhotoEnabled
        self.cameraSwitch.isOn = permission.isCameraEnabled
        self.notificationsSwitch.isOn = permission.isNotificationEnabled
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func turnOffNotificationsSwitch() {
        self.notificationsSwitch.setOn(false, animated: true)
    }
}
