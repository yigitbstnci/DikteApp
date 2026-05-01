import SwiftUI
import AppKit
import Combine

func extractBodyAndFooter(_ mergedOutput: String) -> (body: String, footer: String?) {
    if let range = mergedOutput.range(of: "\n\nAttachments [each file") {
        let body = String(mergedOutput[..<range.lowerBound])
        let footer = String(mergedOutput[range.upperBound...])
        return (body, footer)
    }
    return (mergedOutput, nil)
}

private let superscriptToInt: [Character: Int] = [
    "⁰": 0, "¹": 1, "²": 2, "³": 3, "⁴": 4,
    "⁵": 5, "⁶": 6, "⁷": 7, "⁸": 8, "⁹": 9
]

private func buildAnnotatedAttributedString(body: String, clipboardItems: [ClipboardItem]) -> AttributedString {
    let sortedItems = clipboardItems.sorted { $0.timestamp < $1.timestamp }

    var result = AttributedString(body)
    result.font = .system(size: 13, design: .rounded)
    result.foregroundColor = .white

    let pattern = "\\[focus-context ([⁰¹²³⁴⁵⁶⁷⁸⁹]+)\\]"
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return result
    }

    let nsString = body as NSString
    let matches = regex.matches(in: body, range: NSRange(location: 0, length: nsString.length))

    for match in matches.reversed() {
        guard match.numberOfRanges >= 2,
              let range = Range(match.range, in: body),
              let indexRange = Range(match.range(at: 1), in: body) else { continue }

        let superscriptDigits = String(body[indexRange])
        var index = 0
        for char in superscriptDigits {
            if let digit = superscriptToInt[char] {
                index = index * 10 + digit
            }
        }

        guard index >= 1, index <= sortedItems.count else { continue }
        let item = sortedItems[index - 1]

        let chipColor: Color
        switch item.type {
        case .image: chipColor = Color(hex: "BF5AF2").opacity(0.85)
        case .url: chipColor = Color(hex: "32D6FB").opacity(0.85)
        case .text: chipColor = Color(hex: "5E5CE6").opacity(0.85)
        }

        guard Range(match.range, in: result) != nil else { continue }
        var markerAttr = AttributedString(body[range])
        markerAttr.font = .system(size: 10, weight: .bold, design: .rounded)
        markerAttr.foregroundColor = .white
        markerAttr.backgroundColor = chipColor

        let fullMarkerRange = Range(match.range, in: result)!
        result.replaceSubrange(fullMarkerRange, with: markerAttr)
    }

    return result
}

struct PopoverContent: View {
    let item: ClipboardItem

    private var previewImage: Image? {
        guard item.type == .image,
              let path = item.imageFilePath,
              let nsImage = NSImage(contentsOfFile: path) else {
            return nil
        }
        return Image(nsImage: nsImage)
    }

    private var imageLoadFailed: Bool {
        item.type == .image && previewImage == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = previewImage {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 420, maxHeight: 280)
                    .cornerRadius(6)
            } else if imageLoadFailed {
                VStack(spacing: 6) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.dzTextMuted)
                    Text("Görsel yüklenemedi")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.dzTextMuted)
                }
                .frame(maxWidth: 200, maxHeight: 120)
            }

            if item.type != .image {
                ScrollView {
                    if let text = item.textContent, !text.isEmpty {
                        Text(text)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.dzTextPrimary)
                            .frame(maxWidth: 340, alignment: .leading)
                    }
                }
                .frame(maxWidth: 340, maxHeight: 260)
            }

            HStack(spacing: 4) {
                if let app = item.sourceApp {
                    Text(app)
                        .font(.system(size: 9, design: .rounded))
                        .foregroundColor(.dzTextMuted)
                }
                Text("•")
                    .foregroundColor(.dzTextMuted)
                Text(item.formattedFileSize)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(.dzTextMuted)
                if item.type == .image, let path = item.imageFilePath {
                    Text("•")
                        .foregroundColor(.dzTextMuted)
                    Text((path as NSString).lastPathComponent)
                        .font(.system(size: 9, design: .rounded))
                        .foregroundColor(.dzTextMuted)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .frame(minWidth: 200, maxWidth: 460)
        .background(Color.dzBackgroundGlass)
    }
}

