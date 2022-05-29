//
//  GlobalSearchMainOperativesView.swift
//  GlobalSearch
//
//  Created by César González Palomino on 25/02/2020.
//

import CoreFoundationLib
import UI

protocol GlobalSearchMainOperativesViewDelegate: class {
    func didSelect(action: GlobalSearchButtonAction)
}

final class GlobalSearchMainOperativesView: UIView {
    
    weak var delegate: GlobalSearchMainOperativesViewDelegate?
    private var reportNumber: String = ""
    
    private lazy var initialView: UIView = {
        let initialView = UIView()
        addSubview(initialView)
        initialView.translatesAutoresizingMaskIntoConstraints = false
        initialView.fullFit()
        return initialView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setReportNumber( _ number: String) {
        self.reportNumber = number
    }
    
    fileprivate func setupSeparatorView() {
        let separatorView = UIView()
        separatorView.backgroundColor = .mediumSkyGray
        initialView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.topAnchor.constraint(equalTo: initialView.topAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: initialView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: initialView.trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
    fileprivate func setupTitleLabel() {
        let separatorView = UIView()
        separatorView.backgroundColor = .mediumSkyGray
        initialView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.topAnchor.constraint(equalTo: initialView.topAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: initialView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: initialView.trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
    private func setup() {
        backgroundColor = .white
        setupSeparatorView()
        
        let label = UILabel()
        label.font = UIFont.santander(family: .text, size: 17.0)
        label.set(localizedStylableText: localized("search_title_operational"))
        label.accessibilityIdentifier = "search_title_operational"
        label.textAlignment = .left
        initialView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: initialView.topAnchor, constant: 20).isActive = true
        label.leadingAnchor.constraint(equalTo: initialView.leadingAnchor, constant: 16.0).isActive = true
        label.trailingAnchor.constraint(equalTo: initialView.trailingAnchor, constant: 16.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        
        let reportDuplicatecontainerView = UIView()
        initialView.addSubview(reportDuplicatecontainerView)
        reportDuplicatecontainerView.translatesAutoresizingMaskIntoConstraints = false
        reportDuplicatecontainerView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        reportDuplicatecontainerView.leadingAnchor.constraint(equalTo: initialView.leadingAnchor, constant: 16.0).isActive = true
        initialView.trailingAnchor.constraint(equalTo: reportDuplicatecontainerView.trailingAnchor, constant: 16.0).isActive = true
        reportDuplicatecontainerView.heightAnchor.constraint(equalToConstant: 41.0).isActive = true
        let reportDuplicateView = GlobalSearchButtonView(action: .reportDuplicate)
        reportDuplicatecontainerView.addSubview(reportDuplicateView)
        reportDuplicateView.fullFit()
        
        let returnReceiptView = GlobalSearchButtonView(action: .returnReceipt)
        initialView.addSubview(returnReceiptView)
        returnReceiptView.translatesAutoresizingMaskIntoConstraints = false
        returnReceiptView.topAnchor.constraint(equalTo: reportDuplicateView.bottomAnchor, constant: 8).isActive = true
        returnReceiptView.leadingAnchor.constraint(equalTo: initialView.leadingAnchor, constant: 16.0).isActive = true
        initialView.trailingAnchor.constraint(equalTo: returnReceiptView.trailingAnchor, constant: 16.0).isActive = true
        returnReceiptView.heightAnchor.constraint(equalToConstant: 41.0).isActive = true
        
        let reuseTransfer = GlobalSearchButtonView(action: .reuseTransfer)
        initialView.addSubview(reuseTransfer)
        reuseTransfer.translatesAutoresizingMaskIntoConstraints = false
        reuseTransfer.topAnchor.constraint(equalTo: returnReceiptView.bottomAnchor, constant: 8).isActive = true
        reuseTransfer.leadingAnchor.constraint(equalTo: initialView.leadingAnchor, constant: 16.0).isActive = true
        initialView.trailingAnchor.constraint(equalTo: reuseTransfer.trailingAnchor, constant: 16.0).isActive = true
        reuseTransfer.heightAnchor.constraint(equalToConstant: 41.0).isActive = true
        
        let turnOffCard = GlobalSearchButtonView(action: .turnOffCard)
        initialView.addSubview(turnOffCard)
        turnOffCard.translatesAutoresizingMaskIntoConstraints = false
        turnOffCard.topAnchor.constraint(equalTo: reuseTransfer.bottomAnchor, constant: 8).isActive = true
        turnOffCard.leadingAnchor.constraint(equalTo: initialView.leadingAnchor, constant: 16.0).isActive = true
        initialView.trailingAnchor.constraint(equalTo: turnOffCard.trailingAnchor, constant: 16.0).isActive = true
        turnOffCard.heightAnchor.constraint(equalToConstant: 41.0).isActive = true
        initialView.bottomAnchor.constraint(equalTo: turnOffCard.bottomAnchor, constant: 23.0).isActive = true
        
        [reportDuplicateView, returnReceiptView, reuseTransfer, turnOffCard].forEach({ $0.delegate = self })
    }
    
    private func removeFaqsView() {
        let faqsView = initialView.subviews.filter { $0 is GlobalSearchFaqsView }.first
        faqsView?.removeFromSuperview()
    }
}

extension GlobalSearchMainOperativesView: GlobalSearchButtonViewDelegate {
    func didSelect(button: GlobalSearchButtonView, withAction action: GlobalSearchButtonAction) {
        switch action {
        case .reportDuplicate:
            if !button.isFlipped {
                guard let container = button.superview else { return }
                let reportDublicateBackView = createCallView()
                container.addSubview(reportDublicateBackView)
                reportDublicateBackView.fullFit()
                button.isFlipped = true
                UIView.flipView(viewToShow: reportDublicateBackView, viewToHide: button, flipBackIn: 2.0) {
                    button.isFlipped = false
                }
                return
            }
            delegate?.didSelect(action: action)
        default:
            delegate?.didSelect(action: action)
        }
    }
    
    @objc private func reportDuplicateAction() {
        delegate?.didSelect(action: .reportDuplicate)
    }
    
    private func createCallView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportDuplicateAction)))
        view.backgroundColor = .darkTorquoise
        view.layer.cornerRadius = 5.0
        view.isHidden = true
        
        let callNowLabel = UILabel()
        callNowLabel.text = localized("general_button_callNow")
        callNowLabel.textAlignment = .center
        callNowLabel.font = UIFont.santander(type: .light, size: 16.0)
        callNowLabel.textColor = UIColor.white
        callNowLabel.backgroundColor = .clear
        view.addSubview(callNowLabel)
        callNowLabel.translatesAutoresizingMaskIntoConstraints = false
        callNowLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let center = callNowLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        center.priority = .defaultLow
        center.isActive = true
        
        callNowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let numberLabel = UILabel()
        numberLabel.text = reportNumber
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.santander(type: .bold, size: 16.0)
        numberLabel.textColor = UIColor.white
        numberLabel.backgroundColor = .clear
        view.addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: callNowLabel.trailingAnchor, constant: 8.0).isActive = true
        
        let trailing = view.trailingAnchor.constraint(greaterThanOrEqualTo: numberLabel.trailingAnchor, constant: 50.0)
        trailing.priority = .required
        trailing.isActive = true
        
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let phoneImage = UIImageView(image: Assets.image(named: "icnPhoneWhite"))
        phoneImage.backgroundColor = .clear
        phoneImage.contentMode = .scaleAspectFit
        view.addSubview(phoneImage)
        phoneImage.translatesAutoresizingMaskIntoConstraints = false
        phoneImage.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        phoneImage.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        phoneImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        callNowLabel.leadingAnchor.constraint(equalTo: phoneImage.trailingAnchor, constant: 13.0).isActive = true
        
        return view
    }
}
