//
//  Server.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-10.
//

import Foundation

enum APIError: Error, Decodable {
    case NotFound
    case Muted
    case Banned
    case HubNotFound
    case ChannelNotFound
    case MissingHubPermission(permission: HubPermission)
    case MissingChannelPermission(permission: ChannelPermission)
    case NotInHub
    case MemberNotFound
    case MessageNotFound
    case GroupNotFound
    case InvalidName
    case WsNotAuthenticated
    case TooBig
    case InvalidTime
    case InvalidText
    case AlreadyTyping
    case NotTyping
    case InternalError
    case Id
    case Http
    
    enum CodingKeys: String, CodingKey {
        case NotFound
        case Muted
        case Banned
        case HubNotFound
        case ChannelNotFound
        case MissingHubPermission
        case MissingChannelPermission
        case NotInHub
        case MemberNotFound
        case MessageNotFound
        case GroupNotFound
        case InvalidName
        case WsNotAuthenticated
        case TooBig
        case InvalidTime
        case InvalidText
        case AlreadyTyping
        case NotTyping
        case InternalError
        case Id
        case Http
    }
}

extension APIError {
    enum ApiErrorCodingError: Error {
        case decoding(String)
    }
    
    struct Perm<T: Codable>: Codable {
        let permission: T
    }
    
    struct HubPermMissing: Codable {
        let MissingHubPermission: Perm<HubPermission>
    }
    
    struct ChannelPermMissing: Codable {
        let MissingChannelPermission: Perm<ChannelPermission>
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let value = try? value.decode(HubPermMissing.self) {
            if let permission = HubPermission.init(rawValue: value.MissingHubPermission.permission.rawValue) {
                self = .MissingHubPermission(permission: permission)
                return
            } else {
                throw ApiErrorCodingError.decoding("Unknown permission.")
            }

        }
        if let value = try? value.decode(ChannelPermMissing.self) {
            if let permission = ChannelPermission.init(rawValue: value.MissingChannelPermission.permission.rawValue) {
                self = .MissingChannelPermission(permission: permission)
                return
            } else {
                throw ApiErrorCodingError.decoding("Unknown permission.")
            }
        }
        let label = try value.decode(String.self)
        switch label {
            case "NotFound": self = .NotFound
            case "Muted": self = .Muted
            case "Banned": self = .Banned
            case "HubNotFound": self = .HubNotFound
            case "ChannelNotFound": self = .ChannelNotFound
            case "NotInHub": self = .NotInHub
            case "MemberNotFound": self = .MemberNotFound
            case "MessageNotFound": self = .MessageNotFound
            case "GroupNotFound": self = .GroupNotFound
            case "InvalidName": self = .InvalidName
            case "WsNotAuthenticated": self = .WsNotAuthenticated
            case "TooBig": self = .TooBig
            case "InvalidTime": self = .InvalidTime
            case "InvalidText": self = .InvalidText
            case "AlreadyTyping": self = .AlreadyTyping
            case "NotTyping": self = .NotTyping
            case "InternalError": self = .InternalError
            case "Id": self = .Id
            case "Http": self = .Http
            default:
                throw ApiErrorCodingError.decoding("Unknown value.")
        }
        return
    }
}

struct HttpResponse<T: Decodable>: Decodable {
    let success: T?
    let error: APIError?
    
    init(success: T) {
        self.success = success
        self.error = nil
    }
    
    init(error: APIError) {
        self.error = error
        self.success = nil
    }
}

struct EmptyResponse: Error {}

class HttpClient {
    let base_url: String
    let user_id: UUIDString
    
    init(base_url: String, user_id: UUIDString) {
        self.base_url = base_url
        self.user_id = user_id
    }
    
    func url_request(endpoint: String, method: String) -> URLRequest {
        var url_requset = URLRequest.init(url: URL.init(string: base_url + endpoint)!)
        url_requset.httpMethod = method
        url_requset.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url_requset.addValue(self.user_id/*.uuidString*/, forHTTPHeaderField: "Authorization")
        return url_requset
    }
    
    public func websocket() -> URLSessionWebSocketTask {
        let url_session = URLSession.init(configuration: URLSessionConfiguration.default)
        let url_request = url_request(endpoint: "api/websocket", method: "GET")
        let websocket = url_session.webSocketTask(with: url_request)
        return websocket
    }
    
    public func request<R: Codable, T: Codable>(endpoint: String, method: String, data: R?) throws -> T {
        var url_requset = url_request(endpoint: endpoint, method: method)
        
        if data != nil {
            url_requset.httpBody = try JSONEncoder().encode(data)
        }
        
        var result: HttpResponse<T>?
        var httperror: Error? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: url_requset, completionHandler: { data, response, error in
            if let error = error {
                httperror = error
                result = nil
            } else {
                if let data = data {
                    do {
                        result = try JSONDecoder().decode(HttpResponse<T>.self, from: data)
                    } catch {
                        httperror = error
                        result = nil
                    }
                } else {
                    result = nil
                }
            }
            semaphore.signal()
        })
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let error = httperror {
            throw error
        }
        
        if let result = result?.success {
            return result
        } else {
            throw ClientError.EmptyResponse
        }
    }
    
    public func get<R: Codable, T: Codable>(endpoint: String, data: R) throws -> T {
        try self.request(endpoint: endpoint, method: "GET", data: data)
    }
    
    public func post<R: Codable, T: Codable>(endpoint: String, data: R) throws -> T {
        try self.request(endpoint: endpoint, method: "POST", data: data)
    }
    
    public func put<R: Codable, T: Codable>(endpoint: String, data: R) throws -> T {
        try self.request(endpoint: endpoint, method: "PUT", data: data)
    }
    
    public func delete<R: Codable, T: Codable>(endpoint: String, data: R) throws -> T {
        try self.request(endpoint: endpoint, method: "DELETE", data: data)
    }
    
    public func get<T: Codable>(endpoint: String) throws -> T {
        try self.request(endpoint: endpoint, method: "GET", data: Optional<UInt8>.none)
    }
    
    public func post<T: Codable>(endpoint: String) throws -> T {
        try self.request(endpoint: endpoint, method: "POST", data: Optional<UInt8>.none)
    }
    
    public func put<T: Codable>(endpoint: String) throws -> T {
        try self.request(endpoint: endpoint, method: "PUT", data: Optional<UInt8>.none)
    }
    
    public func delete<T: Codable>(endpoint: String) throws -> T {
        try self.request(endpoint: endpoint, method: "DELETE", data: Optional<UInt8>.none)
    }
}


struct HttpServerInfo: Codable {
    let version: String
}

struct HttpMemberStatus: Codable {
    let member: Bool
    let banned: Bool
    let muted: Bool
}

struct HttpSetPermission: Codable {
    let setting: PermissionSetting
}

struct HttpChannelUpdate: Codable {
    let name: String?
    let description: String?
}

struct HttpHubUpdate: Codable {
    let name: String?
    let description: String?
    let default_group: UUIDString?
}

struct HttpSendMessage: Codable {
    let message: String
}

struct HttpLastMessagesQuery: Codable {
    let max: UInt
}

struct HttpMesssagesBeforeQuery: Codable {
    let to: UUIDString
    let max: UInt
}

struct HttpMessagesAfterQuery: Codable {
    let from: UUIDString
    let max: UInt
}

struct HttpMessagesBetweenQUery: Codable {
    let from: DateString
    let to: DateString
    let max: UInt
    let new_to_old: Bool
}
