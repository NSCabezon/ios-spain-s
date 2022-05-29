//
//  ExportEventViewController.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 24/09/2019.
//

import UIKit

class ExportEventViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var exportEventButton: GlobileEndingButton!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var typeListHeight: NSLayoutConstraint!
    @IBOutlet weak var typeListView: UIView!
    @IBOutlet weak var typeListCard: GlobileCards!
    
    var presenter: ExportEventPresenterProtocol?
    var selectedButton: String?
    var typeListHeightFromList: CGFloat = 0
    var typeListArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        prepareUI()
    }
    
    func prepareUI() {
        self.title = MenuTitle().export
        self.view.backgroundColor = .paleGrey
        infoLabel.text = ExportEventString().info
        infoLabel.textColor = .greyishBrown
        infoLabel.font = .santanderText(type: .bold, with: 17)
        prepareOptions()
        exportEventButton.setTitle(MenuTitle().export, for: .normal)
        setExportEventsButton()
        prepareTransactionTypeList()
    }
    
    func prepareOptions() {
        groupView.addSubviewWithAutoLayout(getOptions())
    }
    
    func prepareTransactionTypeList() {
        typeListArray = presenter?.getTransactionTypes() ?? []
        let list = getTypeList()
        typeListCard.addSubviewWithAutoLayout(list, topAnchorConstant: .equal(to: 16), bottomAnchorConstant: .equal(to: -16), leftAnchorConstant: .equal(to: 8), rightAnchorConstant: .equal(to: -8))
        typeListHeightFromList = CGFloat(list.checkboxes.count * 50) + 72 + 32

    }
    
    func setExportEventsButton() {
        exportEventButton.isEnabled = selectedButton != nil && selectedButton != ""
        
        if selectedButton == ExportEventString().withSpecificTypeOption {
            presenter?.onShowTransactionListTap(true)
            exportEventButton.isEnabled = typeListArray.count > 0
        } else {
            presenter?.onShowTransactionListTap(false)
        }
    }
    
    @IBAction func onExportTap(_ sender: Any) {
        guard let selected = selectedButton else { return }
        presenter?.onExportTap(with: selected, and: nil)
    }
    
}

// MARK: - View Protocol
extension ExportEventViewController: ExportEventViewProtocol {
    func showTransactionTypeList(_ show: Bool) {
        self.typeListView.isHidden = !show
        self.typeListHeight.constant = show ? typeListHeightFromList : 0
        debugPrint("show type list: \(show)")
    }
    
    func onFetching() {
        loadingView.startAnimating()
        debugPrint("fetching")
    }
    
    func onFetchFail(with error: Error) {
        loadingView.stopAnimatig()
        debugPrint("faail")
    }
    
    func onFetch(_ events: TimeLineEvents) {
        loadingView.stopAnimatig()
        debugPrint("fetched")
    }
}

// MARK: - StoryBoardInstatiable
extension ExportEventViewController: StoryBoardInstantiable {
    static func storyboardName() -> String {
        return "ExportEventView"
    }
}
