//
//  OneComponentsQAViewController.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import UIKit
import UI
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import OpenCombine

private struct FloatingButtonExample {
    let type: OneFloatingButton.ButtonType
    let size: OneFloatingButton.ButtonSize
    let status: OneFloatingButton.ButtonStatus
    let enabled: Bool
}

private struct OneAppLinkExample {
    let type: OneAppLink.ButtonType
    let style: OneAppLink.ButtonContent
    let enabled: Bool
}

private struct OneOvalButtonExample {
    public var style: OneOvalButton.OneOvalButtonStyle
    public var size: OneOvalButton.OneOvalButtonSize
    public var direction: OneOvalButton.OneOvalButtonDirection?
}

public final class OneComponentsQAViewController: UIViewController {
    @IBOutlet weak var labelHighlightedTestView: UIView!
    @IBOutlet weak var highlightTestTitleLabel: UILabel!
    @IBOutlet weak var highlightBackgrounViewTest: OneLabelHighlightedView!
    
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    
    @IBOutlet private weak var oneOvalButtonPicker: UIPickerView!
    @IBOutlet private weak var oneOvalButton: OneOvalButton!
    
    
    //TODO Remove when QA it's over.
    @IBOutlet private weak var oneAppPickerView: UIPickerView!
    @IBOutlet private weak var oneAppButton: OneAppLink!
    
    //TODO Remove when QA it's over.
    @IBOutlet private weak var testStackView: UIStackView!
    
    //TODO Remove when QA it's over.
    @IBOutlet private var regularViews: [OneInputRegularView]!

    @IBOutlet weak var oneInputDateLeft: OneInputDateView!
    @IBOutlet weak var oneInputDateRight: OneInputDateView!
    @IBOutlet weak var faqFooterView: OneFooterHelpView!

    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var toastPickerView: UIPickerView!
    private var selectedOneToastViewModel: OneToastViewModel!
    private var logoPickerView: UIPickerView!
    private var selectedLogo: OneNavigationBarSantanderLogo = .normal
    private let dependenciesResolver: DependenciesResolver
    private var subscriptions = Set<AnyCancellable>()
    private let floatingButtonOptions: [String] = [
        "Small Primary",
        "Small Secondary",
        "Small Disabled",
        "Medium Compact Primary",
        "Medium Compact Secondary",
        "Medium Compact Disabled",
        "Medium Compact Icon Primary",
        "Medium Compact Icon Secondary",
        "Medium Compact Icon Disabled",
        "Medium FullWidth Primary",
        "Medium FullWidth Secondary",
        "Medium FullWidth Disabled",
        "Medium FullWidth Icon Primary",
        "Medium FullWidth Icon Secondary",
        "Medium FullWidth Icon Disabled",
        "Large Compact Primary",
        "Large Compact Primary Loading",
        "Large Compact Secondary",
        "Large Compact Secondary Loading",
        "Large Compact Disabled",
        "Large FullWidth Primary",
        "Large FullWidth Secondary",
        "Large FullWidth Disabled",
        "Large FullWidth Icon Primary",
        "Large FullWidth Icon Secondary",
        "Large FullWidth Icon Disabled",
        "Large Primary Icon Right Loading",
        "Large Secondary Icon Right Loading",
        "Large Primary Full Width Icon Right Loading",
        "Large Secondary Full Width Icon Right Loading",
        "Large Primary Full Width Double Icon Loading",
        "Large Secondary Full Width Double Icon Loading",
        "Medium Primary Loading",
        "Medium Secondary Loading",
        "Medium Primary Icon Right Loading",
        "Medium Secondary Icon Right Loading",
        "Medium Primary Full Width Loading",
        "Medium Secondary Icon Right Loading",
        "Medium Primary Full Width Icon Right Loading",
        "Medium Secondary Full Width Icon Right Loading",
        "Small Primary Loading",
        "Small Secondary Loading"
    ]
    
    private let oneOvalButtonOptions: [String] = [
        "Small Default Primary",
        "Small Active Primary",
        "Small Default Secundary",
        "Small Active Secundary",
        "Small Default Terciary",
        "Small Active Terciary",
        "Small Disable",
        "Medium Default Primary",
        "Medium Active Primary",
        "Medium Default Secundary",
        "Medium Active Secundary",
        "Medium Default Terciary",
        "Medium Active Terciary",
        "Medium Disable",
        "Large Default Primary",
        "Large Active Primary",
        "Large Default Secundary",
        "Large Active Secundary",
        "Large Default Terciary",
        "Large Active Terciary",
        "Large Disable"
    ]
    
    private let oneAppLinkOptions: [String] = [
        "Primary None Icons",
        "Primary None Icons Disabled",
        "Primary Right Icon",
        "Primary Right Icon Disabled",
        "Primary Left Icon",
        "Primary Left Icon Disabled",
        "Primary Top Icon",
        "Primary Top Icon Disabled",
        "Secondary None Icons",
        "Secondary None Icons Disabled",
        "Secondary Right Icon",
        "Secondary Right Icon Disabled",
        "Secondary Left Icon",
        "Secondary Left Icon Disabled",
        "Secondary Top Icon",
        "Secondary Top Icon Disabled"
    ]
    
    private let oneToastViewOptions: [String] = [
        "Top Large",
        "Top Large with Link",
        "Top Small",
        "Top Small with Link",
        "Bottom Large",
        "Bottom Large with Link",
        "Bottom Small",
        "Bottom Small with Link"
    ]
    
    private let oneToastViewModels: [OneToastViewModel] = [
        OneToastViewModel(leftIconKey: "oneIcnCheckOthers",
                          titleKey: "¡Todo perfecto!",
                          subtitleKey: "Balance rápido activado con éxito",
                          linkKey: nil,
                          type: .large,
                          position: .top,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnCheckOthers",
                          titleKey: "¡Todo perfecto!",
                          subtitleKey: "Balance rápido activado con éxito",
                          linkKey: "Enlace",
                          type: .large,
                          position: .top,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnWarning",
                          titleKey: nil,
                          subtitleKey: "Los datos introducidos no son correctos. Tienes 2 intentos más.",
                          linkKey: nil,
                          type: .small,
                          position: .top,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnWarning",
                          titleKey: nil,
                          subtitleKey: "Los datos introducidos no son correctos. Tienes 2 intentos más.",
                          linkKey: "Enlace opcional",
                          type: .small,
                          position: .top,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnCheckOthers",
                          titleKey: "¡Todo perfecto!",
                          subtitleKey: "Balance rápido activado con éxito",
                          linkKey: nil,
                          type: .large,
                          position: .bottom,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnCheckOthers",
                          titleKey: "¡Todo perfecto!",
                          subtitleKey: "Balance rápido activado con éxito",
                          linkKey: "Enlace",
                          type: .large,
                          position: .bottom,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnWarning",
                          titleKey: nil,
                          subtitleKey: "Los datos introducidos no son correctos. Tienes 2 intentos más.",
                          linkKey: nil,
                          type: .small,
                          position: .bottom,
                          duration: .infinite),
        OneToastViewModel(leftIconKey: "oneIcnWarning",
                          titleKey: nil,
                          subtitleKey: "Los datos introducidos no son correctos. Tienes 2 intentos más.",
                          linkKey: "Enlace",
                          type: .small,
                          position: .bottom,
                          duration: .infinite)
    ]
    
