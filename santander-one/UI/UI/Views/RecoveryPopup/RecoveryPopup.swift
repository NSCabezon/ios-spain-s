//
//  RecoveryPopup.swift
//  UI
//
//  Created by alvola on 15/10/2020.
//

import UIKit
import CoreFoundationLib

public protocol RecoveryPopupProtocol: AnyObject {
    func setRecoveryViewModel(_ viewModel: RecoveryViewModel)
}

public final class RecoveryPopup: UIViewController, RecoveryPopupProtocol {
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        view.backgroundColor = UIColor.white
        view.drawRoundedBorderAndShadow(with: ShadowConfiguration(color: .black,
                                                                  opacity: 0.2,
                                                                  radius: 3.0,
                                                                  withOffset: 0.0,
                                                                  heightOffset: 2.0),
                                        cornerRadius: 5.0,
                                        borderColor: UIColor.lightSkyBlue,
                                        borderWith: 1.0)
        return view
    }()
    
    private lazy var closeImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnClose"))
        image.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(image)
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: #selector(didPressClose)))
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(family: .headline, size: 20.0)
        label.textColor = .lisboaGray
        label.configureText(withKey: "generic_label_importantNotice")
        popupView.addSubview(label)
        return label
    }()
    
    private lazy var debtView: RecoveryPopupDebtView = {
        let view = RecoveryPopupDebtView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(view)
        return view
    }()
    
    private lazy var rescheduleArea: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(view)
        view.backgroundColor = UIColor.paleYellow
        view.drawBorder(cornerRadius: 4.0,
                        color: UIColor.mediumSkyGray,
                        width: 1.0)
        return view
    }()
    
    private lazy var speakerImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnSpeakerRecovery"))
        image.translatesAutoresizingMaskIntoConstraints = false
        rescheduleArea.addSubview(image)
        return image
    }()
    
    private lazy var rescheduleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .sanGreyDark
        label.numberOfLines = 0
        label.configureText(
            withKey: "recoveredMoney_label_programmerDatePayment",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: UIFont.santander(family: .headline, size: 14.0),
                lineHeightMultiple: 0.85,
                lineBreakMode: .byWordWrapping
            )
        )
        rescheduleArea.addSubview(label)
        return label
    }()
    
    private lazy var manageDebtButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(button)
        button.clipsToBounds = true
        button.backgroundColor = UIColor.santanderRed
        button.setTitle(localized("recoveredMoney_button_managePayments"), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.santander(type: .bold, size: 16.0)
        button.addTarget(self, action: #selector(didPressManageDebt), for: .touchUpInside)
        return button
    }()
    
    public var closeAction: (() -> Void)?
    private var completionAction: (() -> Void)?
    
    public var presenter: RecoveryPopupPresenterProtocol?
    
    public init(presenter: RecoveryPopupPresenterProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.presenter?.viewDidLoad()
    }
    
    public func showIn(_ viewController: UIViewController, presentedAction: @escaping (Bool) -> Void, completion: @escaping () -> Void) {
        presenter?.shouldShow({ [weak self] show in
            presentedAction(show)
            guard show, let self = self, self.view?.window == nil else { return completion() }
            self.completionAction = completion
            self.modalPresentationStyle = .overCurrentContext
            self.modalTransitionStyle = .crossDissolve
            guard viewController.navigationController?.topViewController == viewController else { return }
            viewController.present(self, animated: true)
        })
    }
    
    public func setRecoveryViewModel(_ viewModel: RecoveryViewModel) {
        debtView.setRecoveryViewModel(viewModel)
    }
}

