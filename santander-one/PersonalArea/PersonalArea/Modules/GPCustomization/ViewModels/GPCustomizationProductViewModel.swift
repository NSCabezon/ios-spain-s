import CoreDomain
import CoreFoundationLib

struct GPCustomizationProductViewModel {
    private let backgroundProductType: ProductTypeEntity?
    let product: GlobalPositionProduct
    let baseUrl: String?
    let didUpdateAlias: ((GlobalPositionProduct, String?) -> Void)?

    var identifier: String {
        return product.productIdentifier
    }

    var productName: String {
        return product.alias ?? ""
    }

    var productType: ProductTypeEntity? {
        return backgroundProductType ?? ProductTypeEntity(rawValue: product.productId)
    }

    var imageUrl: String? {
        guard let baseUrl = baseUrl, let relativeUrl = (product as? CardEntity)?.buildImageRelativeUrl(miniature: true) else { return nil }
        return baseUrl + relativeUrl
    }

    var isDisabled: Bool {
        guard let card = (product as? CardEntity) else { return false }
        return card.isDisabled
    }

    var isVisible: Bool
    var isEditable: Bool
    var customAlias: String?
    var newAlias: String?

    init(product: GlobalPositionProduct, productType: ProductTypeEntity? = nil, baseUrl: String? = nil, didUpdateAlias: ((GlobalPositionProduct, String?) -> Void)? = nil, isEditable: Bool = false) {
        self.product = product
        self.isVisible = product.isVisible
        self.backgroundProductType = productType
        self.baseUrl = baseUrl
        self.didUpdateAlias = didUpdateAlias
        self.isEditable = isEditable
    }

    func updateAlias() {
        didUpdateAlias?(product, newAlias)
    }
}

extension GPCustomizationProductViewModel: Equatable {
    static func == (lhs: GPCustomizationProductViewModel, rhs: GPCustomizationProductViewModel) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.isVisible == rhs.isVisible && lhs.customAlias == rhs.customAlias
    }
}
