//
//  WICRS_ClientApp.swift
//  Shared
//
//  Created by Willem Leitso on 2022-01-09.
//

import CFNetwork
import Foundation
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
    static var shared = AppState()
    @Published var hubs: [UUIDString : Hub] = [:]
    
    init() {
        hubs = [:]
        print("Finishing websocket authentication...")
        WICRSClient.websocket.send(.string(WICRSClient.user_id), completionHandler: { err in
            print("Could not authenticate websocket.")
        })
        self.listen()
    }
}

@main
struct WICRSClient: App {
    static let user_id = "7EF6EFB7-75CF-40EF-BD9F-44B5C2A3BE5D"
    static var http_client = HttpClient(base_url: "http://0.0.0.0:8080", user_id: user_id)
    static var websocket = http_client.websocket()
    @StateObject var state: AppState = AppState()
    @State private var ready: Bool?
    
    init() {
        print("User ID: \(WICRSClient.user_id)")
    }
    
    var body: some Scene {
        WindowGroup {
            switch ready {
                case true:
                    ContentView(hubs: state.hubs)
                case false:
                    Text("Error loading data...")
                default:
                    ProgressView().onAppear(perform: loadData)
            }
            
        }
    }
    
    private func loadData() {
        do {
            let hub1 = "0c0375dc-eba7-4e94-9706-f572d1ef6521"
            let channels1 = ["e594d1d3-584e-4296-9037-ff918516a153","8e69a75c-be7e-4d2d-86a3-4e02d099633a","472d5965-1fc5-437b-beb0-f14748cf4d3c","0ab5f1ca-2154-4ab3-92e8-19ce4e14fbf8"]
            print("Getting hub 1...")
            state.hubs[hub1] = try WICRSClient.http_client.get_hub(hub_id: hub1)
            print("Subscribing to hub...")
            WICRSClient.subscribe_hub(hub_id: hub1)
            for channel in channels1 {
                print("Subscribing to channel '\(state.hubs[hub1]?.channels[channel]?.name ?? "UNDEFINED")'...")
                WICRSClient.subscribe_channel(hub_id: hub1, channel_id: channel)
                print("Getting messages for channel '\(state.hubs[hub1]?.channels[channel]?.name ?? "UNDEFINED")'...")
                let messages = try WICRSClient.http_client.get_messages_last(hub_id: hub1, channel_id: channel, max: 100)
                print("Got \(messages.count) messages.")
                state.hubs[hub1]?.channels[channel]?.messages.append(contentsOf: messages)
            }
            
            let hub2 = "9f6d21c5-f5b1-4bf1-b0e2-add0567d49b5"
            let channels2 = ["c5792dcc-e4e6-42f2-9b07-63dbc2a4722c","ca2ff657-8e46-430c-8812-568e0819ef76","4146b5cd-5bea-433d-a16c-bab3df79b7fe","93d3f189-4db3-49b0-8860-33c575d858cb"]
            print("Getting hub 2...")
            state.hubs[hub2] = try WICRSClient.http_client.get_hub(hub_id: hub2)
            print("Subscribing to hub...")
            WICRSClient.subscribe_hub(hub_id: hub2)
            for channel in channels2 {
                print("Subscribing to channel '\(state.hubs[hub2]?.channels[channel]?.name ?? "UNDEFINED")'...")
                WICRSClient.subscribe_channel(hub_id: hub1, channel_id: channel)
                print("Getting messages for channel '\(state.hubs[hub2]?.channels[channel]?.name ?? "UNDEFINED")'...")
                let messages = try WICRSClient.http_client.get_messages_last(hub_id: hub2, channel_id: channel, max: 100)
                print("Got \(messages.count) messages.")
                state.hubs[hub2]?.channels[channel]?.messages.append(contentsOf: messages)
            }
            print("Have \(state.hubs["9f6d21c5-f5b1-4bf1-b0e2-add0567d49b5"]!.channels["ca2ff657-8e46-430c-8812-568e0819ef76"]!.messages.count) messages.")
            
            print("Got hubs, channels and messages.")
            ready = true
        } catch {
            print("Error getting data from server: \(error)")
            ready = false
        }
    }
}

func create_hubs(hubs: inout [UUIDString:Hub]) {
    for i in 1...2 {
        let hub_id = try! WICRSClient.http_client.create_hub(name: "Test \(i)", description: "Testing hub description for 'Test \(i)'.")
        print("hub: \(hub_id)")
        var hub = try! WICRSClient.http_client.get_hub(hub_id: hub_id)
        for i in 1...3 {
            let channel_id = try! WICRSClient.http_client.create_channel(hub_id: hub_id, channel: HttpChannelUpdate.init(name: "Test \(i)", description: "Testing channel description for 'Test \(i)'."))
            WICRSClient.subscribe_channel(hub_id: hub_id, channel_id: channel_id)
        }
        hub = try! WICRSClient.http_client.get_hub(hub_id: hub_id)
        hub.channels.keys.forEach { channel_id in
            print("channel: \(channel_id)")
        }
        WICRSClient.subscribe_hub(hub_id: hub_id)
        hubs[hub_id] = hub
    }
}

func create_messages(hubs: inout [UUIDString:Hub]) {
    for hub in hubs.values {
        for channel in hub.channels.values {
            for i in 1...20 {
                let message_id = try! WICRSClient.http_client.send_message(hub_id: hub.id, channel_id: channel.id, content: "Test message number \(i).")
                let message = try! WICRSClient.http_client.get_message(hub_id: hub.id, channel_id: channel.id, message_id: message_id)
                hubs[hub.id]!.channels[channel.id]!.messages.append(message)
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

func create_preview_hubs() -> [UUIDString:Hub] {
    var hubs: [UUIDString:Hub] = [:]
    for i in 1...10 {
        let hub = create_preview_hub(discriminator: "\(i)")
        hubs[hub.id] = hub
    }
    return hubs
}