    private let exchangeRateAmountViewModels: [OneExchangeRateAmountViewModel] = [
        OneExchangeRateAmountViewModel(originAmount: OneExchangeRateAmount(amount: AmountRepresented(value: .zero,
                                                                                                     currencyRepresentable: CurrencyRepresented(currencyCode: "EUR")),
                                                                           buyRate: AmountRepresented(value: 4.6676, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           sellRate: AmountRepresented(value: 3.22, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           currencySelector: nil),
                                       type: .exchange(destinationAmount: OneExchangeRateAmount(amount: AmountRepresented(value: .zero,
                                                                                                                          currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                buyRate: AmountRepresented(value: 1, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                sellRate: AmountRepresented(value: 1, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                currencySelector: nil))),
        OneExchangeRateAmountViewModel(originAmount: OneExchangeRateAmount(amount: AmountRepresented(value: 20,
                                                                                                     currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           buyRate: AmountRepresented(value: 1, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           sellRate: AmountRepresented(value: 1, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           currencySelector: UIView()),
                                       type: .exchange(destinationAmount: OneExchangeRateAmount(amount: AmountRepresented(value: 3.99,
                                                                                                                          currencyRepresentable: CurrencyRepresented(currencyCode: "EUR")),
                                                                                                buyRate: AmountRepresented(value: 2.45, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                sellRate: AmountRepresented(value: 5.0062, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                currencySelector: nil)),
                                       alert: OneExchangeRateAmountAlert(iconName: "icnInfo",
                                                                         titleKey: "sendMoney_label_conversionExchangeRate")),
        OneExchangeRateAmountViewModel(originAmount: OneExchangeRateAmount(amount: AmountRepresented(value: .zero,
                                                                                                     currencyRepresentable: CurrencyRepresented(currencyCode: "GBP")),
                                                                           buyRate: AmountRepresented(value: 3.22, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           sellRate: AmountRepresented(value: 6.0478, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           currencySelector: nil),
                                       type: .exchange(destinationAmount: OneExchangeRateAmount(amount: AmountRepresented(value: .zero,
                                                                                                                          currencyRepresentable: CurrencyRepresented(currencyCode: "EUR")),
                                                                                                buyRate: AmountRepresented(value: 4.6676, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                sellRate: AmountRepresented(value: 2.04, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                currencySelector: UIView())),
                                       alert: OneExchangeRateAmountAlert(iconName: "icnInfo",
                                                                         titleKey: "sendMoney_label_conversionExchangeRate")),
        OneExchangeRateAmountViewModel(originAmount: OneExchangeRateAmount(amount: AmountRepresented(value: .zero,
                                                                                                     currencyRepresentable: CurrencyRepresented(currencyCode: "GBP")),
                                                                           buyRate: AmountRepresented(value: 3.22, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           sellRate: AmountRepresented(value: 6.0478, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                           currencySelector: UIView()),
                                       type: .exchange(destinationAmount: OneExchangeRateAmount(amount: AmountRepresented(value: .zero,
                                                                                                                          currencyRepresentable: CurrencyRepresented(currencyCode: "EUR")),
                                                                                                buyRate: AmountRepresented(value: 4.6676, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                sellRate: AmountRepresented(value: 2.04, currencyRepresentable: CurrencyRepresented(currencyCode: "PLN")),
                                                                                                currencySelector: UIView())),
                                       alert: OneExchangeRateAmountAlert(iconName: "icnInfo",
                                                                         titleKey: "sendMoney_label_conversionExchangeRate"))
    ]
    
    private let santanderLogo: [String] = [
        "Normal",
        "Smart",
        "Select",
        "Private Banking"
    ]

    private let buttonConfigs: [FloatingButtonExample] = [
        // "Small Primary",
        FloatingButtonExample(
            type: .primary,
            size: .small(
                OneFloatingButton.ButtonSize.SmallButtonConfig(title: "Call to action")
            ),
            status: .ready,
            enabled: true
        ),
        // "Small Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .small(
                OneFloatingButton.ButtonSize.SmallButtonConfig(title: "Call to action")
            ),
            status: .ready,
            enabled: true
        ),
        // "Small Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .small(
                OneFloatingButton.ButtonSize.SmallButtonConfig(title: "Call to action")
            ),
            status: .ready,
            enabled: false
        ),
        // "Medium Compact Primary",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: false)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium Compact Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: false)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium Compact Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: false)
            ),
            status: .ready,
            enabled: false
        ),
        // "Medium Compact Icon Primary",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: false)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium Compact Icon Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: false)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium Compact Icon Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: false)
            ),
            status: .ready,
            enabled: false
        ),
        // "Medium FullWidth Primary",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium FullWidth Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium FullWidth Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: true)
            ),
            status: .ready,
            enabled: false
        ),
        // "Medium FullWidth Icon Primary",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium FullWidth Icon Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Medium FullWidth Icon Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: true)
            ),
            status: .ready,
            enabled: false
        ),
        // "Large Compact Primary",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .ready,
            enabled: true
        ),
        // "Large Compact Primary Loading",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        // "Large Compact Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .ready,
            enabled: true
        ),
        // "Large Compact Secondary Loading",
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        // "Large Compact Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .ready,
            enabled: false
        ),
        // "Large FullWidth Primary",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Large FullWidth Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Large FullWidth Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: true)
            ),
            status: .ready,
            enabled: false
        ),
        // "Large FullWidth Icon Primary",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .both,
                    fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Large FullWidth Icon Secondary",
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .both,
                    fullWidth: true)
            ),
            status: .ready,
            enabled: true
        ),
        // "Large FullWidth Icon Disabled",
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .both,
                    fullWidth: true)
            ),
            status: .ready,
            enabled: false
        ),
        //  "Large Primary Icon Right Loading"
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Large Secondary Icon Right Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Large Primary Full Width Icon Right Loading"
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Large Primary Full Width Icon Right Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .right,
                    fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        // "Large Primary Full Width Double Icon Loading"
        FloatingButtonExample(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .both,
                    fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        // "Large Secondary Full Width Double Icon Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: "Continue",
                    subtitle: "Go to step 2/4",
                    icons: .both,
                    fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Primary Loading"
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Secondary Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Primary Icon Right Loading"
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Secondary Icon Right Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: false)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Primary Full Width Loading"
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Secondary Full Width Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .none, fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Primary Full Width Icon Right Loading"
        FloatingButtonExample(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Medium Secondary Full Width Icon Right Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "Call to action", icons: .right, fullWidth: true)
            ),
            status: .loading,
            enabled: true
        ),
        //  "Small Primary Loading"
        FloatingButtonExample(
            type: .primary,
            size: .small(
                OneFloatingButton.ButtonSize.SmallButtonConfig(title: "Call to action")
            ),
            status: .loading,
            enabled: true
        ),
        //  "Small Secondary Loading"
        FloatingButtonExample(
            type: .secondary,
            size: .small(
                OneFloatingButton.ButtonSize.SmallButtonConfig(title: "Call to action")
            ),
            status: .loading,
            enabled: true
        )
    ]
    
    private let oneOvalButtonConfigs: [OneOvalButtonExample] = [
        // "Small Default Primary"
        OneOvalButtonExample(style: .redWithWhiteTint, size: .small),
        // "Small Active Primary"
        OneOvalButtonExample(style: .redWithWhiteTint, size: .small),
        // "Small Default Secundary"
        OneOvalButtonExample(style: .whiteWithRedTint, size: .small),
        // "Small Active Secundary"
        OneOvalButtonExample(style: .whiteWithRedTint, size: .small),
        // "Small Default Terciary"
        OneOvalButtonExample(style: .whiteWithTurquoiseTint, size: .small),
        // "Small Active Terciary"
        OneOvalButtonExample(style: .whiteWithTurquoiseTint, size: .small),
        // "Small Disable"
        OneOvalButtonExample(style: .disable, size: .small),
        // "Medium Default Primary"
        OneOvalButtonExample(style: .redWithWhiteTint, size: .medium),
        // "Medium Active Primary"
        OneOvalButtonExample(style: .redWithWhiteTint, size: .medium),
        // "Medium Default Secundary"
        OneOvalButtonExample(style: .whiteWithRedTint, size: .medium),
        // "Medium Active Secundary"
        OneOvalButtonExample(style: .whiteWithRedTint, size: .medium),
        // "Medium Default Terciary"
        OneOvalButtonExample(style: .whiteWithTurquoiseTint, size: .medium),
        // "Medium Active Terciary"
        OneOvalButtonExample(style: .whiteWithTurquoiseTint, size: .medium),
        // "Medium Disable"
        OneOvalButtonExample(style: .disable, size: .medium),
        // "Large Default Primary"
        OneOvalButtonExample(style: .redWithWhiteTint, size: .large),
        // "Large Active Primary"
        OneOvalButtonExample(style: .redWithWhiteTint, size: .large),
        // "Large Default Secundary"
        OneOvalButtonExample(style: .whiteWithRedTint, size: .large),
        // "Large Active Secundary"
        OneOvalButtonExample(style: .whiteWithRedTint, size: .large),
        // "Large Default Terciary"
        OneOvalButtonExample(style: .whiteWithTurquoiseTint, size: .large),
        // "Large Active Terciary"
        OneOvalButtonExample(style: .whiteWithTurquoiseTint, size: .large),
        // "Large Disable"
        OneOvalButtonExample(style: .disable, size: .large),
    ]
    
    private func configureOneOvalButton(example: OneOvalButtonExample) {
        self.oneOvalButton.style = example.style
        self.oneOvalButton.size = example.size
        self.oneOvalButton.direction = example.direction ?? .right
    }
    
    private let oneAppButtonConfig: [OneAppLinkExample] = [
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .none),
            enabled: true
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .none),
            enabled: false
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .right),
            enabled: true
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .right),
            enabled: false
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .left),
            enabled: true
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .left),
            enabled: false
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .top,
                image: "icnFilter"),
            enabled: true
        ),
        OneAppLinkExample(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .top,
                image: "icnFilter"),
            enabled: false
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .none),
            enabled: true
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .none),
            enabled: false
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .right),
            enabled: true
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .right),
            enabled: false
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .left),
            enabled: true
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .left),
            enabled: false
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .top,
                image: "icnFilter"),
            enabled: true
        ),
        OneAppLinkExample(
            type: .secondary,
            style: OneAppLink.ButtonContent(
                text: "One App Button Test",
                icons: .top,
                image: "icnFilter"),
            enabled: false
        )
    ]
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "OneComponentsQAViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.testStackView.backgroundColor = .oneWhite
        self.addOneToastView()
        self.addExchangeRateAmount()
        self.addOneRadioButton()
        let config = self.buttonConfigs[0]
        self.floatingButton.configureWith(type: config.type, size: config.size, status: config.status)
        self.floatingButton.isEnabled = config.enabled
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        let ovalButtonExample = self.oneOvalButtonConfigs[0]
        self.configureOneOvalButton(example: ovalButtonExample)
        self.oneOvalButtonPicker.delegate = self
        self.oneOvalButtonPicker.dataSource = self
        // MARK: - OneAppLink
        let oneAppConfig = self.oneAppButtonConfig[0]
        self.oneAppButton.configureButton(type: oneAppConfig.type, style: oneAppConfig.style)
        self.oneAppPickerView.delegate = self
        self.oneAppPickerView.dataSource = self
        self.addOneProductCard()
        self.addOneNotificationView()
        self.addBottomSheet()
        self.addInputCode()
        self.addAmountTextFields()
        self.addFavoriteContactCards()
        self.addPastTransfers()
        self.addOneCheckbox()
        self.addTopBarExamples()
        self.addSeeAllCards()
        self.addLabel()
        self.addAlerts()
        self.addOneRadioButton()
        self.addTextFieldExamples()
        self.addBottomSheet()
        self.addOneFilterWithImage()
        self.addOneFilter()
        self.addInputSelects()
        self.addInputDates()
        self.addIBANField()
        self.hideKeyboardWhenTappedAround()
        self.addOperativeSummaryFooter()
        self.addListFlowItems()
        self.addFaqs()
        self.addGradientViews()
        self.addOneHomeOptionListView()
        self.addOneHomeOptionListViewFromButton()
        self.addSmallSelectorListViews()
        self.addOneToggeView()
        self.setupHighlightedView()
    }
}

extension OneComponentsQAViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == oneAppPickerView {
            return oneAppLinkOptions.count
        } else if pickerView == logoPickerView {
            return santanderLogo.count
        } else if pickerView == oneOvalButtonPicker {
            return oneOvalButtonOptions.count
        } else if pickerView == self.toastPickerView {
            return self.oneToastViewModels.count
        } else {
            return floatingButtonOptions.count
        }
    }
}

extension OneComponentsQAViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == oneAppPickerView {
            return oneAppLinkOptions[row]
        } else if pickerView == logoPickerView {
            return santanderLogo[row]
        } else if pickerView == oneOvalButtonPicker {
            return oneOvalButtonOptions[row]
        } else if pickerView == self.toastPickerView {
            return self.oneToastViewOptions[row]
        } else {
            return floatingButtonOptions[row]
        }
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == oneAppPickerView {
            let config = self.oneAppButtonConfig[row]
            self.oneAppButton.configureButton(type: config.type, style: config.style)
            self.oneAppButton.isEnabled = config.enabled
        } else if pickerView == logoPickerView {
            switch self.santanderLogo[row] {
            case "Normal":
                self.selectedLogo = .normal
            case "Smart":
                self.selectedLogo = .smart
            case "Select":
                self.selectedLogo = .select
            case "Private Banking":
                self.selectedLogo = .privateBanking
            default:
                self.selectedLogo = .normal
            }
        } else if pickerView == oneOvalButtonPicker {
            let ovalButtonExample = self.oneOvalButtonConfigs[row]
            self.configureOneOvalButton(example: ovalButtonExample)
        } else if pickerView == self.toastPickerView {
            self.selectedOneToastViewModel = self.oneToastViewModels[row]
        } else {
            let config = self.buttonConfigs[row]
            self.floatingButton.configureWith(type: config.type, size: config.size, status: config.status)
            self.floatingButton.isEnabled = config.enabled
        }
    }
}

