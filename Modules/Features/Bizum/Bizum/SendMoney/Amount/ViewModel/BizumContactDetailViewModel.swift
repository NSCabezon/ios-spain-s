import Foundation
import CoreFoundationLib

final class BizumContactDetailModel {
    let fullName: String?
    let initials: String?
    let mobile: String
    let amount: Decimal
    let color: ColorsByNameViewModel
    let thumbnailData: Data?
    
    public init(fullName: String?,
                initials: String?,
                mobile: String,
                amount: Decimal = 0,
                color: ColorsByNameViewModel,
                thumbnailData: Data?) {
        self.fullName = fullName
        self.initials = initials
        self.mobile = mobile
        self.amount = amount
        self.color = color
        self.thumbnailData = thumbnailData
    }
}

protocol BizumContactDetailViewProtocol: class {
    func showNameAndInitials(_ fullName: String, _ initials: String)
    func hideFullName()
    func showMobile(_ mobile: String)
    func hideMobile()
    func showAmount(_ amount: NSAttributedString)
    func showColorModel(_ colorModel: ColorsByNameViewModel)
    func showContactThumbnailData(_ data: Data)
    func hideSeparator()
}

class BizumContactDetailViewModel {
    private var amountAtributte: NSAttributedString {
        let amountAtributte = MoneyDecorator(AmountEntity(value: contactDetail.amount),
                                             font: UIFont.santander(family: .text,
                                                                    type: .regular,
                                                                    size: 17.0), decimalFontSize: 17.0).formatAsMillions()
        return amountAtributte ?? NSAttributedString()
    }
    private let contactDetail: BizumContactDetailModel
    weak var view: BizumContactDetailViewProtocol?

    init(destinationDetail: BizumContactDetailModel) {
        self.contactDetail = destinationDetail
    }

    func updateView() {
        if let fullName = contactDetail.fullName {
            view?.showNameAndInitials(fullName, contactDetail.initials ?? "")
        } else {
            view?.hideFullName()
        }
        view?.showMobile(contactDetail.mobile)
        view?.showAmount(amountAtributte)
        if let thumbnailData = contactDetail.thumbnailData {
            view?.showContactThumbnailData(thumbnailData)
        } else {
            view?.showColorModel(contactDetail.color)
        }
    }

    func hideSeparator() {
        view?.hideSeparator()
    }

 }
