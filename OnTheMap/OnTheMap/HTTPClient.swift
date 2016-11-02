//
//  HTTPClient.swift
//  OnTheMap
//
//  Created by Ryan Harri on 2016-10-25.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/// A singleton class that is used to perform HTTP requests using the Foundation's URLSession API.
final class HTTPClient {
    
    /* Rob (2014) Singleton in Swift
     Available at: http://stackoverflow.com/a/26743597 (Accessed: 25 Oct 2016) */
    
    // MARK: Instance Properties
    
    /// A shared URLSession.
    private var session = URLSession.shared
    
    // MARK: Type Properties

    /// A shared instance of the HTTPClient.
    static let shared = HTTPClient()
    
    /// Constants that specify the types of HTTP methods supported by this client.
    enum Method {
        case get
        case post
        case delete
        case put
    }
    
    /// Constants that specify HTTP status codes.
    enum StatusCode: Int {
        case ok = 200
        case endOfSuccessRange = 299
    }
    
    /// Constants that specify the types of errors that can occur while using the HTTPClient.
    enum ClientError: Error {
        case invalidURL
        case noHTTPBody
        case requestNotSuccessful(Int)
        case noStatusCode
        case noData
    }
    
    // MARK: Type Identifiers
    
    /**
     
        - Parameters:
            - response: The response from the HTTP request.
    */
    typealias ResponseHandler = (_ response: HTTPClientResponse) -> Void
    
    // MARK: Initializers
    
    private init() {
        // Do not allow this class to be directly instantiated
    }
    
    // MARK: Instance Methods

    /**
     
        Performs specified HTTP method using the provided URL, JSON body, and HTTP headers.
     
        - Parameters:
            - method: The HTTP method.
            - url: The URL for the HTTP request.
            - httpBody: The body of the HTTP request. This is optional.
            - headers: The headers for the HTTP request. This is optional.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    func perform(_ method: Method, with url: String, andHTTPBody httpBody: Data? = nil, andHTTPHeaders headers: [HTTPHeader]? = nil, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        switch method {
        case .get:
            return get(with: url, andHTTPHeaders: headers, responseHandler: responseHandler)
        case .post:
            return post(with: url, andHTTPHeaders: headers, andHTTPBody: httpBody, responseHandler: responseHandler)
        case .delete:
            return delete(with: url, responseHandler: responseHandler)
        case .put:
            return put(with: url, andHTTPHeaders: headers, andHTTPBody: httpBody, responseHandler: responseHandler)
        }
    }
    
    /**
     
        Performs a HTTP GET request using the provided URL.
     
        - Parameters:
            - url: The URL for the HTTP request.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    private func get(with url: String, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        
        /* Hamish (2016) Closure use of non-escaping parameter may allow it to escape
         Available at: http://stackoverflow.com/a/38990967 (Accessed: 25 Oct 2016) */
        
