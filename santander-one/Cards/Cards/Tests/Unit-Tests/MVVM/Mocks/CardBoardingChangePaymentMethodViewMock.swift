import UnitTestCommons
import CoreFoundationLib
@testable import Cards

final class CardBoardingChangePaymentMethodViewMock: ChangePaymentMethodViewProtocol {
    var isFirstStep: Bool = false
    var associatedLoadingView: UIViewController = UIViewController()
    var isMonthlyViewVisible: SpyableObject<Bool> = SpyableObject(value: false)
    var isMonthlySelected: SpyableObject<Bool> = SpyableObject(value: false)
    var isDeferredViewVisible: SpyableObject<Bool> = SpyableObject(value: false)
    var isDeferredSelected: SpyableObject<Bool> = SpyableObject(value: false)
    var isFixedFeeViewVisible: SpyableObject<Bool> = SpyableObject(value: false)
    var isFixedFeeSelected: SpyableObject<Bool> = SpyableObject(value: false)
    var isSummaryPresented: SpyableObject<Bool> = SpyableObject(value: false)
    var selectedAmount: SpyableObject<Decimal?> = SpyableObject(value: nil)
    var paymentMethod:SpyableObject<PaymentMethodCategory> = SpyableObject(value: .monthlyPayment)
    var isErrorViewVisible: SpyableObject<Bool> = SpyableObject(value: false)
    var headerViewDescription: SpyableObject<String> = SpyableObject(value: "")

    func setHeaderView(_ viewModel: PaymentMethodHeaderViewModel) {
        self.headerViewDescription.value = viewModel.descriptionKey
    }

    func setMonthlyView(_ viewModel: PaymentMethodViewModel) {
        self.isMonthlyViewVisible.value = true
        self.isMonthlySelected.value = viewModel.viewState == .selected ? true : false
    }

    func setDeferredView(_ viewModel: PaymentMethodExpandableViewModel) {
        self.isDeferredViewVisible.value = true
        if viewModel.viewState == .selected {
            self.isDeferredSelected.value = true
            self.selectedAmount.value = viewModel.selectedAmount?.value
        }
    }

    func setFixedFeeView(_ viewModel: PaymentMethodExpandableViewModel) {
        self.isFixedFeeViewVisible.value = true
        if viewModel.viewState == .selected {
            self.isFixedFeeSelected.value = true
            self.selectedAmount.value = viewModel.selectedAmount?.value
        }
    }

    func setPaymentMethod(_ paymentMethod: PaymentMethodCategory) {
        self.paymentMethod.value = paymentMethod
    }

    func presentSummary(_ paymentMethod: PaymentMethodCategory) {
        self.isSummaryPresented.value = true
    }

    func showError(_ key: String) {
        self.isErrorViewVisible.value = true
    }

    func areAllPaymentMethodsViewsVisiblesValue() -> SpyableObject<Bool> {
        return SpyableObject(value: self.isMonthlySelected.value == true && self.isDeferredSelected.value == true && self.isFixedFeeSelected.value == true)
    }
}
