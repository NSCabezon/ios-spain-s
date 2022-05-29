//
//  BizumSplitExpensesAmountViewController+Multimedia.swift
//  Bizum

import UIKit
import UI
import CoreFoundationLib
import Operative

extension BizumSplitExpensesAmountViewController: BizumMultimediaGalleryDelegate {
    func cameraWasTapped() {
        self.presenter.cameraWasTapped()
    }

    func openImageDetail(_ image: Data) {
        let viewController = BizumImageViewerViewController(nibName: "BizumImageViewerViewController",
                                                            bundle: .module,
                                                            image: image)
        let transitioningDelegate = HalfSizePresentationManager()
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .coverVertical
        viewController.transitioningDelegate = transitioningDelegate
        self.present(viewController, animated: true, completion: nil)
    }
}

extension BizumSplitExpensesAmountViewController {
    func showMultimediaView(_ model: BizumMultimediaViewModel) {
        let view = BizumMultimediaView()
         model.update(view: view)
         model.galleryActionsDelegate = self
        self.stackView.addArrangedSubview(view)
    }

    func showOptionsToAddImage(onCamera: @escaping () -> Void, onGallery: @escaping () -> Void) {
        let absoluteMargin: (left: CGFloat, right: CGFloat) = (left: 19.0, right: 9.0)
        let components: [LisboaDialogItem] = [
            .margin(36.0),
            .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_title_select"),
                                             font: .santander(family: .text, type: .regular, size: 22),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(16.0),
            .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_text_select"),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: absoluteMargin)),
            .margin(22.0),
            .horizontalActions(HorizontalLisboaDialogActions(left: LisboaDialogAction(title: localized("customizeAvatar_button_photos"),
                                                                                      type: .white,
                                                                                      margins: absoluteMargin,
                                                                                      action: onGallery),
                                                             right: LisboaDialogAction(title: localized("customizeAvatar_button_camera"),
                                                                                       type: .red,
                                                                                       margins: absoluteMargin,
                                                                                       action: onCamera))),
            .margin(24.0)
        ]
        let builder = LisboaDialog(items: components, closeButtonAvailable: true)
        builder.showIn(self)
    }

    func showRequestGalleryAccess(_ body: String) {
        let allowAction = LisboaDialogAction(title: localized("genericAlert_buttom_settings"), type: .red, margins: (left: 16.0, right: 8.0)) {
            self.openSettings()
        }
        let refuseAction = LisboaDialogAction(title: localized("generic_button_cancel"), type: .white, margins: (left: 16.0, right: 8.0)) { }
        LisboaDialog(
            items: [
                .margin(19.0),
                .styledText(LisboaDialogTextItem(text: localized(body), font: .santander(size: 16), color: .lisboaGray, alignament: .center, margins: (25, 25))),
                .margin(13.0),
                .horizontalActions(HorizontalLisboaDialogActions(left: refuseAction, right: allowAction)),
                .margin(6)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
}

extension BizumSplitExpensesAmountViewController: SystemSettingsNavigatable {}
