//
//  ProductFilterView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 18/11/2019.
//

import UIKit

protocol ProductFilterViewDelegate: class {
    func onUpdatedConstraint(_ height: CGFloat, with title: String)
    func onUpdated(_ list: [Product], with title: String)
}

class ProductFilterView: UIView {
    @IBOutlet var container: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var allViewHeight: NSLayoutConstraint!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    weak var delegate: ProductFilterViewDelegate?
    var isExpanded = false
    var title: String?
    var cellHeight: CGFloat = 40
    var spacing: CGFloat = 16
    var list = [Product]()
    var selectAllGroup: GlobileCheckBoxGroup = GlobileCheckBoxGroup(checkboxes: [])
    var selectAll = GlobileCheckBox()
    var listGroup: GlobileCheckBoxGroup = GlobileCheckBoxGroup(checkboxes: [])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: ProductFilterView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        prepareUI()
    }
    
    private func prepareUI() {
        self.topSeparator.backgroundColor = .paleSkyBlue
        self.bottomSeparator.backgroundColor = .paleSkyBlue
        prepareTitle()
        prepareSelectAll(with: "")
        setHeight()
    }
    
    private func prepareTitle() {
        titleLabel.font = .santanderText(type: .regular, with: 16)
        titleLabel.textColor = .greyishBrown
        addGestureRecognizer()
    }
    
    private func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        tapGesture.cancelsTouchesInView = false
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    func set(list: [Product], with delegate: ProductFilterViewDelegate, and title: String) {
        self.delegate = delegate
        self.title = title
        self.list = list
        self.titleLabel.text = "\(title) (\(list.count))"
        setHeight()
        prepareSelectAll(with: title)
        setList(list)
    }
    
    @objc private func onTap(_ sender: UIGestureRecognizer) {
        self.isExpanded = !isExpanded
        setHeight()
    }
    
    private func setHeight() {
        let height: CGFloat = setAllView() + setListView() + setTitleView()
        guard let thisTitle = title else { return }
        self.delegate?.onUpdatedConstraint(height, with: thisTitle)
    }
    
    private func setAllView() -> CGFloat {
        let height = cellHeight + spacing
        allViewHeight.constant = height
        allView.isHidden = !isExpanded
        return isExpanded ? height : 0
    }
    
    private func setListView() -> CGFloat {
        let height: CGFloat = cellHeight
        let spacingHeight: CGFloat = list.count == 1 ? spacing : (spacing/2) * CGFloat(list.count)
        listHeight.constant = (height * CGFloat(list.count)) + spacingHeight
        listView.isHidden = !isExpanded
        debugPrint("list height: \(listHeight.constant)")
        debugPrint("cell height: \(height)")
        debugPrint("spacing height: \(spacingHeight)")
        return isExpanded ? listHeight.constant : 0
    }
    
    private func setTitleView() -> CGFloat {
        let height = cellHeight + spacing
        titleHeight.constant = height
        return height
    }
    
    private func prepareSelectAll(with title: String) {
        selectAllGroup.removeFromSuperview()
        selectAll.color = .turquoise
        selectAll.text = String(format: SetupString().selectAll, title)
        selectAllGroup = GlobileCheckBoxGroup(checkboxes: [selectAll])
        selectAllGroup.delegate = self
        allView.addSubviewWithAutoLayout(selectAllGroup, topAnchorConstant: .equal(to: 16), bottomAnchorConstant: .equal(to: -16), leftAnchorConstant: .equal(to: 16), rightAnchorConstant: .equal(to: -16))
    }
    
    private func setList(_ list: [Product]) {
        listGroup.removeFromSuperview()
         var checkList = [GlobileCheckBox]()
        list.forEach({
            checkList.append(getListCheBox(for: $0))
        })
        listGroup = GlobileCheckBoxGroup(checkboxes: checkList)
        listGroup.delegate = self
        listView.addSubviewWithAutoLayout(listGroup, topAnchorConstant: .equal(to: 16), bottomAnchorConstant: .equal(to: -16), leftAnchorConstant: .equal(to: 16), rightAnchorConstant: .equal(to: -16))
        checkLocalStorage()
        checkSelection()
    }
    
    private func getListCheBox(for product: Product) -> GlobileCheckBox {
        let check = GlobileCheckBox()
        check.text = product.displayNumber
        check.color = .turquoise
        check.isSelected = true
        return check
    }
    
    private func checkLocalStorage() {
        guard let blackList = SecureStorageHelper.getBlackList() else { return }
        listGroup.checkboxes.forEach { (check) in
            switch self.title {
            case SetupString().accounts:
                self.accountContains(check: check, in: blackList)
            case SetupString().cards:
                self.cardsContains(check: check, in: blackList)
            default:
                break
            }
        }
    }
    
    private func cardsContains(check: GlobileCheckBox, in blackList: BlackList) {
        if blackList.cardCodes?.contains(where: {$0.displayNumber == check.text}) ?? false {
            check.isSelected = false
        }
    }
    
    private func accountContains(check: GlobileCheckBox, in blackList: BlackList) {
         if blackList.accountCodes?.contains(where: {$0.displayNumber == check.text}) ?? false {
             check.isSelected = false
         }
     }
}


extension ProductFilterView: GlobileCheckboxGroupDelegate {
    
    func didSelect(checkbox: GlobileCheckBox) {
        if checkbox == selectAll {
            checkAll()
        } else {
            checkSelection()
        }
    }
    
    func didDeselect(checkbox: GlobileCheckBox) {
        if checkbox != selectAll {
            checkSelection()
        }
    }
    
    func checkAll() {
        listGroup.checkboxes.forEach({$0.isSelected = true})
        returnSelected()
    }
    
    func returnSelected() {
        guard let returnTitle = title else { return }
        var returnList = [Product]()
        listGroup.checkboxes.forEach { (check) in
            guard !check.isSelected, let product = list.first(where: {$0.displayNumber == check.text}) else { return }
            returnList.append(product)
        }
        delegate?.onUpdated(returnList, with: returnTitle)
    }
    
    func checkSelection() {
        selectAll.isSelected = true
        listGroup.checkboxes.forEach { (check) in
            if check.isSelected == false {
                selectAll.isSelected = false
                return
            }
        }
        returnSelected()
    }
}
