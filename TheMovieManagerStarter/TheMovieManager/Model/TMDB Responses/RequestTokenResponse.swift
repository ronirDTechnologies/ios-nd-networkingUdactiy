//
//  RequestTokenResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct RequestTokenResponse: Codable {
    
    
    var success: Bool
    var tokenExpirationDate: String
    var requestTokenRecieved: String
    
  
    
    private enum CodingKeys: String, CodingKey {
        case success
        case tokenExpirationDate = "expires_at"
        case requestTokenRecieved = "request_token"
    }
    
    
    
}

