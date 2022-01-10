//
//  Permissions.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-09.
//

import Foundation

public typealias PermissionSetting = Bool?

public typealias HubPermissions = [HubPermission : PermissionSetting]

public typealias ChannelPermissions = [ChannelPermission : PermissionSetting]

public enum ChannelPermission : String {
    case Write = "WRITE"
    case Read = "READ"
    case Manage = "MANAGE"
    case All = "ALL"
}

public enum HubPermission : String {
    case All = "ALL"
    case ReadChannels = "READ_CHANNELS"
    case WriteChannels = "WRITE_CHANNELS"
    case Administrate = "ADMINISTRATE"
    case ManageChannels = "MANAGE_CHANNELS"
    case Mute = "MUTE"
    case Unmute = "UNMUTE"
    case Kick = "KICK"
    case Ban = "BAN"
    case Unban = "UNBAN"
    
}

extension HubPermission {
    public func from(channel_perm: ChannelPermission) -> Self {
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
