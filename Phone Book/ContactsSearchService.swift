//
//  ContactsSearchService.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salaam on 10/16/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation

class ContactsSearchService {
    
    var retrievedContacts = Array<Contact>()
    var requestService = NetworkRequestService()
    
    func makeContactsSearchRequest(with queryString: String, completion: @escaping (Array<Contact>, Error?)->Void) {
        
        requestService.makeContactSearchRequest(with: "") { (response) in
            //
            
            if let httpError = response.result.error {
                print("Error:", httpError.localizedDescription)
            } else {
                guard let statusCode = response.response?.statusCode else {
                    completion(self.retrievedContacts,nil) // TODO: Create Error object to bubble up
                    return
                }
                
                if statusCode == 200 {
                    let j = response.result.value as? Dictionary<String,Any>
                    if let resultsArry = j?["searchResults"] as? Array<Dictionary<String,Any>> {
                        for resultDict in resultsArry {
                            
                            // Make Contacts
                            let contact = Contact(userDict: resultDict)
                            self.retrievedContacts.append(contact)
                        }
                    }
                }
            }
            completion(self.retrievedContacts, response.result.error)
        }
    }
}
