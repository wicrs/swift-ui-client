//
//  Channel.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-09.
//

import Foundation

struct Message : Codable, Identifiable, Hashable {
    let id: UUIDString
    let hub_id: UUIDString
    let channel_id: UUIDString
    let sender: UUIDString
    let created: DateString
    let content: String
}

struct Channel : Codable, Identifiable {
    let id: UUIDString
    let hub_id: UUIDString
    var description: String
    var name: String
    let created: DateString
    var messages: [Message] = []
    
    enum CodingKeys: String, CodingKey {
        case id, hub_id, description, name, created
    }
}

extension HttpClient {
    func get_channel(hub_id: UUIDString, channel_id: UUIDString) throws -> Channel {
        try self.get(endpoint: "/api/channel/\(hub_id)/\(channel_id)")
    }
    
    func create_channel(hub_id: UUIDString, channel: HttpChannelUpdate) throws -> UUIDString {
        try self.post(endpoint: "/api/channel/\(hub_id)", data: channel)
    }
    
    func update_channel(hub_id: UUIDString, channel_id: UUIDString, update: HttpChannelUpdate) throws -> HttpChannelUpdate {
        try self.put(endpoint: "/api/channel/\(hub_id)/\(channel_id)", data: update)
    }
    
    func delete_channel(hub_id: UUIDString, channel_id: UUIDString) throws -> String {
        try self.delete(endpoint: "/api/channel/\(hub_id)/\(channel_id)")
    }
}

extension HttpClient {
    func get_message(hub_id: UUIDString, channel_id: UUIDString, message_id: UUIDString) throws -> Message {
        try self.get(endpoint: "/api/message/\(hub_id)/\(channel_id)/\(message_id)")
    }
    
    func get_messages_after(hub_id: UUIDString, channel_id: UUIDString, message_id: UUIDString, max: UInt) throws -> [Message] {
        try self.get(endpoint: "/api/message/\(hub_id)/\(channel_id)/after?from=\(message_id)&max=\(max)")
    }
    
    func get_messages_before(hub_id: UUIDString, channel_id: UUIDString, message_id: UUIDString, max: UInt) throws -> [Message] {
        try self.get(endpoint: "/api/message/\(hub_id)/\(channel_id)/before?to=\(message_id)&max=\(max)")
    }
    
    func get_messages_last(hub_id: UUIDString, channel_id: UUIDString, max: UInt) throws -> [Message] {
        try self.get(endpoint: "/api/message/\(hub_id)/\(channel_id)/last?max=\(max)")
    }
    
    func send_message(hub_id: UUIDString, channel_id: UUIDString, content: String) throws -> UUIDString {
        try self.post(endpoint: "/api/message/\(hub_id)/\(channel_id)", data: HttpSendMessage.init(message: content))
    }
}
