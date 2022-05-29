struct SignatureFilled<S: SignatureParamater> {
    let signature: S
}

extension SignatureFilled: OperativeParameter {}
