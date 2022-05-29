import Foundation

class ImpositionSearchHeaderViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {
    
    var imposition: Imposition
    private let dependencies: PresentationComponent
    
    init(imposition: Imposition, dependencies: PresentationComponent) {
        self.imposition = imposition
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: .plain(text: impositionUI(from: imposition.subcontract)))
        view.amountlabel.set(localizedStylableText: .plain(text: imposition.settlementAmount.getFormattedAmountUI()))
    }
    
    private func impositionUI(from subContract: String) -> String {
        return dependencies.stringLoader.getString("detailImposition_text_impositionNumber", [StringPlaceholder(.number, subContract)]).text
    }
}
