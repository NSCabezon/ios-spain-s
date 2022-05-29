import UIKit

class GroupableTableViewCell: BaseViewCell {

    var isFirst = false
    var isLast = false
    var isCellSelected = false
    
    var isSeparatorVisible = false {
        didSet {
            separator.isHidden = !isSeparatorVisible
        }
    }
    var cellSelected = false {
        didSet {
            isCellSelected = cellSelected
        }
    }
    internal lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .lisboaGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSeparator()
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setPlace(isFirst: Bool, isLast: Bool) {
        self.isFirst = isFirst
        self.isLast = isLast
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        applyRoundedStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyRoundedStyle()
    }
    
    var roundedView: UIView {
        fatalError()
    }
    
    private func applyRoundedStyle() {
        switch (isFirst, isLast) {
        case (true, false):
            StylizerNonCollapsibleViewCells.applyHeaderOpenViewCellStyle(view: roundedView, selected: isCellSelected)
        case (false, true):
            StylizerNonCollapsibleViewCells.applyBottomViewCellStyle(view: roundedView, selected: isCellSelected)
        case (true, true):
            StylizerNonCollapsibleViewCells.applyAllCornersViewCellStyle(view: roundedView, selected: isCellSelected)
        case (false, false):
            StylizerNonCollapsibleViewCells.applyMiddleViewCellStyle(view: roundedView, selected: isCellSelected)
        }
    }
    
    private func addSeparator() {
        roundedView.addSubview(separator)
        separator.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -1.0).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: roundedView.leftAnchor, constant: 10).isActive = true
        separator.rightAnchor.constraint(equalTo: roundedView.rightAnchor, constant: -10).isActive = true
    }
}
