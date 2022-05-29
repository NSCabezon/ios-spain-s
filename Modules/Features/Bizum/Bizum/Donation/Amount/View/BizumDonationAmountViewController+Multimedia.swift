import UI
import CoreFoundationLib

extension BizumDonationAmountViewController: BizumMultimediaGalleryDelegate {
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

extension BizumDonationAmountViewController {
    func showMultimediaView(_ model: BizumMultimediaViewModel) {
        let view = BizumMultimediaView()
        model.update(view: view)
        model.galleryActionsDelegate = self
        self.stackView.addArrangedSubview(view)
    }

    @objc func openSettings() {
        self.navigateToSettings()
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
