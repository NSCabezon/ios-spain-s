import CoreFoundationLib
import UI

protocol ListAllFractionablePurchasesDelegate: AnyObject {
    func didSelectSeeFrationateOptions(viewModel: FractionablePurchaseViewModel)
}

final class ListAllFractionablePurchasesTableViewCell: UITableViewCell {
    static let identifier = "ListAllFractionablePurchasesTableViewCell"
    @IBOutlet weak private var stackView: UIStackView!

    var viewModel: FractionablePurchaseViewModel?
    var delegate: ListAllFractionablePurchasesDelegate?
    
    public static var bundle: Bundle? {
        return .module
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configureCell(_ model: FractionablePurchaseViewModel) {
        self.viewModel = model
        stackView.arrangedSubviews.forEach({
            stackView.removeArrangedSubview($0)
        })
        let titleAndAmountView = TitleAndAmountView(frame: .null)
        let cardImageNameAndPan = CardImageNameAndPanView(frame: .null)
        stackView.addArrangedSubview(titleAndAmountView)
        stackView.addArrangedSubview(cardImageNameAndPan)
        cardImageNameAndPan.configView(model.cardTitle, imageUrl: model.imageUrl)
        titleAndAmountView.configView(model)
        addSeeFractionableOptionsView(model)
    }

    func addSeeFractionableOptionsView(_ viewModel: FractionablePurchaseViewModel) {
        let horizontalSeparator = SeparatorView(frame: .null)
        let view = CardSubscriptionSeeFractionateOptionsSelectorView()
        view.backgroundColor = .white
        view.delegate = self
        let isExpanded = viewModel.isExpanded
        let feeViewModels = viewModel.transaction?.feeViewModels ?? []
        view.configView(isExpanded, feeViewModels: feeViewModels)
        self.stackView.addArrangedSubview(view)
        self.stackView.addArrangedSubview(horizontalSeparator)
    }
}

extension ListAllFractionablePurchasesTableViewCell: CardSubscriptionSeeFractionateOptionsSelectorViewDelegate {
    func didTapInSelector() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.didSelectSeeFrationateOptions(viewModel: viewModel)
    }
}
