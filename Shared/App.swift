//
//  WICRS_ClientApp.swift
//  Shared
//
//  Created by Willem on 2022-01-09.
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
}

@main
struct WICRSClient: App, Sendable {
    static var http_client = HttpClient(base_url: AppConfig.server, user_id: AppConfig.user_id)
    static var websocket = http_client.websocket()
    @StateObject var state: AppState = AppState()
    @State private var ready: Bool = false
    
    var body: some Scene {
        WindowGroup {
            switch ready {
                case true:
                    ContentView(hubs: $state.hubs)
#if os(macOS)
                        .frame(width: 720, height: 360, alignment: .center)
#endif
                        .onAppear {
                            DispatchQueue.global(qos: .background).async {
                                Task {
                                    while let message = try? await WICRSClient.websocket.receive() {
                                        if case let .string(string) = message {
                                            do {
                                                let server_message = try JSONDecoder.init().decode(WsServerMessage.self, from: string.data(using: .utf8)!)
                                                switch server_message {
                                                    case let .Error(err):
                                                        print("API error: \(err)")
                                                    case let .ChatMessage(sender_id: _, hub_id: hub_id, channel_id: channel_id, message_id: message_id, message: _):
                                                        DispatchQueue.main.async {
                                                            do {
                                                                self.state.hubs[hub_id]?.channels[channel_id]?.messages.append(try WICRSClient.http_client.get_message(hub_id: hub_id, channel_id: channel_id, message_id: message_id))
                                                            }
                                                            catch {
                                                                print("Error getting message from server: \(error)")
                                                            }
                                                        }
                                                        print("New message! ID: \(message_id)")
                                                    default:
                                                        print("Ws message: \(server_message)")
                                                }
                                            } catch {
                                                print("Error parsing Ws message: \(error)")
                                                print("Message: \(string)")
                                            }
                                        }
                                    }
                                    print("Websocket closed.")
                                }
                            }
                        }
                case false:
                    ProgressView().onAppear(perform: loadData)
            }
        }.commands {
            WICRSCommands()
        }
#if os(macOS)
        Settings {
            GeneralSettingsView(hubs: $state.hubs).onSubmit {
                ready = false
            }
        }
#endif
    }
    
    private func loadData() {
        WICRSClient.websocket = WICRSClient.http_client.websocket()
        Task {
            print("Finishing websocket authentication...")
            do {
                try await WICRSClient.websocket.send(.string(AppConfig.user_id))
            } catch {
                print("Could not authenticate websocket: \(error)")
            }
        }
        
        for hub_id in AppConfig.hubs {
            do {
                self.state.hubs[hub_id] = try HubLoader.shared.loadHubSubscribe(hub_id)
            } catch {
                print("Failed to load hub with ID '\(hub_id)':\n\(error)")
            }
        }
        ready = true
    }
}

#if DEBUG
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
#endif
