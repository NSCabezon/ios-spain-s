//
//  OperativeSummaryBizumBodyView.swift
//  Bizum
//
//  Created by Jose C.Yebes on 15/10/2020.
//

import UIKit
import UI
import Operative

protocol OperativeSummaryBizumBodyViewDelegate: class {
    func didCollapseRecipientsBody()
    func shareByWhatsappSelected()
}

final class OperativeSummaryBizumBodyView: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tornImageView: UIImageView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var actionStackView: UIStackView!
    @IBOutlet private weak var openCloseButton: UIButton!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var topActionsConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shareByWhatsappView: BizumSummarySharingByWhatsappView!
    @IBOutlet private weak var contentBrokenImgView: UIView!
    @IBOutlet private weak var contentBrokenImgViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var shareByWhatsappViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var actionStackViewWidth: NSLayoutConstraint!
    
    // MARK: - Private attributes
    
    private lazy var openCloseButtonBottomMarginToImage: NSLayoutConstraint = {
        self.openCloseButton.bottomAnchor.constraint(equalTo: self.tornImageView.bottomAnchor)
    }()
    private lazy var openCloseButtonBottomMarginToContent: NSLayoutConstraint = {
        self.openCloseButton.centerYAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    }()
    private var items: [BizumSummaryItem] = []
    
    // MARK: - Public methods
    
    public weak var delegate: OperativeSummaryBizumBodyViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupWithItems(_ items: [BizumSummaryItem], actions: [OperativeSummaryStandardBodyActionViewModel], showLastSeparator: Bool = true, shareViewModel: ShareBizumSummaryViewModel? = nil) {
        self.items = items
        self.add(self.items.prefix(items.count), collapsingContacts: true)
        setupActions(actions)
        if let contacts = shareViewModel {
            self.setSharingByWhatsappView(contacts)
        } else {
            self.hideShareByWhatsappView()
        }
    }
    
    public func hideShareByWhatsappView() {
        self.shareByWhatsappView.isHidden = true
        self.shareByWhatsappViewHeight.constant = .zero
    }
}

