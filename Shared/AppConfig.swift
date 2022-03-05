//
//  AppConfig.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-03-04.
//

import Foundation

struct AppConfig {
    public var user_id: UUIDString
    public var server: String
    public var hubs: [UUIDString] // [ String : [ Hub.ID ] ]
    
    init() {
        if let user = UserDefaults.standard.string(forKey: "user_id") {
            self.user_id = user
        } else {
            self.user_id = "7EF6EFB7-75CF-40EF-BD9F-44B5C2A3BE5D"
            UserDefaults.standard.set(self.user_id, forKey: "user_id")
        }
        
        if let server = UserDefaults.standard.string(forKey: "server") {
            self.server = server
        } else {
            self.server = "http://0.0.0.0:8080"
            UserDefaults.standard.set(self.server, forKey: "server")
        }
        
        if let hubs = UserDefaults.standard.stringArray(forKey: "hubs") {
            self.hubs = hubs
        } else {
            self.hubs = ["0c0375dc-eba7-4e94-9706-f572d1ef6521","9f6d21c5-f5b1-4bf1-b0e2-add0567d49b5"]
            UserDefaults.standard.set(self.hubs, forKey: "hubs")
        }
    }
}

extension AppConfig {
    func save() {
        UserDefaults.standard.set(self.server, forKey: "server")
        UserDefaults.standard.set(self.user_id, forKey: "user_id")
        UserDefaults.standard.set(self.hubs, forKey: "hubs")
    }
}
