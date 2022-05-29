//
//  ConfigurationEngine.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

protocol ConfigurationEngineDelegate: AnyObject {
    func configurationDidFinishLoad(_ configuration: TimeLineConfiguration)
    func configurationDidFinishWithError(_ error: Error)
}

class ConfigurationEngine {
    
    private let configurationRepository: ConfigurationRepository
    private let textsEngine: TextsEngine
    private let ctasEngine: CTAEngine
    private let merchantIconEngine: MerchantIconEngine
    private var delegates: [WeakReference<ConfigurationEngineDelegate>] = []
    private var isLoading: Bool = false
    
    init(configurationRepository: ConfigurationRepository, textsEngine: TextsEngine, ctasEngine: CTAEngine, merchantIconEngine: MerchantIconEngine) {
        self.configurationRepository = configurationRepository
        self.textsEngine = textsEngine
        self.ctasEngine = ctasEngine
        self.merchantIconEngine = merchantIconEngine
    }
    
    func load(delegate: ConfigurationEngineDelegate? = nil) {
        if isLoading {
            addDelegate(delegate)
        } else {
            isLoading = true
            addDelegate(delegate)
            configurationRepository.fetchConfiguration { [weak self] result in
                self?.isLoading = false
                switch result {
                case .success(let configuration):
                    self?.merchantIconEngine.baseUrl = configuration.merchantIconBaseUrl
                    self?.textsEngine.setupTexts(configuration.textTransactions, productCodes: configuration.textProductCodes, calculationUnits: configuration.textCalculationUnitCodes, groupedMonthsDisclaimer: configuration.groupedMonthsDisclaimer)
                    self?.ctasEngine.setupCTAs(configuration.textTransactions, CTAs: configuration.CTAs)
                    self?.delegates.forEach { $0.get()?.configurationDidFinishLoad(configuration) }
                    self?.delegates.removeAll()
                case .failure(let error):
                    self?.delegates.forEach { $0.get()?.configurationDidFinishWithError(error) }
                    self?.delegates.removeAll()
                }
            }
        }
    }
    
    private func addDelegate(_ delegate: ConfigurationEngineDelegate?) {
        guard let delegate = delegate, !delegates.contains(where: { $0.get().map(String.init(describing:)) == String(describing: delegate) }) else { return }
        delegates.append(WeakReference(value: delegate))
    }
}
