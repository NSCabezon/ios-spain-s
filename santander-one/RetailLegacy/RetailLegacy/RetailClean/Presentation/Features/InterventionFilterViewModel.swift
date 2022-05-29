import CoreFoundationLib
import Foundation
import UIKit

protocol InterventionFilterDelegate: class {
    func filter(ownershipProfile: OwnershipProfile)
    func updateTable(scrollToTop: Bool)
}

class InterventionFilterViewModel: TableModelViewItem<InterventionFilterViewCell> {
    weak var delegate: InterventionFilterDelegate?
    var isCollapsed: Bool = true
    var selected: Int? = 0

    private var filterProfiles: [OwnershipProfile] = [.all, .owner, .authorised, .representative]
    private var onGetResponse: (() -> Void)?

    init(delegate: InterventionFilterDelegate?, privateComponent: PresentationComponent) {
        self.delegate = delegate
        super.init(dependencies: privateComponent)
    }

    override func bind(viewCell: InterventionFilterViewCell) {
        getSelectedProfile()
        onGetResponse = {
            viewCell.selectedOption = self.selected
            self.setSpinnerTitle(inCell: viewCell)
        }
        viewCell.options = filterProfiles.map {
            text(of: $0)
        }
        viewCell.selectionDone = { cell in
            self.setSelected(selected: cell.selectedOption)
            self.setSpinnerTitle(inCell: cell)
            self.isCollapsed = true
            self.updateProducts()
            self.delegate?.updateTable(scrollToTop: true)
        }
        viewCell.spinnerTouched = { cell in
            self.isCollapsed = !self.isCollapsed
            self.setSpinnerTitle(inCell: cell)
            self.delegate?.updateTable(scrollToTop: false)
        }
        viewCell.set(imageUp: isCollapsed)
        viewCell.titleLabel.set(localizedStylableText: dependencies.stringLoader.getString("pg_label_filter_pb"))
        viewCell.drawOptions(draw: !isCollapsed)
    }

    private func updateProducts() {
        if let selected = selected {
            delegate?.filter(ownershipProfile: filterProfiles[selected])
        }
    }

    private func setSpinnerTitle(inCell cell: InterventionFilterViewCell) {
        if let index = self.selected {
            let option = self.filterProfiles[index]
            cell.set(spinnerTitle: self.text(of: option))
        } else {
            cell.set(spinnerTitle: LocalizedStylableText(text: "", styles: nil))
        }
    }

    private func text(of profile: OwnershipProfile) -> LocalizedStylableText {
        var key: String
        switch profile {
        case .all:
            key = "pg_select_everyone_pb"
        case .owner:
            key = "pg_select_owner_pb"
        case .authorised:
            key = "pg_select_authorised_pb"
        case .representative:
            key = "pg_select_legalrepResentative_pb"
        }
        return dependencies.stringLoader.getString(key)
    }

    private func getSelectedProfile() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getPGInterventionTypeUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: nil,
                onSuccess: { (result) in self.gotSelected(selected: result.profile) })
    }

    private func gotSelected(selected: OwnershipProfile) {
        if let index = (filterProfiles.firstIndex {
            $0 == selected
        }) {
            self.selected = index
            onGetResponse?()
        }
    }

    private func setSelected(selected: Int?) {
        self.selected = selected
        guard let selected = selected else {
            return
        }
        UseCaseWrapper(with: dependencies.useCaseProvider.setPGInterventionTypeUseCase(input: SetPGInterventionTypeUseCaseInput(profile: filterProfiles[selected])), useCaseHandler: dependencies.useCaseHandler, errorHandler: nil)
    }
    
    override var height: CGFloat? {
        return isCollapsed ? 50.0 : 200.0
    }
}
