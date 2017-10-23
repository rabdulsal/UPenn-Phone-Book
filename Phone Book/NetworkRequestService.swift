//
//  NetworkRequestService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/15/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import Alamofire

class NetworkRequestService {
    
    let phonebookAPIStr = "http://uphsnettest2012.uphs.upenn.edu/ADRS"
    let searchAPIStr = "/api/phonebook/search"
    let profileAPIStr = "/api/phonebook/profile"
    var authToken: String? {
        return AuthenticationService.authToken
    }
    var headers: HTTPHeaders {
        guard let token = self.authToken else { return [:] }
        return [ "Authorization" : "Bearer " + token ]
    }
    
    func makeLoginRequest(email: String, password: String, completion: @escaping (DataResponse<Any>)->Void) {
        
        guard let url = URL(string: self.phonebookAPIStr + "/oauth/token") else {
            // TODO: Return an Error about the URI
            return
        }
        
        let parameters: Parameters = [
            "grant_type" : "password",
            "username" : email,
            "password" : password
        ]
        
        // Make Request for JWT
        let jwtRequest = Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
        jwtRequest.responseJSON { (response) in
            completion(response)
        }
    }
    
    func makeContactsListSearchRequest(with queryString: String, completion: @escaping (DataResponse<Any>)->Void) {
        guard let encodedString = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let phoneSearchStr = self.phonebookAPIStr + self.searchAPIStr
        let requestURI = phoneSearchStr+"/"+encodedString
        let searchRequest = Alamofire.request(requestURI, headers: self.headers)
        searchRequest.responseJSON(completionHandler: { (response) in
            completion(response)
        })
    }
    
    func makeContactSearchRequest(with profileID: String, completion: @escaping (DataResponse<Any>)->Void) {
        let profileSearchStr = self.phonebookAPIStr + self.profileAPIStr
        let requestURI = profileSearchStr+"/"+profileID
        let searchRequest = Alamofire.request(requestURI, headers: self.headers)
        searchRequest.responseJSON(completionHandler: { (response) in
            completion(response)
        })
    }
}
