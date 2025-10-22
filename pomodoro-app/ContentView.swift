//
//  ContentView.swift
//  pomodoro-app
//
//  Created by şeyma nur fansa on 15.10.2025.
//
//
//  ContentView.swift
//  pomodoro-app
//
//  Yenilenen sürüm: tek başlık, düzgün butonlar, düzeltilmiş ağaçlar,
//  ayarlar butonu (⚙️) ve bildirim entegrasyonu.
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final sürüm: tek başlık, düzgün butonlar, bildirim entegrasyonu,
//  gerçekçi ağaçlar (tepe üstte, gövde altta) ve ayarlar (⚙️) butonu.
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: tek başlık, düzgün butonlar, bildirim entegrasyonu,
//  gerçekçi ağaçlar (tepe üstte, gövde altta) ve Ayarlar (⚙️).
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: tek başlık, düzgün butonlar, bildirim entegrasyonu,
//  gerçekçi ağaçlar (tepe üstte, gövde altta) ve Ayarlar (⚙️).
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: beyaz bar yok, arka plan ana ekranla aynı,
//  gerçekçi yeşil tepe + kahverengi gövde ağaç kümesi.
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: beyaz bar yok, arka plan aynı,
//  özel ağaç şekli (bulut formlu tepe + kahverengi gövde/çatallı dallar)
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: beyaz bar yok, arka plan aynı,
//  özel ağaç şekli (bulut tepe + kahverengi gövde/çatallı dallar)
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final v2
//  - Beyaz bar yok, arka plan ana ekranla aynı.
//  - Başta TEK ağaç gösterir. Her tamamlanan Pomodoro ile
//    ağaç sayısı artar ve “orman”a dönüşür (bitişik değil, aralıklı).
//  - Tepe: bulut/çentikli form (yuvarlak değil, estetik).
//  - Gövde: düz (kahverengi) + iki yan dal; dallar tepeye doğru uzar
//    ve tepenin içine girer (üstte kalır).
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Created by şeyma nur fansa on 15.10.2025.
//
//
//  ContentView.swift
//  pomodoro-app
//
//  Yenilenen sürüm: tek başlık, düzgün butonlar, düzeltilmiş ağaçlar,
//  ayarlar butonu (⚙️) ve bildirim entegrasyonu.
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final sürüm: tek başlık, düzgün butonlar, bildirim entegrasyonu,
//  gerçekçi ağaçlar (tepe üstte, gövde altta) ve ayarlar (⚙️) butonu.
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: tek başlık, düzgün butonlar, bildirim entegrasyonu,
//  gerçekçi ağaçlar (tepe üstte, gövde altta) ve Ayarlar (⚙️).
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: tek başlık, düzgün butonlar, bildirim entegrasyonu,
//  gerçekçi ağaçlar (tepe üstte, gövde altta) ve Ayarlar (⚙️).
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: beyaz bar yok, arka plan ana ekranla aynı,
//  gerçekçi yeşil tepe + kahverengi gövde ağaç kümesi.
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: beyaz bar yok, arka plan aynı,
//  özel ağaç şekli (bulut formlu tepe + kahverengi gövde/çatallı dallar)
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final: beyaz bar yok, arka plan aynı,
//  özel ağaç şekli (bulut tepe + kahverengi gövde/çatallı dallar)
//

//
//  ContentView.swift
//  pomodoro-app
//
//  Final v2
//  - Beyaz bar yok, arka plan ana ekranla aynı.
//  - Başta TEK ağaç gösterir. Her tamamlanan Pomodoro ile
//    ağaç sayısı artar ve “orman”a dönüşür (bitişik değil, aralıklı).
//  - Tepe: bulut/çentikli form (yuvarlak değil, estetik).
//  - Gövde: düz (kahverengi) + iki yan dal; dallar tepeye doğru uzar
//    ve tepenin içine girer (üstte kalır).
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Timer Model
final class PomodoroManager: ObservableObject {
    @Published var timeRemaining = 25 * 60
    @Published var isRunning = false
    @Published var isBreak = false
    @Published var completedPomodoros = 0
    @Published var showReward = false

