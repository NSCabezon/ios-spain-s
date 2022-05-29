//
//  EmergencyView.swift
//  PersonalArea
//
//  Created by alvola on 20/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol EmergencyViewDelegate: AnyObject {
    func didSelectCardReportCall(_ phoneNumber: String)
    func didSelectFraudReportCall(_ phoneNumber: String)
    func unlockSignatureKeyDidPress()
    func embassyHeightDidChange()
}

protocol EmergencyViewProtocol: AnyObject {
    func setEmbassyInfo(_ info: EmbassyViewModel)
    func setReportInfo(_ info: EmergencyReportViewModel)
    func setDelegate(_ delegate: EmergencyViewDelegate)
}

final class EmergencyView: DesignableView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cardReportContainerView: UIView!
    @IBOutlet private weak var cardReportView: ReportCard!
    @IBOutlet private weak var reportFraudContainerView: UIView!
    @IBOutlet private weak var reportFraudView: ReportFraud!
    @IBOutlet private weak var unlockSignatureKeyView: UnlockView!
    @IBOutlet private weak var embassyDetailView: EmbassyExpandableView!
    
    override var backgroundColor: UIColor? {
        get {
            return contentView?.backgroundColor
        }
        set {
            self.contentView?.backgroundColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reportFraudView?.setTitle("yourTrips_button_fraud", image: "icnThief")
    }
    
    private lazy var reportCardCallView: UIView = {
        return (self.emergencyReportViewModel?.cardReportNumbers ?? []).count > 1 ?
            multipleStolenCallView() : singleStolenCallView()
    }()
    
    private lazy var reportFraudCallView: SinglePhoneView = {
        let view = SinglePhoneView(frame: reportFraudView?.frame ?? .zero)
        view.setViewModel(PhoneViewModel(phone: self.emergencyReportViewModel?.fraudReportNumber ?? ""))
        view.delegate = self
        view.isHidden = true
        reportFraudContainerView?.addSubview(view)
        return view
    }()
    
    private func singleStolenCallView() -> UIView {
        let view = CallNowView(frame: cardReportView?.frame ?? .zero)
        view.setViewModel(PhoneViewModel(phone: self.emergencyReportViewModel?.cardReportNumbers.first ?? ""))
        view.isHidden = true
        view.delegate = self
        cardReportContainerView?.addSubview(view)
        return view
    }
    
    private func multipleStolenCallView() -> UIView {
        let doblePhoneCallView = DoublePhoneView()
        if let cardNumbers = self.emergencyReportViewModel?.cardReportNumbers, cardNumbers.count == 2 {
            let viewModels = (PhoneViewModel(phone: cardNumbers[0]),
                              PhoneViewModel(phone: cardNumbers[1]))
            doblePhoneCallView.setViewModels(viewModels)
        }
        cardReportContainerView.addSubview(doblePhoneCallView)
        doblePhoneCallView.fullFit()
        doblePhoneCallView.delegate = self
        doblePhoneCallView.isHidden = true
        return doblePhoneCallView
    }
    
    weak var delegate: EmergencyViewDelegate?
    private var emergencyReportViewModel: EmergencyReportViewModel?

    // MARK: - privateMethods
    
    private func commonInit() {
        contentView?.backgroundColor = UIColor.whitesmokes
        configureTitle()
        configureSubviews()
    }
    
    private func configureTitle() {
        titleLabel.font = UIFont.santander(type: .bold, size: 20.0)
        titleLabel.textColor = UIColor.lisboaGray
        titleLabel.text = localized("yourTrips_label_emergencies")
    }
    
    private func configureSubviews() {
        embassyDetailView?.delegate = self
        configureReportCard()
        configureReportFraud()
        configureUnlockView()
    }
    
    private func configureReportCard() {
        cardReportView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCardReport)))
        cardReportView.isUserInteractionEnabled = true
    }
    
    private func configureReportFraud() {
        reportFraudView.setTitle("yourTrips_button_fraud", image: "icnThief")
        reportFraudView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipReportFraud)))
        reportFraudView.isUserInteractionEnabled = true
    }
    
    private func configureUnlockView() {
        unlockSignatureKeyView?.setTitle("yourTrips_button_signatureKey", image: "icnKeyLock")
        unlockSignatureKeyView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unlockDidPress)))
    }
    
    @objc private func unlockDidPress() {
        self.delegate?.unlockSignatureKeyDidPress()
    }
    
    @objc private func flipReportFraud() {
        UIView.flipView(viewToShow: reportFraudCallView,
                        viewToHide: reportFraudView,
                        flipBackIn: 2.2)
    }
    
    @objc private func flipCardReport() {
        UIView.flipView(viewToShow: reportCardCallView,
                        viewToHide: cardReportView,
                        flipBackIn: 2.2)
    }
}

extension EmergencyView: EmergencyViewProtocol {
    func setEmbassyInfo(_ info: EmbassyViewModel) {
        self.embassyDetailView?.setEmbassyInfo(info)
    }
    
    func setReportInfo(_ info: EmergencyReportViewModel) {
        self.emergencyReportViewModel = info
    }
    
    func setDelegate(_ delegate: EmergencyViewDelegate) {
        self.delegate = delegate
    }
}

extension EmergencyView: CallNowViewDelegate {
    func didSelectCall(_ phoneNumber: String) {
        delegate?.didSelectCardReportCall(phoneNumber)
    }
}

extension EmergencyView: SinglePhoneViewDelegate {
    func didSelectSinglePhoneView(_ phoneNumber: String) {
        delegate?.didSelectFraudReportCall(phoneNumber)
    }
}

extension EmergencyView: DoublePhoneViewDelegate {
    func didSelectDobleCall(_ phoneNumber: String) {
        delegate?.didSelectCardReportCall(phoneNumber)
    }
}

extension EmergencyView: EmbassyExpandableViewDelegate {
    func heightDidChange() {
        delegate?.embassyHeightDidChange()
    }
}
