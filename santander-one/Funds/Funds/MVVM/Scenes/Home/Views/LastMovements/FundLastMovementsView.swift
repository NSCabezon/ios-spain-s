//
//  FundLastMovementsView.swift
//  Funds
//

import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib

private enum LastMovementsIdentifiers {
    static let viewMoreLabel: String = "funds_label_viewMore"
    static let arrowRight: String = "icnArrowRight"
}

private enum LastMovementsConstants {
    static let moreMovementsViewHeight: CGFloat = 41
}

final class FundLastMovementsView: XibView {
    @IBOutlet private weak var movementsStackView: UIStackView!
    @IBOutlet private weak var moreMovementsView: UIView!
    @IBOutlet private weak var moreMovementsImageView: UIImageView!
    @IBOutlet private weak var moreMovementsLabel: UILabel!
    @IBOutlet private weak var moreMovementsButton: UIButton!
    
    private var anySubscriptions: Set<AnyCancellable> = []
    let lastMovementsSubject = PassthroughSubject<FundMovements, Never>()
    let lastMovementsErrorSubject = PassthroughSubject<LocalizedError, Never>()
    let movementDetailsSubject = PassthroughSubject<FundMovementDetails, Never>()
    let movementsIsLoadingSubject = PassthroughSubject<Bool, Never>()
    let didSelectMoreMovementsSubject = PassthroughSubject<FundMovements, Never>()
    let didSelectMovementDetailSubject = PassthroughSubject<(movement: FundMovementRepresentable, fund: FundRepresentable), Never>()
    var viewModel: FundMovements?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setAccessibilityIdentifiers()
        self.setupView()
        self.bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAccessibilityIdentifiers()
        self.setupView()
        self.bind()
    }

    @IBAction func goToMoreMovements(_ sender: UIButton) {
        guard let fundMovements = self.viewModel else { return }
        self.didSelectMoreMovementsSubject.send(fundMovements)
    }
}

private extension FundLastMovementsView {
    func setupView() {
        self.moreMovementsLabel.text = localized(LastMovementsIdentifiers.viewMoreLabel)
        self.moreMovementsImageView.image = UIImage(named: LastMovementsIdentifiers.arrowRight, in: .module, compatibleWith: nil)
        self.moreMovementsView.isHidden = true
    }

    func setAccessibilityIdentifiers() {
        moreMovementsLabel.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsLabelViewMore.rawValue
        moreMovementsImageView.accessibilityIdentifier = AccessibilityIdFundLastMovements.icnArrowRight.rawValue
        moreMovementsButton.accessibilityIdentifier = AccessibilityIdFundLastMovements.fundsBgViewMore.rawValue
        setAccessibility { [weak self] in
            self?.moreMovementsButton.accessibilityLabel = localized("product_button_seeMore")
        }
    }

    func bind() {
        self.lastMovementsSubject
            .sink { [unowned self] fundMovements in
                self.viewModel = fundMovements
                self.setupSections()
                self.setupMoreMovementsView()
            }.store(in: &self.anySubscriptions)

        self.lastMovementsErrorSubject
            .sink { [unowned self] _ in
                self.addEmptyList()
                self.moreMovementsView.isHidden = true
            }.store(in: &self.anySubscriptions)

        self.movementDetailsSubject
            .sink { [unowned self] fundMovementDetails in
                let movementViews = self.movementsStackView.arrangedSubviews as? [FundMovementView]
                movementViews?.filter({ $0.isOpeningMovementDetails }).first?.setDetailView(fundMovementDetails)
            }.store(in: &self.anySubscriptions)

        movementsIsLoadingSubject
            .sink { [unowned self] isMovementsLoading in
                if isMovementsLoading {
                    self.addLoadingView()
                }
            }
            .store(in: &anySubscriptions)
    }

    func setupSections() {
        guard let lastThreeMovements = viewModel?.lastThreeMovements,
              lastThreeMovements.isNotEmpty else {
            addEmptyList()
            return
        }
        addSections(lastThreeMovements)
    }

    func setupMoreMovementsView() {
        let hasMoreThanThreeMovements = self.viewModel?.hasMoreThanThreeMovements ?? false
        self.moreMovementsView.isHidden = !hasMoreThanThreeMovements
    }

    func addSections(_ lastThreeMovements: [FundMovementRepresentable]) {
        emptyStack()
        lastThreeMovements.forEach({ movement in
            let fundMovementView = FundMovementView()
            fundMovementView.setViewModel(self.viewModel, andMovement: movement)
            fundMovementView.didSelectMovementDetail = { [weak self] movement, fund in
                self?.didSelectMovementDetailSubject.send((movement: movement, fund: fund))
            }
            self.movementsStackView.addArrangedSubview(fundMovementView)
        })
    }
    
    func addEmptyList() {
        emptyStack()
        let emptyListView = FundSectionEmptyView()
        movementsStackView.addArrangedSubview(emptyListView)
    }

    func addLoadingView() {
        emptyStack()
        let loadingView = FundSectionLoadingView()
        loadingView.updateTitle(with: .transactions)
        movementsStackView.addArrangedSubview(loadingView)
    }

    func emptyStack() {
        movementsStackView.arrangedSubviews.forEach {  removeView($0) }
    }

    func removeView(_ view: UIView) {
        movementsStackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}

extension FundLastMovementsView: AccessibilityCapable {}

