import CoreFoundationLib

protocol ShareActivityLauncher {
    func launchActivityController(info: String, onViewController controller: UIViewController)
}

extension ShareActivityLauncher {
    func launchActivityController(info: String, onViewController controller: UIViewController) {
        let fakeBackground = getSnapshot(fromView: controller.navigationController?.view)
        let containerViewController = SharableFakeController()
        addImage(fakeBackground, toView: containerViewController.view)
        let extraNavigationController = createExtraNavigationController(withRootViewController: containerViewController)
        let shareController = createShareController(withContent: info, returnTo: controller)
        controller.present(extraNavigationController, animated: false) {
            containerViewController.present(shareController, animated: true, completion: nil)
        }
    }
    
    private func getSnapshot(fromView view: UIView?) -> UIImage {
        guard let view = view else { return UIImage() }
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
    }
    
    private func addImage(_ image: UIImage, toView view: UIView) {
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.fullFit()
    }
    
    private func createExtraNavigationController(withRootViewController viewController: UIViewController) -> UINavigationController {
        let navigationController = NotRotableNavigationViewController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    private func createShareController(withContent content: String, returnTo viewController: UIViewController) -> ShareActivityViewController {
        let shareController = ShareActivityViewController(activityItems: [content], applicationActivities: nil)
        shareController.excludedActivityTypes = [.mail, .message]
        
        if #available(iOS 13.0, *) {
            shareController.completionWithItemsHandler = { activityType, completed, _, _ -> Void in
                guard activityType == nil || (activityType != nil && completed) else { return }
                viewController.dismiss(animated: false, completion: nil)
            }
        } else {
            shareController.completionWithItemsHandler = { _, _, _, _ -> Void in
                viewController.dismiss(animated: false, completion: nil)
            }
        }
        return shareController
    }
}

fileprivate final class SharableFakeController: UIViewController, NotRotatable { }
