import Foundation
import CoreFoundationLib


class GetFileDataUseCase: UseCase<GetFileDataUseCaseInput, GetFileDataUseCaseOkOutput, GetFileDataUseCaseErrorOutput> {
    
    override public func executeUseCase(requestValues: GetFileDataUseCaseInput) throws -> UseCaseResponse<GetFileDataUseCaseOkOutput, GetFileDataUseCaseErrorOutput> {
//        guard let url = requestValues.url else {
//            return UseCaseResponse.ok(GetFileDataUseCaseOkOutput(data: nil))
//        }
//
//        let (data, _, error) = URLSession(configuration: .default).synchronousDataTask(with: url)
//
//        guard error == nil else {
//            return UseCaseResponse.error(GetFileDataUseCaseErrorOutput(error.debugDescription))
//        }
//
//        return UseCaseResponse.ok(GetFileDataUseCaseOkOutput(data: data))
        
        return UseCaseResponse.error(GetFileDataUseCaseErrorOutput(nil))
    }
}

struct GetFileDataUseCaseInput {
    let url: URL?
}

struct GetFileDataUseCaseOkOutput {
    let data: Data?
}

class GetFileDataUseCaseErrorOutput: StringErrorOutput {}
