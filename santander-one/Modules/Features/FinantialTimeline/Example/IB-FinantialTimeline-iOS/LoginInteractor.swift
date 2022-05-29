//
//  LoginInteractor.swift
//  IB-FinantialTimeline-iOS
//
//  Created by Jose Ignacio de Juan Díaz on 12/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
import UIKit

enum LoginError: Error {
    case error
}


class LoginInteractor {
                    
    func login(user: String, password: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        let url = URL(string: "https://starterapp-login.develop.blue4sky.com/login/auth")!
        let params = ["userName": user, "userPass": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                var token = response.allHeaderFields["Authorization"] as? String {
                if let range = token.range(of: "Bearer ") {
                    token.removeSubrange(range)
                }
                completion(.success(token))
            } else {
                completion(.failure(LoginError.error))
            }
            
            }.resume()
    }
}

