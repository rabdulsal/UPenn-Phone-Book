//
//  AutheticationService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/15/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class AuthenticationService {
    
    private var isAuthenticated = false
    static var authToken: String?
    
//    func makeLoginRequest(email: String, password: String, completion: @escaping (Bool, Error?)->Void?) {
//        
//        var error: Error?=nil
//        
//        NetworkRequestService.makeLoginRequest(email: email, password: password) { (response) -> Void in
//            
//            if let httpError = response.result.error {
//                //                print("Error:", httpError.localizedDescription) TODO: Move to VC Alert
//                error = httpError
//            } else {
//                let statusCode = (response.response?.statusCode)!
//                if statusCode == 200 {
//                    let json = response.result.value as? Dictionary<String,Any>
//                    if let token = json?["access_token"] {
//                        self.authToken = token as! String // TODO: Store in a separate KeyChain-like object
//                        self.isAuthenticated = true
//                        
//                        // Make Request to Search Endpoint passing JWT in header
////                        let headers: HTTPHeaders = [ "Authorization" : "Bearer" + self.authToken! ]
////                        let searchRequest = Alamofire.request(searchURI+"/jones", headers: headers)
////                        searchRequest.responseJSON(completionHandler: { (response) in
////
////                            if let httpError = response.result.error {
////                                print("Error:", httpError.localizedDescription)
////                            } else {
////                                let statusCode = (response.response?.statusCode)!
////                                if statusCode == 200 {
////                                    let j = response.result.value as? Dictionary<String,Any>
////                                    if let resultsArry = j?["searchResults"] as? Array<Dictionary<String,Any>> {
////                                        for resultDict in resultsArry {
////
////                                            // Make Users
////                                            let user = Contact(userDict: resultDict)
////                                            self.users.append(user)
////
////                                        }
////                                    }
////                                }
////                            }
////                        })
//                    }
//                }
//            }
//        }
//        completion(self.isAuthenticated, error)
//    }
    // Need method for storing/retrieving JWT Token
}
