import UIKit
import UI
import CoreFoundationLib

protocol GlobalSecurityViewFactory {
    func makeProtectionView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> ProtectionView
    func makePermissionsView(idContainer: String?, idButton: String?) -> PermissionsView
    func makeTravelView(idContainer: String?, idButton: String?) -> TravelView
    func makeSecureDeviceView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> SecureDeviceView
    func makeLargeSecureDeviceView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> LargeSecureDeviceView
    func makeBottomSquareView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> BottomSquareView
    func makeSmallBottomSquareView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> SmallBottomSquareView
    func makeReportFraudView(idContainer: String?, idButton: String?) -> ReportFraudView
    func makeCallNowView(_ viewModel: PhoneViewModel, viewStyle: FlipViewStyle) -> CallNowView
    func makeStoleView(idContainer: String?, idButton: String?) -> StoleView
    func makeSinglePhoneView(_ viewModel: PhoneViewModel, idContainer: String?, idButton: String?, viewStyle: FlipViewStyle) -> SinglePhoneView
    func makeDoublePhoneView(_ viewModel: (PhoneViewModel, PhoneViewModel), container: String?, topButton: String?, bottomButton: String?) -> DoublePhoneView
    func makeLastLogonView(_ viewModel: LastLogonViewModel) -> LastLogonView
}

extension GlobalSecurityViewFactory {
    func makeProtectionView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> ProtectionView {
        let view = ProtectionView()
        view.setViewModel(viewModel)
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makePermissionsView(idContainer: String?, idButton: String?) -> PermissionsView {
        let view = PermissionsView()
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeTravelView(idContainer: String?, idButton: String?) -> TravelView {
        let view = TravelView()
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeSecureDeviceView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> SecureDeviceView {
        let view = SecureDeviceView()
        view.setViewModel(viewModel)
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeLargeSecureDeviceView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> LargeSecureDeviceView {
        let view = LargeSecureDeviceView()
        view.setViewModel(viewModel)
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeBottomSquareView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> BottomSquareView {
        let view = BottomSquareView()
        view.setViewModel(viewModel, existOffer: false)
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeSmallBottomSquareView(_ viewModel: SecurityViewModel, idContainer: String?, idButton: String?) -> SmallBottomSquareView {
        let view = SmallBottomSquareView()
        view.setViewModel(viewModel)
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeReportFraudView(idContainer: String?, idButton: String?) -> ReportFraudView {
        let view = ReportFraudView()
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeCallNowView(_ viewModel: PhoneViewModel, viewStyle: FlipViewStyle) -> CallNowView {
        let view = CallNowView()
        if viewStyle == .showNumberLabel {
            view.setViewModel(viewModel)
        } else {
            view.setViewModelWithoutNumberLabel(viewModel)
        }
        return view
    }
    
    func makeStoleView(idContainer: String?, idButton: String?) -> StoleView {
        let view = StoleView()
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeSinglePhoneView(_ viewModel: PhoneViewModel, idContainer: String?, idButton: String?, viewStyle: FlipViewStyle) -> SinglePhoneView {
        let view = SinglePhoneView()
        if viewStyle == .showNumberLabel {
            view.setViewModel(viewModel)
        } else {
            view.setViewModelWithoutNumberLabel(viewModel)
        }
        view.setAccessibilityIdentifiers(container: idContainer, button: idButton)
        return view
    }
    
    func makeDoublePhoneView(_ viewModel: (PhoneViewModel, PhoneViewModel), container: String?, topButton: String?, bottomButton: String?) -> DoublePhoneView {
        let view = DoublePhoneView()
        view.setViewModels(viewModel)
        view.setAccessibilityIdentifiers(container: container, topButton: topButton, bottomButton: bottomButton)
        return view
    }
    
    func makeLastLogonView(_ viewModel: LastLogonViewModel) -> LastLogonView {
        let view = LastLogonView()
        view.setDate(with: viewModel)
        return view
    }
}
