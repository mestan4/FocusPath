import SwiftUI

struct Hedef: Identifiable {
    let id = UUID()
    var baslik: String
    var tamamlandi: Bool = false
}

struct ContentView: View {
    
    @State private var hedefSayisi = 0
    @State private var yeniHedefMetni = ""
    @State private var planlarim = [
        Hedef(baslik:"SwiftUI Mantığını Kavramak."),
        Hedef(baslik:"Yarın Sinemaya Gitmek."),
        Hedef(baslik:"180 Sayfa Kitap Okumak.")
    ]
    
    @State private var silmeOnayiGosterilsin = false
    @State private var silinecekIndexler: IndexSet?
    
    // Toplam hedef sayısı
    var toplamHedef: Int {
        planlarim.count
    }

    // Tamamlanan hedef sayısı
    var tamamlananHedef: Int {
        planlarim.filter { $0.tamamlandi }.count
    }

    // Başarı yüzdesi (0.0 ile 1.0 arası)
    var basariYuzdesi: Double {
        toplamHedef > 0 ? Double(tamamlananHedef) / Double(toplamHedef) : 0
    }
    
    var body: some View {
        NavigationStack {
            
            Section {
                VStack(alignment: .leading, spacing: 12) { // Rakamlar ve yazı arası boşluk eski haline döndü
                    Text("Günün Başarı Oranı")
                        .font(.headline) // Eski büyük hali
                    
                    ProgressView(value: basariYuzdesi)
                        .tint(basariYuzdesi == 1.0 ? .green : .blue)
                        //.padding(.horizontal, 25) // Çubuğu yanlardan iyice daralttık
                        .scaleEffect(y: 1.2) // Çubuğu biraz kalın tutuyoruz
                    
                    HStack {
                        Text("Başarı: %\(Int(basariYuzdesi * 100))")
                        Spacer()
                        Text("\(tamamlananHedef) / \(toplamHedef)")
                    }
                    .font(.subheadline) // Eski okunaklı hali
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            
            List {
                // Yeni hedef ekleme bölümü
                Section(header: Text("Yeni Hedef Ekle")) {
                    HStack {
                        TextField("Yeni Hedefinizi Giriniz...", text: $yeniHedefMetni)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                if !yeniHedefMetni.isEmpty {
                                    // DÜZELTME: Hedef objesi olarak ekliyoruz
                                    planlarim.append(Hedef(baslik: yeniHedefMetni))
                                    yeniHedefMetni = ""
                                }
                            }
                        
                        if !yeniHedefMetni.isEmpty {
                            Button(action: {
                                // DÜZELTME: Hedef objesi olarak ekliyoruz
                                planlarim.append(Hedef(baslik: yeniHedefMetni))
                                yeniHedefMetni = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                // Liste gösterimi
                Section(header: Text("Planlarım:")) {
                    ForEach($planlarim) { $plan in
                        HStack {
                            Image(systemName: plan.tamamlandi ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(plan.tamamlandi ? .green : .gray)
                                .onTapGesture {
                                    plan.tamamlandi.toggle()
                                }
                            
                            Text(plan.baslik)
                                .strikethrough(plan.tamamlandi)
                                .foregroundColor(plan.tamamlandi ? .secondary : .primary)
                        }
                    }
                    .onDelete(perform: SilKaydir) // DÜZELTME: onDelete yeri burası
                }
                
                // Buton ve durum bölümü
                Section {
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
            .navigationTitle("Focus Path") // DÜZELTME: List'e ait olmalı
            .alert("Emin misin yoldaş?", isPresented: $silmeOnayiGosterilsin) {
                Button("Evet, Sil", role: .destructive) {
                    if let offsets = silinecekIndexler {
                        planlarim.remove(atOffsets: offsets)
                    }
                }
                Button("Vazgeç", role: .cancel) { }
            } message: {
                Text("Bu hedefi silmek devrimci disipline sığmaz, yine de silmek istiyor musun?")
            }
        }
    } // body bitti
    
    func SilKaydir(at offsets: IndexSet) {
        silinecekIndexler = offsets // Silinecek yeri not et
        silmeOnayiGosterilsin = true // Alert penceresini uyandır
    }
}

#Preview {
    ContentView()
}
