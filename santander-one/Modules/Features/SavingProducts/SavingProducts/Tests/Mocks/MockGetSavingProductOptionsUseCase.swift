import OpenCombine
import CoreFoundationLib
import CoreDomain
import SavingProducts

final class MockGetSavingProductOptionsUseCase: GetSavingProductOptionsUseCase {
    func fetchHomeOptions(contractNumber: String?, savingsProductType: String) -> AnyPublisher<[SavingProductOptionRepresentable], Never> {
        return Just(buildOptions()).eraseToAnyPublisher()
    }

    func fetchOtherOperativesOptions(contractNumber: String?, savingsProductType: String) -> AnyPublisher<[SavingProductOptionRepresentable], Never> {
        return Just([]).eraseToAnyPublisher()
    }
    
    func buildOptions() -> [SavingProductOptionRepresentable] {
        var options: [SavingProductOptionRepresentable] = []
        options.append(
            SavingProductOption(title: "accountOption_button_transfer",
                                imageName: "oneIcnSendMoney",
                                accessibilityIdentifier: "",
                                type: .sendMoney,
                                titleIdentifier: "",
                                imageIdentifier: "")
        )
        options.append(
            SavingProductOption(title: "accountOption_button_statements",
                                imageName: "oneIcnReceipt",
                                accessibilityIdentifier: "",
                                type: .statements,
                                titleIdentifier: "",
                                imageIdentifier: "")
        )
        options.append(
            SavingProductOption(title: "accountOptions_button_regularPayments",
                                imageName: "oneIcnRegularPayments",
                                accessibilityIdentifier: "",
                                type: .regularPayments,
                                titleIdentifier: "",
                                imageIdentifier: "")
        )
        return options
    }
}

struct SavingProductOption: SavingProductOptionRepresentable {
    let title: String
    let imageName: String
    let accessibilityIdentifier: String
    let type: SavingProductOptionType
    var hash: String
    let titleIdentifier: String?
    let imageIdentifier: String?
    var imageColor: UIColor?
    var otherOperativesSection: SavingsActionSection?
    
    init(title: String,
         imageName: String,
         accessibilityIdentifier: String,
         type: SavingProductOptionType,
         titleIdentifier: String?,
         imageIdentifier: String?) {
        self.title = title
        self.imageName = imageName
        self.accessibilityIdentifier = accessibilityIdentifier
        self.type = type
        self.hash = title
        self.titleIdentifier = titleIdentifier
        self.imageIdentifier = imageIdentifier
    }
}
