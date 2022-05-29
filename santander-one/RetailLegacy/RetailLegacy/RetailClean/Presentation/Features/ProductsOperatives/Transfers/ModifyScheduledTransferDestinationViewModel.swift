//

import Foundation

class ModifyScheduledTransferDestinationViewModel: TableModelViewItem<ModifyScheduledTransferDestinationCell> {
    
    // MARK: - Private attributes
    
    private let beneficiary: String
    private let periodicity: String
    private let periodicityDetail: String
    private let country: String
    private let currency: String
    
    // MARK: - Public methods
    
    init(beneficiary: String, periodicity: String, periodicityDetail: String, country: String, currency: String, dependencies: PresentationComponent) {
        self.beneficiary = beneficiary
        self.periodicity = periodicity
        self.periodicityDetail = periodicityDetail
        self.country = country
        self.currency = currency
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ModifyScheduledTransferDestinationCell) {
        viewCell.beneficiary.text = beneficiary
        viewCell.periodicity.text = periodicity
        viewCell.periodicityDetail.text = periodicityDetail
        viewCell.country.text = country
        viewCell.currency.text = currency
    }
}