private extension OperativeSummaryBizumBodyView {
    func setupView() {
        self.tornImageView.image = Assets.image(named: "imgTornSummary")
        self.openCloseButton.setBackgroundImage(Assets.image(named: "icnOvalArrowDown"), for: .normal)
        self.openCloseButton.setBackgroundImage(Assets.image(named: "icnOvalArrowUp"), for: .selected)
        self.openCloseButton.addTarget(self, action: #selector(didTapOnOpenCloseButton), for: .touchUpInside)
        self.openCloseButtonBottomMarginToImage.isActive = true
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
    }
    
    func add(_ items: ArraySlice<BizumSummaryItem>, collapsingContacts collapsecontacts: Bool) {
        items.enumerated().forEach { _, viewModel in
            switch viewModel.metadata {
            case .standard(let standardItemData):
                let model = OperativeSummaryStandardBodyItemViewModel(title: viewModel.title, subTitle: standardItemData.subTitle, info: standardItemData.info, accessibilityIdentifier: standardItemData.accessibilityIdentifier)
                addStandardItem(model, showingSeparator: viewModel.position == .unknown)
            case .recipients(let list):
                addRecipientsList(list, title: viewModel.title, collapsingContacts: collapsecontacts, showingSeparator: viewModel.position == .unknown)
            case .multimedia(let data):
                addMultimediaItem(data, showingSeparator: viewModel.position == .unknown)
            case .organization(let data):
                self.disableExpansionBehaviour()
                self.addOrganizationItem(data)
            }
        }
    }
    
    func addStandardItem(_ model: OperativeSummaryStandardBodyItemViewModel, showingSeparator showSeparator: Bool) {
        let item = OperativeSummaryStandardBodyItemView(model)
        self.contentStackView.addArrangedSubview(item)
        if showSeparator {
            self.addSeparator()
        }
    }
    
    func addRecipientsList(_ list: [BizumSummaryRecipientItemViewModel], title: String, collapsingContacts collapsecontacts: Bool, showingSeparator: Bool) {
        let containerView = BizumSummaryRecipientsContainerView(title)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        if list.count > 1 {
            if collapsecontacts {
                 if let firstContact = list.first {
                     let itemView = BizumSummaryContactDetailView(firstContact)
                     containerView.addReceiver(itemView)
                 }
            } else {
                 list.enumerated().forEach { _, viewModel in
                     let itemView = BizumSummaryContactDetailView(viewModel)
                     containerView.addReceiver(itemView)
                 }
            }
        } else {
            disableExpansionBehaviour()
            if let firstContact = list.first {
                let itemView = BizumSummaryContactDetailView(firstContact)
                containerView.addReceiver(itemView)
            }
        }
        self.contentStackView.addArrangedSubview(containerView)
        if showingSeparator {
           self.addSeparator()
       }
    }
    
    func addMultimediaItem(_ multimediaData: BizumSummaryMultimediaViewModel, showingSeparator: Bool) {
        if let image = multimediaData.image, let imageText = multimediaData.imageText {
            let photoView = BizumSummaryMultimediaView()
            photoView.setup(BizumSummaryMultimediaItemViewModel(imageSize: CGSize(width: 24.0, height: 24.0),
                                                                topMargin: 8.0,
                                                                image: UIImage(data: image),
                                                                text: imageText))
                   self.contentStackView.addArrangedSubview(photoView)
            if multimediaData.note == nil && showingSeparator {
                photoView.showSeparator()
            }
        }
        if let note = multimediaData.note, let iconImage = multimediaData.noteIcon {
            let noteView = BizumSummaryMultimediaView()
            let topMargin: CGFloat = (multimediaData.image != nil) ? 0.0 : 8.0
            noteView.setup(BizumSummaryMultimediaItemViewModel(imageSize: CGSize(width: 32.0, height: 32.0), topMargin: topMargin, image: iconImage, text: note))
                    self.contentStackView.addArrangedSubview(noteView)
            if showingSeparator {
                noteView.showSeparator()
            }
        }
    }
    
    func addOrganizationItem(_ viewModel: BizumSummaryOrganizationViewModel) {
        let organizationView = BizumSummaryOrganizationView()
        organizationView.setupViewModel(viewModel)
        self.contentStackView.addArrangedSubview(organizationView)
    }
    
    func addSeparator() {
        let separator = PointLine(frame: .zero)
        separator.pointColor = UIColor.mediumSkyGray
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.contentStackView.addArrangedSubview(separator)
    }
    
    func expandContacts() {
        self.topActionsConstraint.constant = 30
        removeContactView()
        addContactView(collapsingtoFirst: false)
        self.tornImageView.image = nil
        self.openCloseButtonBottomMarginToImage.isActive = false
        self.openCloseButtonBottomMarginToContent.isActive = true
    }
     
    func collapseContacts() {
        self.topActionsConstraint.constant = 64
        removeContactView()
        addContactView(collapsingtoFirst: true)
        self.tornImageView.image = Assets.image(named: "imgTornSummary")
        self.openCloseButtonBottomMarginToImage.isActive = true
        self.openCloseButtonBottomMarginToContent.isActive = false
        self.delegate?.didCollapseRecipientsBody()
    }

    func disableExpansionBehaviour() {
        self.topActionsConstraint.constant = 12
        self.tornImageView.image = nil
        self.openCloseButton.isHidden = true
        self.contentBrokenImgView = nil
        self.contentBrokenImgViewHeight.constant = 0
    }
    
    func removeContactView() {
        if let lastView = contentStackView.arrangedSubviews.last {
            lastView.removeFromSuperview()
        }
    }
    
    func addContactView(collapsingtoFirst: Bool) {
        guard self.items.count > 0 else {
            return
        }
        let itemsLastIndex = items.count - 1
        self.add(self.items.suffix(from: itemsLastIndex), collapsingContacts: collapsingtoFirst)
    }
    
    func setSharingByWhatsappView(_ viewModel: ShareBizumSummaryViewModel) {
        // Check if user has whatsapp app installed
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let whatsappURL = URL(string: urlString), UIApplication.shared.canOpenURL(whatsappURL) {
            // In case onSuccess, draw view
            self.showShareByWhatsappView(viewModel)
        } else {
            // In case onError, hide view
            self.hideShareByWhatsappView()
        }
    }
    
    func showShareByWhatsappView(_ viewModel: ShareBizumSummaryViewModel) {
        self.shareByWhatsappView.delegate = self
        self.shareByWhatsappView.configure(viewModel)
    }
    
    // MARK: - Actions
    // MARK: expand/contract behaviour
    @objc func didTapOnOpenCloseButton() {
        if self.openCloseButton.isSelected {
            self.collapseContacts()
        } else {
            self.expandContacts()
        }
        self.openCloseButton.isSelected = !self.openCloseButton.isSelected
    }
    
    @objc func didTapOnAction(_ gesture: UIGestureRecognizer) {
           guard let actionButton = gesture.view as? ActionButton, let summaryAction = actionButton.getViewModel() as? OperativeSummaryStandardBodyActionViewModel else { return }
           summaryAction.action()
    }
       
    func setupActions(_ actions: [OperativeSummaryStandardBodyActionViewModel]) {
        let actionItemWidth: CGFloat = 164
        var stackActionsWidth: CGFloat = 0
        actions.forEach {
            let action = ActionButton()
            action.addSelectorAction(target: self, #selector(didTapOnAction))
            action.setViewModel($0)
            let constraint = action.widthAnchor.constraint(equalToConstant: actionItemWidth)
            constraint.priority = UILayoutPriority(rawValue: 749)
            constraint.isActive = true
            stackActionsWidth += actionItemWidth
            self.actionStackView.addArrangedSubview(action)
        }
        self.actionStackViewWidth.constant = stackActionsWidth
    }
}

extension OperativeSummaryBizumBodyView: DidTapInSharingByWhatsappDelegate {
    func didTapInShareByWhatsapp() {
        delegate?.shareByWhatsappSelected()
    }
}
