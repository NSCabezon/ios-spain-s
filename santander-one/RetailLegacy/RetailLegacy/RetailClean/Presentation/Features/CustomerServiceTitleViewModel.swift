import Foundation

class CustomerServiceTitleViewModel: TableModelViewHeader<CustomerServiceTitleHeaderView> {
    
    var title: LocalizedStylableText?
    
    init(title: LocalizedStylableText?) {
        self.title = title
        super.init()
    }
    
    override func bind(viewHeader: CustomerServiceTitleHeaderView) {
        if let title = title {
            viewHeader.setTitle(title)
        }
    }
    
}
