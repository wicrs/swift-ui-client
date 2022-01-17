//
//  Permissions.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-09.
//

import Foundation

typealias PermissionSetting = Bool?

typealias HubPermissions = [HubPermString : PermissionSetting]

typealias ChannelPermissions = [ChannelPermString : PermissionSetting]

enum ChannelPermission : String, CodingKey, Codable {
    case Write = "Write"
    case Read = "Read"
    case Manage = "Manage"
    case All = "All"
    
    enum CodingKeys: String, CodingKey {
        case Write = "Write"
        case Read = "Read"
        case Manage = "Manage"
        case All = "All"
//        case Write = "WRITE"
//        case Read = "READ"
//        case Manage = "MANAGE"
//        case All = "ALL"
    }
}

extension ChannelPermission {
    enum ChannelPermissionCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        let label = try value.decode(String.self)
        switch label {
//            case "ALL": self = .All
//            case "READ": self = .Read
//            case "WRITE": self = .Write
//            case "MANAGE": self = .Manage
            case "All": self = .All
            case "Read": self = .Read
            case "Write": self = .Write
            case "Manage": self = .Manage
            default:
                throw ChannelPermissionCodingError.decoding("Unknown value.")
        }
        return
    }
}

enum HubPermission : String, CodingKey, Codable {
    case All = "All"
    case ReadChannels = "ReadChannels"
    case WriteChannels = "WriteChannels"
    case Administrate = "Administrate"
    case ManageChannels = "ManageChannels"
    case Mute = "Mute"
    case Unmute = "Unmute"
    case Kick = "Kick"
    case Ban = "Ban"
    case Unban = "Unban"
    
    enum CodingKeys: String, CodingKey {
        case All = "All"
        case ReadChannels = "ReadChannels"
        case WriteChannels = "WriteChannels"
        case Administrate = "Administrate"
        case ManageChannels = "ManageChannels"
        case Mute = "Mute"
        case Unmute = "Unmute"
        case Kick = "Kick"
        case Ban = "Ban"
        case Unban = "Unban"
//        case All = "ALL"
//        case ReadChannels = "READ_CHANNELS"
//        case WriteChannels = "WRITE_CHANNELS"
//        case Administrate = "ADMINISTRATE"
//        case ManageChannels = "MANAGE_CHANNELS"
//        case Mute = "MUTE"
//        case Unmute = "UNMUTE"
//        case Kick = "KICK"
//        case Ban = "BAN"
//        case Unban = "UNBAN"
    }
}

extension HubPermission {
    enum HubPermissionCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        let label = try value.decode(String.self)
        switch label {
//            case "ALL": self = .All
//            case "MUTED": self = .ReadChannels
//            case "BANNED": self = .WriteChannels
//            case "ADMINISTRATE": self = .Administrate
//            case "MANAGE_CHANNELS": self = .ManageChannels
//            case "MUTE": self = .Mute
//            case "UNMUTE": self = .Unmute
//            case "KICK": self = .Kick
//            case "BAN": self = .Ban
//            case "UNBAN": self = .Unban
            case "All": self = .All
            case "Muted": self = .ReadChannels
            case "Banned": self = .WriteChannels
            case "Administrate": self = .Administrate
            case "ManageChannels": self = .ManageChannels
            case "Mute": self = .Mute
            case "Unmute": self = .Unmute
            case "Kick": self = .Kick
            case "Ban": self = .Ban
            case "Unban": self = .Unban
            default:
                throw HubPermissionCodingError.decoding("Unknown value.")
        }
        return
    }
}

extension HubPermission {
    func from(channel_perm: ChannelPermission) -> Self {
        switch channel_perm {
            case .Write:
                return HubPermission.WriteChannels
            case .Read:
                return HubPermission.ReadChannels
            case .Manage:
                return HubPermission.ManageChannels
            case .All:
                return HubPermission.All
        }
    }
}
