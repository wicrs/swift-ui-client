//
//  Hub.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-09.
//

import Foundation

struct HubMember : Codable {
    let user_id: UUIDString
    let joined: DateString
    let hub: UUIDString
    var nick: String = ""
    var groups: [UUIDString]
    var hub_permissions: HubPermissions
    var channel_permissions: [UUIDString : ChannelPermissions]
}

extension HubMember : Identifiable {
    var id: UUIDString { return user_id }
}

struct PermissionGroup : Codable, Identifiable {
    let id: UUIDString
    var name: String
    var hub_permissions: HubPermissions
    var channel_permissions: [UUIDString : ChannelPermissions]
    let created: DateString
}

struct Hub : Codable, Identifiable {
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

extension HttpClient {
    func create_hub(name: String, description: String?) throws -> UUIDString {
        try self.post(endpoint: "/api/hub", data: HttpHubUpdate.init(name: name, description: description, default_group: nil))
    }
    
    func get_hub(hub_id: UUIDString) throws -> Hub {
        try self.get(endpoint: "/api/hub/\(hub_id)")
    }
    
    func delete_hub(hub_id: UUIDString) throws -> String {
        try self.delete(endpoint: "/api/hub/\(hub_id)")
    }
    
    func update_hub(hub_id: UUIDString, update: HttpHubUpdate) throws -> HttpHubUpdate {
        try self.put(endpoint: "/api/hub/\(hub_id)", data: update)
    }
    
    func join_hub(hub_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/hub/\(hub_id)/join")
    }
    
    func leave_hub(hub_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/hub/\(hub_id)/leave")
    }
}

extension HttpClient {
    func get_member_status(hub_id: UUIDString, member_id: UUIDString) throws -> HttpMemberStatus {
        try self.get(endpoint: "/api/member/\(hub_id)/\(member_id)/status")
    }
    
    func get_member(hub_id: UUIDString, member_id: UUIDString) throws -> HubMember {
        try self.get(endpoint: "/api/member/\(hub_id)/\(member_id)")
    }
    
    func kick_member(hub_id: UUIDString, member_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/kick")
    }
    
    func mute_member(hub_id: UUIDString, member_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/mute")
    }
    
    func ban_member(hub_id: UUIDString, member_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/ban")
    }
    
    func unmute_member(hub_id: UUIDString, member_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/unmute")
    }
    
    func unban_member(hub_id: UUIDString, member_id: UUIDString) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/unban")
    }
    
    func set_member_nick(hub_id: UUIDString, member_id: UUIDString, nick: String, setting: PermissionSetting) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/set_nick", data: HttpSetNick.init(nick: nick))
    }
    
    func set_member_hub_permission(hub_id: UUIDString, member_id: UUIDString, permission: HubPermission, setting: PermissionSetting) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/hub_permission/\(permission)", data: HttpSetPermission.init(setting: setting))
    }
    
    func get_member_hub_permission(hub_id: UUIDString, member_id: UUIDString, permission: HubPermission) throws -> String {
        try self.get(endpoint: "/api/member/\(hub_id)/\(member_id)/hub_permission/\(permission)")
    }
    
    func set_member_channel_permission(hub_id: UUIDString, member_id: UUIDString, channel_id: UUIDString, permission: ChannelPermission, setting: PermissionSetting) throws -> String {
        try self.post(endpoint: "/api/member/\(hub_id)/\(member_id)/channel_permission/\(channel_id)/\(permission)", data: HttpSetPermission.init(setting: setting))
    }
    
    func get_member_channel_permission(hub_id: UUIDString, member_id: UUIDString, channel_id: UUIDString, permission: ChannelPermission) throws -> String {
        try self.get(endpoint: "/api/member/\(hub_id)/\(member_id)/channel_permission/\(channel_id)/\(permission)")
    }
}