private extension RecoveryPopup {
    func commonInit() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        addPopupConstraints()
        addCloseConstraints()
        addTitleConstraints()
        addDebtConstraints()
        addRescheduleAreaConstraints()
        addSpeakerConstraints()
        addRescheduleLabelConstraints()
        addManageButtonConstraints()
    }
    
    func addPopupConstraints() {
        NSLayoutConstraint.activate([popupView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                                     popupView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     self.view.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: 23.0),
                                     popupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 23.0),
                                     popupView.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: 10.0)
        ])
    }
    
    func addCloseConstraints() {
        NSLayoutConstraint.activate([closeImage.heightAnchor.constraint(equalToConstant: 26.0),
                                     closeImage.widthAnchor.constraint(equalToConstant: 26.0),
                                     popupView.trailingAnchor.constraint(equalTo: closeImage.trailingAnchor, constant: 6.0),
                                     closeImage.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 6.0)
        ])
    }
    
    func addTitleConstraints() {
        NSLayoutConstraint.activate([titleLabel.heightAnchor.constraint(equalToConstant: 35.0),
                                     titleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16.0),
                                     titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 16.0)
        ])
    }
    
    func addDebtConstraints() {
        NSLayoutConstraint.activate([debtView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16.0),
                                     popupView.trailingAnchor.constraint(equalTo: debtView.trailingAnchor, constant: 16.0),
                                     debtView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.0),
                                     debtView.heightAnchor.constraint(greaterThanOrEqualToConstant: 104.0)])
    }
    
    func addRescheduleAreaConstraints() {
        NSLayoutConstraint.activate([rescheduleArea.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16.0),
                                     popupView.trailingAnchor.constraint(equalTo: rescheduleArea.trailingAnchor, constant: 16.0),
                                     rescheduleArea.topAnchor.constraint(equalTo: debtView.bottomAnchor, constant: 11.0),
                                     rescheduleArea.bottomAnchor.constraint(equalTo: manageDebtButton.topAnchor, constant: -33.0)])
    }
    
    func addSpeakerConstraints() {
        NSLayoutConstraint.activate([speakerImage.leadingAnchor.constraint(equalTo: rescheduleArea.leadingAnchor, constant: 15.0),
                                     speakerImage.heightAnchor.constraint(equalToConstant: 24.0),
                                     speakerImage.widthAnchor.constraint(equalToConstant: 24.0),
                                     speakerImage.topAnchor.constraint(equalTo: rescheduleArea.topAnchor, constant: 15.0)])
    }
    
    func addRescheduleLabelConstraints() {
        NSLayoutConstraint.activate([rescheduleLabel.leadingAnchor.constraint(equalTo: speakerImage.trailingAnchor, constant: 15.0),
                                     rescheduleArea.trailingAnchor.constraint(equalTo: rescheduleLabel.trailingAnchor, constant: 17.0),
                                     rescheduleLabel.topAnchor.constraint(equalTo: rescheduleArea.topAnchor, constant: 10.0),
                                     rescheduleArea.bottomAnchor.constraint(equalTo: rescheduleLabel.bottomAnchor, constant: 13.0)])
    }
    
    func addManageButtonConstraints() {
        manageDebtButton.layer.cornerRadius = 20.0
        NSLayoutConstraint.activate([manageDebtButton.heightAnchor.constraint(equalToConstant: 40.0),
                                     manageDebtButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16.0),
                                     popupView.trailingAnchor.constraint(equalTo: manageDebtButton.trailingAnchor, constant: 16.0),
                                     popupView.bottomAnchor.constraint(equalTo: manageDebtButton.bottomAnchor, constant: 22.0)
        ])
    }
    
    func configureAccessibilityIds() {
        popupView.accessibilityIdentifier = "pgAlertRecovered"
        titleLabel.accessibilityIdentifier = "generic_label_importantNotice"
        rescheduleArea.accessibilityIdentifier = "pgViewProgrammerDatePayment"
        rescheduleLabel.accessibilityIdentifier = "recoveredMoney_label_programmerDatePayment"
        speakerImage.accessibilityIdentifier = "icnSpeaker"
        manageDebtButton.accessibilityIdentifier = "pgBtnManagePayments"
        view.accessibilityIdentifier = "pgViewImportantNotice"
    }
    
    @objc func didPressManageDebt() {
        presenter?.didSelectManageDebt()
        hidePopup()
    }
    
    @objc func didPressClose() {
        hidePopup()
    }
    
    func hidePopup() {
        UIView.animate(withDuration: 0.15, animations: {
            self.popupView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.1, animations: {
                self?.popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self?.view.alpha = 0.0
            }, completion: { _ in
                self?.closeActions()
            })
        })
    }
    
    func closeActions() {
        self.dismiss(animated: false)
        self.closeAction?()
        self.completionAction?()
    }
}

extension RecoveryPopup: RootMenuController {
    public var isSideMenuAvailable: Bool { false }
}
