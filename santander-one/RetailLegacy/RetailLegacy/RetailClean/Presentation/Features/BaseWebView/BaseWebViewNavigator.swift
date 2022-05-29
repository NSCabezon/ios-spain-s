import UIKit
import ContactsUI
import CoreFoundationLib

enum ContactPickerProperty {
    case contactIdentifier
    case name
    case surname
    case imageDataAvailable
    case phones
    case thumbnailImage
    
    fileprivate var cnProperty: String {
        switch self {
        case .contactIdentifier:
            return CNContactIdentifierKey
        case .name:
            return CNContactGivenNameKey
        case .surname:
            return CNContactFamilyNameKey
        case .imageDataAvailable:
            return CNContactImageDataAvailableKey
        case .phones:
            return CNContactPhoneNumbersKey
        case .thumbnailImage:
            return CNContactThumbnailImageDataKey
        }
    }
}

struct ContactsPickerSetup {
    let displayedProperties: [ContactPickerProperty]
}

class BaseWebViewNavigator: AppStoreNavigator, BaseWebViewNavigatorProtocol {

    var presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.drawer = drawer
        self.presenterProvider = presenterProvider
    }
    
    var navigationController: UINavigationController? {
        let currentRootViewController = drawer.currentRootViewController as? UINavigationController
        return currentRootViewController?.topViewController?.presentedViewController as? UINavigationController ?? currentRootViewController
    }
    
    func back() {
        guard let navigator = self.navigationController else { return }
        if !(navigator.viewControllers.last is BackNotAvailableViewProtocol) {
            _ = navigator.popViewController(animated: true)
        }
	}

    func goToPdfViewer(with data: Data, andTitle title: LocalizedStylableText?, andPdfSource pdfSource: PdfSource) {
        goToPdfViewer(with: data, andTitle: title, andPdfSource: pdfSource, isFullscreen: false)
    }

    func goToPdfViewer(with data: Data, andTitle title: LocalizedStylableText?, andPdfSource pdfSource: PdfSource, isFullscreen: Bool) {
        let presenter = presenterProvider.pdfViewerPresenter(pdfData: data, title: title?.text ?? "toolbar_title_pdfExtract", pdfSource: pdfSource)
        guard let navigator = self.navigationController else {
            return
        }
        if isFullscreen {
            guard let currentTopController = navigator.topViewController else { return }
            let topViewController = topMostViewController(of: currentTopController)
            let navigationController = UINavigationController(rootViewController: presenter.view)
            navigationController.modalPresentationStyle = .fullScreen
            topViewController.present(navigationController, animated: true, completion: nil)
        } else {
            navigator.pushViewController(presenter.view, animated: true)
        }
    }

    private func topMostViewController(of viewController: UIViewController) -> UIViewController {
        var topViewController = viewController
        while topViewController.presentedViewController != nil {
            guard let presentedViewController = topViewController.presentedViewController else {
                return topViewController
            }
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    func goToFiles(with url: URL, title: String) {
        let documentInteractionController = UIDocumentInteractionController()
        documentInteractionController.url = url
        documentInteractionController.name = title
        documentInteractionController.delegate = self
        documentInteractionController.presentPreview(animated: true)
    }
    
    // MARK: ContactS
    
    func showContacts(completion: (() -> Void)?, selected: (([UserContact]) -> Void)?, setup: ContactsPickerSetup) {
        let navigator = self.navigationController
        let baseWebViewController = navigator?.viewControllers.last as? BaseWebViewViewController
        baseWebViewController?.contactsSelected = selected
        let contactsPicker = CNContactPickerViewController()
        contactsPicker.delegate = baseWebViewController
        contactsPicker.displayedPropertyKeys = setup.displayedProperties.map { $0.cnProperty }
        navigator?.viewControllers.last?.present(contactsPicker, animated: true, completion: completion)
    }

    func goToOpenUrl(with url: URL) {
        guard canOpen(url) else {
            return
        }
        open(url)
    }
}

extension BaseWebViewNavigator: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return nil
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return drawer.currentRootViewController ?? UIViewController()
    }
}
