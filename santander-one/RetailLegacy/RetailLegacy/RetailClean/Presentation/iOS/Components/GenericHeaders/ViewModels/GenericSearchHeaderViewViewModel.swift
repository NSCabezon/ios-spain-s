import UIKit

class GenericSearchHeaderViewViewModel: TableModelViewHeader<GenericSearchHeaderView> {
    
    private var title: LocalizedStylableText
    var searchAction: (() -> Void)?
    var clearAction: (() -> Void)?
    var coachmarkId: CoachmarkIdentifier?
    var isClearVisible = false
    private var setViewTitle: ((LocalizedStylableText) -> Void)?
    private var setViewClearVisible: ((Bool) -> Void)?
    private var setViewSearchIconVisible: ((Bool) -> Void)?

    init(title: LocalizedStylableText) {
        self.title = title
        super.init()
    }
    
    override var height: CGFloat {
        return 37
    }
    
    func setTitle(title: LocalizedStylableText, isClearVisible: Bool) {
        self.title = title
        setViewTitle?(title)
        self.isClearVisible = isClearVisible
        setViewClearVisible?(isClearVisible)
    }
        
    override func bind(viewHeader: GenericSearchHeaderView) {
        viewHeader.setTitle(title)
        setViewTitle = viewHeader.setTitle
        viewHeader.setClearButtonVisible(isClearVisible)
        setViewClearVisible = viewHeader.setClearButtonVisible
        setViewSearchIconVisible = viewHeader.setClearButtonVisible
        viewHeader.clearAction = clearAction
        viewHeader.searchAction = searchAction
        viewHeader.setButtonCoachmarkId(coachmarkId)
    }

}
