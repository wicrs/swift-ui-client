//
//  Loaders.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-03-05.
//

import Foundation

class HubLoader {
    let user_id: UUIDString
    var storage = UserDefaults.init(suiteName: "hubs")
    
    var servers: [String:[UUIDString:Hub]]
    
    init(user_id: UUIDString) {
        self.user_id = user_id
        self.servers = [:]
    }
    
    func loadHubFromRemote(id: Hub.ID, server: String) throws -> Hub {
        let client = HttpClient(base_url: server, user_id: self.user_id)
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
            DispatchQueue.global(qos: .background).async {
                let client = HttpClient(base_url: server, user_id: self.user_id)
                if let hub = try? client.get_hub(hub_id: id) {
                    if var hubs = self.servers[server] {
                        hubs[id] = hub
                    } else {
                        self.servers[server] = [id:hub]
                    }
                }
            }
            return hub
        } else {
            let client = HttpClient(base_url: server, user_id: self.user_id)
            return try client.get_hub(hub_id: id)
        }
    }
}

class MessageLoader {
    
}
