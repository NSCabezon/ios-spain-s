//
//  TimeLineDetailViewController.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 01/07/2019.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib

public class TimeLineDetailViewController: UIViewController {
    @IBOutlet weak var logoDetailTL: URLImageView!
    @IBOutlet weak var icon: MerchantLetterIcon!
    @IBOutlet weak var invoiceCompanyLabel: UILabel!
    @IBOutlet weak var productNumberLabel: UILabel!
    @IBOutlet weak var shortDescriptionTextView: UITextView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var buttonStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notifyQuantityLabel: UILabel!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var dateDayLabel: UILabel!
    @IBOutlet weak var dateMonthLabel: UILabel!
    @IBOutlet weak var issueDateTitleLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    @IBOutlet weak var programmedInfoView: ProgrammedInfoView!
    @IBOutlet weak var loaderContainerView: UIView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var ctaStackView: CTAStackView!
    @IBOutlet weak var principalIssueDateView: UIStackView!
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chartViewTLDetail: TLChartView!
    
    var customAlertBar: AlertBarView!
    var remindmeOptionsView: ReminderFrequencySelector!
    
    var presenter: TimeLineDetailPresenterProtocol?
    let buttonStackHeight: CGFloat = 90
    let reminderOptionsHeight: CGFloat = 50
    let merchantColors = TimelineCellMerchantColors.shared
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = TimeLineString().titleToolbar
        modalPresentationStyle = .custom
        customAlertBar = AlertBarView(from: self)
        configureView()
        presenter?.viewDidLoad()
    }
    
    func configureView() {
        invoiceCompanyLabel.isHidden = true
        shortDescriptionTextView.isHidden = true
        notifyQuantityLabel.isHidden = true
        quantityLabel.isHidden = true
        chartViewTLDetail.isHidden = true
        productNumberLabel.isHidden = true
        issueDateTitleLabel.isHidden = true
        issueDateLabel.isHidden = true
        loader.setAnimationImagesWith(prefixName: "BS_s-loader-", range: 1...48)
        loaderContainerView.isHidden = true
        setReminderOptionsView()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.reset()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .sky30
        self.navigationController?.navigationBar.setNavigationBarColor(.sky30)
        self.navigationController?.navigationBar.barStyle = .default
        self.redrawNavigationBar()
        self.extendedLayoutIncludesOpaqueBars = true
        configureBack()
        self.view.backgroundColor = .sky30
    }

    private func redrawNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func reset() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func setReminderOptionsView() {
        remindmeOptionsView = ReminderFrequencySelector(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.contentStack.insertArrangedSubview(remindmeOptionsView, at: contentStack.arrangedSubviews.count - 2)
        remindmeOptionsView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 0).isActive = true
        remindmeOptionsView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: 0).isActive = true
        remindmeOptionsView.delegate = self
        remindmeOptionsView.isHidden = true
    }
    
    func setTextInLanguage() {
        self.title = TimeLineString().titleToolbar
    }
    
    private func configureBack() {
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "iconBack"), style: .plain, target: self, action: #selector(onBackPressed))
        barButton.tintColor = .sanRed
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc private func onBackPressed() {
        presenter?.didSelectBack()
    }
    
    func configProgrammedInfoViewForPeriodicEvent(_ event: PeriodicEvent) {
        programmedInfoView.issueDateTitleLabel.text = CustomEventDetailString().startDate
        programmedInfoView.issueDateInfoLabel.text = event.startDate.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyy)
        programmedInfoView.arrangmentDateTitleLabel.text = CustomEventDetailString().frequency
        switch event.frequency {
        case "00": programmedInfoView.arrangmentDateInfoLabel.text = CustomEventDetailString().none
        case "01": programmedInfoView.arrangmentDateInfoLabel.text = CustomEventDetailString().weekly
        case "02": programmedInfoView.arrangmentDateInfoLabel.text = CustomEventDetailString().twoWeeks
        case "03": programmedInfoView.arrangmentDateInfoLabel.text = CustomEventDetailString().monthly
        case "04": programmedInfoView.arrangmentDateInfoLabel.text = CustomEventDetailString().annually
        default:()
        }
        
        if let date = event.endDate {
            programmedInfoView.frecuencyTitleLabel.text = CustomEventDetailString().endDate
            programmedInfoView.frecuencyInfoLabel.text = date.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyy)
        } else {
            programmedInfoView.frecuencyTitleLabel.isHidden = true
            programmedInfoView.frecuencyInfoLabel.isHidden = true
        }
    }
        
}

