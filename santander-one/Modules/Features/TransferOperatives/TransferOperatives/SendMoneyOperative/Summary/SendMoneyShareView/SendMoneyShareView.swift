//
//  SendMoneyShareView.swift
//  TransferOperatives
//

import UI
import UIOneComponents
import CoreFoundationLib
import CoreDomain
import UIKit

final class SendMoneyShareView: UIShareView {
    @IBOutlet private var borders: [UIView]!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var brokenTicketImage: UIImageView!

    private let dependenciesResolver: DependenciesResolver
    private let summaryType: SendMoneyShareViewSectionBuilder.SummaryShareType
    private let operativeData: SendMoneyOperativeData
    private let fullName: String?

    init(dependenciesResolver: DependenciesResolver,
         summaryType: SendMoneyShareViewSectionBuilder.SummaryShareType,
         operativeData: SendMoneyOperativeData,
         fullName: String?) {
        self.dependenciesResolver = dependenciesResolver
        self.summaryType = summaryType
        self.operativeData = operativeData
        self.fullName = fullName
        super.init(nibName: "SendMoneyShareView", bundleName: Bundle.module)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        let views = SendMoneyShareViewSectionBuilder(dependenciesResolver: self.dependenciesResolver,
                                                     operativeData: self.operativeData,
                                                     fullName: self.fullName)
            .buildSummaryFor(summaryType)
        views.forEach { self.stackView.addArrangedSubview($0) }
        self.setAccessibilityIdentifiers()
    }
}

private extension SendMoneyShareView {

    func setupView() {
        self.brokenTicketImage.image = Assets.image(named: "imgTornBig")
        self.borders.forEach { $0.backgroundColor = .oneFlMediumSky }
    }

    func setAccessibilityIdentifiers() {
        self.brokenTicketImage.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareView.brokenTicketImage
    }
}
