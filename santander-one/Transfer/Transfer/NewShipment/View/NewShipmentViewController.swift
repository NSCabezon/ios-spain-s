//
//  MoreTransferOptionViewController.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/26/19.
//

import UIKit
import UI
import CoreFoundationLib

protocol NewShipmentViewProtocol {
    func showTransferActions(_ viewModels: [TransferActionViewModel])
}

final class NewShipmentViewController: UIViewController {
    private let presenter: NewShipmentPresenterProtocol
    private let scrollableStackView = ScrollableStackView()
    private let newShipmentHeader = NewShipmentHeader()
    private let transferActionsView = TransferActionsStackView()
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var radiusView: UIView!
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: NewShipmentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.scrollableStackView.setup(with: contentView)
        self.radiusView.backgroundColor = UIColor.white
        self.radiusView.layer.cornerRadius = 6
        self.scrollableStackView.addArrangedSubview(newShipmentHeader)
        self.scrollableStackView.addArrangedSubview(transferActionsView)
        self.newShipmentHeader.delegate = self
        self.topConstraint.constant = view.frame.height
        self.view.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }

    @IBAction func didTapOnView(_ sender: Any) {
        self.didSelectClose()
    }
}

extension NewShipmentViewController: NewShipmentViewProtocol {
    func showTransferActions(_ viewModels: [TransferActionViewModel]) {
        self.scrollableStackView.enableScroll(isEnabled: false)
        self.transferActionsView.setOrigin(.curtain)
        self.transferActionsView.setViewModels(viewModels)
        self.view.layoutIfNeeded()
        self.performAnimation()
    }
}

extension NewShipmentViewController: NewShipmentHeaderDelegate {
    func didSelectClose() {
        self.scrollableStackView.enableScroll(isEnabled: true)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.presenter.didSelectClose()
    }
}

private extension NewShipmentViewController {
    var topDistance: CGFloat {
        let headerHeight = newShipmentHeader.frame.height
        let topMargin = CGFloat(24)
        let bottomMargin = CGFloat(36)
        var safeAreaBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeAreaBottom = view.safeAreaInsets.bottom
        }
        return view.frame.height - headerHeight - transferActionsView.height - bottomMargin - topMargin - safeAreaBottom
    }
    
    func performAnimation() {
        self.topConstraint.constant = Screen.isIphone5 ? 0.0 : topDistance
        self.view.alpha = 1.0
        UIView.animate(withDuration: 0.4) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            self.view.layoutIfNeeded()
        }
    }
}