extension TimeLineDetailViewController: StoryBoardInstantiable {
    static func storyboardName() -> String {
        return "TimeLineDetail"
    }
}

extension TimeLineDetailViewController: TimeLineDetailViewProtocol {
    func showEventLogo(_ logo: String?, type: TimeLineEvent.TransactionType) {
        icon.isHidden = true
        logoDetailTL.isHidden = false
        if let logoUrl = logo {
            let placeholder = UIImage.icon(for: type)
            if let size = placeholder?.size {
                imageWidth.constant = logoDetailTL.frame.size.height * size.width / size.height
            }
            logoDetailTL.setImage(fromUrl: logoUrl, placeholder: placeholder) { [weak self] image in
                guard let size = image?.size, let imageView = self?.logoDetailTL else { return }
                self?.imageWidth.constant = imageView.frame.size.height * size.width / size.height
            }
        } else if let defaultImage = UIImage.icon(for: type) {
            logoDetailTL.image = defaultImage
            imageWidth.constant = logoDetailTL.frame.size.height * defaultImage.size.width / defaultImage.size.height
        }
        
        switch type {
        case .personalEvent, .customEvent:
            logoDetailTL.tintColor = .lightBurgundy
        default:
            logoDetailTL.tintColor = .sanRed
        }
    }
    
