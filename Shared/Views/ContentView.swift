//
//  ContentView.swift
//  Shared
//
//  Created by Willem Leitso on 2022-01-09.
//

import SwiftUI

struct ContentView: View {
    @Binding var hubs: [UUIDString:Hub]
    
    var body: some View {
        HubList(hubs: $hubs)
#if os(iOS)
            .navigationViewStyle(.stack)
#endif
    }
}

#if (DEBUG)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewPreviewWrapper()
    }
}

struct ContentViewPreviewWrapper: View {
    @State var hubs = create_preview_hubs()
    
    var body: some View {
        ContentView(hubs: $hubs)
    }
}
#endif
