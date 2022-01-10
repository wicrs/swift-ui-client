//
//  Hub.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-09.
//

import Foundation

public struct HubMember {
    public let user_id: UUID
    public let joined: Date
    public let hub: UUID
    public var groups: [UUID]
    public var hub_permissions: HubPermissions
    public var channel_permissions: [UUID : ChannelPermissions]
}

public struct PermissionGroup {
    public let id: UUID
    public var name: String
    public var hub_permissions: HubPermissions
    public var channel_permissions: [UUID : ChannelPermissions]
    public let created: Date
}

public struct Hub {
    public var channels: [UUID : Channel]
    public var members: [UUID : HubMember]
    public var bans: [UUID]
    public var mutes: [UUID]
    public var description: String
    public let owner: UUID
    public var groups: [UUID : PermissionGroup]
    public var default_group: UUID
    public var name: String
    public let id: UUID
    public let created: Date
}