//TODO Remove when QA it's over.
private extension OneComponentsQAViewController {
    func addOneRadioButton() {
        let options: [OneStatus] = [.activated, .inactive, .disabled]
        var viewModels: [OneRadioButtonViewModel] = []
        options.forEach { status in
            viewModels.append(OneRadioButtonViewModel(status: status, titleKey: "Standard title"))
            viewModels.append(OneRadioButtonViewModel(status: status, titleKey: "Standard title", bottomSheetView: self.addViewBottomSheet()))
        }
        viewModels.append(OneRadioButtonViewModel(status: .inactive, titleKey: "Extended title to show in radio button", subtitleKey: "It gets there within 24-48 hours", additionalInfoKey: "Aditional information about this item"))
        viewModels.append(OneRadioButtonViewModel(status: .inactive, titleKey: "Extended title to show in radio button", subtitleKey: "It gets there within 24-48 hours", additionalInfoKey: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem."))
        viewModels.append(OneRadioButtonViewModel(status: .disabled, titleKey: "Extended title to show two lines or more in a radio button", subtitleKey: "It gets there within 24-48 hours", additionalInfoKey: "Aditional information about this item", isSelected: true))
        viewModels.append(OneRadioButtonViewModel(status: .inactive, titleKey: "Extended title to show two lines or more in a radio button", subtitleKey: "It gets there within 24-48 hours", additionalInfoKey: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.", isSelected: true, bottomSheetView: self.addViewBottomSheet()))
        let container = OneRadioButtonsContainerView()
        let viewModel = OneRadioButtonsContainerViewModel(selectedIndex: 1, viewModels: viewModels)
        container.setViewModel(viewModel)
        self.testStackView.addArrangedSubview(container)
    }
    
    func addOneToastView() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.toastPickerView = picker
        self.testStackView.addArrangedSubview(picker)
        self.selectedOneToastViewModel = self.oneToastViewModels.first
        let button = UIButton()
        button.setTitle("Toast test", for: .normal)
        button.setTitleColor(.oneSantanderRed, for: .normal)
        button.addTarget(self, action: #selector(showToast), for: .touchUpInside)
        self.testStackView.addArrangedSubview(button)
    }
    
    func addExchangeRateAmount() {
        self.exchangeRateAmountViewModels.enumerated().forEach {
            let oneExchangeRateAmountView = OneExchangeRateAmountView(viewModel: $0.element)
            oneExchangeRateAmountView.setAccessibilitySuffix("_\($0.offset + 1)")
            self.testStackView.addArrangedSubview(oneExchangeRateAmountView)
            oneExchangeRateAmountView
                .publisher
                .case(OneExchangeRateAmountViewState.didChangeOriginAmount)
                .sink { (originAmount, destinationAmount) in
                    print("Did change origin: \(originAmount.value!) - \(destinationAmount.value!)")
                }.store(in: &subscriptions)
            oneExchangeRateAmountView
                .publisher
                .case(OneExchangeRateAmountViewState.didEndEditingOriginAmount)
                .sink { (originAmount, destinationAmount) in
                    print("Did end editing origin: \(originAmount.value!) - \(destinationAmount.value!)")
                }.store(in: &subscriptions)
            oneExchangeRateAmountView
                .publisher
                .case(OneExchangeRateAmountViewState.didChangeDestinationAmount)
                .sink { (originAmount, destinationAmount) in
                    print("Did change destination: \(originAmount.value!) - \(destinationAmount.value!)")
                }.store(in: &subscriptions)
            oneExchangeRateAmountView
                .publisher
                .case(OneExchangeRateAmountViewState.didEndEditingDestinationAmount)
                .sink { (originAmount, destinationAmount) in
                    print("Did end editing destination: \(originAmount.value!) - \(destinationAmount.value!)")
                }.store(in: &subscriptions)
        }
    }
    
    @objc func showToast() {
        let toast = OneToastView()
        toast.setViewModel(self.selectedOneToastViewModel)
        toast
            .publisher
            .case(ReactiveOneToastViewState.didPresent)
            .sink { _ in
                print("Did Present Toast")
            }.store(in: &subscriptions)
        toast
            .publisher
            .case(ReactiveOneToastViewState.didDismiss)
            .sink { _ in
                print("Did Dismiss Toast")
            }.store(in: &subscriptions)
        toast
            .publisher
            .case(ReactiveOneToastViewState.didPressOptionalLink)
            .sink { _ in
                print("Did Press Optional Link Toast")
            }.store(in: &subscriptions)
        toast.present()
    }
    
    func addOneCheckbox() {
        var title: String?
        let options: [OneStatus] = [.inactive, .activated, .disabled]
        options.forEach { status in
            let normalCheckboxView = OneCheckboxView()
            let viewModel = OneCheckboxViewModel(status: status,
                                                titleKey: title ?? "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem.")
            title = "Type somethig"
            normalCheckboxView.setViewModel(viewModel)
            self.testStackView.addArrangedSubview(normalCheckboxView)
        }
        let viewModel = OneCheckboxViewModel(status: .disabled, titleKey: "Disabled activated checkbox option", isSelected: true)
        let checkboxView = OneCheckboxView()
        checkboxView.setViewModel(viewModel)
        self.testStackView.addArrangedSubview(checkboxView)
    }
    struct MockFaq: FaqRepresentable {
        public let identifier: Int?
        public let question: String
        public let answer: String
        public let icon: String?
        public let keywords: [String]?
    }
    struct MockTip: PullOfferTipRepresentable {
        public var title: String?
        public var description: String?
        public var icon: String?
        public var offerId: String?
        public var offerRepresentable: OfferRepresentable?
        public var tag: String?
        public var keyWords: [String]?
    }
    
    func addFaqs() {
        var tips: [OfferTipViewModel] = []
        var faqs: [FaqsViewModel] = []
        let faq = FaqsViewModel(MockFaq(identifier: 0, question: "¿Cómo obtener mi clave Bizum?", answer: "Puedes obtener una clave Bizum pulsando {{LINK:santanderRetail://deeplink?n=bizum}} aquí {{/LINK}} En la pantalla de Bizum selecciona el l icono de una tuerca que aparece en la parte superior derecha, y en \"He olvidado mi clave Bizum\". Decide una clave de 4 dígitos y márcala dos veces. Confirma tu identidad introduciendo la clave de un solo uso que recibirás en tu teléfono. ¡Ya puedes utilizar Bizum para tus compras online en comercios que estén habilitados para este tipo de pagos! ", icon: nil, keywords: nil))
        let tip = OfferTipViewModel(MockTip(title: "Para el día a día", description: "Tu oficina en el móvil 24 horas", icon: "/apps/SAN/img/tips/icn_pig_tip.png", offerId: "oferta_elab5", offerRepresentable: nil, tag: nil, keyWords: nil), baseUrl: self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL)
        for _ in 1...5 {
            faqs.append(faq)
            tips.append(tip)
        }
        let viewModel = OneFooterHelpViewModel(faqs: faqs, tips: tips, showVirtualAssistant: true)
        let faqView = OneFooterHelpView()
        faqView.setFooterHelp(viewModel)
        self.faqFooterView.setFooterHelp(viewModel)
        self.testStackView.addArrangedSubview(faqView)
    }
    
    func addCards() {
        let optionsCard: [OneAccountSelectionCardItem.CardStatus] = [.inactive, .selected, .favourite]
        let numberFormatter = self.dependenciesResolver.resolve(for: AccountNumberFormatterProtocol.self)
        optionsCard.forEach { status in
            let oneCard = OneAccountSelectionCardView()
            var accountDto = AccountDTO()
            accountDto.currentBalance = AmountDTO(value: Decimal(12313), currency: .create(.eur))
            accountDto.alias = "Test Alias"
            accountDto.iban = IBANDTO(ibanString: "ESXXXXXXXXXXXXXXXXX")
            let item = OneAccountSelectionCardItem(account: accountDto,
                                                   cardStatus: status,
                                                   accessibilityOfView: "",
                                                   numberFormater: numberFormatter)
            oneCard.setupAccountItem(item)
            self.testStackView.addArrangedSubview(oneCard)
        }
    }
    
    func addSeeAllCards() {
        let keys = ["Favorito", "Ver todos los favoritos", "Zobacz wsyzstkie ulubionesgjkicz"]
        keys.forEach { self.addSeeAllCard($0) }
    }
    
    func addSeeAllCard(_ descriptionKey: String) {
        let viewModel = OneSeeAllCardViewModel(imageKey: "icnStar", descriptionKey: descriptionKey)
        let oneSeeAllCard = OneSeeAllCardView()
        oneSeeAllCard.setViewModel(viewModel)
        let containerView = UIView()
        containerView.addSubview(oneSeeAllCard)
        NSLayoutConstraint.activate([
            oneSeeAllCard.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0),
            oneSeeAllCard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0),
            oneSeeAllCard.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        self.testStackView.addArrangedSubview(containerView)
    }
    
    func addLabel() {
        let types: [OneLabelViewModel.LabelType] = [.normal, .helper, .action, .helperAndAction, .counter]
        for (index, type) in types.enumerated() {
            let oneLabel = OneLabelView()
            oneLabel.setupViewModel(
                OneLabelViewModel(type: type,
                                  mainTextKey: type == .action ? "Country" : "Concepto (opcional)",
                                  actionTextKey: "Change country",
                                  helperAction: {
                                    print("Select helper \(index)")
                                  },
                                  action: {
                                    print("Select action \(index)")
                                  },
                                  accessibilitySuffix: "Prueba accesibilidad")
            )
            self.testStackView.addArrangedSubview(oneLabel)
        }
    }
    
    func addAlerts() {
        let alerts: [OneAlertType] = [
            .textOnly(stringKey: "originAccount_label_infoWhithoutAccounts"),
            .textAndImage(imageKey: "icnInfo",
                          stringKey: "originAccount_label_infoWhithoutAccounts"),
            .textAndLink(stringKey: "originAccount_label_infoWhithoutAccounts", linkKey: "voiceover_openLink"),
            .textImageAndLink(imageKey: "icnInfo", stringKey: "originAccount_label_infoWhithoutAccounts", linkKey: "voiceover_openLink")]
        alerts.forEach {
            let alertView = OneAlertView()
            alertView.setType($0)
            self.testStackView.addArrangedSubview(alertView)
            switch $0 {
            case .textImageAndLink(_, _, _):
                alertView.linkSubject
                    .sink {
                        Toast.show(localized("textImageAndLink"))
                    }.store(in: &subscriptions)
            case .textAndLink(_, _):
                alertView.linkSubject
                    .sink {
                        Toast.show(localized("textAndLink"))
                    }.store(in: &subscriptions)
            default:
                break
            }
        }
    }
    
    func addBottomSheet() {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle("Bottom Sheet Adaptative", for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didBottomSheet), for: .touchUpInside)
        let buttonTop = UIButton(type: .system)
        buttonTop.titleLabel?.numberOfLines = 0
        buttonTop.titleLabel?.lineBreakMode = .byWordWrapping
        buttonTop.setTitle("Bottom Sheet Top", for: .normal)
        buttonTop.backgroundColor = .clear
        buttonTop.addTarget(self, action: #selector(didBottomSheetTop), for: .touchUpInside)
        let buttonHalf = UIButton(type: .system)
        buttonHalf.setTitle("Bottom Sheet Half", for: .normal)
        buttonHalf.titleLabel?.numberOfLines = 0
        buttonHalf.titleLabel?.lineBreakMode = .byWordWrapping
        buttonHalf.backgroundColor = .clear
        buttonHalf.addTarget(self, action: #selector(didBottomSheetHalf), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(buttonTop)
        stackView.addArrangedSubview(buttonHalf)
        self.testStackView.addArrangedSubview(stackView)
    }
    
    func addInputCode() {
        let viewModels: [OneInputCodeViewModel] = [
            OneInputCodeViewModel(
                isAlphanumeric: true,
                hiddenCharacters: true,
                enabledChangeVisibility: false,
                itemsCount: 8,
                requestedPositions: OneInputCodeViewModel.RequestedPositions.all),
            OneInputCodeViewModel(
                hiddenCharacters: false,
                enabledChangeVisibility: false,
                itemsCount: 3,
                requestedPositions: OneInputCodeViewModel.RequestedPositions.all),
            OneInputCodeViewModel(
                hiddenCharacters: true,
                enabledChangeVisibility: true,
                itemsCount: 4,
                requestedPositions: OneInputCodeViewModel.RequestedPositions.all),
            OneInputCodeViewModel(
                isAlphanumeric: true,
                hiddenCharacters: false,
                enabledChangeVisibility: true,
                itemsCount: 8,
                requestedPositions: OneInputCodeViewModel.RequestedPositions.all),
            OneInputCodeViewModel(
                isAlphanumeric: true,
                hiddenCharacters: true,
                enabledChangeVisibility: true,
                itemsCount: 6,
                requestedPositions: OneInputCodeViewModel.RequestedPositions.positions([1, 3, 5])),
            OneInputCodeViewModel(
                hiddenCharacters: false,
                enabledChangeVisibility: false,
                itemsCount: 4,
                requestedPositions: OneInputCodeViewModel.RequestedPositions.all)
        ]
        viewModels.enumerated().forEach {
            let oneInputCodeView = OneInputCodeView(with: $0.element, delegate: self)
            oneInputCodeView.setAccessibilitySuffix("_\($0.offset + 1)")
            if $0.offset == viewModels.count - 1 {
                oneInputCodeView.enableError()
            }
            self.testStackView.addArrangedSubview(oneInputCodeView)
        }
    }
    
    func addOneFilter() {
        self.addOneFilterView(["Gastos", "Ingresos"], isSimple: true)
        self.addOneFilterView(["Recibos", "Impuestos", "Préstamos"], isSimple: true)
        self.addOneFilterView(["Todos", "Recibos", "Impuestos", "Préstamos"], isSimple: true)
        self.addOneFilterView(["Últimos 7 días", "Últimos 30 días", "Últimos 90 días", "Meses"], isSimple: false)
    }
    
    func addOneFilterView(_ keys: [String], isSimple: Bool) {
        let oneFilterView = OneFilterView(frame: .zero)
        if isSimple {
            oneFilterView.setupSimple(with: keys)
        } else {
            oneFilterView.setupDouble(with: keys)
        }
        let containerView = UIView()
        containerView.addSubview(oneFilterView)
        let height: CGFloat = isSimple ? 48 : 64
        NSLayoutConstraint.activate([
            oneFilterView.heightAnchor.constraint(equalToConstant: height),
            oneFilterView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0),
            oneFilterView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0),
            oneFilterView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 16),
            oneFilterView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16),
            oneFilterView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        self.testStackView.addArrangedSubview(oneFilterView)
    }
    
    func addOneFilterWithImage() {
        let oneFilterWithImage = OneFilterLargeWithIconView()
        let viewModel = self.getOneFilterWithImageViewModel()
        oneFilterWithImage.setViewModel(viewModel)
        let containerView = UIView()
        containerView.addSubview(oneFilterWithImage)
        NSLayoutConstraint.activate([
            oneFilterWithImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0),
            oneFilterWithImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0),
            oneFilterWithImage.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 16),
            oneFilterWithImage.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16),
            oneFilterWithImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        self.testStackView.addArrangedSubview(oneFilterWithImage)
    }
    
    func getOneFilterWithImageViewModel() -> OneFilterLargeWithIconViewModel {
        let activeSegmentViewModel = OneSegmentedItemViewModel(imageKey: "icnPowerOn", descriptionKey: "Encendida", index: 0)
        let inactiveSegmentViewModel = OneSegmentedItemViewModel(imageKey: "icnSleepOff", descriptionKey: "Apagada", index: 1)
        return OneFilterLargeWithIconViewModel([activeSegmentViewModel, inactiveSegmentViewModel])
    }
    
    func addInputSelects() {
        let selectViewModels: [OneInputSelectViewModel] = [
            OneInputSelectViewModel(pickerData: ["Diaria", "Semanal", "Mensual", "Anual"], placeholderKey: "Selecciona la periodicidad", warningKey: "Debes indicar la periodicidad"),
            OneInputSelectViewModel(status: .activated, pickerData: ["Diaria", "Semanal", "Mensual", "Anual"], selectedInput: 0, warningKey: "Debes indicar la periodicidad"),
            OneInputSelectViewModel(status: .focused, pickerData: ["Diaria", "Semanal", "Mensual", "Anual"], selectedInput: 1, warningKey: "Debes indicar la periodicidad"),
            OneInputSelectViewModel(status: .error, pickerData: ["Diaria", "Semanal", "Mensual", "Anual"], placeholderKey: "Selecciona la periodicidad", warningKey: "Debes indicar la periodicidad"),
            OneInputSelectViewModel(status: .disabled, pickerData: ["Diaria", "Semanal", "Mensual", "Anual"], selectedInput: 0, placeholderKey: "Selecciona la periodicidad", warningKey: "Debes indicar la periodicidad")
        ]
        selectViewModels.forEach { viewModel in
            let selectView = OneInputSelectView(with: viewModel)
            self.testStackView.addArrangedSubview(selectView)
        }
        
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        let buttonRight = UIButton(type: .system)
        buttonRight.titleLabel?.numberOfLines = 0
        buttonRight.titleLabel?.lineBreakMode = .byWordWrapping
        buttonRight.setTitle("Show error", for: .normal)
        buttonRight.backgroundColor = .clear
        buttonRight.addTarget(self, action: #selector(showErrorInOneInputSelect), for: .touchUpInside)
        let buttonLeft = UIButton(type: .system)
        buttonLeft.titleLabel?.numberOfLines = 0
        buttonLeft.titleLabel?.lineBreakMode = .byWordWrapping
        buttonLeft.setTitle("Hide error", for: .normal)
        buttonLeft.backgroundColor = .clear
        buttonLeft.addTarget(self, action: #selector(hideErrorInOneInputSelect), for: .touchUpInside)
        stackView.addArrangedSubview(buttonLeft)
        stackView.addArrangedSubview(buttonRight)
        self.testStackView.addArrangedSubview(stackView)
    }
    
    @objc func showErrorInOneInputSelect() {
        let firstSelectView = self.testStackView.subviews.first(where: { $0 is OneInputSelectView })
        guard let view = firstSelectView as? OneInputSelectView else { return }
        view.showError("Forced error")
    }
    
    @objc func hideErrorInOneInputSelect() {
        let firstSelectView = self.testStackView.subviews.first(where: { $0 is OneInputSelectView })
        guard let view = firstSelectView as? OneInputSelectView else { return }
        view.hideError()
    }
    
    func addInputDates() {
        let startingDate = Date(timeIntervalSinceNow: 0).addDay(days: 2)
        let dateViewModels: [OneInputDateViewModel] = [
            OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver, status: .inactive, placeholderKey: "Select a date"),
            OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver, status: .activated, firstDate: startingDate, placeholderKey: "Select a date", minDate: Date(timeIntervalSinceNow: 0)),
            OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver, status: .focused, firstDate: Date(timeIntervalSinceNow: 0), placeholderKey: "Select a date", maxDate: Date(timeIntervalSinceNow: 0)),
            OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver, status: .disabled, firstDate: Date(timeIntervalSinceNow: 0)),
            OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver, status: .disabled)
        ]
        dateViewModels.forEach { viewModel in
            let selectView = OneInputDateView(with: viewModel)
            selectView.delegate = self
            self.testStackView.addArrangedSubview(selectView)
        }
        
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        let dateRight = OneInputDateView(with: dateViewModels[0])
        let dateLeft = OneInputDateView(with: dateViewModels[2])
        dateRight.setViewModel(dateViewModels[1])
        
        stackView.addArrangedSubview(dateLeft)
        stackView.addArrangedSubview(dateRight)
        self.testStackView.addArrangedSubview(stackView)
        
        oneInputDateLeft.setViewModel(dateViewModels[1])
        oneInputDateRight.setViewModel(dateViewModels[1])
    }
    
    @objc func hideKeyboard() {
        view?.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }

    func addListFlowItems() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let label = UILabel()
        label.text = "With separators"
        self.testStackView.addArrangedSubview(label)
        let decorator = AmountRepresentableDecorator(AmountDTO(value: 300, currency: CurrencyDTO(currencyName: "GBP", currencyType: .pound)), font: .typography(fontName: .oneH500Bold), decimalFont: .typography(fontName: .oneB400Bold))
        let alertView = OneAlertView()
        alertView.setType(.textAndImage(imageKey: "icnInfo", stringKey: "Please note that the amount received by the recipient may vary due to this charge by his/her side."))
        let viewModels: [OneListFlowItemViewModel] = [
            OneListFlowItemViewModel(items:
                                        [OneListFlowItemViewModel.Item(type: .title(keyOrValue: "The recipient will receive"), accessibilityId: "title"),
                                         OneListFlowItemViewModel.Item(type: .attributedLabel(attributedString: decorator.getFormatedWithCurrencyName()!)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "From Roberto S.", isBold: false), accessibilityId: "text"),
                                         OneListFlowItemViewModel.Item(type: .spacing(height: 6)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "Exchange buy rate", isBold: false), accessibilityId: "Item 1"),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "1GBP = 1,17 EUR", isBold: true), accessibilityId: "Item 2"),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "Amount after conversion", isBold: false)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "351,20 EUR", isBold: true)),
                                         OneListFlowItemViewModel.Item(type: .image(imageKeyOrUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/entidades/iconos/es_2100.png"), accessibilityId: "icon")
                                        ],
                                     action: .edit(action: { })),
            OneListFlowItemViewModel(isLastItem: true,
                                     items:
                                        [OneListFlowItemViewModel.Item(type: .label(keyOrValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod", isBold: false)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "tempor incididunt ut labore et dolore magna aliqua. Ut enim", isBold: true)),
                                         OneListFlowItemViewModel.Item(type: .custom(view: alertView)),
                                         OneListFlowItemViewModel.Item(type: .tag(tag: .init(itemKeyOrValue: "Today", tagKeyOrValue: "FREE")))
                                        ],
                                     action: .edit(action: {}))
        ]
        var indexPath = IndexPath(item: 0, section: 0)
        viewModels.forEach {
            let listFlowItem = OneListFlowItemView()
            listFlowItem.setupViewModel($0, at: indexPath)
            indexPath.row = indexPath.row + 1
            stackView.addArrangedSubview(listFlowItem)
        }
        indexPath = IndexPath(item: 0, section: 1)
        let label2 = UILabel()
        label2.text = "Without separators"
        stackView.addArrangedSubview(label2)
        let viewModels2: [OneListFlowItemViewModel] = [
            OneListFlowItemViewModel(items:
                                        [OneListFlowItemViewModel.Item(type: .title(keyOrValue: "The recipient will receive"), accessibilityId: "title"),
                                         OneListFlowItemViewModel.Item(type: .attributedLabel(attributedString: decorator.getFormatedWithCurrencyName()!)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "From Roberto S.", isBold: false), accessibilityId: "text"),
                                         OneListFlowItemViewModel.Item(type: .spacing(height: 6)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "Exchange buy rate", isBold: false), accessibilityId: "Item 1"),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "1GBP = 1,17 EUR", isBold: true), accessibilityId: "Item 2"),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "Amount after conversion", isBold: false)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "351,20 EUR", isBold: true)),
                                         OneListFlowItemViewModel.Item(type: .image(imageKeyOrUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/entidades/iconos/es_2100.png"), accessibilityId: "icon")
                                        ],
                                     shouldShowSeparators: false,
                                     action: .edit(action: { })),
            OneListFlowItemViewModel(isLastItem: true,
                                     items:
                                        [OneListFlowItemViewModel.Item(type: .label(keyOrValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod", isBold: false)),
                                         OneListFlowItemViewModel.Item(type: .label(keyOrValue: "tempor incididunt ut labore et dolore magna aliqua. Ut enim", isBold: true)),
                                         OneListFlowItemViewModel.Item(type: .custom(view: alertView)),
                                        ],
                                     shouldShowSeparators: false,
                                     action: .edit(action: {}))
        ]
        viewModels2.forEach {
            let listFlowItem = OneListFlowItemView()
            listFlowItem.setupViewModel($0, at: indexPath)
            indexPath.row = indexPath.row + 1
            stackView.addArrangedSubview(listFlowItem)
        }
        self.testStackView.addArrangedSubview(stackView)
    }
    
    func addGradientViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let titles = ["oneSantanderGradient", "oneGrayGradient (top to bottom)", "oneGrayGradient (bottom to top)", "oneTurquoiseGradient"]
        let gradients: [OneGradientType] = [.oneSantanderGradient(), .oneGrayGradient(), .oneGrayGradient(direction: .bottomToTop), .oneTurquoiseGradient()]
        for (index, element) in titles.enumerated() {
            let label = UILabel()
            label.text = element
            stackView.addArrangedSubview(label)
            let view = OneGradientView()
            view.heightAnchor.constraint(equalToConstant: 300).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setupType(gradients[index])
            stackView.addArrangedSubview(view)
        }
        self.testStackView.addArrangedSubview(stackView)
    }
    
    func addIBANField() {
        let bankingUtils = self.dependenciesResolver.resolve(for: BankingUtilsProtocol.self)
        bankingUtils.setCountryCode("ES")
        let iban = IBANEntity.create(fromText: "ES1000492352082414205416")
        let bankUrl: String? = {
            guard let baseUrl = self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL else { return nil }
            guard let entityCode = iban.ibanElec.substring(4, 8) else { return nil }
            return String(format: "%@%@/%@_%@%@", baseUrl,
                          GenericConstants.relativeURl,
                          iban.countryCode.lowercased(),
                          entityCode,
                          GenericConstants.iconBankExtension)
        }()
        let viewModels = [
            OneInputSpecialIBANViewModel(
                bankingUtils: bankingUtils,
                status: .inactive,
                didTapTooltip: showUnavailable,
                didTapCountryButton: showUnavailable,
                flagImageUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/country/icons/es.png"
            ),
            OneInputSpecialIBANViewModel(
                bankingUtils: bankingUtils,
                status: .activated,
                didTapTooltip: showUnavailable,
                didTapCountryButton: showUnavailable,
                flagImageUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/country/icons/es.png"
            ),
            OneInputSpecialIBANViewModel(
                bankingUtils: bankingUtils,
                status: .focused,
                didTapTooltip: showUnavailable,
                didTapCountryButton: showUnavailable,
                flagImageUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/country/icons/es.png"
            ),
            OneInputSpecialIBANViewModel(
                bankingUtils: bankingUtils,
                status: .disabled,
                ibanString: "ES1000492352082414205416",
                didTapTooltip: showUnavailable,
                didTapCountryButton: showUnavailable,
                flagImageUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/country/icons/es.png"
            ),
            OneInputSpecialIBANViewModel(
                bankingUtils: bankingUtils,
                status: .error,
                validableType: .alert(errorMessageKey: "sendMoney_alert_valueIban"),
                didTapTooltip: showUnavailable,
                didTapCountryButton: showUnavailable,
                flagImageUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/country/icons/es.png"
            ),
            OneInputSpecialIBANViewModel(
                bankingUtils: bankingUtils,
                status: .activated,
                validableType: .validatedBank(bankName: "Banco Santander", bankUrl: bankUrl),
                ibanString: "ES1000492352082414205416",
                didTapTooltip: showUnavailable,
                didTapCountryButton: showUnavailable,
                flagImageUrl: "https://serverftp.ciber-es.com/movilidad/files_qa/RWD/country/icons/es.png"
            )
        ]
        for model in viewModels {
            self.testStackView.addArrangedSubview(OneInputSpecialIBAN(viewModel: model))
        }
    }
    
    private func showUnavailable() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func addOperativeSummaryFooter() {
        let actionSendMoney = { print("Send more money selected") }
        let actionGlobalPosition = { print("Go to Global position selected") }
        let actionHelp = { print("Help us improve selected") }
        let optionViewModels: [OneFooterNextStepItemViewModel] = [
            OneFooterNextStepItemViewModel(titleKey: "Send more money", imageName: "oneIcnTransfer", action: actionSendMoney),
            OneFooterNextStepItemViewModel(titleKey: "Go to Global position", imageName: "oneIcnPg", action: actionGlobalPosition),
            OneFooterNextStepItemViewModel(titleKey: "Help us improve", imageName: "oneIcnOk", action: actionHelp),
        ]
        let viewModel = OneFooterNextStepViewModel(titleKey: "And now?", elements: optionViewModels)
        let view = OneFooterNextStepView(with: viewModel)
        self.testStackView.addArrangedSubview(view)
    }
    
    func getSendMoreMoneyItem() -> OneFooterNextStepItemViewModel {
        return OneFooterNextStepItemViewModel(titleKey: "Send more money", imageName: "oneIcnTransfer")
    }
    
    func getGlobalPositionItem() -> OneFooterNextStepItemViewModel {
        return OneFooterNextStepItemViewModel(titleKey: "Go to Global position", imageName: "oneIcnPg")
    }
    
    func getHelpItem() -> OneFooterNextStepItemViewModel {
        return OneFooterNextStepItemViewModel(titleKey: "Help us improve", imageName: "oneIcnOk")
    }
    
    func addOperativeSummaryFooterReactive() {
        let builder = SummaryBuilder(subscriptions: &subscriptions)
        builder.addSendMoney { self.printText(text: "SendMoney") }
        builder.addGlobalPosition { self.printText(text: "GlobalPosition") }
        builder.addHelp { self.printText(text: "Help") }
        let footer = builder.buildFooter()
        let view = OneFooterNextStepView(with: footer)
        self.testStackView.addArrangedSubview(view)
    }
    
    func printText(text: String) {
        print(text)
    }
    
    private class SummaryBuilder {
        private var footerItems: [OneFooterNextStepItemViewModel] = []
        private var subscriptions = Set<AnyCancellable>()
        
        init(subscriptions: inout Set<AnyCancellable>) {
            self.subscriptions = subscriptions
        }
        
        func addSendMoney(_ action: @escaping () -> Void) {
            let viewModel = OneFooterNextStepItemViewModel(
                titleKey: "Send more money",
                imageName: "oneIcnTransfer",
                accessibilitySuffix: "_0"
            )
            viewModel.subject
                .sink(receiveValue: action)
                .store(in: &subscriptions)
            self.footerItems.append(viewModel)
        }

        func addGlobalPosition(_ action: @escaping () -> Void) {
            let viewModel = OneFooterNextStepItemViewModel(
                titleKey: "Go to Global position",
                imageName: "oneIcnPg",
                accessibilitySuffix: "_1"
            )
            viewModel.subject
                .sink(receiveValue: action)
                .store(in: &subscriptions)
            self.footerItems.append(viewModel)
        }

        func addHelp(_ action: @escaping () -> Void) {
            let viewModel = OneFooterNextStepItemViewModel(
                titleKey: "Help us improve",
                imageName: "oneIcnOk",
                accessibilitySuffix: "_2"
            )
            viewModel.subject
                .sink(receiveValue: action)
                .store(in: &subscriptions)
            self.footerItems.append(viewModel)
        }
        
        func buildFooter() -> OneFooterNextStepViewModel {
            return OneFooterNextStepViewModel(
                titleKey: "summary_label_nowThat",
                elements: self.footerItems
            )
        }
    }
    
    func addOneHomeOptionListView() {
        let oneHomeOptionListView = OneHomeOptionsListView()
        self.testStackView.addArrangedSubview(oneHomeOptionListView)
        oneHomeOptionListView.setViewModels(self.getHomeOneTransferActions())
    }
    
    func addOneHomeOptionListViewFromButton() {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitle("Show OneHomeOptionListView", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(didOneHomeOptionsBottomSheet), for: .touchUpInside)
        self.testStackView.addArrangedSubview(button)
    }
    
    @objc func didOneHomeOptionListInBottomSheet() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let oneHomeOptionListView = OneHomeOptionsListView()
        oneHomeOptionListView.setViewModels(self.getHomeOneTransferActions())
        view.addSubview(oneHomeOptionListView)
        oneHomeOptionListView.fullFit(topMargin: 16, bottomMargin: 32, leftMargin: 16, rightMargin: 16)
        view.sizeToFit()
        return view
    }
    
    @objc func didOneHomeOptionsBottomSheet() {
        guard let navigation = self.navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation, type: .custom(isPan: true), component: .all, view: self.didOneHomeOptionListInBottomSheet())
    }
    
    func getHomeOneTransferActions() -> [SendMoneyHomeOption] {
        let bizum: SendMoneyHomeActionType = .custom(
            identifier: "bizum",
            title: "transferOption_button_bizum",
            description: "transferOption_text_bizum",
            icon: "icnBizum"
        )
        let oneActions: [SendMoneyHomeActionType] = [.transfer, .transferBetweenAccounts, bizum, .atm, .scheduleTransfers, .donations(nil)]
        return oneActions.compactMap {
            let value = $0.values()
            return SendMoneyHomeOption(
                title: value.title,
                description: value.description,
                imageName: value.imageName,
                actionType: $0,
                action: self.didSelectActionType
            )
        }
    }
        
    func didSelectActionType(_ actionType: SendMoneyHomeActionType) {
        print(actionType, actionType.accessibilityIdentifier)
    }
}

