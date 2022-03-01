//
//  Websocket.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-02-28.
//

import Foundation
import SwiftUI

extension WICRSClient {
    static func subscribe_hub(hub_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"SubscribeHub\":{\"hub_id\":\"\(hub_id)\"}}"), completionHandler: {err in
            if err != nil {
                print(err!.localizedDescription)
                exit(1)
            }
        })
    }
    
    static func unsubscribe_hub(hub_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"UnsubscribeHub\":{\"hub_id\":\"\(hub_id)\"}}"), completionHandler: {err in
            if err != nil {
                print(err!.localizedDescription)
                exit(1)
            }
        })
    }
    
    static func subscribe_channel(hub_id: UUIDString, channel_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"SubscribeChannel\":{\"hub_id\":\"\(hub_id)\",\"channel_id\":\"\(channel_id)\"}}"), completionHandler: {err in
            if err != nil {
                print(err!.localizedDescription)
                exit(1)
            }
        })
    }
    
    static func unsubscribe_channel(hub_id: UUIDString, channel_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"UnsubscribeChannel\":{\"hub_id\":\"\(hub_id)\",\"channel_id\":\"\(channel_id)\"}}"), completionHandler: {err in
            if err != nil {
                print(err!.localizedDescription)
                exit(1)
            }
        })
    }
}

func handle_ws_message(_ result: Result<URLSessionWebSocketTask.Message, Error>) -> () {
    print("Got a Ws message.")
    WICRSClient.websocket.receive(completionHandler: handle_ws_message)
    do {
        if case let .string(string) = try result.get() {
            let server_message = try JSONDecoder.init().decode(WsServerMessage.self, from: string.data(using: .utf8)!)
            switch server_message {
                case let .Error(err):
                    print(err.localizedDescription)
                case let .ChatMessage(sender_id: _, hub_id: hub_id, channel_id: channel_id, message_id: message_id, message: _):
                    
                    DispatchQueue.main.async {
                        AppState.shared.hubs[hub_id]?.channels[channel_id]?.messages.append(try! WICRSClient.http_client.get_message(hub_id: hub_id, channel_id: channel_id, message_id: message_id))
                    }
                    print("New message! ID: \(message_id)")
                default:
                    print("Ws message: \(string)")
            }
        }
    } catch {
        print("Error from Ws read: \(error)")
    }
    
    return
}

extension AppState {
    func listen() {
        WICRSClient.websocket.receive(completionHandler: handle_ws_message)
    }
}


enum WsHubUpdateType: Decodable {
    case HubDeleted
    case HubUpdated
    case UserJoined(UUIDString)
    case UserLeft(UUIDString)
    case UserBanned(UUIDString)
    case UserMuted(UUIDString)
    case UserUnmuted(UUIDString)
    case UserUnbanned(UUIDString)
    case UserKicked(UUIDString)
    case UserHubPermissionChanged(UUIDString)
    case UserChannelPermissionChanged(UUIDString, UUIDString)
    case MemberNicknameChanged(UUIDString)
    case ChannelCreated(UUIDString)
    case ChannelDeleted(UUIDString)
    case ChannelUpdated(UUIDString)
    
    enum CodingKeys: String, CodingKey {
        case HubDeleted
        case HubUpdated
        case UserJoined
        case UserLeft
        case UserBanned
        case UserMuted
        case UserUnmuted
        case UserUnbanned
        case UserKicked
        case UserHubPermissionChanged
        case UserChannelPermissionChanged
        case MemberNicknameChanged
        case ChannelCreated
        case ChannelDeleted
        case ChannelUpdated
    }
}

extension WsHubUpdateType {
    enum WsHubUpdateTypeCodingError: Error {
        case decoding(String)
    }
    
    struct UJ: Codable {
        let UserJoined: UUIDString
    }
    
    struct UL: Codable {
        let UserLeft: UUIDString
    }
    
    struct UK: Codable {
        let UserKicked: UUIDString
    }
    
    struct UB: Codable {
        let UserBanned: UUIDString
    }
    
    struct UM: Codable {
        let UserMuted: UUIDString
    }
    
    struct UUm: Codable {
        let UserUnmuted: UUIDString
    }
    
    struct UUb: Codable {
        let UserUnbanned: UUIDString
    }
    
    struct UHPC: Codable {
        let UserHubPermissionChanged: UUIDString
    }
    
    struct UCPC: Codable {
        let UserChannelPermissionChanged: [UUIDString]
    }
    
    struct MNC: Codable {
        let MemberNicknameChanged: UUIDString
    }
    
    struct CD: Codable {
        let ChannelDeleted: UUIDString
    }
    
    struct CU: Codable {
        let ChannelUpdated: UUIDString
    }
    
