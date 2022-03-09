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

struct ConfigDefaults {
    public static let user_id = UUID.init().uuidString
    public static let server = "http://192.168.192.2:8080"
    public static let hubs = ["0c0375dc-eba7-4e94-9706-f572d1ef6521","9f6d21c5-f5b1-4bf1-b0e2-add0567d49b5"]
    //public static let servers = [Server(address: server, hubs: hubs)]
}

struct AppConfig {
    public static var user_id: UUIDString {
        get {
            if let user_id = UserDefaults.standard.string(forKey: "user_id") {
                return user_id
            } else {
                UserDefaults.standard.set(ConfigDefaults.user_id, forKey: "user_id")
                return ConfigDefaults.user_id
            }
        }
        set (set_to) {
            UserDefaults.standard.set(set_to, forKey: "user_id")
        }
    }
    
    public static var server: String {
        get {
            if let server = UserDefaults.standard.string(forKey: "server") {
                return server
            } else {
                UserDefaults.standard.set(ConfigDefaults.server, forKey: "server")
                return ConfigDefaults.server
            }
        }
        set (set_to) {
            UserDefaults.standard.set(set_to, forKey: "server")
        }
    }
    
    public static var hubs: [UUIDString] {
        get {
            if let hubs = UserDefaults.standard.stringArray(forKey: "hubs") {
                return hubs
            } else {
                UserDefaults.standard.set(ConfigDefaults.hubs, forKey: "hubs")
                return ConfigDefaults.hubs
            }
        }
        set (set_to) {
            UserDefaults.standard.set(set_to, forKey: "hubs")
        }
    }
    
//    public static var servers: [Server] {
//        get {
//            if let servers = UserDefaults.standard.array(forKey: "servers") as? [Server] {
//                return servers
//            } else {
//                UserDefaults.standard.set(ConfigDefaults.servers, forKey: "servers")
//                return ConfigDefaults.servers
//            }
//        }
//        set (set_to) {
//            UserDefaults.standard.set(set_to, forKey: "servers")
//        }
//    }
}

struct GeneralSettingsView: View {
    @AppStorage("server") private var server = ConfigDefaults.server
    @AppStorage("user_id") private var user_id = ConfigDefaults.user_id
    
    var body: some View {
        Form {
            TextField("Server Address", text: $server)
            TextField("User ID", text: $user_id)
        }
        .padding(20)
    }
}
