import Foundation
import CoreFoundationLib

class PermissionsPresenter: PrivatePresenter<CustomOptionsFormViewController, PersonalAreaNavigatorProtocol & PullOffersActionsNavigatorProtocol, CustomFormPresenterProtocol>, SystemSettingsNavigatable {
    
    private let contactsManager = ContactsStoreManager()
    private let cameraManager = PhotoPermissionHelper()
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_permissionManagement")
        makeSections()
        view.isSideMenuCapable = true
        view.showMenuClosure = { [weak self] in
            self?.toggleSideMenu()
        }
        
        view.executeWhenReturnFromBackground { [weak self] in
            self?.makeSections()
        }
    }
    
    private func makeSections() {
        let useCase = useCaseProvider.getPermissionsStatusUseCase(dependencies: dependencies)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            let sectionInfo = StackSection()
            
            let header = TitleWithDescriptionStackModel(title: strongSelf.stringLoader.getString("managementPermission_label_aboutPermission"), subtitle: strongSelf.stringLoader.getString("managementPermission_label_changePermission"))
            sectionInfo.add(item: header)
            
            let titleItem = TitleLabelStackModel(title: strongSelf.stringLoader.getString("managementPermission_label_permission").uppercased(), insets: Insets(left: 14, right: 14, top: 30, bottom: 8))
            sectionInfo.add(item: titleItem)

            for (index, section) in result.items.enumerated() {
                let isFirstElement = index == 0
                let isLastElement = index == result.items.count - 1
                let item = OptionWithStatusStackModel(title: strongSelf.stringLoader.getString(section.0.titleKey), subtitle: strongSelf.stringLoader.getString(section.0.descriptionKey), isChecked: section.1, isFirst: isFirstElement, isLast: isLastElement)
                item.action = { [weak self] in
                    self?.requestPermissionOrNavigateToSettings(section)
                }
                sectionInfo.add(item: item)
            }
            self?.view.dataSource.reloadSections(sections: [sectionInfo])
        })
    }
    
    private func requestPermissionOrNavigateToSettings(_ info: (PermissionSectionType, Bool)) {
        switch info.0 {
        case .location:
            if dependencies.locationManager.isAlreadySet {
                navigateToSettings()
            } else {
                dependencies.locationManager.askAuthorizationIfNeeded { [weak self] in
                    self?.makeSections()
                }
            }
        case .contacts:
            if contactsManager.isAlreadySet {
                navigateToSettings()
            } else {
                contactsManager.scanContacts { [weak self] _, _ in
                    self?.makeSections()
                }
            }
        case .photos:
            if cameraManager.isPhotoAccessAlreadySet {
                navigateToSettings()
            } else {
                cameraManager.askAuthorization(type: .photoLibraryAccess) { [weak self] _ in
                    self?.makeSections()
                }
            }
        case .camera:
            if cameraManager.isCameraAccessAlreadySet {
                navigateToSettings()
            } else {
                cameraManager.askAuthorization(type: .cameraAccess) { [weak self] _ in
                    self?.makeSections()
                }
            }
        case .notifications:
            break
        }
    }
    
}

extension PermissionsPresenter: CustomFormPresenterProtocol {
    var shouldDetectEnteringForeground: Bool {
        return true
    }
}

extension PermissionsPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

private extension PermissionSectionType {
    var titleKey: String {
        switch self {
        case .location:
            return "managementPermission_label_location"
        case .contacts:
            return "managementPermission_label_contact"
        case .photos:
            return "managementPermission_label_photos"
        case .camera:
            return "managementPermission_label_camera"
        case .notifications:
            return "managementPermission_label_notifications"
        }
    }
    
    var descriptionKey: String {
        switch self {
        case .location:
            return "managementPermission_label_locationPermission"
        case .contacts:
            return "managementPermission_label_readContacts"
        case .photos:
            return "managementPermission_label_photosPermission"
        case .camera:
            return "managementPermission_label_cameraPermission"
        case .notifications:
            return "managementPermission_label_notificationsPermission"
        }
    }
}