    struct CC: Codable {
        let ChannelCreated: UUIDString
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let value = try? value.decode(CU.self) {
            self = .ChannelUpdated(value.ChannelUpdated)
        }
        if let value = try? value.decode(CC.self) {
            self = .ChannelCreated(value.ChannelCreated)
        }
        if let value = try? value.decode(CD.self) {
            self = .ChannelDeleted(value.ChannelDeleted)
        }
        if let value = try? value.decode(MNC.self) {
            self = .MemberNicknameChanged(value.MemberNicknameChanged)
        }
        if let value = try? value.decode(UCPC.self) {
            let array = value.UserChannelPermissionChanged
            if array.count != 2 {
                throw WsHubUpdateTypeCodingError.decoding("Too many items in user channel permission changed array.")
            }
            self = .UserChannelPermissionChanged(array[0], array[1])
        }
        if let value = try? value.decode(UHPC.self) {
            self = .UserHubPermissionChanged(value.UserHubPermissionChanged)
        }
        if let value = try? value.decode(UUm.self) {
            self = .UserUnmuted(value.UserUnmuted)
        }
        if let value = try? value.decode(UUb.self) {
            self = .UserUnbanned(value.UserUnbanned)
        }
        if let value = try? value.decode(UJ.self) {
            self = .UserJoined(value.UserJoined)
        }
        if let value = try? value.decode(UL.self) {
            self = .UserLeft(value.UserLeft)
        }
        if let value = try? value.decode(UB.self) {
            self = .UserBanned(value.UserBanned)
        }
        if let value = try? value.decode(UK.self) {
            self = .UserKicked(value.UserKicked)
        }
        let label = try value.decode(String.self)
        switch label {
            case "HubDeleted": self = .HubDeleted
            case "HubUpdated": self = .HubUpdated
            default:
                throw WsHubUpdateTypeCodingError.decoding("Unknown value.")
        }
        return
    }
}

enum WsServerMessage: Decodable {
    case Error(APIError)
    case InvalidCommand
    case NotSigned
    case CommandFailed
    case ChatMessage(
        sender_id: UUIDString,
        hub_id: UUIDString,
        channel_id: UUIDString,
        message_id: UUIDString,
        message: String
    )
    case HubUpdated(
        hub_id: UUIDString,
        update_type: WsHubUpdateType
    )
    case Success
    case UserStartedTyping(
        user_id: UUIDString,
        hub_id: UUIDString,
        channel_id: UUIDString
    )
    case UserStoppedTyping(
        user_id: UUIDString,
        hub_id: UUIDString,
        channel_id: UUIDString
    )
    
    enum CodingKeys: String, CodingKey {
        case Error
        case InvalidCommand
        case NotSigned
        case CommandFailed
        case ChatMessage
        case HubUpdated
        case Success
        case UserStartedTyping
        case UserStoppedTyping
    }
}

extension WsServerMessage {
    enum WsServerMessageCodingError: Error {
        case decoding(String)
    }
    
    struct CMessage: Codable {
        let sender_id: UUIDString
        let hub_id: UUIDString
        let channel_id: UUIDString
        let message_id: UUIDString
        let message: String
    }
    
    struct ChMessage: Codable {
        let ChatMessage: CMessage
    }
    
    struct SoType: Codable {
        let user_id: UUIDString
        let hub_id: UUIDString
        let channel_id: UUIDString
    }
    
    struct USoType: Codable {
        let UserStoppedTyping: SoType
    }
    
    struct SaType: Codable {
        let user_id: UUIDString
        let hub_id: UUIDString
        let channel_id: UUIDString
    }
    
    struct USaType: Codable {
        let UserStartedTyping: SoType
    }
    
    struct Er: Decodable {
        let Error: APIError
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let value = try? value.decode(ChMessage.self) {
            let info = value.ChatMessage
            self = .ChatMessage(sender_id: info.sender_id, hub_id: info.hub_id, channel_id: info.channel_id, message_id: info.message_id, message: info.message)
        }
        if let value = try? value.decode(USoType.self) {
            let info = value.UserStoppedTyping
            self = .UserStoppedTyping(user_id: info.user_id, hub_id: info.hub_id, channel_id: info.channel_id)
        }
        if let value = try? value.decode(USaType.self) {
            let info = value.UserStartedTyping
            self = .UserStartedTyping(user_id: info.user_id, hub_id: info.hub_id, channel_id: info.channel_id)
        }
        if let value = try? value.decode(Er.self) {
            self = .Error(value.Error)
        }
        let label = try value.decode(String.self)
        switch label {
            case "InvalidCommand": self = .InvalidCommand
            case "NotSigned": self = .NotSigned
            case "CommandFailed": self = .CommandFailed
            case "Success": self = .Success
            default:
                throw WsServerMessageCodingError.decoding("Unknown value.")
        }
        return
    }
}

