//
//  InboxNotificationDetailViewController.swift
//  Pods
//
//  Created by José María Jiménez Pérez on 18/5/21.
//  

import UI
import CoreFoundationLib
import Foundation

protocol InboxNotificationDetailViewProtocol: class {
    func showNotification(_ viewModel: NotificationDetailViewModel)
    func shareWithCase(_ type: ShareCase, delegate: Shareable)
    func showError(localizedKey: String)
}

final class InboxNotificationDetailViewController: UIViewController {
    
    @IBOutlet weak private var scrollContainer: UIView!
    @IBOutlet weak private var infoContainer: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var topSeparator: UIView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var bottomSeparator: UIView!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var actionView: UIView!
    @IBOutlet weak private var actionImage: UIImageView!
    @IBOutlet weak private var actionLabel: UILabel!
    @IBOutlet weak private var shareContainer: UIView!
    @IBOutlet weak private var shareView: UIStackView!
    @IBOutlet weak private var smsView: UIView!
    @IBOutlet weak private var smsImageView: UIImageView!
    @IBOutlet weak private var smsLabel: UILabel!
    @IBOutlet weak private var mailView: UIView!
    @IBOutlet weak private var mailImageView: UIImageView!
    @IBOutlet weak private var mailLabel: UILabel!
    @IBOutlet weak private var shareImageView: UIImageView!
    @IBOutlet weak private var otherView: UIView!
    @IBOutlet weak private var shareLabel: UILabel!
    
    private let presenter: InboxNotificationDetailPresenterProtocol
    
    init(presenter: InboxNotificationDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "InboxNotificationDetailViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.configGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.presenter.viewWillAppear()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky, title: .title(key: "toolbar_title_notificationDetail"))
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func dismissViewController() {
        presenter.dismissViewController()
    }
    
    @objc private func openMenu() {
        presenter.openMenu()
    }
}

extension InboxNotificationDetailViewController: InboxNotificationDetailViewProtocol {
    func showNotification(_ viewModel: NotificationDetailViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        dateLabel.text = viewModel.date
    }

    func shareWithCase(_ type: ShareCase, delegate: Shareable) {
        var shareType: ShareType
        switch type {
        case .sms: shareType = .sms
        case .mail: shareType = .mail
        case .share: shareType = .text
        }
        
        SharedHandler().doShare(for: delegate, in: self, type: shareType)
    }
    
    func showError(localizedKey: String) {
        showOldDialog(title: nil, description: localized(localizedKey), acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil), cancelAction: nil, isCloseOptionAvailable: false)
    }
}

private extension InboxNotificationDetailViewController {
    func setupViews() {
        setupBackground()
        setupInfoStackView()
        setupActionView()
        setupShare()
    }
    
    func setupBackground() {
        view.backgroundColor = .paleGrey
        scrollContainer.backgroundColor = .paleGrey
        shareContainer.backgroundColor = .paleGrey
    }
    
    func setupInfoStackView() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .bold, size: 16), textAlignment: .left))
        messageLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .light, size: 14), textAlignment: .left))
        dateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .light, size: 14), textAlignment: .right))
        topSeparator.backgroundColor = .lightGray
        bottomSeparator.backgroundColor = .lightGray
        drawRoundedAndShadowed(view: infoContainer)
    }
    
    func setupActionView() {
        actionLabel.applyStyle(LabelStylist(textColor: .santanderRed, font: .santander(family: .lato, type: .bold, size: 16), textAlignment: .center))
        actionLabel.text = localized("generic_button_notificationDelete")
        actionImage.image = Assets.image(named: "icnDeleteRed")
        drawRoundedAndShadowed(view: actionView)
    }
    
    func drawRoundedAndShadowed(view: UIView) {
        view.drawShadow(offset: 3.0, color: UIColor.black.withAlphaComponent(0.05))
        view.drawBorder(cornerRadius: 5.0, color: UIColor(white: 216.0 / 255.0, alpha: 1.0))
    }
    
    func setupShare() {
        shareView.arrangedSubviews.forEach { self.drawRoundedAndShadowed(view: $0) }
        
        let fontConstant: CGFloat = UIDevice.current.isSmallScreenIphone ? 14.0 : 16.0
        smsImageView.image = Assets.image(named: "icnSmss")
        mailImageView.image = Assets.image(named: "icnMailMadrid")
        shareImageView.image = Assets.image(named: "icnShareMadrid")
        mailLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .bold, size: fontConstant)))
        smsLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .bold, size: fontConstant)))
        shareLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santander(family: .lato, type: .bold, size: fontConstant)))
        
        mailLabel.set(localizedStylableText: localized("generic_button_mail"))
        smsLabel.set(localizedStylableText: localized("generic_button_sms"))
        shareLabel.set(localizedStylableText: localized("generic_button_share"))
    }
    
    func configGestures() {
        actionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnDelete)))
        smsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnShareSms)))
        mailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnShareMail)))
        otherView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnShareOther)))
    }
    
    @objc func didTapOnDelete() {
        presenter.didTapOnDelete()
    }
    
    @objc func didTapOnShareSms() {
        presenter.didSelectShareOfType(.sms)
    }
    
    @objc func didTapOnShareMail() {
        presenter.didSelectShareOfType(.mail)
    }
    
    @objc func didTapOnShareOther() {
        presenter.didSelectShareOfType(.share)
    }
}

extension InboxNotificationDetailViewController: OldDialogViewPresentationCapable { }
