//
//  AppConfig.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-03-04.
//

import Foundation
import SwiftUI

struct Server: Codable {
    public var address: String
    public var hubs: [UUIDString]
}

struct AppConfig {
    public var user_id: UUIDString
    public var server: String
    public var hubs: [UUIDString] // [ String : [ Hub.ID ] ]
    public var servers: [Server]
    
    init() {
        UserDefaults.standard.set("http://0.0.0.0:8080", forKey: "server")
        
        if let user = UserDefaults.standard.string(forKey: "user_id") {
            self.user_id = user
        } else {
            self.user_id = "7EF6EFB7-75CF-40EF-BD9F-44B5C2A3BE5D"
            UserDefaults.standard.set(self.user_id, forKey: "user_id")
        }
        
        print("User ID: \(user_id)")
        
        if let server = UserDefaults.standard.string(forKey: "server") {
            self.server = server
        } else {
            self.server = "http://192.168.1.72:8080"
            UserDefaults.standard.set(self.server, forKey: "server")
        }
        
        if let hubs = UserDefaults.standard.stringArray(forKey: "hubs") {
            self.hubs = hubs
        } else {
            self.hubs = ["0c0375dc-eba7-4e94-9706-f572d1ef6521","9f6d21c5-f5b1-4bf1-b0e2-add0567d49b5"]
            UserDefaults.standard.set(self.hubs, forKey: "hubs")
        }
        
        if let servers = UserDefaults.standard.array(forKey: "servers") as? [Server] {
            self.servers = servers
        } else {
            self.servers = [Server(address: "http://192.168.1.72:8080", hubs: ["0c0375dc-eba7-4e94-9706-f572d1ef6521","9f6d21c5-f5b1-4bf1-b0e2-add0567d49b5"])]
        }
    }
}

struct GeneralSettingsView: View {
    private var server = Binding<String>(
        get: {
            if let server = UserDefaults.standard.string(forKey: "server") {
                return server
            } else {
                UserDefaults.standard.set("http://0.0.0.0:8080", forKey: "server")
                return "http://0.0.0.0:8080"
            }
        },
        set: {
            UserDefaults.standard.set($0, forKey: "server")
        }
    )
    
    private var user_id = Binding<String>(
        get: {
            if let uuid = UserDefaults.standard.string(forKey: "user_id") {
                return uuid
            } else {
                let uuid = UUID.init().uuidString
                UserDefaults.standard.set(uuid, forKey: "user_id")
                return uuid
            }
        },
        set: {
            UserDefaults.standard.set($0, forKey: "user_id")
        }
    )
    
    var body: some View {
        Form {
            TextField("Server Address", text: server)
            TextField("User ID", text: user_id)
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}

extension AppConfig {
    func save() {
        UserDefaults.standard.set(self.server, forKey: "server")
        UserDefaults.standard.set(self.user_id, forKey: "user_id")
        UserDefaults.standard.set(self.hubs, forKey: "hubs")
        UserDefaults.standard.set(self.servers, forKey: "servers")
    }
}