struct HistoryView: View {
    @State private var entries: [HistoryEntry] = []
    @State private var searchIndex: [UUID: String] = [:]
    @State private var selectedID: UUID?
    @State private var searchText: String = ""
    @Environment(AppState.self) private var appState

    private let historyStore = HistoryStore()
    @State private var cancellable: AnyCancellable?

    @State private var showClearOldConfirmation = false
    @State private var showClearAllConfirmation = false

    var filteredEntries: [HistoryEntry] {
        if searchText.isEmpty {
            return entries
        }
        return entries.filter {
            (searchIndex[$0.id] ?? $0.historySearchText).localizedCaseInsensitiveContains(searchText)
        }
    }

    var selectedEntry: HistoryEntry? {
        entries.first { $0.id == selectedID }
    }

    var body: some View {
        HStack(spacing: 0) {
            listPanel
                .frame(width: 240)

            Divider()
                .frame(width: 1)
                .background(Color.dzBorder)

            detailPanel
                .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 680, minHeight: 480)
        .glassPanel(radius: 18)
        .onAppear {
            setEntries(historyStore.load())
            if selectedID == nil, let first = entries.first {
                selectedID = first.id
            }
            setupNotification()
        }
        .onDisappear {
            cancellable?.cancel()
        }
        .alert("7 günden eski kayıtlar silinsin mi?", isPresented: $showClearOldConfirmation) {
            Button("Vazgeç", role: .cancel) {}
            Button("Sil", role: .destructive) {
                historyStore.prune(olderThanDays: 7)
                setEntries(historyStore.load())
                selectedID = entries.first?.id
                DikteLog.action("history", "cleanup.manual", "7 günden eski kayıtlar temizlendi.", metadata: [:])
            }
        } message: {
            Text("Bu işlem transkripsiyonları, geçmiş kayıtlarını ve ilgili clipboard görsel/metin dosyalarını kalıcı olarak siler.")
        }
        .alert("Tüm geçmiş silinsin mi?", isPresented: $showClearAllConfirmation) {
            Button("Vazgeç", role: .cancel) {}
            Button("Tümünü Sil", role: .destructive) {
                historyStore.clearAll()
                setEntries(historyStore.load())
                selectedID = nil
                DikteLog.action("history", "cleanup.manual", "Tüm geçmiş temizlendi.", metadata: [:])
            }
        } message: {
            Text("Bu işlem transkripsiyonları, geçmiş kayıtlarını ve ilgili clipboard görsel/metin dosyalarını kalıcı olarak siler.")
        }
    }

    private func setupNotification() {
        cancellable = NotificationCenter.default.publisher(for: .historyDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [self] _ in
                let previousID = selectedID
                setEntries(historyStore.load())
                if searchText.isEmpty {
                    if let topEntry = entries.first, previousID != topEntry.id {
                        selectedID = topEntry.id
                    }
                } else {
                    selectedID = previousID.flatMap { id in entries.first { $0.id == id }?.id }
                }
            }
    }

    private func setEntries(_ newEntries: [HistoryEntry]) {
        entries = newEntries
        searchIndex = Dictionary(uniqueKeysWithValues: newEntries.map { entry in
            (entry.id, entry.historySearchText)
        })
    }