private extension OneComponentsQAViewController {

    struct FavoriteContactCardOption {
        let status: OneFavoriteContactCardViewModel.CardStatus
        let avatar: OneAvatarViewModel
        let payee: PayeeRepresentable
    }
    
    func favoriteMock(index: Int = -1) -> PayeeRepresentable {
        var payeeDTO = PayeeDTO()
        let names = ["Francisco Javier Esposito", "Francisco Manuel Javier Esposito", "Javier"]
        payeeDTO.beneficiary = index == -1 ? names.randomElement() : names[index]
        payeeDTO.iban = IBANDTO(ibanString: "ESXXXXXXXXXXXXXXXXX")
        return payeeDTO
    }

    func accountMock(index: Int = -1) -> AccountRepresentable {
        var accountDto = AccountDTO()
        let names = ["Francisco Javier Esposito", "Francisco Manuel Javier Esposito", "Javier", "Perico el de los Palotes", "Jeremías Fonso González"]
        accountDto.alias = index == -1 ? names.randomElement() : names[index]
        let ibans = ["ES40 2038 2307 3860 0010 6863", "ES34 0049 0592 3721 1133 1754", "ES64 0049 0592 3424 1133 1894", "ES77 0049 9000 7420 1040 3672", "ES10 0049 2352 0824 1420 5416"]
        accountDto.iban = IBANDTO(ibanString: index == -1 ? ibans.randomElement() ?? ibans[0] : ibans[index])
        return accountDto
    }

