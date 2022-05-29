import Foundation
import CoreFoundationLib

protocol OldPhotoPickerPresenter: PhotoHelperDelegate {
    var photoHelper: PhotoHelper { get }
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var stringLoader: StringLoader { get }
    var photoPickerNavigator: SystemSettingsNavigatable { get }
    
    var presentationView: ViewControllerProxy { get }
    
    func selected(image: Data)
}

extension OldPhotoPickerPresenter {
    func openPhotoSelection(title: LocalizedStylableText, body: LocalizedStylableText, cameraOptionTitle: LocalizedStylableText, photoLibraryOptionTitle: LocalizedStylableText) {
        let cameraComponent = DialogButtonComponents(titled: cameraOptionTitle, does: { [weak self] in
            self?.photoHelper.askImage(type: .camera)
        })
        let photoLibaryComponent = DialogButtonComponents(titled: photoLibraryOptionTitle, does: { [weak self] in
            self?.photoHelper.askImage(type: .photoLibrary)
        })
        Dialog.alert(title: title, body: body, withAcceptComponent: photoLibaryComponent, withCancelComponent: cameraComponent, showsCloseButton: true, source: presentationView)
    }
}

extension OldPhotoPickerPresenter {
    var viewForPresentation: UIViewController? {
        return presentationView.viewController
    }
    
    func selectedImage(image: Data) {
        selected(image: image)
    }
    
    func showError(error: PhotoHelperError) {
        let settingsComponent = DialogButtonComponents(titled: stringLoader.getString("genericAlert_buttom_settings_android"), does: { [weak self] in
            guard let presenter = self else { return }
            presenter.photoPickerNavigator.navigateToSettings()
        })
        let cancelComponent = DialogButtonComponents(titled: stringLoader.getString("generic_button_cancel"), does: nil)
        let keyDesc: String
        switch error {
        case .noPermissionCamera:
            keyDesc = "permissionsAlert_text_camera"
        case .noPermissionPhotoLibrary:
            keyDesc = "permissionsAlert_text_photos"
        }
        Dialog.alert(title: stringLoader.getString("generic_title_permissionsDenied"), body: stringLoader.getString(keyDesc), withAcceptComponent: settingsComponent, withCancelComponent: cancelComponent, showsCloseButton: false, source: presentationView)
    }
}
