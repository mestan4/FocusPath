//
//  ContentView.swift
//  FocusPath
//
//  Created by Tolgahan Mestan on 10.01.2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var hedefSayisi = 0
    @State private var planlarim = ["SwiftUI Mantığını Kavramak.", "Github Commitlerini Yapmak.", "Viskiyi Tazele."]
    @State private var yeniHedefMetni = ""
    
    var body: some View {
        NavigationStack {
            List{
                //burada yeni hedeflerimizi ekliyoruz
                Section(header: Text("Yeni Hedef Ekle")){
                    HStack{
                        TextField("Yeni Hedefinizi Giriniz...", text: $yeniHedefMetni)
                            .textFieldStyle(.plain)
                        
                        //eger kutu boş değilse listeye ekle
                        if !yeniHedefMetni.isEmpty {
                            Button(action: {
                                
                                planlarim.append(yeniHedefMetni)
                                yeniHedefMetni = "" //kutuyu temizle
                                
                            }) {
                                Image (systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                //bu bölümde liste gösterimini elde ediyorum
                    Section(header: Text("Planlarım:")){
                        // ForEach: 'planlarım' dizisindeki her bir öge için bir satır oluşturur
                        ForEach(planlarim, id: \.self) { plan in
                            Text(plan)
                        }
                        .onDelete(perform: SilKaydir)
                        
                    }
                
                // buton ve durum bölümü
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
        }
        .navigationTitle("Focus Path")

        }
    
    func SilKaydir(at offsets: IndexSet) {
        planlarim.remove(atOffsets: offsets)
        hedefSayisi += 1
    }
    }

    
#Preview {
        ContentView()
    }