    func addFavoriteContactCards() {
        let options: [FavoriteContactCardOption] = [
            FavoriteContactCardOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock().alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                payee: favoriteMock()
            ),
            FavoriteContactCardOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock().alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                payee: favoriteMock()
            ),
            FavoriteContactCardOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: favoriteMock().payeeDisplayName,
                    dependenciesResolver: self.dependenciesResolver
                ),
                payee: favoriteMock()
            ),
            FavoriteContactCardOption(
                status: .selected,
                avatar: OneAvatarViewModel(
                    fullName: favoriteMock().payeeDisplayName,
                    dependenciesResolver: self.dependenciesResolver
                ),
                payee: favoriteMock()
            ),
            FavoriteContactCardOption(
                status: .selected,
                avatar: OneAvatarViewModel(
                    fullName: favoriteMock().payeeDisplayName,
                    dependenciesResolver: self.dependenciesResolver
                ),
                payee: favoriteMock()
            ),
            FavoriteContactCardOption(
                status: .selected,
                avatar: OneAvatarViewModel(
                    fullName: favoriteMock().payeeDisplayName,
                    dependenciesResolver: self.dependenciesResolver
                ),
                payee: favoriteMock()
            ),

        ]
        options.forEach { option in
            let viewModel = OneFavoriteContactCardViewModel(
                cardStatus: option.status,
                avatar: option.avatar,
                payee: option.payee,
                dependenciesResolver: self.dependenciesResolver
            )
            let favoriteCard = OneFavoriteContactCardView()
            favoriteCard.setupFavoriteContactViewModel(viewModel)
            let containerView = UIView()
            containerView.addSubview(favoriteCard)
            NSLayoutConstraint.activate([
                favoriteCard.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0),
                favoriteCard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0),
                favoriteCard.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            ])
            self.testStackView.addArrangedSubview(containerView)
        }
    }
}

