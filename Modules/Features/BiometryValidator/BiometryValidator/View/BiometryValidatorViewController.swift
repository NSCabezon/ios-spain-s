//
//  BiometryValidatorViewController.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol BiometryValidatorViewProtocol: AnyObject {
    func update(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus)
}

final public class BiometryValidatorViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var headerView: BiometryValidatorHeaderView!
    @IBOutlet private weak var containerView: BiometryValidatorContainerView!
    @IBOutlet private weak var footerView: BiometryValidatorFooterView!
    @IBOutlet private weak var footerMarginView: UIView!
    @IBOutlet private weak var containerScrollView: UIScrollView!
    
    // MARK: - Attributes
    
    private var presenter: BiometryValidatorPresenterProtocol
    private var status: BiometryValidatorStatus?
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private var topSafeAreaHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets.top
        } else {
            return self.topLayoutGuide.length
        }
    }

    // MARK: - UIInterfaceOrientationMask
    /// shouldAutorotate isn't  needed, the custom navigationController  is  overFullScreen presentationStyle

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - Initializers

    init(presenter: BiometryValidatorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "BiometryValidatorViewController", bundle: Bundle.module)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupNavigationBar()
        self.setDelegates()
        self.setColors()
        self.containerScrollView.scrollRectToVisible(.zero, animated: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.containerScrollView.delegate = self
        self.containerScrollView.bounces = false
        self.containerScrollView.scrollRectToVisible(.zero, animated: true)
        self.presenter.viewWillAppear()

        setPopGestureEnabled(false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.footerView.handleShadow((containerScrollView.contentOffset.y + 1) < (containerScrollView.contentSize.height - containerScrollView.frame.size.height))
    }
}

private extension BiometryValidatorViewController {
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setDelegates() {
        self.headerView.delegate = self
        self.containerView.delegate = self
        self.footerView.delegate = self
    }
    
    func setColors() {
        self.view.backgroundColor = .silverDark
        self.footerMarginView.backgroundColor = .skyGray
    }
}

extension BiometryValidatorViewController: DidTapInHeaderButtonsDelegate {
    public func didTapInMoreInfo() {
        self.presenter.moreInfo()
    }
    
    public func didTapInDismiss() {
        self.presenter.dismiss()
    }
}

extension BiometryValidatorViewController: BiometryValidatorFooterViewDelegate {
    func didTapInCancel() {
        presenter.cancel()
    }
    
    func didTapInRightButton(status: BiometryValidatorStatus) {
        presenter.confirm(status: status)
    }
}

extension BiometryValidatorViewController: BiometryValidatorContainerViewDelegate {
    func didTapInImage() {
        if case .error = self.status {
            return 
        }
        presenter.confirm(status: .confirm)
    }
    
    func didTapInSign() {
        presenter.useSign()
    }
}

extension BiometryValidatorViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle shadow when scroll moves
        let minY = scrollView.contentOffset.y + topSafeAreaHeight
        self.footerView.handleShadow(minY >= .zero)
        // Handle shadow when scrolls to bottom
        let scrollHeight = scrollView.contentSize.height - scrollView.frame.size.height
        if scrollView.contentOffset.y >= scrollHeight {
            self.footerView.removeShadow()
        }
    }
}

extension BiometryValidatorViewController: BiometryValidatorViewProtocol {
    func update(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        self.status = status
        self.containerView.configView(type, status: status)
        self.footerView.configView(type, status: status)
    }
}
