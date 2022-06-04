//
//  Loaders.swift
//  WICRS Client
//
//  Created by Willem on 2022-03-05.
//

import Foundation
import SwiftUI

class HubLoader {
    public static var shared = HubLoader()
    
    var servers: [String:[UUIDString:Hub]] = [:]
    
    func clientForServer(server: String) -> HttpClient {
        return HttpClient(base_url: server, user_id: AppConfig.user_id)
    }
    
    func loadHubFromRemote(id: Hub.ID, server: String) throws -> Hub {
        let client = HttpClient(base_url: server, user_id: AppConfig.user_id)
        let hub = try client.get_hub(hub_id: id)
        if var hubs = self.servers[server] {
            hubs[id] = hub
        } else {
            self.servers[server] = [id:hub]
        }
        return hub
    }
    
    func loadHub(id: Hub.ID, server: String) throws -> Hub {
        if let hub = self.servers[server]?[id] {
            return hub
        } else {
            return try clientForServer(server: server).get_hub(hub_id: id)
        }
    }
    
    func loadNickFromRemote(server: String, hub_id: Hub.ID, member_id: HubMember.ID) throws -> String {
        do {
            let member = try clientForServer(server: server).get_member(hub_id: hub_id, member_id: member_id)
            if var hub = self.servers[server]?[hub_id] {
                hub.members[member_id] = member
                self.servers[server]?[hub_id] = hub
            }
            return member.user_id.prefix(8).description
        } catch {
            if let member = self.servers[server]?[hub_id]?.members[member_id] {
                if member.nick.isEmpty {
                    return member.user_id.prefix(8).description
                } else {
                    return member.nick
                }
            } else {
                return member_id.prefix(8).description
            }
        }
    }
    
    public func loadHubSubscribe(_ hub_id: UUIDString) throws -> Hub {
        let _ = try? WICRSClient.http_client.join_hub(hub_id: hub_id)
        var hub = try self.loadHub(id: hub_id, server: AppConfig.server)
        Task {
            try? await WICRSClient.subscribe_hub(hub_id: hub_id)
        }
        for (channel_id, var channel) in hub.channels {
            Task {
                try? await WICRSClient.subscribe_channel(hub_id: hub_id, channel_id: channel_id)
            }
            do {
                let messages = try WICRSClient.http_client.get_messages_last(hub_id: hub_id, channel_id: channel_id, max: 100)
                channel.messages.append(contentsOf: messages)
                hub.channels[channel_id] = channel
            } catch {
                print("Failed to load messages for \(channel.name) in \(hub.name).")
            }
        }
        return hub
    }
}