    private var timer: Timer?

    func start() {
        guard !isRunning else { return }
        isRunning = true

        NotificationManager.shared.clearPending()
        NotificationManager.shared.schedulePomodoroEnd(
            after: TimeInterval(timeRemaining),
            title: isBreak ? "Mola bitti" : "Odak tamamlandı",
            body:  isBreak ? "Çalışmaya dönme zamanı." : "Kısa bir mola ver!"
        )

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stop()
                self.playSound()
                self.nextPhase()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        NotificationManager.shared.clearPending()
    }

    func reset() {
        stop()
        timeRemaining = isBreak ? 5 * 60 : 25 * 60
    }

    private func nextPhase() {
        if !isBreak {
            // Odak bitti → kısa mola başlasın
            isBreak = true
            timeRemaining = 5 * 60
            start()
        } else {
            // Mola bitti → yeni odak başlasın diye bekle
            isBreak = false
            completedPomodoros += 1         // <<< ORMANI TETİKLER
            showReward = true
            timeRemaining = 25 * 60
        }
    }

    private func playSound() { AudioServicesPlaySystemSound(1005) }
}

// MARK: - Main View
struct ContentView: View {
    @StateObject private var pomodoro = PomodoroManager()
    @EnvironmentObject var settingsStore: SettingsStore
    @State private var showSettings = false

    private var bgGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: backgroundColors(for: pomodoro.completedPomodoros, isBreak: pomodoro.isBreak)),
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    bgGradient
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 1.2), value: pomodoro.isBreak)
                        .animation(.easeInOut(duration: 1.5), value: pomodoro.completedPomodoros)

                    VStack(spacing: 24) {
                        Text(pomodoro.isBreak ? "Mola Zamanı" : "Odaklanma Zamanı")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 28)

                        TimerRingView(
                            remaining: pomodoro.timeRemaining,
                            total: pomodoro.isBreak ? 5*60 : 25*60,
                            width: min(geo.size.width * 0.68, 340)
                        )

                        HStack(spacing: 14) {
                            TimerButton(label: "Başlat",  systemIcon: "play.fill",  action: pomodoro.start)
                            TimerButton(label: "Duraklat", systemIcon: "pause.fill", action: pomodoro.stop)
                            TimerButton(label: "Sıfırla",  systemIcon: "arrow.clockwise", action: pomodoro.reset)
                        }

                        // Başta 1 ağaç; her tamamlamada bir yenisi eklenir (maks. 7)
                        ForestAreaView(count: max(1, min(1 + pomodoro.completedPomodoros, 7)))
                            .frame(height: 190)
                            .padding(.top, 4)

                        Text("Tamamlanan Pomodoro: \(pomodoro.completedPomodoros)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Spacer(minLength: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)

                    if pomodoro.showReward {
                        RewardView { withAnimation { pomodoro.showReward = false } }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape").foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView(store: settingsStore) }
            // Beyaz şeridi tamamen kaldır
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Tema paleti (Assets’taki isimler)
    private func backgroundColors(for completed: Int, isBreak: Bool) -> [Color] {
        if isBreak { return [Color("MintPastel"), Color("BeigePastel")] }
        return [Color("LavenderPastel"), Color("PeachPastel")]
    }
}

// MARK: - Timer Ring
private struct TimerRingView: View {
    let remaining: Int
    let total: Int
    let width: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.25), lineWidth: 14)
                .frame(width: width)

            Circle()
                .trim(from: 0, to: CGFloat(Double(remaining) / Double(total)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color("Accent1"), Color("Accent2")]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: width)
                .animation(.easeInOut(duration: 0.5), value: remaining)

            Text(String(format: "%02d:%02d", remaining/60, remaining%60))
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 4)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Timer Button
struct TimerButton: View {
    var label: String
    var systemIcon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemIcon)
                Text(label).lineLimit(1).minimumScaleFactor(0.9)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(minWidth: 108)
            .background(.white.opacity(0.22))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Forest Area (1→7 ağaç; aralıklı, bitişik değil)
struct ForestAreaView: View {
    let count: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(.black.opacity(0.10))
                .frame(height: 6)
                .padding(.horizontal, 36)
                .offset(y: 3)

