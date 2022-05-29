//
//  HybridTimeLineController.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 20/08/2019.
//

import UIKit
import WebKit

class HybridTimeLineController: UIViewController {
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var errorView: ErrorView!
    
    var webView: WKWebView!
    var dependencies: Dependencies?
    
    override func viewWillAppear(_ animated: Bool) {
       changeStatusBar(with: .white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        changeStatusBar(with: .clear)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func changeStatusBar(with color: UIColor) {
        if #available(iOS 13.0, *) {
            guard let statusFrame = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return }
            let statusBar = UIView(frame: statusFrame)
            statusBar.backgroundColor = color
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
            statusBar.backgroundColor = color
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        configureBack()
        workWithWebView()
       
     }
    
    func workWithWebView() {
        setWebView()
        loadWebView()
    }
    
    func getURLQuery() -> URL? {
        guard let config = dependencies?.configuration, let urlStr = dependencies?.configuration?.hybrid?.url.absoluteString else { return nil }
        var components = URLComponents(string: urlStr)
        let userToken = URLQueryItem(name: "userToken", value: config.authorization.token())
        let language = URLQueryItem(name: "language", value: config.language)
        components?.queryItems = [userToken, language]
        return components?.url
    }
    
    func onLoadSucces() {
        endLoading()
        errorView.isHidden = true
    }
    
    func onLoadError() {
        endLoading()
        errorView.isHidden = false
        view.backgroundColor = .iceBlue
        errorView.setError(with: GeneralString().errorTitle, and: GeneralString().errorUnknow, type: .error)
    }
    
    func startLoading() {
        loadingView.isHidden = false
        loadingView.setAnimationImagesWith(prefixName: "BS_", range: 1...154, format: "%03d")
        loadingView.startAnimating()
    }
    
    func endLoading() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
    }
}


// MARK: - Navigation configuration
extension HybridTimeLineController: UIGestureRecognizerDelegate {
    private func setNavBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        showNavBar()
        configureBack()
        configureTitle()
    }
    
    private func showNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureBack() {
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "backButton"), style: .plain, target: self, action: #selector(onBackPressed))
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func onBackPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureTitle() {
        let view = UIView()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        let label = UILabel()
        label.text = TimeLineString().titleToolbar
        label.font = .santanderHeadline(type: .bold, with: 18)
        label.textColor = .sanRed
        stackView.addArrangedSubview(label)
        let button = UIButton()
        button.setImage(UIImage(fromModuleWithName: "icTooltip")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .sanRed
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.addTarget(self, action: #selector(showTooltip(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        view.addSubviewWithAutoLayout(stackView)
        view.layoutIfNeeded()
        view.sizeToFit()
        view.translatesAutoresizingMaskIntoConstraints = true
        navigationItem.titleView = view
    }
    
    @objc private func showTooltip(_ sender: UIButton) {
        let tooltip = ToolTip(
            title: TimeLineString().titleToolbar,
            description: TimeLineString().infoToolbar,
            sourceViewController: self,
            sourceView: sender,
            sourceFrame: sender.bounds,
            arrowDirection: .up
        )
        tooltip.show()
    }
}

extension HybridTimeLineController: StoryBoardInstantiable {
    static func storyboardName() -> String {
        return "HybridTimeLine"
    }
}
