import UIKit

public enum OperativeSummaryStandardLocationType {
    case payment
}

public struct OperativeSummaryStandardLocationViewModel {
    public let locationType: OperativeSummaryStandardLocationType
    public let viewModel: Any
    
    public init(locationType: OperativeSummaryStandardLocationType, viewModel: Any) {
        self.locationType = locationType
        self.viewModel = viewModel
    }
}

public final class OperativeSummaryStandardLocationView: UIView {
    public convenience init(_ item: OperativeSummaryStandardLocationViewModel) {
        self.init(frame: .zero)
        self.backgroundColor = .clear
        switch item.locationType {
        case .payment:
            guard
                let viewModel = item.viewModel as? OperativeSummaryPaymentLocationViewModel
                else { return }
            let view = getPaymentView(model: viewModel)
            addView(view)
        }
    }
    
    private func getPaymentView(model: OperativeSummaryPaymentLocationViewModel) -> UIView {
        return OperativeSummaryPaymentLocationView(model)
    }
    
    private func addView(_ view: UIView) {
        self.addSubview(view)
        view.fullFit()
    }
}
