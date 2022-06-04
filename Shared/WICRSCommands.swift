//
//  WICRSCommands.swift
//  WICRS Client
//
//  Created by Willem on 2022-03-09.
//

import SwiftUI

struct WICRSCommands: Commands {
    @FocusedBinding(\.selectedHub) var selectedHub
    @FocusedBinding(\.selectedChannel) var selectedChannel
    
    var body: some Commands {
        SidebarCommands()
        
        CommandMenu("Hubs") {
            Button("Leave") {
                if let hub = selectedHub {
                    let _ = try? WICRSClient.http_client.leave_hub(hub_id: hub.id)
                }
            }.disabled(selectedHub == nil)
        }
    }
}

private struct SelectedHubKey: FocusedValueKey {
    typealias Value = Binding<Hub>
}

private struct SelectedChannelKey: FocusedValueKey {
    typealias Value = Binding<Channel>
}

extension FocusedValues {
    var selectedHub: Binding<Hub>? {
        get { self[SelectedHubKey.self] }
        set { self[SelectedHubKey.self] = newValue }
    }
    
    var selectedChannel: Binding<Channel>? {
        get { self[SelectedChannelKey.self] }
        set { self[SelectedChannelKey.self] = newValue }
    }
}
