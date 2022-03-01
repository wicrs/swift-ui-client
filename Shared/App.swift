//
//  WICRS_ClientApp.swift
//  Shared
//
//  Created by Willem Leitso on 2022-01-09.
//

import SwiftUI

typealias UUIDString = String
typealias DateString = String
typealias HubPermString = String
typealias ChannelPermString = String

enum ClientError: Error {
    case EmptyResponse
}

typealias UUIDPair = String
typealias MessageMap = [UUIDPair : [Message]]

class AppState: ObservableObject {
    @Published var hubs: [Hub]
    
    init() {
        hubs = []
        create_hubs(hubs: &hubs)
        create_messages(hubs: &hubs)
    }
}

@main
struct WICRSClient: App {
    static let user_id = UUID.init().uuidString
    static var http_client = HttpClient(base_url: "http://0.0.0.0:8080", user_id: user_id)
    static var websocket = http_client.websocket()
    @StateObject var state = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(hubs: state.hubs)
        }
    }
}

func create_hubs(hubs: inout [Hub]) {
    for i in 1...2 {
        let hub_id = try! WICRSClient.http_client.create_hub(name: "Test \(i)", description: "Testing hub description for 'Test \(i)'.")
        let hub = try! WICRSClient.http_client.get_hub(hub_id: hub_id)
        for i in 1...3 {
            let channel_id = try! WICRSClient.http_client.create_channel(hub_id: hub_id, channel: HttpChannelUpdate.init(name: "Test \(i)", description: "Testing channel description for 'Test \(i)'."))
            WICRSClient.subscribe_channel(hub_id: hub_id, channel_id: channel_id)
        }
        WICRSClient.subscribe_hub(hub_id: hub_id)
        hubs.append(hub)
    }
}

func create_messages(hubs: inout [Hub]) {
    for (num, hub) in hubs.enumerated() {
        for channel in hub.channels.values {
            for i in 1...20 {
                let message_id = try! WICRSClient.http_client.send_message(hub_id: hub.id, channel_id: channel.id, content: "Test message number \(i).")
                let message = try! WICRSClient.http_client.get_message(hub_id: hub.id, channel_id: channel.id, message_id: message_id)
                hubs[num].channels[channel.id]!.messages.append(message)
            }
        }
    }
}

func create_preview_message(discriminator: String = "1", hub_id: UUIDString = "00000000-0000-0000-0000-00000000000", channel_id: UUIDString = "00000000-0000-0000-0000-00000000000", sender_id: UUIDString = "00000000-0000-0000-0000-00000000000") -> Message {
    let message = Message.init(id: UUID.init().uuidString, hub_id: hub_id, channel_id: channel_id, sender: sender_id, created: Date.now.ISO8601Format(), content: "Test message number \(discriminator).")
    return message
}

func create_preview_channel(discriminator: String = "1", hub_id: UUIDString = "00000000-0000-0000-0000-00000000000", sender_id: UUIDString = "00000000-0000-0000-0000-00000000000") -> Channel {
    var channel = Channel.init(id: UUID.init().uuidString, hub_id: hub_id, description: "Preview test channel \(discriminator)", name: "Test \(discriminator)", created: Date.now.ISO8601Format(), messages: [])
    for k in 1...10 {
        channel.messages.append(create_preview_message(discriminator: "\(k)"))
    }
    return channel
}

func create_preview_hub(discriminator: String = "1") -> Hub {
    var hub = Hub.init(channels: [:], members: [:], bans: [], mutes: [], description: "Preview test hub \(discriminator).", owner: UUID.init().uuidString, groups: [:], default_group: "", name: "Test \(discriminator)", id: UUID.init().uuidString, created: Date.now.ISO8601Format())
    let default_group = PermissionGroup.init(id: UUID.init().uuidString, name: "Default Group", hub_permissions: [HubPermission.ReadChannels.stringValue:true, HubPermission.WriteChannels.stringValue:true], channel_permissions: [:], created: Date.now.ISO8601Format())
    hub.default_group = default_group.id
    hub.groups[default_group.id] = default_group
    let owner = HubMember.init(user_id: hub.owner, joined: Date.now.ISO8601Format(), hub: hub.id, groups: [default_group.id], hub_permissions: [HubPermission.All.stringValue:true], channel_permissions: [:])
    hub.members[owner.id] = owner
    for j in 1...10 {
        let channel = create_preview_channel(discriminator: "\(j)", hub_id: hub.id, sender_id: owner.id)
        hub.channels[channel.id] = channel
        let group = PermissionGroup.init(id: UUID.init().uuidString, name: "Test \(j)", hub_permissions: [:], channel_permissions: [:], created: Date.now.ISO8601Format())
        hub.groups[group.id] = group
        let member = HubMember.init(user_id: UUID.init().uuidString, joined: Date.now.ISO8601Format(), hub: hub.id, groups: [default_group.id], hub_permissions: [:], channel_permissions: [:])
        hub.members[member.user_id] = member
    }
    return hub
}

func create_preview_hubs() -> [Hub] {
    var hubs: [Hub] = []
    for i in 1...10 {
        hubs.append(create_preview_hub(discriminator: "\(i)"))
    }
    return hubs
}
