import Foundation
import UI
import CoreFoundationLib
import OpenCombine

public protocol GetPhotoDialogReactiveCapable {
    var associatedViewController: UIViewController { get }
    var didSelectPhotoActionSubject: PassthroughSubject<PhotoType, Never> { get }
    
    func showPhotoSourceDialog()
}

extension GetPhotoDialogReactiveCapable where Self: UIViewController {
    var associatedViewController: UIViewController { self }
}

extension GetPhotoDialogReactiveCapable {
    func showPhotoSourceDialog() {
        let libraryAction = LisboaDialogAction(
            title: localized("customizeAvatar_button_photos"),
            type: .white,
            margins: (left: 16, right: 16),
            action: {
                didSelectPhotoActionSubject.send(PhotoType.photoLibrary)
            }
        )
        let cameraAction = LisboaDialogAction(
            title: localized("customizeAvatar_button_camera"),
            type: .custom(backgroundColor: .santanderRed, titleColor: .white, font: .santander(type: .bold, size: 16.0)),
            margins: (left: 16, right: 16),
            action: {
                didSelectPhotoActionSubject.send(PhotoType.camera)
            }
        )
        let horizontalActions = HorizontalLisboaDialogActions(left: libraryAction, right: cameraAction)
        let builder = LisboaDialog(
            items: [
                .margin(5.0),
                .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_title_select"),
                                                 font: .santander(family: .headline, size: 22.0),
                                                 color: UIColor.Legacy.uiBlack,
                                                 alignament: .center,
                                                 margins: (15, 15))),
                .margin(8.0),
                .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_text_select"),
                                                 font: .santander(size: 16.0),
                                                 color: UIColor.Legacy.lisboaGrayNew,
                                                 alignament: .center,
                                                 margins: (15, 15))),
                .margin(8.0),
                .horizontalActions(horizontalActions)
            ],
            closeButtonAvailable: true
        )
        builder.showIn(associatedViewController)
    }
}