            HStack(alignment: .bottom, spacing: 24) {
                ForEach(0..<count, id: \.self) { i in
                    let base: CGFloat = 62
                    let size = base + CGFloat((i % 3) * 12)
                    SingleTreeStraight(size: size,
                                       trunkColor: Color("TreeTrunk"),
                                       leafStart: Color("Leaf1"),
                                       leafEnd: Color("Leaf2"))
                        .opacity(0.96 - Double(i) * 0.04)
                }
            }
            .padding(.horizontal, 8)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.78), value: count)
    }
}

// MARK: - TEK AĞAÇ (DÜZ GÖVDE + İKİ DAL, DAL UÇLARI TEPEYE GİRER)
struct SingleTreeStraight: View {
    let size: CGFloat
    let trunkColor: Color
    let leafStart: Color
    let leafEnd: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gövde (düz)
            RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                .fill(
                    LinearGradient(colors: [trunkColor.opacity(0.95), trunkColor.opacity(0.75)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: max(10, size * 0.12), height: size * 0.95)
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)

            // Dallar (üstte, tepeye doğru girer)
            Group {
                Capsule()
                    .fill(trunkColor.opacity(0.92))
                    .frame(width: max(8, size * 0.10), height: size * 0.55)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -size * 0.20, y: -size * 0.18)

                Capsule()
                    .fill(trunkColor.opacity(0.92))
                    .frame(width: max(8, size * 0.10), height: size * 0.55)
                    .rotationEffect(.degrees(18))
                    .offset(x:  size * 0.20, y: -size * 0.18)
            }

            // TEPE (bulut/çentikli) – en üst katman
            CloudCanopy()
                .fill(
                    LinearGradient(colors: [leafStart, leafEnd],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: size * 1.35, height: size * 1.05)
                .offset(y: -size * 0.35)
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 4)
                .overlay(
                    CloudCanopy()
                        .stroke(.white.opacity(0.12), lineWidth: max(1, size * 0.018))
                        .blur(radius: 0.4)
                        .offset(y: -size * 0.35)
                )
        }
        .accessibilityLabel("Ağaç")
    }
}

// MARK: - Canopy Shape (bulut/çentikli, yuvarlak değil)
struct CloudCanopy: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        // dış kontur – üstte geniş, altta daha düz
        p.move(to: CGPoint(x: w * 0.12, y: h * 0.70))
        p.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.45), control: CGPoint(x: w * 0.08, y: h * 0.52))
        p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.28), control: CGPoint(x: w * 0.32, y: h * 0.25))
        p.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.45), control: CGPoint(x: w * 0.68, y: h * 0.24))
        p.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.72), control: CGPoint(x: w * 0.92, y: h * 0.55))
        p.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.72), control: CGPoint(x: w * 0.50, y: h * 0.96))
        p.closeSubpath()

        // iç yumuşatma lobları (dolgu ile birleşip bulut hissi verir)
        func addCircle(_ center: CGPoint, _ r: CGFloat) {
            p.addArc(center: center, radius: r, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        }
        let r1 = min(w, h) * 0.30
        let r2 = r1 * 0.78
        let r3 = r1 * 0.68

        addCircle(CGPoint(x: w * 0.50, y: h * 0.38), r1)   // orta
        addCircle(CGPoint(x: w * 0.30, y: h * 0.50), r2)   // sol
        addCircle(CGPoint(x: w * 0.70, y: h * 0.50), r2)   // sağ
        addCircle(CGPoint(x: w * 0.40, y: h * 0.70), r3)   // alt sol
        addCircle(CGPoint(x: w * 0.60, y: h * 0.70), r3)   // alt sağ

        return p
    }
}

// MARK: - Reward
struct RewardView: View {
    var onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Harika!")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundColor(.white)

                Text("Bir fidan diktin 🌿")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Image(systemName: "leaf.fill")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("Leaf1"))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            scale = 1; opacity = 1
                        }
                    }

                Button("Devam Et") { onDismiss() }
                    .padding(.horizontal, 30).padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsStore())
}

