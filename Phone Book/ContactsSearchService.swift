//
//  ContactsSearchService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/16/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class ContactsSearchService {
    
    var requestService = NetworkRequestService()
    
    func makeContactsListSearchRequest(with queryString: String, completion: @escaping (Array<Contact>, Bool, Error?)->Void) {
        
        requestService.makeContactsListSearchRequest(with: queryString) { (response) in
            
            var retrievedContacts = Array<Contact>()
            var hasExcessContacts = false
            
            if let httpError = response.result.error {
                completion([],hasExcessContacts,httpError)
            } else {
                guard let statusCode = response.response?.statusCode else {
                    completion(retrievedContacts,hasExcessContacts,nil) // TODO: Create Error object to bubble up
                    return
                }
                
                if statusCode == 200 {
                    let j = response.result.value as? Dictionary<String,Any>
                    
                    // Handle Search Results
                    if let resultsArry = j?["searchResults"] as? Array<Dictionary<String,Any>> {
                        for resultDict in resultsArry {
                            // Make Contacts
                            let contact = Contact(userDict: resultDict)
                            retrievedContacts.append(contact)
                        }
                    }
                    
                    // Update hasExcessContacts
                    hasExcessContacts = self.processReturnedResults(response: j!)
                }
            }
            completion(retrievedContacts, hasExcessContacts, response.result.error)
        }
    }
    
    func makeContactSearchRequest(with profileID: String, completion: @escaping (Contact?, Error?)->Void) {
        
        requestService.makeContactSearchRequest(with: profileID) { (response) in
            
            if let httpError = response.result.error {
                completion(nil,httpError)
            } else {
                guard let statusCode = response.response?.statusCode else {
                    // TODO: Create Error object to bubble up
                    return
                }
                
                if statusCode == 200 {
                    if let dict = response.result.value as? Dictionary<String,Any> {
                        let contact = Contact(userDict: dict)
                        completion(contact,nil)
                        return
                    }
                }
            }
        }
    }
}

fileprivate extension ContactsSearchService {
    
    func processReturnedResults(response: Dictionary<String,Any>) -> Bool {
        guard
            let returnedCount = response["returnedSearchResultsCount"] as? Int,
            let totalCount = response["totalSearchResultsCount"] as? Int
            else {
                return false
        }
        
        if returnedCount == totalCount {
            return false
        }
        print("Displaying the first \(returnedCount) matching contacts. You may need to narrow your search.")
        return true
    }
}