private extension OneComponentsQAViewController {
    func addTopBarExamples() {
        let topBarSectionLabel = UILabel()
        topBarSectionLabel.text = "Top bar examples"
        self.testStackView.addArrangedSubview(topBarSectionLabel)
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.logoPickerView = picker
        self.testStackView.addArrangedSubview(picker)
        let bizumButton = UIButton(type: .system)
        bizumButton.setTitle("Bizum top bar example", for: .normal)
        bizumButton.addTarget(self, action: #selector(pushBizumExample), for: .touchUpInside)
        self.testStackView.addArrangedSubview(bizumButton)
        let accountsButton = UIButton(type: .system)
        accountsButton.setTitle("Accounts top bar example", for: .normal)
        accountsButton.addTarget(self, action: #selector(pushAccountsExample), for: .touchUpInside)
        self.testStackView.addArrangedSubview(accountsButton)
        let gpButton = UIButton(type: .system)
        gpButton.setTitle("White GP top bar example", for: .normal)
        gpButton.addTarget(self, action: #selector(didTapWhiteGP), for: .touchUpInside)
        self.testStackView.addArrangedSubview(gpButton)
        let tripButton = UIButton(type: .system)
        tripButton.setTitle("Trip top bar example", for: .normal)
        tripButton.addTarget(self, action: #selector(didTapTrip), for: .touchUpInside)
        self.testStackView.addArrangedSubview(tripButton)
        let smartButton = UIButton(type: .system)
        smartButton.setTitle("Smart GP top bar example", for: .normal)
        smartButton.addTarget(self, action: #selector(didTapSmart), for: .touchUpInside)
        self.testStackView.addArrangedSubview(smartButton)
    }
    
    @objc func pushBizumExample() {
        self.navigationController?.pushViewController(BizumTopBarExampleViewController(), animated: true)
    }
    
    @objc func pushAccountsExample() {
        self.navigationController?.pushViewController(AccountsTopBarExampleViewController(), animated: true)
    }
    
    @objc func didTapWhiteGP() {
        let viewController = GPTopBarExampleViewController()
        viewController.santanderLogo = self.selectedLogo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func didTapTrip() {
        self.navigationController?.pushViewController(TripTopBarExampleViewController(), animated: true)
    }
    
    @objc func didTapSmart() {
        let viewController = SmartGPTopBarExampleViewController()
        viewController.santanderLogo = self.selectedLogo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func didBottomSheet() {
        guard let navigation = self.navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation, type: .custom(isPan: true), component: .all, view: self.addViewBottomSheet())
    }
    
    @objc func didBottomSheetTop() {
        guard let navigation = self.navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation, type: .top(isPan: true), component: .all, view: UIView())
    }
    
    @objc func didBottomSheetHalf() {
        guard let navigation = self.navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation, type: .half(isPan: true), component: .all, view: UIView())
    }
}

//TODO Remove when QA it's over.
private extension OneComponentsQAViewController {
    func addTextFieldExamples() {
        let status: [OneInputRegularViewModel.Status] = [.inactive,
                                                                  .focused,
                                                                  .disabled,
                                                                  .error,
                                                                  .activated]
        self.regularViews.enumerated().forEach { textfield in
            let status = status[textfield.offset] 
            let viewModel = OneInputRegularViewModel(status: status,
                                     text: status == .inactive ? nil : "**Concept",
                                     placeholder: "**Write here the concept",
                                     searchAction: status == .activated ? self.searchDidPressed : nil,
                                     resetText: true)
            textfield.element.setupTextField(viewModel)
        }
    }
    
    func searchDidPressed() {
        print("Search did pressed")
    }
    
    func addAmountTextFields() {
        let status: [OneStatus] = [
            .inactive,
            .focused,
            .activated,
            .disabled,
            .error
        ]
        status.forEach { status in
            let viewModel = OneInputAmountViewModel(status: status)
            let oneInputAmount = OneInputAmountView()
            oneInputAmount.setupTextField(viewModel)
            let oneInputAmountError = OneSubLabelError()
            oneInputAmountError.setContainer(oneInputAmount)
            self.testStackView.addArrangedSubview(oneInputAmountError)
        }
        var accountDto = AccountDTO()
        accountDto.currentBalance = AmountDTO(value: Decimal(250), currency: .create(.eur))
        let viewModelIcon = OneInputAmountViewModel(status: .activated, type: .icon, amountRepresentable: accountDto.currentBalanceRepresentable)
        let oneInputAmountIcon = OneInputAmountView()
        oneInputAmountIcon.setupTextField(viewModelIcon)
        let oneInputAmountErrorIcon = OneSubLabelError()
        oneInputAmountErrorIcon.errorProtocol = oneInputAmountIcon
        oneInputAmountErrorIcon.setContainer(oneInputAmountIcon)
        oneInputAmountErrorIcon.showError("Showing error and disabled")
        oneInputAmountIcon.status = .inactive
        self.testStackView.addArrangedSubview(oneInputAmountErrorIcon)
        let viewModelText = OneInputAmountViewModel(status: .activated, type: .text, placeholder: "0,00", amountRepresentable: accountDto.currentBalanceRepresentable)
        let oneInputAmountText = OneInputAmountView()
        oneInputAmountText.setupTextField(viewModelText)
        let oneInputAmountErrorText = OneSubLabelError()
        oneInputAmountErrorText.errorProtocol = oneInputAmountText
        oneInputAmountErrorText.setContainer(oneInputAmountText)
        oneInputAmountErrorText.showError("Error text")
        self.testStackView.addArrangedSubview(oneInputAmountErrorText)
    }
    
    func addViewBottomSheet() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: Assets.image(named: "imgChangeWayToPay"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let titlelabel = UILabel()
        titlelabel.configureText(withKey: "Validate your credit card", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 24), alignment: .center))
        titlelabel.textColor = .lisboaGray
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        let descriptionLabel = UILabel()
        descriptionLabel.configureText(withKey: "For your security, we’ve closed your session. Please re-enter your credentials.For your security, we’ve closed your session. Please re-enter your credentials.", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 16), alignment: .center))
        descriptionLabel.textColor = .lisboaGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let buttonLeft = WhiteLisboaButton()
        buttonLeft.addAction(self.didSelectDismiss)
        buttonLeft.setTitle("Cancel", for: .normal)
        buttonLeft.translatesAutoresizingMaskIntoConstraints = false
        let buttonRight = RedLisboaButton()
        buttonRight.setTitle("Validate", for: .normal)
        buttonRight.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addSubview(titlelabel)
        view.addSubview(descriptionLabel)
        view.addSubview(buttonLeft)
        view.addSubview(buttonRight)
        imageView.heightAnchor.constraint(equalToConstant: 190).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 327).isActive = true
        view.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -13).isActive = true
        view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        titlelabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 13).isActive = true
        view.leadingAnchor.constraint(equalTo: titlelabel.leadingAnchor, constant: -24).isActive = true
        view.trailingAnchor.constraint(equalTo: titlelabel.trailingAnchor, constant: 24).isActive = true
        titlelabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        view.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 24).isActive = true
        buttonLeft.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        buttonLeft.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24).isActive = true
        buttonLeft.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 56).isActive = true
        buttonLeft.trailingAnchor.constraint(equalTo: buttonRight.leadingAnchor, constant: -16).isActive = true
        buttonLeft.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        buttonRight.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: buttonRight.topAnchor, constant: -24).isActive = true
        buttonRight.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -56).isActive = true
        buttonLeft.widthAnchor.constraint(equalTo: buttonRight.widthAnchor).isActive = true
        descriptionLabel.sizeToFit()
        view.sizeToFit()
        return view
    }
    
    func didSelectDismiss() {
        self.navigationController?.dismiss(animated: true)
    }
}

// TODO: Remove when QA is over
private extension OneComponentsQAViewController {

    struct PastTransferOption {
        let status: OnePastTransferViewModel.CardStatus
        let avatar: OneAvatarViewModel
        let transfer: TransferRepresentable
    }

    func transferMock(
        type: TransferRepresentableType,
        scheduleType: TransferRepresentableScheduleType,
        index: Int = -1
    ) -> TransferRepresentable? {
        var transfer: TransferRepresentable? = nil
        let descriptions = ["Gift for Juanito", "Gift for Juanito, Lucia and co.", ""]
        let amounts = [Decimal(500.50), Decimal(59865.56), Decimal(-4)]
        if type == .emitted {
            var transferEmitted = TransferEmittedDTO()
            let amountValue = index == -1 ? amounts.randomElement() : amounts[index]
            transferEmitted.amount = AmountDTO(value: amountValue!, currency: .create(.eur))
            transferEmitted.concept = index == -1 ? descriptions.randomElement() : descriptions[index]
            transferEmitted.executedDate = Date()
            transfer = transferEmitted
        } else if type == .received {
            var transferReceived = AccountTransactionDTO()
            let amountValue = index == -1 ? amounts.randomElement() : amounts[index]
            transferReceived.amount = AmountDTO(value: amountValue!, currency: .create(.eur))
            transferReceived.description = index == -1 ? descriptions.randomElement() : descriptions[index]
            transferReceived.operationDate = Date()
            transfer = transferReceived
        }
        return transfer
    }

