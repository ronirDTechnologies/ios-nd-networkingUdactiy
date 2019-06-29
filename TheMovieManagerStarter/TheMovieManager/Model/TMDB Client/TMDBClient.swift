//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "1d7e083e248e96da6dd1febb2cef955d"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getRequestToken
        case createSessionId
        case login
        case webAuth
        case logOut
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            case .createSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .webAuth: return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
            case .logOut: return Endpoints.base + "/authenticate/session" + Endpoints.apiKeyParam
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    class func getRequestToken(completion: @escaping (Bool,Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) {data, response, error in
            guard let data = data else{
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let successStatus = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = successStatus.requestTokenRecieved
                completion(successStatus.success,error)
            }
            catch{
                completion(false, error)
            }
        }
        task.resume()
    }
    class func login(userName: String, password: String ,completion: @escaping (Bool, Error?) -> Void){
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LoginRequest(username: userName, password: password, requestToken: Auth.requestToken)
        request.httpBody = try!JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request){(data,response,error) in
            guard let data = data else {
                completion(false, error)
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = responseObject.requestTokenRecieved
                completion(true, nil)
            }
            catch{
                completion(false,error)
            }
          
        }
         task.resume()
    }
    
    class func logOut (completion:@escaping () -> Void){
        var request = URLRequest(url: Endpoints.logOut.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LogoutRequest(sessionId: Auth.sessionId)
        request.httpBody = try!JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request){data,response,error in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
            }
        task.resume()
    }
    
    class func getRequestSessionId(completion: @escaping (Bool,Error?) -> Void){
       
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostSession(requestToken: Auth.requestToken)
        request.httpBody  = try!JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) {data,response,error in
            guard let data = data else{
                completion(false,error)
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(SessionResponse.self, from: data)
                Auth.sessionId = responseObject.sessionId
                completion(true,nil)
            }
            catch{
                completion(false,error)
            }
        }
        
        task.resume()
    
    }
    
}
