//
//  FundMovementView.swift
//  Funds
//

import UI
import OpenCombine
import UIOneComponents
import CoreDomain
import CoreFoundationLib

private enum FundMovementIdentifiers {
    static let arrowUp: String = "icnArrowUp"
    static let arrowDown: String = "icnArrowDown"
    static let arrowUpUnits: String = "icnArrowUpUnits"
    static let arrowDownUnits: String = "icnArrowDownUnits"
}

final class FundMovementView: XibView {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var submittedDateLabel: UILabel!
    @IBOutlet private weak var submittedDateValueLabel: UILabel!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var amountView: OneLabelHighlightedView!
    @IBOutlet private weak var unitsView: UIView!
    @IBOutlet private weak var unitsLabel: UILabel!
    @IBOutlet private weak var unitsButton: UIButton!
    @IBOutlet private weak var unitsImageView: UIImageView!
    @IBOutlet private weak var detailView: FundMovementDetailView!
    @IBOutlet private weak var infoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dottedLineView: DottedLineView!
    private var viewModel: FundMovements?
    private var movement: FundMovementRepresentable?
    var didSelectMovementDetail: ((FundMovementRepresentable, FundRepresentable) -> Void)?
    var didUpdateHeight:(() -> Void)?
    var movementDetailsSubject: PassthroughSubject<(FundMovementRepresentable, FundMovementDetailRepresentable), Never>?
    var isOpeningMovementDetails: Bool = false

    private var isShowingInfoView: Bool {
        self.infoViewHeightConstraint.constant != 0
    }

    private var amountAttributeString: NSAttributedString? {
        guard let amount = self.movement?.amountRepresentable else { return nil}
        let font: UIFont = UIFont.santander(family: .micro, type: .bold, size: 16.0)
        let decorator = AmountRepresentableDecorator(amount, font: font, decimalFontSize: 16.0)
        return decorator.formatAsMillions()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setAccessibilityIdentifiers()
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAccessibilityIdentifiers()
        self.setupView()
    }

    @IBAction func showMovementInfo(_ sender: UIButton) {
        guard self.detailView.viewModel.isNil else {
            self.changeMovementInfoVisibility()
            return
        }
        self.isOpeningMovementDetails = true
        guard let movement = movement, let fund = viewModel?.fund else { return }
        self.didSelectMovementDetail?(movement, fund)
    }

    func setViewModel(_ viewModel: FundMovements?, andMovement movement: FundMovementRepresentable?, andDetail detail: FundMovementDetails? = nil) {
        self.viewModel = viewModel
        self.movement = movement
        if let detail = detail {
            self.detailView.setViewModel(detail)
        }
        let dateFormatted = movement?.dateRepresentable?.toString("eeee, d MMMM", locale: viewModel?.currentLocale ?? Locale.current).camelCasedString ?? ""
        var dateValue = dateFormatted
        if movement?.dateRepresentable?.isDayInToday() ?? false {
            let datePlaceholder = StringPlaceholder(.date, dateFormatted)
            dateValue = localized("generic_label_todayTransaction", [datePlaceholder]).text
        }
        self.dateLabel.text = dateValue
        self.aliasLabel.text = movement?.nameRepresentable
        var unitsValue = ""
        if let movement = movement, let units = viewModel?.getUnits(for: movement) {
            unitsValue = units
        }
        let unitsPlaceholder: StringPlaceholder = StringPlaceholder(.value, unitsValue)
        self.unitsLabel.text = localized("funds_label_units_other", [unitsPlaceholder]).text
        let submittedDateFormatted = movement?.submittedDateRepresentable?.toString(TimeFormat.d_MMM.rawValue, locale: viewModel?.currentLocale ?? Locale.current).camelCasedString ?? ""
        self.submittedDateLabel.text = localized("funds_label_submitted")
        self.submittedDateValueLabel.text = submittedDateFormatted
        self.submittedDateValueLabel.isAccessibilityElement = false
        self.amountView.attributedText = self.amountAttributeString
        self.amountView.style = (movement?.amountRepresentable?.value ?? 0) > 0 ? .lightGreen : .clear
        self.setAccessibility {
            self.dateLabel.accessibilityLabel = localized("voiceover_executionDate", [StringPlaceholder(.date, dateValue)]).text
            self.aliasLabel.accessibilityLabel = localized("voiceover_transactionName", [StringPlaceholder(.value, movement?.nameRepresentable ?? "")]).text
            self.submittedDateLabel.accessibilityLabel = localized("voiceover_submittedDate", [StringPlaceholder(.date, submittedDateFormatted)]).text
            self.amountView.accessibilityLabel = localized("voiceover_transactionAmount", [StringPlaceholder(.value, self.amountView.text ?? "")] ).text
            self.setAccessibilityLabels()
        }
    }

    func setDetailView(_ viewModel: FundMovementDetails) {
        self.isOpeningMovementDetails = false
        self.detailView.setViewModel(viewModel)
        self.changeMovementInfoVisibility()
    }

    func showMovementInfo() {
        self.changeMovementInfoVisibility()
    }
}

private extension FundMovementView {
    func setupView() {
        self.setupUnitsArrow()
        dottedLineView.lineDashPattern = [4, 2]
    }

    func setAccessibilityIdentifiers() {
        dateLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsLabelDay.rawValue
        submittedDateLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsLabelSubmittedTitle.rawValue
        submittedDateValueLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundLabelSubmitted.rawValue
        aliasLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsLabelTransactionsAlias.rawValue
        amountView.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsLabelTransactionsAmount.rawValue
        unitsLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsLabelUnits.rawValue
        unitsImageView.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundUnitsChevron.rawValue
        unitsButton.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundUnitsBtn.rawValue
    }

    func setAccessibilityLabels() {
        accessibilityElements = [dateLabel, submittedDateLabel, aliasLabel, amountView, unitsButton, detailView]
        var unitsValue = ""
        if let movement = movement, let units = viewModel?.getUnits(for: movement) {
            unitsValue = units
        }
        self.unitsButton.accessibilityLabel = localized("voiceover_detailsNumberUnits", [StringPlaceholder(.number, unitsValue), StringPlaceholder(.value, self.detailView.isHidden ? localized("voiceover_folded") : localized("voiceover_unfolded"))]).text
    }

    func changeMovementInfoVisibility() {
        self.detailView.isHidden = self.isShowingInfoView
        let detailStackViewHeight = self.detailView.detailStackViewHeightConstraint.constant
        let detailViewTotalHeight = detailStackViewHeight + 112
        self.infoViewHeightConstraint.constant = self.isShowingInfoView ? 0 : detailViewTotalHeight
        self.setupUnitsArrow()
        self.didUpdateHeight?()
        self.setAccessibility { 
            self.setAccessibilityLabels()
        }
    }

    func setupUnitsArrow() {
        let unitsImage = self.isShowingInfoView ? FundMovementIdentifiers.arrowUpUnits : FundMovementIdentifiers.arrowDownUnits
        self.unitsImageView.image = UIImage(named: unitsImage, in: .module, compatibleWith: nil)
    }
}

extension FundMovementView: AccessibilityCapable {}
