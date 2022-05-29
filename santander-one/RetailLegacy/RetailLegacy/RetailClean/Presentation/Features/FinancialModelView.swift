import UIKit

class FinancialModelView: TableModelViewItem<FinancialViewCell> {

    var globalPosition: GlobalPositionWrapper

    var financingLabelCoachmarkId: CoachmarkIdentifier?
    
    init(_ globalPosition: GlobalPositionWrapper, _ privateComponent: PresentationComponent) {
        self.globalPosition = globalPosition
        super.init(dependencies: privateComponent)
    }

    private func getFinancialText() -> String? {
        guard let financing = try? globalPosition.getTotalFinancing().getFormattedAmountUIWith1M() else {
            return nil
        }
        return financing
    }

    private func getYourMoneyText() -> String? {
        guard let inversion = try? globalPosition.getTotalMoney().getFormattedAmountUIWith1M() else {
            return nil
        }
        return inversion
    }

    private func getMultipleCurrencyString() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("pgBasket_label_differentCurrency")
    }

    private func getYourMoneyLabelString() -> LocalizedStylableText {
        var text = dependencies.stringLoader.getString("pg_label_totMoney")
        text.text = text.text.uppercased()
        return text
    }

    private func getFinancingabelString() -> LocalizedStylableText {
        var text = dependencies.stringLoader.getString("pg_label_totFinancing")
        text.text = text.text.uppercased()
        return text
    }

    override func bind(viewCell: FinancialViewCell) {
        viewCell.setLabelText(getYourMoneyLabelString(), getFinancingabelString())
        if let text = getYourMoneyText() {
            viewCell.setYourMoneyAmount(text)
        } else {
            viewCell.setYourMoneyMultipleCurrency(getMultipleCurrencyString())
        }
        if let text = getFinancialText() {
            viewCell.setFinancingAmount(text)
        } else {
            viewCell.setFinancingAmountMultipleCurrency(getMultipleCurrencyString())
        }
        viewCell.financingLabelCoachmarkId = financingLabelCoachmarkId
    }

    override var height: CGFloat? {
        return 80
    }
}
