//
//  ContentView.swift
//  FocusPath
//
//  Created by Tolgahan Mestan on 10.01.2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var hedefSayisi = 0
    
    var body: some View {
        NavigationStack {
            List{
                Section(header: Text("Durum")){
                    Text("Tamamlanan Hedef: \(hedefSayisi)")
                        .font(.title3)
                        .bold()
                }
                Section(header: Text("Planlarım.")){
                    Text("SwiftUI Mantığını Kavramak.")
                    Text("Github Commitlerini Yapmak.")
                    Text("Viskiyi Tazele.")
                }
                
                Button(action: {
                    hedefSayisi += 1
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Bir hedef daha tamamlandı!")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Focus Path")
        }
    }
}

#Preview {
    ContentView()
}