    func showIcon(event: TimeLineEvent) {
        icon.isHidden = false
        logoDetailTL.isHidden = true

        icon.setupIcon(event: event)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 36).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 36).isActive = true
        icon.centerXAnchor.constraint(equalTo: icon.superview!.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: icon.superview!.centerYAnchor).isActive = true
    }
    
    func showEventName(_ name: String) {
        invoiceCompanyLabel.text = name
        invoiceCompanyLabel.isHidden = false
    }
    
    func showDescription(_ description: LocalizedStylableText, isPast: Bool) {
        shortDescriptionTextView.delegate = self
        shortDescriptionTextView.font = .santanderText(with: 14)
        if isPast {
            shortDescriptionTextView.textColor = .mediumSanGray
        } else {
            shortDescriptionTextView.textColor = .lisboaGray
        }
        shortDescriptionTextView.configureText(withLocalizedString: description)
        shortDescriptionTextView.isHidden = false
    }
    
    func showAmount(_ amount: Amount?, issueDate: Date, calculation: String?) {
        let today = Calendar.current.startOfDay(for: TimeLine.dependencies.configuration?.currentDate ?? Date())
        let isPastEvent = issueDate < today
        if let thisAmount = amount {
            setQuantityLabel(with: thisAmount, isPastEvent: isPastEvent)
        }
        setDisclaimerLabel(with: calculation, isPastEvent: isPastEvent)
    }
    
    func setQuantityLabel(with amount: Amount, isPastEvent: Bool) {
        quantityLabel.isHidden = false
        let isPast = isPastEvent
        let fontType: FontType = isPastEvent ? .bold : .boldItalic
        quantityLabel.attributedText = NSAttributedString(amount, isPast: isPast ,color: .greyishBrown, integerFont: .santanderText(type: fontType, with: 36), fractionFont: .santanderText(type: fontType, with: 27))
    }
    
    func setDisclaimerLabel(with disclaimer: String?, isPastEvent: Bool) {
        notifyQuantityLabel.isHidden = isPastEvent
        notifyQuantityLabel.text = disclaimer ?? TimeLineDetailString().calculatedDefectLabel
    }
    
    func showActivity(_ activity: [TimeLineEvent.Activity], event: TimeLineEvent, hasGroupedMonths: Bool) {
        loader.stopAnimating()
        loaderContainerView.isHidden = true
        switch event.transaction.type {
        case .personalEvent, .customEvent:
            chartViewTLDetail.isHidden = true
        default:
            if activity.count > 1 {
                chartViewTLDetail.renderChartWith(activity, event: event, delegate: self, hasGroupedMonths: hasGroupedMonths)
                chartViewTLDetail.isHidden = false
            }
        }
    }
    
    func showProduct(_ product: String, type: String?) {
        guard let detailDelegate = TimeLine.dependencies.configuration?.native?.timeLineDelegate else {
            showDisplayNumber(product, type: type)
            return
        }
        detailDelegate.mask(displayNumber: product, completion: { [weak self] displayNumber in
            self?.showDisplayNumber(displayNumber, type: type)
        })
    }
    
    func showDisplayNumber(_ product: String?, type: String?) {
        productNumberLabel.isHidden = false
        productNumberLabel.text = "\(type ?? "") \(product ?? "")".uppercased()
    }
    
    func showEventDate(_ date: Date) {
        dateContainer.layer.cornerRadius = 5
        dateContainer.backgroundColor = .sky30
        dateDayLabel.textColor = .brownishGrey
        dateDayLabel.font = .santanderText(type: .bold, with: 18)
        dateMonthLabel.textColor = .brownishGrey
        dateMonthLabel.font = .santanderText(type: .bold, with: 10)
        dateDayLabel.text = "\(date.getDay())"
        dateMonthLabel.text = date.getMonth().uppercased()
    }
    
    func showIssueDate(_ date: Date) {
        issueDateTitleLabel.isHidden = false
        issueDateLabel.isHidden = false
        issueDateTitleLabel.text = TimeLineDetailString().issueDate
        issueDateTitleLabel.textColor = .greyishBrown
        issueDateTitleLabel.font = .santanderText(with: 14)
        issueDateLabel.textColor = .greyishBrown
        issueDateLabel.font = .santanderText(type: .light, with: 14)
        issueDateLabel.text = date.string(format: .ddMMyyyy)
    }
    
    func showDetails(_ deferred: TimeLineEvent.DeferredDetails?) {
        guard let deferredDetails = deferred, deferredDetails.shouldPresentDetails() else {
            self.programmedInfoView.isHidden = true
            self.principalIssueDateView.isHidden = false
            return
        }
        self.programmedInfoView.isHidden = false
        self.principalIssueDateView.isHidden = true
        self.programmedInfoView.set(deferredDetails)
    }
    
    func showActivityLoadingIndicator() {
        loader.startAnimating()
        loaderContainerView.isHidden = false
    }
    
    func hideActivityLoadingIndicator() {
        loader.stopAnimating()
        loaderContainerView.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    func activityDidFail(with error: Error) {
        loader.stopAnimating()
        loaderContainerView.isHidden = true
    }
    
    func showCTAs(_ CTAs: [CTAAction]?, for event: TimeLineEvent, ctaEngine: CTAEngine) {
        guard let ctas = CTAs else {
            ctaStackView.isHidden = true
            buttonStackViewHeight.constant = 0
            return
        }
        ctaStackView.isHidden = false
        buttonStackViewHeight.constant = ctas.count <= 3 ? buttonStackHeight : (buttonStackHeight * 2) + 15
        ctaStackView.set(ctas, with: self, and: event, ctaEngine: ctaEngine)
    }
    
    func showHideAlertDropdown(alertType type: String?) {
        self.remindmeOptionsView.isHidden = type == nil
        self.remindmeOptionsView.set(alertType: type)
    }
    
    func showAlert(message: String, isAlertCreated: Bool) {
        customAlertBar.showAlertBar(messageHTML: message)
                
        if isAlertCreated {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) { [weak self] in
                guard let self = self else { return }
                self.scrollView.scrollToView(view: self.remindmeOptionsView, animated: true)
            }
        }
    }
            
    func showDeleteAlert() {
        let alert = GlobileAlertController(title: TimeLineDetailString().deleteAlertTitle,
                                             subtitle: TimeLineDetailString().deleteAlertMessage,
                                             message: nil,
                                             actions: [],
                                             completion: nil)
        let acceptAction = GlobileAlertAction(title: TimeLineDetailString().confirm, style: .primary, action: { [weak self] in
            guard let self = self else { return }
            self.presenter?.deleteAlertConfirmed()
            alert.dismiss(animated: true, completion: nil)
        })
        let cancelAction = GlobileAlertAction(title: TimeLineDetailString().cancel, style: .secondary, action: {
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(acceptAction)
        alert.modalPresentationStyle = .overCurrentContext
        present(alert, animated: true)
    }
    
    func configViewForPeriodicEvent(event: PeriodicEvent) {
        self.title = CustomEventDetailString().title
        showEventLogo(nil, type: .personalEvent)
        showEventName(event.title)
        showDescription(applyStyles(to: event.description ?? ""), isPast: false)
        dateDayLabel.isHidden = true
        dateMonthLabel.isHidden = true
        configProgrammedInfoViewForPeriodicEvent(event)
    }
    
    func showCTAsForPeriodicEvent(ctaEngine: CTAEngine) {
        guard let ctas = TimeLine.dependencies.ctasEngine.getCTAs(for: TimeLineEvent.TransactionType.masterEvent.rawValue) else {
            ctaStackView.isHidden = true
            buttonStackViewHeight?.constant = 0
            return
        }
        ctaStackView.isHidden = false
        buttonStackViewHeight?.constant = ctas.count <= 3 ? buttonStackHeight : (buttonStackHeight * 2) + 15
        ctaStackView.setForPeridicEvent(ctas, parentViewController: self, ctaEngine: ctaEngine)
    }
    
    func showDeleteEventAlert() {
        let alert = GlobileAlertController(title: CustomEventDetailString().deleteEventTitle,
                                             subtitle: CustomEventDetailString().deleteEventMessage,
                                             message: nil,
                                             actions: [],
                                             completion: nil)
        let acceptAction = GlobileAlertAction(title: TimeLineDetailString().confirm, style: .primary, action: { [weak self] in
            guard let self = self else { return }
            self.presenter?.deleteEventConfirmed()
            alert.dismiss(animated: true, completion: nil)
        })
        let cancelAction = GlobileAlertAction(title: TimeLineDetailString().cancel, style: .secondary, action: {
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(acceptAction)
        alert.modalPresentationStyle = .overCurrentContext
        present(alert, animated: true)
    }
    
    func blockCTAButtons() {
        loader.startAnimating()
        loaderContainerView.isHidden = false
        ctaStackView.isUserInteractionEnabled = false
    }
    
    func unblockCTAButtons() {
        loader.stopAnimating()
        loaderContainerView.isHidden = true
        ctaStackView.isUserInteractionEnabled = true
    }
}

extension TimeLineDetailViewController: ReminderFrequencySelectorDelegate {
    func reminderDropDownSelected<T>(_ item: GlobileDropdownData<T>, _ sender: GlobileDropdown<T>) {
        guard let type = item.value as? AlertType else { return }
        presenter?.alertSelected(type: type)
    }
    
    func reminderDropdownExpanded<T>(_ sender: GlobileDropdown<T>) {
        self.view.layoutIfNeeded()
    }
    
    func reminderDropdownCompressed<T>(_ sender: GlobileDropdown<T>) { }

}

extension TimeLineDetailViewController: TLChartViewDelegate {
    func onTapXAxis(_ axis: Double) {
        presenter?.onAxisFromChartSelected(axis)
    }
}

extension TimeLineDetailViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.presenter?.trackLink(with: URL)
        return true
    }
}
