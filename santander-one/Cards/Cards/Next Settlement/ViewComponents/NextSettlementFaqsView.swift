//
//  NextSettlementFaqsView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 26/10/2020.
//

import UI
import CoreFoundationLib

protocol NextSettlementFaqsViewDelegate: TripFaqViewDelegate {}

final class NextSettlementFaqsView: UIDesignableView {
    weak var delegate: NextSettlementFaqsViewDelegate?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var faqsView: TripFaqsView!
    @IBOutlet private weak var separatorView: UIView!
    
    override func getBundleName() -> String {
        return "Cards"
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    public func addFaqs(_ viewModels: [TripFaqViewModel]) {
        faqsView.setupVieModels(viewModels)
    }
}

private extension NextSettlementFaqsView {
    func setupViews() {
        configureView()
        configureLabel()
    }
    
    func configureView() {
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = true
        separatorView.backgroundColor = .mediumSkyGray
        faqsView.delegate = self
        faqsView.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.nextSettlementListHowCardsOperate.rawValue
    }
    
    func configureLabel() {
        titleLabel.textColor = .sanGreyDark
        titleLabel.configureText(withKey: "nextSettlement_title_howCardsOperate",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20)))
        titleLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.nextSettlementTitleHowCardsOperate.rawValue
    }
}

extension NextSettlementFaqsView: TripFaqsViewDelegate {
    func didReloadTripFaq() {}
    
    func didExpandAnswer(question: String) {
        delegate?.didExpandAnswer(question: question)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        delegate?.didTapAnswerLink(question: question, url: url)
    }
}