    private var listPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.dzGradientAccent)
                Text("Geçmiş")
                    .font(.dzHeading())
                    .foregroundColor(.dzTextPrimary)
                Spacer()
                if !entries.isEmpty {
                    Menu {
                        Button(action: {
                            showClearOldConfirmation = true
                        }) {
                            Label("7 günden eski kayıtları temizle", systemImage: "calendar.badge.minus")
                        }

                        Button(role: .destructive, action: {
                            showClearAllConfirmation = true
                        }) {
                            Label("Tüm geçmişi temizle", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.dzTextMuted)
                    }
                    .fixedSize()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
                .background(Color.dzBorder)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.dzTextMuted)
                    .font(.system(size: 11))
                TextField("Ara...", text: $searchText)
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.dzSurfaceGlass)
            .cornerRadius(6)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()
                .background(Color.dzBorder)

            if filteredEntries.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .font(.system(size: 28))
                        .foregroundColor(.dzTextMuted)
                    Text("Henüz kayıt yok")
                        .font(.dzBody())
                        .foregroundColor(.dzTextMuted)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredEntries) { entry in
                            entryRow(entry)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
        .background(Color.dzBackgroundGlass)
    }

    private func entryRow(_ entry: HistoryEntry) -> some View {
        let isSelected = selectedID == entry.id
        return Button(action: {
            selectedID = entry.id
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.formattedDate)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.dzTextPrimary)
                    .lineLimit(1)

                Text(entry.formattedDuration)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.dzTextMuted)

                Text(entry.transcriptText)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.dzTextMuted)
                    .lineLimit(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.dzSurfaceGlass : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var detailPanel: some View {
        VStack(spacing: 0) {
            if let entry = selectedEntry {
                detailContent(entry)
            } else {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "text.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.dzTextMuted)
                    Text("Kayıt seçin")
                        .font(.dzBody())
                        .foregroundColor(.dzTextPrimary)
                }
                Spacer()
            }
        }
        .background(Color.dzBackgroundGlass)
    }

    private func detailContent(_ entry: HistoryEntry) -> some View {
        let (bodyText, _) = extractBodyAndFooter(entry.mergedOutput)
        let attributedBody = buildAnnotatedAttributedString(body: bodyText, clipboardItems: entry.clipboardItems)

        return VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.formattedDate)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.dzTextPrimary)
                    Text(entry.formattedDuration)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.dzTextMuted)
                }
                Spacer()
                Button(action: {
                    copyOutput(entry)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11))
                        Text("Kopyala")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.dzPrimary)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button(action: {
                    historyStore.delete(id: entry.id)
                    setEntries(historyStore.load())
                    selectedID = entries.first?.id
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.dzTextMuted)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
                .background(Color.dzBorder)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(attributedBody)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)

                    if !entry.clipboardItems.isEmpty {
                        Divider()
                            .background(Color.dzBorder)

                        Text("Ekler")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.dzTextMuted)
                            .textCase(.uppercase)

                        VStack(spacing: 4) {
                            ForEach(Array(entry.clipboardItems.enumerated()), id: \.element.id) { index, item in
                                AttachmentRow(index: index + 1, item: item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    private func copyOutput(_ entry: HistoryEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entry.mergedOutput, forType: .string)
        DikteLog.action("history", "output.copied", "Geçmiş çıktısı panoya kopyalandı.", metadata: [
            "chars": entry.mergedOutput.count,
            "entry_id": entry.id.uuidString
        ])
    }
}

private extension HistoryEntry {
    var historySearchText: String {
        transcriptText + "\n" + mergedOutput
    }
}

struct AttachmentRow: View {
    let index: Int
    let item: ClipboardItem
    @State private var isPopoverPresented = false

    private static let superscriptDigits = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]

    private var superscriptIndex: String {
        Self.superscriptDigits.indices.contains(index) ? Self.superscriptDigits[index] : "\(index)"
    }

    private var chipColor: Color {
        switch item.type {
        case .image: return Color(hex: "BF5AF2").opacity(0.85)
        case .url: return Color(hex: "32D6FB").opacity(0.85)
        case .text: return Color(hex: "5E5CE6").opacity(0.85)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                Text(superscriptIndex)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(item.attachmentPath)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)

                if let sourceApp = item.sourceApp {
                    Text("[\(sourceApp)]")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("(\(item.formattedFileSize))")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(chipColor)
            .cornerRadius(8)

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
            PopoverContent(item: item)
        }
        .onHover { hovering in
            isPopoverPresented = hovering
        }
    }
}