        // Is the URL valid?
        guard let url = URL(string: url) else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.invalidURL))
            return nil
        }
        
        // Peform the data task
        let task = session.dataTask(with: url) { (data, response, error) in
            // Was there an error?
            guard (error == nil) else {
                responseHandler(HTTPClientResponse(data: nil, error: error))
                return
            }
            
            // 200 OK?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= StatusCode.ok.rawValue && statusCode <= StatusCode.endOfSuccessRange.rawValue else {
                    
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    responseHandler(HTTPClientResponse(data: nil, error: ClientError.requestNotSuccessful(statusCode)))
                } else {
                    responseHandler(HTTPClientResponse(data: nil, error: ClientError.noStatusCode))
                }
                return
            }
            
            // Is there data?
            guard let data = data as NSData? else {
                responseHandler(HTTPClientResponse(data: nil, error: ClientError.noData))
                return
            }
            
            responseHandler(HTTPClientResponse(data: data, error: nil))
        }
        
        task.resume()
        
        return task
    }

    /**
     
        Performs a HTTP GET request using the provided URL and HTTP headers.
     
        - Parameters:
            - url: The URL for the HTTP request.
            - headers: The headers for the HTTP request. This is optional.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    private func get(with url: String, andHTTPHeaders headers: [HTTPHeader]? = nil, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        // Is the URL valid?
        guard let url = URL(string: url) else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.invalidURL))
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = Constants.Method.get
        
        // Add any HTTP headers provided
        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        // Perform the data task
        let task = session.dataTask(with: request) { (data, response, error) in
            // Was there an error?
            guard (error == nil) else {
                responseHandler(HTTPClientResponse(data: nil, error: error))
                return
            }
            
            // 200 OK?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= StatusCode.ok.rawValue && statusCode <= StatusCode.endOfSuccessRange.rawValue else {
                    
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        responseHandler(HTTPClientResponse(data: nil, error: ClientError.requestNotSuccessful(statusCode)))
                    } else {
                        responseHandler(HTTPClientResponse(data: nil, error: ClientError.noStatusCode))
                    }
                    return
            }
            
            // Is there data?
            guard let data = data as NSData? else {
                responseHandler(HTTPClientResponse(data: nil, error: ClientError.noData))
                return
            }
            
            responseHandler(HTTPClientResponse(data: data, error: nil))
        }
        
        task.resume()
        
        return task
    }
    
    /**
     
        Performs a HTTP POST request using the provided URL and HTTP body.
     
        - Parameters:
            - url: The URL for the HTTP request.
            - httpBody: The body of the HTTP request.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    private func post(with url: String, andHTTPBody httpBody: Data?, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        // Is the URL valid?
        guard let url = URL(string: url) else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.invalidURL))
            return nil
        }
        
        // Is there a HTTP body?
        guard let httpBody = httpBody else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.noHTTPBody))
            return nil
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = Constants.Method.post
        request.addValue(Constants.Header.Value.applicationJSON, forHTTPHeaderField: Constants.Header.Name.accept)
        request.addValue(Constants.Header.Value.applicationJSON, forHTTPHeaderField: Constants.Header.Name.contentType)
        request.httpBody = httpBody
        
        // Perform the data task
        let task = session.dataTask(with: request) { (data, response, error) in
            // Was there an error?
            guard (error == nil) else {
                responseHandler(HTTPClientResponse(data: nil, error: error))
                return
            }
            
            // 200 OK?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= StatusCode.ok.rawValue && statusCode <= StatusCode.endOfSuccessRange.rawValue else {
                    
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    responseHandler(HTTPClientResponse(data: nil, error: ClientError.requestNotSuccessful(statusCode)))
                } else {
                    responseHandler(HTTPClientResponse(data: nil, error: ClientError.noStatusCode))
                }
                return
            }
            
            // Is there data?
            guard let data = data as NSData? else {
                responseHandler(HTTPClientResponse(data: nil, error: ClientError.noData))
                return
            }
            
            responseHandler(HTTPClientResponse(data: data, error: nil))
        }
        
        task.resume()
        
        return task
    }
    
    /**
     
        Performs a HTTP POST request using the provided URL, HTTP headers and HTTP body.
     
        - Parameters:
            - url: The URL for the HTTP request.
            - headers: The headers for the HTTP request. This is optional.
            - httpBody: The body of the HTTP request.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    private func post(with url: String, andHTTPHeaders headers: [HTTPHeader]? = nil, andHTTPBody httpBody: Data?, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        // Is the URL valid?
        guard let url = URL(string: url) else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.invalidURL))
            return nil
        }
        
        // Is there a HTTP body?
        guard let httpBody = httpBody else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.noHTTPBody))
            return nil
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = Constants.Method.post
        request.httpBody = httpBody
        
        // Add any HTTP headers provided
        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        // Perform the data task
        let task = session.dataTask(with: request) { (data, response, error) in
            // Was there an error?
            guard (error == nil) else {
                responseHandler(HTTPClientResponse(data: nil, error: error))
                return
            }
            
            // 200 OK?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= StatusCode.ok.rawValue && statusCode <= StatusCode.endOfSuccessRange.rawValue else {
                    
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        responseHandler(HTTPClientResponse(data: nil, error: ClientError.requestNotSuccessful(statusCode)))
                    } else {
                        responseHandler(HTTPClientResponse(data: nil, error: ClientError.noStatusCode))
                    }
                    return
            }
            
            // Is there data?
            guard let data = data as NSData? else {
                responseHandler(HTTPClientResponse(data: nil, error: ClientError.noData))
                return
            }
            
            responseHandler(HTTPClientResponse(data: data, error: nil))
        }
        
        task.resume()
        
        return task
    }

    /**
     
        Performs a HTTP PUT request using the provided URL, HTTP headers and HTTP body.
     
        - Parameters:
            - url: The URL for the HTTP request.
            - headers: The headers for the HTTP request. This is optional.
            - httpBody: The body of the HTTP request.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    private func put(with url: String, andHTTPHeaders headers: [HTTPHeader]? = nil, andHTTPBody httpBody: Data?, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        // Is the URL valid?
        guard let url = URL(string: url) else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.invalidURL))
            return nil
        }
        
        // Is there a HTTP body?
        guard let httpBody = httpBody else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.noHTTPBody))
            return nil
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = Constants.Method.put
        request.httpBody = httpBody
        
        
        // Add any HTTP headers provided
        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        // Perform the data task
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                responseHandler(HTTPClientResponse(data: nil, error: error))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= StatusCode.ok.rawValue && statusCode <= StatusCode.endOfSuccessRange.rawValue else {
                    
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        responseHandler(HTTPClientResponse(data: nil, error: ClientError.requestNotSuccessful(statusCode)))
                    } else {
                        responseHandler(HTTPClientResponse(data: nil, error: ClientError.noStatusCode))
                    }
                    return
            }
            
            guard let data = data as NSData? else {
                responseHandler(HTTPClientResponse(data: nil, error: ClientError.noData))
                return
            }
            
            responseHandler(HTTPClientResponse(data: data, error: nil))
        }
        
        task.resume()
        
        return task
    }
    
    /**
     
        Performs a HTTP DELETE request using the provided URL.
     
        - Parameters:
            - url: The URL for the HTTP request.
            - responseHandler: Handler that is invoked to handle the outcome of the HTTP request.
     
    */
    private func delete(with url: String, responseHandler: @escaping ResponseHandler) -> URLSessionDataTask? {
        // Is the URL valid?
        guard let url = URL(string: url) else {
            responseHandler(HTTPClientResponse(data: nil, error: ClientError.invalidURL))
            return nil
        }
        
        // Get the XSRF cookie from the HTTPCookieStorage shared instance
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Constants.xsrfTokenCookieName {
                xsrfCookie = cookie
            }
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = Constants.Method.delete
        
        // Set the HTTP header using the XSRF cookie
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Constants.Header.Name.xsrfToken)
        }
        
        // Perform the data task
        let task = session.dataTask(with: request) { (data, response, error) in
            // Was there an error?
            guard (error == nil) else {
                responseHandler(HTTPClientResponse(data: nil, error: error))
                return
            }
            
            // 200 OK?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= StatusCode.ok.rawValue && statusCode <= StatusCode.endOfSuccessRange.rawValue else {
                    
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    responseHandler(HTTPClientResponse(data: nil, error: ClientError.requestNotSuccessful(statusCode)))
                } else {
                    responseHandler(HTTPClientResponse(data: nil, error: ClientError.noStatusCode))
                }
                return
            }
            
            // Is there data?
            guard let data = data as NSData? else {
                responseHandler(HTTPClientResponse(data: nil, error: ClientError.noData))
                return
            }
            
            responseHandler(HTTPClientResponse(data: data, error: nil))
        }
        
        task.resume()
        
        return task
    }
}
