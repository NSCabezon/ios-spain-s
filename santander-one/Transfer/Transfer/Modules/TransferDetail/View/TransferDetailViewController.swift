//
//  EmittedTransferDetailViewController.swift
//  Account
//
//  Created by Alvaro Royo on 17/6/21.
//

import CoreFoundationLib
import UIKit
import UI

protocol EmittedTransferDetailViewProtocol: AnyObject {
    func showActionsWithModels(_ viewModels: [TransferDetailActionViewModel])
    func performShare(with content: Shareable)
    func showConfirmDialog()
}

final class TransferDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonTicketContainer: UIView!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var toggleButtonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var ticketImage: UIImageView!
    private let presenter: TransferDetailPresenterProtocol
    private var actionButtons = TransferDetailActions()
    
    var expanded = false {
        didSet {
            self.didSetExpanded()
        }
    }
    
    private var stackIndex: Int {
        stackView.arrangedSubviews.count - 1
    }
    
    init(presenter: TransferDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "TransferDetailViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .skyGray
        ticketImage.image = Assets.image(named: "imgTorn")
        setupView()
        configureButtons()
        expanded = false
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: presenter.transferDetailType.titleForNavBar)
        )
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: self.presenter)
    }
    
    func setupView() {
        scrollView.contentInset.bottom = 16
        presenter.configuration.enumerated().forEach { index, configuration in
            switch configuration {
            case let config as TransferDetailConfiguration.Amount:
                stackView.insertArrangedSubview(config.view, at: stackIndex)
            case let config as TransferDetailConfiguration.DestinationAccount:
                let destination = config.view
                (destination as? DestinationEmittedTransferView)?.shareAction = { [weak self] iban in
                    guard let self = self else { return }
                    SharedHandler().doShare(for: ShareableIban(iban: iban), in: self)
                }
                stackView.insertArrangedSubview(destination, at: stackIndex)
            case let config as TransferDetailConfiguration.DefaultViewConfig:
                let defaultView = config.view
                defaultView.setLastRow(index == (presenter.configuration.count - 1))
                stackView.insertArrangedSubview(defaultView, at: stackIndex)
            case let config as TransferDetailConfiguration.OriginAccount:
                let defaultView = config.view
                defaultView.setLastRow(index == (presenter.configuration.count - 1))
                stackView.insertArrangedSubview(defaultView, at: stackIndex)
            case let config as TransferDetailConfiguration.DefaultWithSubtitleViewConfig:
                let defaultView = config.view
                defaultView.setLastRow(index == (presenter.configuration.count - 1))
                stackView.insertArrangedSubview(defaultView, at: stackIndex)
            default: break
            }
            let separator = SeparatorEmittedTransferView(frame: .zero)
            if index == presenter.configuration.endIndex - 1 {
                separator.borders(for: [.left, .right, .bottom], color: .mediumSkyGray)
                separator.hideDottedLine()
            }
            stackView.insertArrangedSubview(separator, at: stackIndex)
        }
    }
    
    @objc func close() {
        presenter.close()
    }
    
    @IBAction func expandAction(_ sender: UIButton) {
        self.expanded.toggle()
    }
}

extension TransferDetailViewController: EmittedTransferDetailViewProtocol {
    func showConfirmDialog() {
        confirmDialog()
    }
    
    func performShare(with content: Shareable) {
        SharedHandler().doShare(for: content, in: self)
    }
    
    func showActionsWithModels(_ viewModels: [TransferDetailActionViewModel]) {
        self.actionButtons.removeSubviews()
        self.actionButtons.setViewModels(viewModels)
    }
    
    func configureButtons() {
        let distance = UIView()
        distance.backgroundColor = .clear
        distance.heightAnchor.constraint(equalToConstant: 19).isActive = true
        stackView.addArrangedSubview(distance)
        stackView.addArrangedSubview(actionButtons)
    }
}

private extension TransferDetailViewController {
    func setArrowButton(imageKey: String) {
        self.expandCollapseButton.setImage(Assets.image(named: imageKey), for: .normal)
        self.expandCollapseButton.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.arrowButton
        self.expandCollapseButton.imageView?.accessibilityIdentifier = imageKey
    }
    
    func didSetExpanded() {
        if self.presenter.isExpanded {
            let maxViews = self.presenter.maxViewsNotExpanded * 2 - 2
            self.stackView.arrangedSubviews.enumerated()
                .filter { index, _ in
                    index > maxViews && index < self.stackView.arrangedSubviews.count - 3
                }
                .forEach { _, view in
                    view.isHidden = !self.expanded
                    view.layoutIfNeeded()
                }
            self.ticketImage.isHidden = self.expanded
            self.setArrowButton(imageKey: self.expanded ? "icnOvalArrowUp" : "icnOvalArrowDown")
            self.toggleButtonCenterConstraint.constant = self.expanded ? -20 : 0
        } else {
            self.buttonTicketContainer.isHidden = true
        }
    }
    
    struct ShareableIban: Shareable {
        let iban: String
        
        func getShareableInfo() -> String {
            iban
        }
    }
    
    // MARK: - Confirm delete dialog
    
    func confirmDialog() {
        var confirmDeleteDialogContentKey = ""
        var confirmDeleteDialogTitleKey = ""
        
        guard case .scheduled(_, let transfer, _, _) = presenter.transferDetailType,
              let isPeriodic = transfer?.isPeriodic else { return }
        confirmDeleteDialogContentKey = isPeriodic ? "transfer_text_cancelPeriodic" : "transfer_text_removeScheduledShipping"
        confirmDeleteDialogTitleKey = isPeriodic ? "periodicOnePay_label_cancelPeriodic" : "delayedOnePay_label_cancelOnePay"
        let allowAction = LisboaDialogAction(title: localized("generic_link_yes"), type: .red, margins: (left: 16.0, right: 8.0)) { [weak self] in
            self?.presenter.proceedToDeleteTransfer()
        }
        let refuseAction = LisboaDialogAction(title: localized("generic_link_no"), type: .white, margins: (left: 16.0, right: 8.0)) { }
        LisboaDialog(
            items: [
                .margin(18.0),
                .styledText(LisboaDialogTextItem(text: localized(confirmDeleteDialogTitleKey), font: .santander(size: 26), color: .black, alignament: .center, margins: (25, 25))),
                .margin(13.0),
                .styledText(LisboaDialogTextItem(text: localized(confirmDeleteDialogContentKey), font: .santander(family: .micro, size: 16.0), color: .lisboaGray, alignament: .center, margins: (27, 27))),
                .margin(24),
                .horizontalActions(HorizontalLisboaDialogActions(left: refuseAction, right: allowAction)),
                .margin(6)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
}
