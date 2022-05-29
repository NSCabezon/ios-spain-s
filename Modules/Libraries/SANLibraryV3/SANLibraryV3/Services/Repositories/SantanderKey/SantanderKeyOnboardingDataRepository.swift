import CoreDomain
import CoreFoundationLib
import Foundation
import OpenCombine
import OpenCombineDispatch
import SANServicesLibrary
import SANSpainLibrary
import SANLibraryV3

struct SantanderKeyOnboardingDataRepository: SantanderKeyOnboardingRepository {
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let configurationRepository: ConfigurationRepository

    public func getClientStatusReactive(santanderKeyID: String?, deviceId: String?) -> AnyPublisher<SantanderKeyStatusRepresentable, Error> {
        return Future<SantanderKeyStatusRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let status = try getClientStatus(santanderKeyID: santanderKeyID, deviceId: deviceId)
                    promise(.success(status))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func getClientStatus(santanderKeyID: String?, deviceId: String?) throws -> SantanderKeyStatusRepresentable {
        guard let authToken: AuthenticationTokenDto = self.storage.get() else {
            throw SantanderKeyError.genericError()
        }
        var query = [String: String]()
        if let sanKeyId = santanderKeyID {
            query = ["sanKeyId": sanKeyId]
        } else if let devId = deviceId {
            query = ["deviceId": devId]
        }
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json"]
        let request = RestSpainRequest(
            method: "GET",
            serviceName: "status",
            url: url + "/api/v1/san-keys/status",
            headers: headers,
            query: query,
            body: "",
            encoding: .urlEncoded
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case let .success(resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyStatusDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return result
        case let .failure(error):
            throw error
        }
    }
    
    public func updateTokenPushReactive(input: SantanderKeyUpdateTokenPushInput, signature: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let status = try updateTokenPush(input: input, signature: signature)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func updateTokenPush(input: SantanderKeyUpdateTokenPushInput, signature: String) throws -> Void {
        guard let authToken: AuthenticationTokenDto = self.storage.get() else {
            throw RepositoryError.unknown
        }
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json",
                       "Signature": signature]
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "device-info",
            url: url + "/api/v1/san-keys/device-info",
            headers: headers,
            query: "",
            body: input,
            encoding: .json
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case .success(let resp):
            return
        case .failure(let error):
            throw error
        }
    }

    public func automaticRegisterReactive(deviceId: String, tokenPush: String, publicKey: String, signature: String) -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error> {
        return Future<SantanderKeyAutomaticRegisterResultRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let sankeyId = try automaticRegister(deviceId: deviceId, tokenPush: tokenPush, publicKey: publicKey, signature: signature)
                    promise(.success(sankeyId))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func automaticRegister(deviceId: String, tokenPush: String, publicKey: String, signature: String) throws -> SantanderKeyAutomaticRegisterResultRepresentable {
        guard let authToken: AuthenticationTokenDto = self.storage.get()
        else {
            throw SantanderKeyError.genericError()
        }
        let body = SantanderKeyAutomaticRegisterBodyDTO(publicKey: publicKey, deviceId: deviceId, tokenPush: tokenPush)
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json",
                       "Signature": signature]
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "automatic",
            url: url + "/api/v1/san-keys/automatic",
            headers: headers,
            query: "",
            body: body,
            encoding: .json
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case let .success(resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyAutomaticRegisterResultDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return result
        case let .failure(error):
            throw error
        }
    }

    public func registerGetAuthMethodReactive() -> AnyPublisher<(SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable), Error> {
        return Future<(SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable), Error> { promise in
            do {
                let method = try registerGetAuthMethod()
                promise(.success(method))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    public func registerGetAuthMethod() throws -> (SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable) {

        guard let authToken: AuthenticationTokenDto = self.storage.get() else {
            throw SantanderKeyError.genericError()
        }
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json"]
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "step-one",
            url: url + "/api/v1/san-keys/step-one",
            headers: headers,
            query: ""
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case let .success(resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyRegisterAuthMethodResultDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return (result, result)
        case let .failure(error):
            throw error
        }
    }

    public func registerValidationWithPINReactive(sanKeyId: String, cardPan: String, cardType: String, pin: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        return Future<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let otpReference = try registerValidationWithPIN(sanKeyId: sanKeyId, cardPan: cardPan, cardType: cardType, pin: pin)
                    promise(.success(otpReference))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func registerValidationWithPIN(sanKeyId: String, cardPan: String, cardType: String, pin: String) throws -> (SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable) {
        guard let authToken: AuthenticationTokenDto = self.storage.get()
        else {
            throw SantanderKeyError.genericError()
        }
        let body = ["sanKeyId": sanKeyId,
                    "cardPan": cardPan,
                    "cardType": cardType,
                    "pin": pin]
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json"]
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "step-two",
            url: url + "/api/v1/san-keys/step-two",
            headers: headers,
            query: "",
            body: body,
            encoding: .json
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case let .success(resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyRegisterValidationResultDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return (result, result)
        case let .failure(error):
            throw error
        }
    }

    public func registerValidationWithPositionsReactive(sanKeyId: String, positions: String, valuePositions: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        return Future<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let otpReference = try registerValidationWithPositions(sanKeyId: sanKeyId, positions: positions, valuePositions: valuePositions)
                    promise(.success(otpReference))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func registerValidationWithPositions(sanKeyId: String, positions: String, valuePositions: String) throws -> (SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable) {
        guard let authToken: AuthenticationTokenDto = self.storage.get()
        else {
            throw SantanderKeyError.genericError()
        }
        let body = ["sanKeyId": sanKeyId,
                    "positions": positions.replacingOccurrences(of: " ", with: "").map{ "\($0)" }.joined(separator: " "),
                    "valuePositions": valuePositions.replacingOccurrences(of: " ", with: "").map{ "\($0)" }.joined(separator: " ")]
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json"]
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "step-two",
            url: url + "/api/v1/san-keys/step-two",
            headers: headers,
            query: "",
            body: body,
            encoding: .json
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case let .success(resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyRegisterValidationResultDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return (result, result)
        case let .failure(error):
            throw error
        }
    }

    public func registerConfirmationReactive(input: SantanderKeyRegisterConfirmationInput, signature: String) -> AnyPublisher<SantanderKeyRegisterConfirmationResultRepresentable, Error> {
        return Future<SantanderKeyRegisterConfirmationResultRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let deviceId = try registerConfirmation(input: input, signature: signature)
                    promise(.success(deviceId))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func registerConfirmation(input: SantanderKeyRegisterConfirmationInput, signature: String) throws -> SantanderKeyRegisterConfirmationResultRepresentable {
        guard let authToken: AuthenticationTokenDto = self.storage.get()
        else {
            throw SantanderKeyError.genericError()
        }

        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json",
                       "Signature": signature]
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "step-three",
            url: url + "/api/v1/san-keys/step-three",
            headers: headers,
            query: "",
            body: input,
            encoding: .json
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case let .success(resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyRegisterConfirmationResultDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return result
        case let .failure(error):
            throw error
        }
    }
    
    public func getSantanderKeyDetailReactive(sanKeyId: String?) -> AnyPublisher<SantanderKeyDetailResultRepresentable, Error> {
        return Future<SantanderKeyDetailResultRepresentable, Error> { promise in
            Async(queue: .global(qos: .background)) {
                do {
                    let detail = try getSantanderKeyDetail(sanKeyId: sanKeyId)
                    promise(.success(detail))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getSantanderKeyDetail(sanKeyId: String?) throws -> SantanderKeyDetailResultRepresentable {
        guard let authToken: AuthenticationTokenDto = self.storage.get()
        else {
            throw SantanderKeyError.genericError()
        }
        var query = [String: String]()
        if let sanKeyId = sanKeyId {
            query["sanKeyId"] = sanKeyId
        }
        let url = self.environmentProvider.getEnvironment().santanderKeyUrl
        let headers = ["Content-Type": "application/json"]
        let request = RestSpainRequest(
            method: "GET",
            serviceName: "detail",
            url: url + "/api/v1/san-keys/detail",
            headers: headers,
            query: query,
            body: "",
            encoding: .urlEncoded
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls)
            ],
            responseInterceptors: [
                SantanderKeyResponseInterceptor()
            ]
        )
        switch response {
        case .success(let resp):
            guard let result = try? JSONDecoder().decode(SantanderKeyDetailResultDTO.self, from: resp.data) else {
                throw SantanderKeyError.genericError()
            }
            return result
        case .failure(let error):
            throw SantanderKeyError.genericError()
        }
    }
}

private extension SantanderKeyOnboardingDataRepository {
    struct SantanderKeyResponseInterceptor: NetworkResponseInterceptor {
        struct SKGenericErrorResponse: Decodable {
            let moreInformation: String
            let httpMessage: String
        }

        func interceptResponse(_ response: NetworkResponse) -> Result<NetworkResponse, Error> {
            if let result = try? JSONDecoder().decode(SantanderKeyErrorResponse.self, from: response.data) {
                let currentLocale = Locale.appLocale.identifier.prefix(2).lowercased() ?? "es"
                let httpCode = Int(response.status)
                let code = result.code
                let descriptions: [String: String] = result.descriptions
                let localizedDesc = ["localizedDescription": (descriptions[currentLocale] ?? descriptions["es"]) ?? localized("generic_error_txt")]
                let sKerror = SantanderKeyError(httpCode: httpCode,
                                                code: code,
                                                descriptions: localizedDesc)
                return .failure(sKerror)
            } else if let result = try? JSONDecoder().decode(SKGenericErrorResponse.self, from: response.data) {
                return .failure(SantanderKeyError.genericError())
            }
            return .success(response)
        }
    }
}
