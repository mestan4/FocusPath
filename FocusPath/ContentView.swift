import SwiftUI
import Lottie

// MARK: - Model
struct Hedef: Identifiable, Codable, Equatable {
    var id = UUID()
    var baslik: String
    var tamamlandi: Bool = false
    var kategori: String = "Genel"
}

struct ContentView: View {
    // MARK: - State Properties
    @State private var yeniHedefMetni = ""
    @State private var secilenKategori = "Genel"
    @State private var silmeOnayiGosterilsin = false
    @State private var silinecekIndexler: IndexSet?
    @State private var konfetiGosterilsin = false
    
    let kategoriler = ["Genel", "İş", "Hobi", "Sağlık"]
    
    // Hafızadan yükleme mantığı
    @State private var planlarim: [Hedef] = {
        if let data = UserDefaults.standard.data(forKey: "KayitliHedefler"),
           let decoded = try? JSONDecoder().decode([Hedef].self, from: data) {
            return decoded
        }
        return []
    }()
    
    // MARK: - Computed Properties (Hesaplamalar)
    var toplamHedef: Int { planlarim.count }
    var tamamlananHedef: Int { planlarim.filter { $0.tamamlandi }.count }
    var basariYuzdesi: Double { toplamHedef > 0 ? Double(tamamlananHedef) / Double(toplamHedef) : 0 }
    
    var cubukRengi: Color {
        switch basariYuzdesi {
        case 0..<0.25: return .red
        case 0.25..<0.50: return .orange
        case 0.50..<0.75: return .yellow
        case 0.75..<1.0: return .green
        default: return .blue
        }
    }
    
    var tebrikMesaji: String {
        if basariYuzdesi == 0 { return "Harekete geçme vakti!" }
        else if basariYuzdesi < 0.5 { return "Güzel başlangıç, devam et." }
        else if basariYuzdesi < 1.0 { return "Neredeyse bitti, harikasın!" }
        else { return "Tebrikler, tüm hedefler tamamlandı! 🏆" }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack { // 1. Katman: Arka Plan ve İçerik
                VStack(spacing: 0) {
                    // Üst Bölüm: İlerleme Raporu
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Günün Başarı Oranı")
                            .font(.headline)
                        
                        ProgressView(value: basariYuzdesi)
                            .tint(cubukRengi)
                            .scaleEffect(y: 1.2)
                            .animation(.spring(), value: basariYuzdesi)
                        
                        Text(tebrikMesaji)
                            .font(.caption)
                            .italic()
                            .foregroundColor(cubukRengi)
                        
                        HStack {
                            Text("Başarı: %\(Int(basariYuzdesi * 100))")
                            Spacer()
                            Text("\(tamamlananHedef) / \(toplamHedef)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(Color(UIColor.systemBackground))
                    
                    List {
                        Picker("Kategori", selection: $secilenKategori) {
                            ForEach(kategoriler, id: \.self) { kat in
                                Text(kat)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 5)
                        
                        Section(header: Text("Yeni Hedef Ekle")) {
                            HStack {
                                TextField("Yeni hedefinizi giriniz...", text: $yeniHedefMetni)
                                    .textFieldStyle(.plain)
                                    .onSubmit { ekle() }
                                
                                if !yeniHedefMetni.isEmpty {
                                    Button(action: ekle) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.title2)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Planlarım")) {
                            ForEach($planlarim) { $plan in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plan.baslik)
                                            .strikethrough(plan.tamamlandi)
                                            .foregroundColor(plan.tamamlandi ? .secondary : .primary)
                                            .font(.body)
                                        
                                        Text(plan.kategori)
                                            .font(.caption2)
                                            .bold()
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(kategoriRengi(kat: plan.kategori).opacity(0.15))
                                            .foregroundColor(kategoriRengi(kat: plan.kategori))
                                            .cornerRadius(6)
                                    }
                                    Spacer()
                                    Image(systemName: plan.tamamlandi ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(plan.tamamlandi ? .green : .gray)
                                        .font(.title3)
                                        .onTapGesture {
                                            plan.tamamlandi.toggle()
                                        }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: SilKaydir)
                        }
                    }
                }
                
                // 2. Katman: Konfeti (Sadece tetiklendiğinde en üstte görünür)
                if konfetiGosterilsin {
                    LottieView(name: "celebration")
                        .id("celebration_view")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .zIndex(10)
                }
            }
            .navigationTitle("Focus Path")
            .onChange(of: planlarim) { _ in
                kaydet()
                if basariYuzdesi == 1.0 {
                    konfetiGosterilsin = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        konfetiGosterilsin = false
                    }
                }
            }
            .alert("Emin misiniz?", isPresented: $silmeOnayiGosterilsin) {
                Button("Evet, Sil", role: .destructive) {
                    if let offsets = silinecekIndexler {
                        planlarim.remove(atOffsets: offsets)
                    }
                }
                Button("Vazgeç", role: .cancel) { }
            } message: {
                Text("Bu hedefi silmek istediğinizden emin misiniz?")
            }
        }
    }
    
    // MARK: - Functions
    func ekle() {
        if !yeniHedefMetni.isEmpty {
            let yeniHedef = Hedef(baslik: yeniHedefMetni, kategori: secilenKategori)
            planlarim.append(yeniHedef)
            yeniHedefMetni = ""
        }
    }
    
    func kaydet() {
        if let encoded = try? JSONEncoder().encode(planlarim) {
            UserDefaults.standard.set(encoded, forKey: "KayitliHedefler")
        }
    }
    
    func kategoriRengi(kat: String) -> Color {
        switch kat {
        case "İş": return .blue
        case "Hobi": return .orange
        case "Sağlık": return .red
        default: return .green
        }
    }
    
    func SilKaydir(at offsets: IndexSet) {
        silinecekIndexler = offsets
        silmeOnayiGosterilsin = true
    }
}

// MARK: - LottieView Bridge
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

#Preview {
    ContentView()
}
