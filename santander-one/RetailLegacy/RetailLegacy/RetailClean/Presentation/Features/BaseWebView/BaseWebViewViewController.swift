import UIKit
import WebKit
import ContactsUI
import UI
import WebViews

protocol BaseWebViewPresenterProtocol {
    var title: LocalizedStylableText? { get }
    var showBackNavigationItem: Bool { get }
    var showRightCloseNavigationItem: Bool { get }
    func backPressed()
    func closePressed()
    func navigateWebBack()
    func getTipsPresenter() -> LoadingTipPresenter
    func getTipsViewController() -> LoadingTipViewController?
}

class BaseWebViewViewController: BaseViewController<BaseWebViewPresenterProtocol>, CNContactPickerDelegate {
    
    var contactsSelected: (([UserContact]) -> Void)?
    lazy var loadingTipsViewController: LoadingTipViewController? = presenter.getTipsViewController()

    override class var storyboardName: String {
        return "BaseWebView"
    }
    
    override var isKeyboardDismisserActivated: Bool {
        return false
    }
    
    public override var prefersStatusBarHidden: Bool { false }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: presenter.title?.text ?? "", identifier: "drawer_custom_title_textview")
        )
        if presenter.showRightCloseNavigationItem {
            builder.setRightActions(
                .close(action: #selector(closeButtonTouched))
            )
        }
        if presenter.showBackNavigationItem {
            builder.setLeftAction(
                .back(action: #selector(navigateBack))
            )
        }
        DispatchQueue.main.async {
            builder.build(on: self, with: nil)
        }
    }
    
    func setWebView(_ webView: WebView) {
        let constraintBuilder = NSLayoutConstraint.Builder()
        webView.view.translatesAutoresizingMaskIntoConstraints = false
        constraintBuilder += webView.view.leftAnchor.constraint(equalTo: view.leftAnchor)
        constraintBuilder += webView.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        if #available(iOS 11.0, *) {
            constraintBuilder += webView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            constraintBuilder += webView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            constraintBuilder += webView.view.topAnchor.constraint(equalTo: view.topAnchor)
            constraintBuilder += webView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .scrollableAxes
        }
        view.backgroundColor = .sky30
        view.addSubview(webView.view)
        constraintBuilder.activate()
    }
    
    func loadRequest(in webView: WebView, request: URLRequest) {
        webView.loadRequest(request)
    }
    
    @objc override func closeButtonTouched() {
        presenter.closePressed()
    }
    
    @objc func navigateBack() {
        presenter.navigateWebBack()
    }
    
    func webViewGoBack(webView: WebView) {
        if webView.canGoBack {
            webView.back()
        } else {
            presenter.backPressed()
        }
    }
    
    func showTipLoading() {
        let parent = self
        guard let child = loadingTipsViewController else { return }
        parent.view.addSubview(child.view)
        child.view.fullFit()
        parent.addChild(child)
        child.didMove(toParent: parent)
    }
    
    func hideTipLoading() {
        guard let child = loadingTipsViewController else { return }
        child.willMove(toParent: nil)
        child.removeFromParent()
        child.view.removeFromSuperview()
    }
    // MARK: Contacts
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        contactsSelected?([contactProperty.contact.userContact])
    }
}

extension BaseWebViewViewController: LoadingAreaProvider {
    var loadingArea: LoadingViewType {
        return LoadingViewType.onView(view: view, frame: safeFrame, position: .center, controller: self)
    }
}

extension BaseWebViewViewController {
    func inject(in webView: WebView, javascript: String) {
        _ = webView.stringByEvaluatingJavaScript(from: javascript, completion: nil)
    }
}

extension BaseWebViewViewController: ActionClosableProtocol {}
extension BaseWebViewViewController: NavigationBarCustomizable {}
