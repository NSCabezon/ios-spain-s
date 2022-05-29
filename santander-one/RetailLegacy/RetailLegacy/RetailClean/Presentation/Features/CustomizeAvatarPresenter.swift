import Foundation
import CoreFoundationLib

class CustomizeAvatarPresenter: PrivatePresenter<CustomizeAvatarViewController, PersonalAreaNavigatorProtocol, CustomizeAvatarPresenterProtocol> {
    private(set) lazy var photoHelper: PhotoHelper = {
       let helper = PhotoHelper(delegate: self)
        helper.compressionQuality = 0.6
        
        return helper
    }()
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_customizeAvatar")
        view.setTitleHeader(text: stringLoader.getString("customizeAvatar_text_description"))
        view.setTitleAvatar(text: stringLoader.getString("customizeAvatar_title_actualAvatar"))
        view.setTitleButton(tex: stringLoader.getString("customizeAvatar_button_modifyAvatar"))
        UseCaseWrapper(with: dependencies.useCaseProvider.getPersistedUserAvatarUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let presenter = self else { return }
            if let image = response.image {
                presenter.view.setImage(data: image)
            }
        })
    }
}

extension CustomizeAvatarPresenter: CustomizeAvatarPresenterProtocol {
    func changeAvatar() {
        openPhotoSelection(title: localized(key: "customizeAvatar_popup_title_select"),
                           body: localized(key: "customizeAvatar_popup_text_select"),
                           cameraOptionTitle: localized(key: "customizeAvatar_button_camera"),
                           photoLibraryOptionTitle: localized(key: "customizeAvatar_button_photos"))
    }
}

extension CustomizeAvatarPresenter: Presenter {}

extension CustomizeAvatarPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension CustomizeAvatarPresenter: OldPhotoPickerPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    var photoPickerNavigator: SystemSettingsNavigatable {
        return navigator
    }
    
    func selected(image: Data) {
        let input = SetPersistedUserAvatarUseCaseInput(image: image)
        let usecase = useCaseProvider.setPersistedUserAvatarUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] in
            guard let presenter = self else { return }
            presenter.view.setImage(data: image)
            NotificationCenter.default.post(name: Notification.Name.didChangeAvatarImage, object: nil)
        })
    }
}
