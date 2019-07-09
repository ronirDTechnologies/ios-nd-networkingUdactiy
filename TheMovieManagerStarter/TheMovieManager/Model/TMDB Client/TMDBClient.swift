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
        case getFavorites
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/movie/favorites" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
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
    class func getFavorites(completion: @escaping ([Movie], Error?) -> Void){
        print("GET FAVORITES URL ==> \(Endpoints.getFavorites.url)")
        taskForGETRequest(url: Endpoints.getFavorites.url, responseType: MovieResults.self) {
            (response,error) in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response.results, nil)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
            }
        }
        
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        // Refactored version of Network request
        taskForGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) {
            (response,error) in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response.results, nil)
                }
                
            }
            else{
                DispatchQueue.main.async{
                    completion([],error)
                }
                
            }
        }
        
    /*
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
        task.resume()*/
    }
    
    class func getRequestToken(completion: @escaping (Bool,Error?) -> Void) {
        // Refactored getRequest
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) {(response,error) in
            if let response = response {
                Auth.requestToken = response.requestTokenRecieved
                DispatchQueue.main.async {
                completion(true,nil)
                }
                
            }
            else{
                DispatchQueue.main.async {
                completion(false,error)
                }
                
            }
        }
        /*
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
        task.resume()*/
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
    class func login(userName: String, password: String ,completion: @escaping (Bool, Error?) -> Void){
        let loginData = LoginRequest(username: userName, password: password, requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: loginData
        ){(response,error) in
            if let response = response{
                    Auth.requestToken = response.requestTokenRecieved
                DispatchQueue.main.async {
                completion(true, nil)
                }
                
            }
            else
            {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                
            }
        }}
        
        /* var request = URLRequest(url: Endpoints.login.url)
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
        task.resume()*/
    
    class func getRequestSessionId(completion: @escaping (Bool,Error?) -> Void){
        let postSession = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: postSession) {(response,error) in
            if let response = response{
                Auth.sessionId = response.sessionId
                DispatchQueue.main.async {
                    completion(true,nil)
                }
                
            }
            else
            {   DispatchQueue.main.async {
                    completion(false,error)
                }
                
            }
            
            }
        
    }
        
        /*var request = URLRequest(url: Endpoints.createSessionId.url)
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
    */
    
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try!JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request){data,response,error in
            guard let data = data else{
                completion(nil,error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(responseType.self,from:data)
                completion(responseObject,nil)
            }
            catch{
                completion(nil,error)
            }
        }
        task.resume()
    }
    
        class func taskForGETRequest<ResponseType: Decodable>(url:URL, responseType: ResponseType.Type,completion: @escaping(ResponseType?,Error?)->Void){
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
            }
        }
        task.resume()
        
        }
        
    
    
}
