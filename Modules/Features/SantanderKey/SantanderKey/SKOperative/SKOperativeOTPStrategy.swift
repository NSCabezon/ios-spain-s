//
//  SKOperativeOTPStrategy.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 25/3/22.
//

import Foundation
import Operative
import OpenCombine
import CoreDomain
import CoreFoundationLib
import SANSpainLibrary
import ESCommons
import SANLibraryV3

final class SKOperativeOTPStrategy: OTPCapabilityStrategy {

    let operative: SKOperative
    let validateStep: SKOperativeStep = .signature
    var otpStep: SKOperativeStep = .otp
    let dependencies: SKOperativeExternalDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    var coordinator: SKOperativeCoordinator
    let compilation: SpainCompilationProtocol

    var otpPublisher: Deferred<AnyPublisher<Void, Error>> {
        return Deferred {
            Future { promise in
                guard let otpData: OTPValidationRepresentable? = self.operative.dataBinding.get() else {
                    return promise(.failure(GenericErrorOTPErrorOutput("Ha ocurrido un error. Debe reintentar la operación.", .unknown, "")))
                }
                let skOperativeData: SKOnboardingOperativeData? = self.operative.dataBinding.get()
                guard let otpReference = skOperativeData?.otpReference, let otpValue = otpData?.magicPhrase, let sanKeyId = skOperativeData?.sanKeyId,
                      let deviceAlias = skOperativeData?.alias else {
                          return promise(.failure(GenericErrorOTPErrorOutput("Ha ocurrido un error. Debe reintentar la operación.", .unknown, "")))
                      }
                self.getLocationInfo { [weak self] (latitude, longitude) in
                    guard let self = self else { return }
                    var deviceLatitude = ""
                    var deviceLongitude = ""
                    if let lat = latitude, let lon = longitude {
                        deviceLatitude = "\(lat)"
                        deviceLongitude = "\(lon)"
                    }
                    self.registerConfirmationPublisher(otpReference: otpReference, otpValue: otpValue, sanKeyId: sanKeyId, deviceAlias: deviceAlias, lat: deviceLatitude, long: deviceLongitude)
                    .subscribe(on: Schedulers.global)
                    .receive(on: Schedulers.main)
                    .sink { [unowned self] completion in
                        if case .failure(let error) = completion {
                            guard let errorType = error as? SantanderKeyError else {
                                promise(.failure(error))
                                return
                            }
                            switch errorType.getAction() {
                            case .goToPG:
                                let skError = GenericErrorOTPErrorOutput(errorType.getLocalizedDescription(), .otpRevoked, "")
                                promise(.failure(skError))
                            case .goToOperative:
                                let skError = GenericErrorOTPErrorOutput(errorType.getLocalizedDescription(), .otherError(errorDesc: ""), "")
                                promise(.failure(skError))
                            case .stay:
                                let skError = GenericErrorOTPErrorOutput(errorType.getLocalizedDescription(), .unknown, "")
                                promise(.failure(skError))
                            }
                        }
                    } receiveValue: { [unowned self] result in
                        self.saveDeviceId(deviceId: result.deviceId ?? "")
                        self.saveSankeyId(sanKeyId)
                        promise(.success(()))
                    }
                    .store(in: &self.anySubscriptions)
                }
            }.eraseToAnyPublisher()
        }
    }

    public init(operative: SKOperative, dependencies: SKOperativeExternalDependenciesResolver) {
        self.operative = operative
        self.dependencies = dependencies
        self.coordinator = dependencies.resolve()
        self.compilation = dependencies.resolve()
    }
}

extension SKOperativeOTPStrategy {
    var registerConfirmationUseCase: SantanderKeyRegisterConfirmationUseCase {
        dependencies.resolve()
    }
    var locationManager: LocationPermissionsManagerProtocol {
        dependencies.resolve()
    }
    func registerConfirmationPublisher(otpReference: String, otpValue: String, sanKeyId: String, deviceAlias: String, lat: String, long: String) -> AnyPublisher<SantanderKeyRegisterConfirmationResultRepresentable, Error> {
        return registerConfirmationUseCase.registerConfirmation(otpReference: otpReference, otpValue: otpValue, sanKeyId: sanKeyId, deviceAlias: deviceAlias, lat: lat, long: long)
    }
    
    func getLocationInfo(completion: @escaping ((_ latitude: Double?, _ longitude: Double?) -> Void)) {
        guard locationManager.isLocationAccessEnabled() else {
            completion(nil, nil)
            return
        }
        return locationManager.getCurrentLocation(completion: completion)
    }
    
    func saveDeviceId(deviceId: String) {
        let deviceIdQuery = KeychainQuery(service: compilation.service,
                                          account: compilation.keychainSantanderKey.deviceId,
                                          accessGroup: compilation.sharedTokenAccessGroup,
                                          data: deviceId as NSCoding)
        do {
            try KeychainWrapper().save(query: deviceIdQuery)
        } catch {
            return
        }
    }
    
    func saveSankeyId(_ sanKeyId: String) {
        let sankeyIdQuery = KeychainQuery(service: compilation.service,
                                                account: compilation.keychainSantanderKey.sankeyId,
                                                accessGroup: compilation.sharedTokenAccessGroup,
                                                data: sanKeyId as NSCoding)
        do {
            try KeychainWrapper().save(query: sankeyIdQuery)
        } catch {
            return
        }
    }
}
