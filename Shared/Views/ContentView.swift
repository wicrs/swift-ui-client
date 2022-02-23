//
//  ContentView.swift
//  Shared
//
//  Created by Willem Leitso on 2022-01-09.
//

import SwiftUI

struct ContentView: View {
    var hubs: [Hub]
    
    var body: some View {
        HubList(hubs: hubs)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(hubs: create_preview_hubs())
        }
    }
}
