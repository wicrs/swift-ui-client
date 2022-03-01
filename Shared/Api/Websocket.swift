//
//  Websocket.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-02-28.
//

import Foundation
import SwiftUI

extension WICRSClient {
    static func subscribe_hub(hub_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"SubscribeHub\":{\"hub_id\":\"\(hub_id)\"}}"), completionHandler: {err in
            print(err!.localizedDescription)
            exit(1)
        })
    }
    
    static func unsubscribe_hub(hub_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"UnsubscribeHub\":{\"hub_id\":\"\(hub_id)\"}}"), completionHandler: {err in
            print(err!.localizedDescription)
            exit(1)
        })
    }
    
    static func subscribe_channel(hub_id: UUIDString, channel_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"SubscribeChannel\":{\"hub_id\":\"\(hub_id)\",\"channel_id\":\"\(channel_id)\"}}"), completionHandler: {err in
            print(err!.localizedDescription)
            exit(1)
        })
    }
    
    static func unsubscribe_channel(hub_id: UUIDString, channel_id: UUIDString) {
        WICRSClient.websocket.send(.string("{\"UnsubscribeChannel\":{\"hub_id\":\"\(hub_id)\",\"channel_id\":\"\(channel_id)\"}}"), completionHandler: {err in
            print(err!.localizedDescription)
            exit(1)
        })
    }
}

extension AppState {    
    func listen() async throws {
        while await WICRSClient.websocket.state == .running {
            let message = try await WICRSClient.websocket.receive()
            if case let .string(thing) = message {
                print(thing)
            }
        }
    }
}
