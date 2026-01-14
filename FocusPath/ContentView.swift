import SwiftUI

struct Hedef: Identifiable, Codable, Equatable {
    let id = UUID()
    var baslik: String
    var tamamlandi: Bool = false
}

struct ContentView: View {  
    
    @State private var hedefSayisi = 0
    @State private var yeniHedefMetni = ""
    // Hafızadan yükle veya boş başlat
        @State private var planlarim: [Hedef] = {
            if let data = UserDefaults.standard.data(forKey: "KayitliHedefler"),
               let decoded = try? JSONDecoder().decode([Hedef].self, from: data) {
                return decoded
            }
            return []
        }()
    
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
    
    // Yüzdeye göre renk belirleyen fonksiyon
    var cubukRengi: Color {
        switch basariYuzdesi {
        case 0..<0.25:
            return .red
        case 0.25..<0.50:
            return .orange
        case 0.50..<0.75:
            return .yellow
        case 0.75..<1.0:
            return .green
        case 1.0:
            return .blue
        default:
            return .gray
        }
    }
    
    var body: some View {
        NavigationStack {
            
            Section {
                VStack(alignment: .leading, spacing: 12) { // Rakamlar ve yazı arası boşluk eski haline döndü
                    Text("Günün Başarı Oranı")
                        .font(.headline) // Eski büyük hali
                    
                    ProgressView(value: basariYuzdesi)
                        .tint(cubukRengi)
                        .scaleEffect(y: 1.2) // Çubuğu biraz kalın tutuyoruz
                        .animation(.spring(), value: basariYuzdesi)

                    // Bu tebrikMesaji'nı da yukarıdaki değişkenlerin oraya eklemelisin:
                    var tebrikMesaji: String {
                        if basariYuzdesi == 0 { return "Harekete geç yoldaş!" }
                        else if basariYuzdesi < 0.5 { return "Güzel başlangıç, devam et." }
                        else if basariYuzdesi < 1.0 { return "Neredeyse bitti, harikasın!" }
                        else { return "Devrim tamamlandı! 🥃" }
                    }
                    
                    Text(tebrikMesaji)
                        .font(.caption)
                        .italic()
                        .foregroundColor(cubukRengi)
                    
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
                
                .onChange(of: planlarim) {
                    if let encoded = try? JSONEncoder().encode(planlarim) {
                        UserDefaults.standard.set(encoded, forKey: "KayitliHedefler")
                    }
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
