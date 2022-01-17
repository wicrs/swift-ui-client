//
//  Hub.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-09.
//

import Foundation

struct HubMember : Codable {
    let user_id: UUIDString
    let joined: DateString
    let hub: UUIDString
    var groups: [UUIDString]
    var hub_permissions: HubPermissions
    var channel_permissions: [UUIDString : ChannelPermissions]
}

struct PermissionGroup : Codable {
    let id: UUIDString
    var name: String
    var hub_permissions: HubPermissions
    var channel_permissions: [UUIDString : ChannelPermissions]
    let created: DateString
}

struct Hub : Codable {
    var channels: [UUIDString : Channel]
    var members: [UUIDString : HubMember]
    var bans: [UUIDString]
    var mutes: [UUIDString]
    var description: String
    let owner: UUIDString
    var groups: [UUIDString : PermissionGroup]
    var default_group: UUIDString
    var name: String
    let id: UUIDString
    let created: DateString
}
