//

import Foundation

class OrderDetailInfoViewModel: TableModelViewItem<OrderDetailViewCell> {
    
    private let titleInfo: LocalizedStylableText
    private let detailInfo: String
    
    init(titleInfo: LocalizedStylableText, detailInfo: String, dependencies: PresentationComponent) {
        self.titleInfo = titleInfo
        self.detailInfo = detailInfo
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OrderDetailViewCell) {
        viewCell.orderDetailTitleLabel.set(localizedStylableText: titleInfo)
        viewCell.orderDetailInfoLabel.text = detailInfo
    }
}