    func addPastTransfers() {
        let options: [PastTransferOption] = [
            // Normal
            PastTransferOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 0).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .emitted, scheduleType: .normal, index: 0)!
            ),
            // Min
            PastTransferOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 2).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .received, scheduleType: .normal, index: 2)!
            ),
            // Max
            PastTransferOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 1).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .emitted, scheduleType: .normal, index: 1)!
            ),
            // Selected
            PastTransferOption(
                status: .selected,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 1).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .received, scheduleType: .normal)!
            ),
            // Scheduled
            PastTransferOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 1).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .emitted, scheduleType: .scheduled)!
            ),
            // Periodic
            PastTransferOption(
                status: .inactive,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 1).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .emitted, scheduleType: .periodic)!
            ),
            // Scheduled & Selected
            PastTransferOption(
                status: .selected,
                avatar: OneAvatarViewModel(
                    fullName: accountMock(index: 1).alias,
                    dependenciesResolver: self.dependenciesResolver
                ),
                transfer: transferMock(type: .emitted, scheduleType: .scheduled)!
            ),
        ]

        options.forEach { option in
            let viewModel = OnePastTransferViewModel(
                cardStatus: option.status,
                transfer: option.transfer,
                avatar: option.avatar,
                dependenciesResolver: self.dependenciesResolver
            )
            let pastTransferCard = OnePastTransferCardView()
            pastTransferCard.setupPastTransferCard(viewModel)
            let containerView = UIView()
            containerView.addSubview(pastTransferCard)
            NSLayoutConstraint.activate([
                pastTransferCard.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0),
                pastTransferCard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0),
                pastTransferCard.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            ])
            self.testStackView.addArrangedSubview(containerView)
        }
    }
    
    func addSmallSelectorListViews() {
        let viewModels: [OneSmallSelectorListViewModel] = [
            OneSmallSelectorListViewModel(leftTextKey: "Euro",
                                          rightAccessory: .none,
                                          status: .inactive,
                                          accessibilitySuffix: "_one"),
            OneSmallSelectorListViewModel(leftTextKey: "Euro",
                                          rightAccessory: .text(textKey: "EUR"),
                                          status: .inactive,
                                          accessibilitySuffix: "_two"),
            OneSmallSelectorListViewModel(leftTextKey: "Spain",
                                          rightAccessory: .icon(imageName: "oneIcnFlagSpain"),
                                          status: .inactive,
                                          accessibilitySuffix: "_three"),
            OneSmallSelectorListViewModel(leftTextKey: "Euro",
                                          rightAccessory: .none,
                                          status: .activated,
                                          accessibilitySuffix: "_four"),
            OneSmallSelectorListViewModel(leftTextKey: "Euro",
                                          rightAccessory: .text(textKey: "EUR"),
                                          status: .activated,
                                          accessibilitySuffix: "_five"),
            OneSmallSelectorListViewModel(leftTextKey: "Euro",
                                          rightAccessory: .icon(imageName: "oneIcnFlagSpain"),
                                          status: .activated),
            OneSmallSelectorListViewModel(leftTextKey: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus mattis gravida est nec aliquam.",
                                          rightAccessory: .none,
                                          status: .inactive),
            OneSmallSelectorListViewModel(leftTextKey: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus mattis gravida est nec aliquam.",
                                          rightAccessory: .text(textKey: "MCDBYR"),
                                          status: .inactive),
            OneSmallSelectorListViewModel(leftTextKey: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus mattis gravida est nec aliquam.",
                                          rightAccessory: .icon(imageName: "oneIcnFlagSpain"),
                                          status: .inactive)
        ]
        viewModels.enumerated().forEach { (index, item) in
            let smallSelectorListView = OneSmallSelectorListView()
            smallSelectorListView.setViewModel(item)
            self.testStackView.addArrangedSubview(smallSelectorListView)
        }
    }
    
    func addOneToggeView() {
        let toggleViewSmall = OneToggleView()
        toggleViewSmall.oneSize = .small
        self.testStackView.addArrangedSubview(toggleViewSmall)
        let toggleView = OneToggleView()
        toggleView.oneSize = .big
        self.testStackView.addArrangedSubview(toggleView)
        let toggleViewDisabledSmall = OneToggleView()
        toggleViewDisabledSmall.oneSize = .small
        toggleViewDisabledSmall.isEnabled = false
        self.testStackView.addArrangedSubview(toggleViewDisabledSmall)
        let toggleViewDisabled = OneToggleView()
        toggleViewDisabled.oneSize = .big
        toggleViewDisabled.isEnabled = false
        self.testStackView.addArrangedSubview(toggleViewDisabled)
        toggleViewSmall
            .publisher
            .sink { isOn in
                print(isOn)
            }.store(in: &subscriptions)
        
        toggleView
            .publisher
            .sink { [unowned toggleViewDisabled] isOn in
                print(isOn)
                toggleViewDisabled.isEnabled = isOn
            }.store(in: &subscriptions)
        
        toggleViewDisabledSmall
            .publisher
            .sink { isOn in
                print(isOn)
            }.store(in: &subscriptions)
        
        toggleViewDisabled
            .publisher
            .sink { isOn in
                print(isOn)
            }.store(in: &subscriptions)
    }
    
    func addOneNotificationView() {
        let notificationViewText = OneNotificationsView()
        var mockOneNotificationView = MockOneNotificationView(type: .textOnly(stringKey: "manager_subtitle_keeptoRequirement"),
                                                              defaultColor: .onePaleYellow,
                                                              inactiveColor: nil)
        notificationViewText.setNotificationView(with: mockOneNotificationView)
        self.testStackView.addArrangedSubview(notificationViewText)
        
        let notificationView2 = OneNotificationsView()
        mockOneNotificationView = MockOneNotificationView(type: .textAndHelp(stringKey: "manager_subtitle_keeptoRequirement"),
                                                          defaultColor: .oneSkyGray,
                                                          inactiveColor: nil)
        notificationView2.setNotificationView(with: mockOneNotificationView)
        self.testStackView.addArrangedSubview(notificationView2)
        notificationView2
            .publisher
            .case(OneNotificationState.didTappedIcnHelp)
            .sink { _ in
                Toast.show("Did Tapped Help")
            }.store(in: &subscriptions)
        
        let notificationViewText3 = OneNotificationsView()
        mockOneNotificationView = MockOneNotificationView(type: .textAndLink(stringKey: "manager_subtitle_keeptoRequirement", linkKey: "Update", linkIsEnabled: true),
                                                          defaultColor: .onePaleYellow,
                                                          inactiveColor: nil)
        notificationViewText3.setNotificationView(with: mockOneNotificationView)
        self.testStackView.addArrangedSubview(notificationViewText3)
        notificationViewText3
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { _ in
                Toast.show("Did Tapped Link")
            }.store(in: &subscriptions)
        
        let notificationViewText4 = OneNotificationsView()
        mockOneNotificationView = MockOneNotificationView(type: .textHelpAndLink(stringKey: "manager_subtitle_keeptoRequirement", linkKey: "Update", linkIsEnabled: false),
                                                          defaultColor: .oneTurquoise.withAlphaComponent(0.07),
                                                          inactiveColor: nil)
        notificationViewText4.setNotificationView(with: mockOneNotificationView)
        self.testStackView.addArrangedSubview(notificationViewText4)
        notificationViewText4
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { _ in
                Toast.show("Did Tapped Link")
            }.store(in: &subscriptions)
        
        notificationViewText4
            .publisher
            .case(OneNotificationState.didTappedIcnHelp)
            .sink { _ in
                Toast.show("Did Tapped Help")
            }.store(in: &subscriptions)
        
        let notificationViewText5 = OneNotificationsView()
        mockOneNotificationView = MockOneNotificationView(type: .textAndToggle(stringKey: "manager_subtitle_keeptoRequirement",
                                                                               toggleValue: true,
                                                                               toggleIsEnabled: true),
                                                          defaultColor: .oneSkyGray,
                                                          inactiveColor: .oneWhite)
        notificationViewText5.setNotificationView(with: mockOneNotificationView)
        self.testStackView.addArrangedSubview(notificationViewText5)
        notificationViewText5
            .publisher
            .case(OneNotificationState.didChangeToggle)
            .sink { [unowned notificationViewText4] isOn in
                Toast.show("Did Tapped Toggle. Value is: \(isOn)")
                notificationViewText4.setLinkIsEnabled(isOn)
            }.store(in: &subscriptions)
        
        let notificationViewText6 = OneNotificationsView()
        mockOneNotificationView = MockOneNotificationView(type: .textAndToggle(stringKey: "manager_subtitle_keeptoRequirement",
                                                                               toggleValue: true,
                                                                               toggleIsEnabled: false),
                                                          defaultColor: .oneSkyGray,
                                                          inactiveColor: .oneWhite)
        notificationViewText6.setNotificationView(with: mockOneNotificationView)
        self.testStackView.addArrangedSubview(notificationViewText6)
    }
    
    struct MockOneNotificationView: OneNotificationRepresentable {
        var type: OneNotificationType
        var defaultColor: UIColor
        var inactiveColor: UIColor?
    }
    struct MockOneProductCardView: OneProductCardViewRepresentable {
        var title: String
        var subTitle: String?
        var defatultImageName: String?
        var urlImage: String?
        var logoSize: OneProductCardLogoHeight?
        var moreActionsImageName: String?
        var mainAmount: OneProductCardAmountRepresentable?
        var extraAmounts: [OneProductCardAmountRepresentable]?
        var infoExtra: LocalizedStylableText?
        var firstNotification: OneNotificationRepresentable?
        var secondNotification: OneNotificationRepresentable?
        var thirdNotification: OneNotificationRepresentable?
        var toggleNotification: OneNotificationRepresentable?
        var cardStatus: OneProductCardStatus
        var borderStyle: OneProductCardBorderStyle
        var mainBackgroundColor: UIColor
        var secundaryBackgroundColor: UIColor?
        var notificationTitleAccessibilityLabel: String?
    }
    
    struct MockOneProductCardAmount: OneProductCardAmountRepresentable {
        var title: String
        var amount: AmountRepresentable
    }
    
    func addOneProductCard() {
        let mockOneProductCardModel = MockOneProductCardView(title: "1|2|3 Everyday Personal Expenses Current Account Main",
                                                             subTitle: "Saving Account | PL61 1090 1014 0000 0712 1981 2874",
                                                             defatultImageName: "oneDefaultCard",
                                                             urlImage: "https://serverftp.ciber-es.com/movilidad/files_dev/RWD/entidades/pfm/es_1465.png",
                                                             logoSize: .small,
                                                             moreActionsImageName: "oneIcnMoreOptions",
                                                             mainAmount: MockOneProductCardAmount(title: "Balance", amount: AmountEntity(value: 71220)),
                                                             extraAmounts: [MockOneProductCardAmount(title: "Balance incl. pending", amount: AmountEntity(value: 5.97)),
                                                                            MockOneProductCardAmount(title: "Overdraft remaining for the account principal", amount: AmountEntity(value: 2269.01))],
                                                             infoExtra: localized("Updated {{BOLD}}Yesterday 22:15{{/BOLD}}"),
                                                             firstNotification: MockOneNotificationView(type: .textOnly(stringKey: "manager_subtitle_keeptoRequirement"),
                                                                                                        defaultColor: .onePaleYellow,
                                                                                                        inactiveColor: nil),
                                                             secondNotification: MockOneNotificationView(type: .textAndHelp(stringKey: "manager_subtitle_keeptoRequirement"),
                                                                                                         defaultColor: .oneSkyGray,
                                                                                                         inactiveColor: nil),
                                                             thirdNotification: MockOneNotificationView(type: .textHelpAndLink(stringKey: "manager_subtitle_keeptoRequirement", linkKey: "Update", linkIsEnabled: true),
                                                                                                        defaultColor: .oneTurquoise.withAlphaComponent(0.07),
                                                                                                        inactiveColor: nil),
                                                             toggleNotification: MockOneNotificationView(type: .textAndToggle(stringKey: "manager_subtitle_keeptoRequirement",
                                                                                                                              toggleValue: true,
                                                                                                                              toggleIsEnabled: true),
                                                                                                         defaultColor: .oneSkyGray,
                                                                                                         inactiveColor: .oneWhite),
                                                             cardStatus: .normal,
                                                             borderStyle: .shadow,
                                                             mainBackgroundColor: .oneWhite,
                                                             secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView = OneProductCardView()
        oneProductCardView.setupProductCard(mockOneProductCardModel)
        self.testStackView.addArrangedSubview(oneProductCardView)
        
        let oneProductCardView4 = OneProductCardView()
        
        oneProductCardView.publisher
            .case(OneProductCardState.didChangeToggle)
            .sink { [unowned oneProductCardView4] isOn in
                Toast.show("Did Tapped Toggle. Value is: \(isOn)")
                oneProductCardView4.setStatus(isOn ? .selected : .normal)
            }.store(in: &subscriptions)
        
        oneProductCardView.publisher
            .case(OneProductCardState.didTappedMoreActionButton)
            .sink { _ in
                Toast.show("Did Tapped more action button")
            }.store(in: &subscriptions)
        
        oneProductCardView.publisher
            .case(OneProductCardState.didTappedNotificationIcnHelp)
            .sink { orderNotification in
                Toast.show("Did Tapped Help in \(orderNotification.rawValue) notification")
            }.store(in: &subscriptions)
        
        oneProductCardView.publisher
            .case(OneProductCardState.didTappedNotificationLink)
            .sink { orderNotification in
                Toast.show("Did Tapped Link in \(orderNotification.rawValue) notification")
            }.store(in: &subscriptions)
        
        let mockOneProductCardModel2 = MockOneProductCardView(title: "Personal Card",
                                                              subTitle: "Credit | *5678",
                                                              defatultImageName: "oneDefaultCard",
                                                              urlImage: nil,
                                                              logoSize: .big,
                                                              moreActionsImageName: "oneIcnMoreOptions",
                                                              mainAmount: MockOneProductCardAmount(title: "Balance", amount: AmountEntity(value: 71220)),
                                                              extraAmounts: [MockOneProductCardAmount(title: "Balance incl. pending", amount: AmountEntity(value: 5.97)),
                                                                             MockOneProductCardAmount(title: "Overdraft remaining", amount: AmountEntity(value: 269))],
                                                              infoExtra: localized("Updated {{BOLD}}Yesterday 22:15{{/BOLD}}"),
                                                              firstNotification: MockOneNotificationView(type: .textOnly(stringKey: "manager_subtitle_keeptoRequirement"),
                                                                                                         defaultColor: .onePaleYellow,
                                                                                                         inactiveColor: nil),
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: MockOneNotificationView(type: .textAndToggle(stringKey: "manager_subtitle_keeptoRequirement",
                                                                                                                               toggleValue: false,
                                                                                                                               toggleIsEnabled: true),
                                                                                                          defaultColor: .oneSkyGray,
                                                                                                          inactiveColor: .oneWhite),
                                                              cardStatus: .normal,
                                                              borderStyle: .line,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView2 = OneProductCardView()
        oneProductCardView2.setupProductCard(mockOneProductCardModel2)
        self.testStackView.addArrangedSubview(oneProductCardView2)
        
        let mockOneProductCardModel3 = MockOneProductCardView(title: "1|2|3 Everyday Personal Expenses Current Account",
                                                              subTitle: "PL61 1090 1014 0000 0712 1981 2874",
                                                              defatultImageName: "oneIcnBankGenericLogo",
                                                              urlImage: "https://serverftp.ciber-es.com/movilidad/files_dev/RWD/entidades/pfm/es_0216.png",
                                                              logoSize: .small,
                                                              moreActionsImageName: nil,
                                                              mainAmount: MockOneProductCardAmount(title: "Balance", amount: AmountEntity(value: 71220)),
                                                              extraAmounts: [MockOneProductCardAmount(title: "Balance incl. pending", amount: AmountEntity(value: 5.97))],
                                                              infoExtra: localized("Updated {{BOLD}}Yesterday 22:15{{/BOLD}}"),
                                                              firstNotification: nil,
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .normal,
                                                              borderStyle: .shadow,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView3 = OneProductCardView()
        oneProductCardView3.setupProductCard(mockOneProductCardModel3)
        self.testStackView.addArrangedSubview(oneProductCardView3)
        
        let mockOneProductCardModel4 = MockOneProductCardView(title: "Personal Card",
                                                              subTitle: "Credit | *5678",
                                                              defatultImageName: "oneDefaultCard",
                                                              urlImage: nil,
                                                              logoSize: .big,
                                                              moreActionsImageName: nil,
                                                              mainAmount: nil,
                                                              extraAmounts: nil,
                                                              infoExtra: localized("Updated {{BOLD}}Yesterday 22:15{{/BOLD}}"),
                                                              firstNotification: nil,
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .selected,
                                                              borderStyle: .line,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        
        oneProductCardView4.setupProductCard(mockOneProductCardModel4)
        self.testStackView.addArrangedSubview(oneProductCardView4)
        
        let mockOneProductCardModel5 = MockOneProductCardView(title: "Personal Card",
                                                              subTitle: "Credit | *5678",
                                                              defatultImageName: "oneDefaultCard",
                                                              urlImage: nil,
                                                              logoSize: .big,
                                                              moreActionsImageName: nil,
                                                              mainAmount: nil,
                                                              extraAmounts: nil,
                                                              infoExtra: nil,
                                                              firstNotification: nil,
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .normal,
                                                              borderStyle: .line,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView5 = OneProductCardView()
        oneProductCardView5.setupProductCard(mockOneProductCardModel5)
        self.testStackView.addArrangedSubview(oneProductCardView5)
        
        let mockOneProductCardModel6 = MockOneProductCardView(title: "Personal Account",
                                                              subTitle: "09-87-65  12345678",
                                                              defatultImageName: "icnArrowRightBlack",
                                                              urlImage: "https://serverftp.ciber-es.com/movilidad/files_dev/RWD/entidades/pfm/es_0049.png",
                                                              logoSize: .small,
                                                              moreActionsImageName: nil,
                                                              mainAmount: MockOneProductCardAmount(title: "Balance", amount: AmountEntity(value: 34124.08)),
                                                              extraAmounts: nil,
                                                              infoExtra: nil,
                                                              firstNotification: nil,
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .normal,
                                                              borderStyle: .shadow,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView6 = OneProductCardView()
        oneProductCardView6.setupProductCard(mockOneProductCardModel6)
        self.testStackView.addArrangedSubview(oneProductCardView6)
        
        let mockOneProductCardModel7 = MockOneProductCardView(title: "Personal Account",
                                                              subTitle: "09-87-65  12345678",
                                                              defatultImageName: "icnArrowRight",
                                                              urlImage: nil,
                                                              logoSize: .small,
                                                              moreActionsImageName: nil,
                                                              mainAmount: MockOneProductCardAmount(title: "Available balance", amount: AmountEntity(value: 34124.08)),
                                                              extraAmounts: [MockOneProductCardAmount(title: "Balance incl. pending", amount: AmountEntity(value: 5.97)),
                                                                             MockOneProductCardAmount(title: "Overdraft remaining", amount: AmountEntity(value: 269))],
                                                              infoExtra: nil,
                                                              firstNotification: nil,
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .normal,
                                                              borderStyle: .shadow,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView7 = OneProductCardView()
        oneProductCardView7.setupProductCard(mockOneProductCardModel7)
        self.testStackView.addArrangedSubview(oneProductCardView7)
        
        let mockOneProductCardModel8 = MockOneProductCardView(title: "ING",
                                                              subTitle: nil,
                                                              defatultImageName: "oneIcnBankGenericLogo",
                                                              urlImage: "https://serverftp.ciber-es.com/movilidad/files_dev/RWD/entidades/pfm/es_1465.png",
                                                              logoSize: .small,
                                                              moreActionsImageName: nil,
                                                              mainAmount: nil,
                                                              extraAmounts: nil,
                                                              infoExtra: localized("Updated {{BOLD}}Yesterday 22:15{{/BOLD}}"),
                                                              firstNotification: MockOneNotificationView(type: .textOnly(stringKey: "{{BOLD}}Permit valid until 02-10-2022{{/BOLD}}"),
                                                                                                         defaultColor: .oneSkyGray,
                                                                                                         inactiveColor: nil),
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .normal,
                                                              borderStyle: .shadow,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView8 = OneProductCardView()
        oneProductCardView8.setupProductCard(mockOneProductCardModel8)
        self.testStackView.addArrangedSubview(oneProductCardView8)
        
        let mockOneProductCardModel9 = MockOneProductCardView(title: "Credit Card",
                                                              subTitle: "Credit | *5678",
                                                              defatultImageName: "oneDefaultCard",
                                                              urlImage: "https://serverftp.ciber-es.com/movilidad/files_dev/RWD/tarjetas/pfm/es_1465.png",
                                                              logoSize: .big,
                                                              moreActionsImageName: nil,
                                                              mainAmount: nil,
                                                              extraAmounts: nil,
                                                              infoExtra: nil,
                                                              firstNotification: nil,
                                                              secondNotification: nil,
                                                              thirdNotification: nil,
                                                              toggleNotification: nil,
                                                              cardStatus: .normal,
                                                              borderStyle: .line,
                                                              mainBackgroundColor: .oneWhite,
                                                              secundaryBackgroundColor: .oneSkyGray)
        let oneProductCardView9 = OneProductCardView()
        oneProductCardView9.setupProductCard(mockOneProductCardModel9)
        self.testStackView.addArrangedSubview(oneProductCardView9)
    }
}

extension OneComponentsQAViewController: OneInputDateViewDelegate {
    public func didSelectNewDate(_ date: Date) {
        print("Selected option: " + date.toString(format: TimeFormat.dd_MM_yyyy.rawValue))
    }
}

extension OneComponentsQAViewController: OneInputCodeViewDelegate {
    public func inputCodeView(_ view: OneInputCodeView, didChange string: String, for position: Int) { }
    public func inputCodeView(_ view: OneInputCodeView, willChange string: String, for position: Int)  { }
    public func inputCodeView(_ view: OneInputCodeView, didBeginEditing position: Int) { }
    public func inputCodeView(_ view: OneInputCodeView, didEndEditing position: Int) { }
}

extension OneComponentsQAViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollView.backgroundColor = scrollView.contentOffset.y > 0 ? .blueAnthracita: .clear
    }
}


// MARK: - oneLabelHighlightedView
private extension OneComponentsQAViewController {
    func setupHighlightedView() {
        highlightBackgrounViewTest.text = "1200.30€"
        highlightBackgrounViewTest.style = .lightGreen
    }
}
