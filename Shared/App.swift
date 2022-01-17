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

@main
struct WICRS_ClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    static func main() {
        print("Hello world!")
        let user_id = UUID.init().uuidString
        let http_client = HttpClient(base_url: "http://0.0.0.0:8080", user_id: user_id)
        do {
            let hub_create_result: HttpResponse<UUID> = try! http_client.post(endpoint: "/api/hub", data: HttpHubUpdate.init(name: "test", description: "testing", default_group: nil))!
            let hub: HttpResponse<Hub> = try http_client.get(endpoint: "/api/hub/\(hub_create_result.success!)")!
            if let hub = hub.success {
                print("Hub name: \(hub.name)")
                dump(hub)
            }
            else if let error = hub.error {
                print("API Error: \(error)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
