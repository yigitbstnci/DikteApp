# Dikte - Tasarımcı Özeti (Design Brief)

## 🎯 Proje Özeti
**Dikte**, kullanıcıların sesli dikte (konuşmayı metne çevirme) yaparken aynı anda kopyaladıkları bağlamları (metin, bağlantı, ekran görüntüsü vb.) zaman damgalarına göre otomatik olarak birleştirip tek bir Markdown çıktısı üreten, **gizlilik odaklı ve tamamen çevrimdışı** çalışan yerel bir **macOS Menü Çubuğu (Menu Bar)** uygulamasıdır.

Özellikle Claude, ChatGPT gibi yapay zeka asistanlarıyla çalışan kullanıcıların iş akışını hızlandırmayı hedefler.

## 🎨 Tasarım Dili ve Hissiyat (Vibe)
- **Native macOS Deneyimi:** Tasarım, Apple'ın Human Interface Guidelines (HIG) standartlarına uygun, macOS'un kendi uygulamasıymış gibi hissettirmelidir.
- **Minimalist ve İşlevsel:** Kullanıcıyı yormayan, sadece gerektiğinde ortaya çıkan bir arayüz.
- **Premium ve Akıcı:** Pürüzsüz geçişler, şık mikro-animasyonlar (hover efektleri, yükleme/işleme animasyonları).
- **Karanlık Mod (Dark Mode) Odaklı:** Geliştirici ve profesyonel kullanıcı kitlesine hitap ettiği için kusursuz bir karanlık mod deneyimi şarttır. (Aydınlık mod da desteklenmelidir).

## 🔄 Kullanıcı Akışı (User Flow)
1. **Bekleme (Idle):** Menü çubuğunda sessizce bekleyen ikon.
2. **Kayıt (Recording):** Kullanıcı kısayola (ör: `⌘⇧Space`) bastığında kayıt başlar. **Ekranın sağ üst köşesinde (yüzen bir HUD şeklinde)** kaydın başladığını belirten dinamik bir tasarım belirir (mikrofon dalgası veya yanan kırmızı bir nokta).
3. **Kopyalama (Context Capture):** Kullanıcı konuşurken metin veya resim kopyaladığında, sağ üstteki bu HUD paneline kopyalanan öğe (örneğin kaynağın ikonu ve adı: "Ghostty" veya "Safari") **yeni bir satır/kart olarak sırayla eklenir.** Kullanıcı böylece konuşurken neleri eklediğini görsel olarak üst üste binen bir listeden takip edebilir.
4. **İşleme (Processing):** Kullanıcı kaydı durdurduğunda AI modelinin çevrimdışı işleme süreci başlar. Sağ üstteki HUD, sürecin hangi aşamada olduğunu adım adım gösteren bir panele dönüşür (örneğin önce `✓ Saved`, sonra `✓ Transcribed` ibareleri belirir).
5. **Tamamlanma (Completed):** İşlem bittiğinde HUD üzerinde `✓ ⌘V to paste` (Yapıştırmaya hazır) bildirimi görünerek metnin panoya kopyalandığını müjdeler ve ardından HUD ekranı pürüzsüz bir animasyonla kaybolur.

## 📋 Tasarlanması Beklenen Ekranlar ve Bileşenler

Tasarımcıdan aşağıdaki bileşenler için Figma (veya benzeri bir araçta) ekranlar ve bileşen state'leri (durumları) hazırlaması beklenmektedir:

### 1. Menü Çubuğu İkonları (Menu Bar Status Icons)
- **Idle (Boşta):** Normal uygulama ikonu.
- **Recording (Kayıtta):** Ses kaydedildiğini belli eden, dikkat çekici ama rahatsız etmeyen ikon (örneğin kırmızı bir nokta veya ses dalgası).
- **Processing (İşleniyor):** AI'ın çalıştığını gösteren animasyonlu ikon (örneğin dönen bir çark veya parlayan bir efekt).
- **Error (Hata):** Mikrofon izni yok veya model yüklenemedi durumu.

### 2. Ana Menü Popover'ı (Main Dropdown/Popover)
Menü çubuğundaki ikona tıklandığında açılacak ana pencere.
*İçerebileceği öğeler:*
- Uygulama başlığı ve versiyonu.
- Büyük/Belirgin bir "Kayda Başla / Kaydı Durdur" butonu (klavye kısayolunu da belirten).
- Son kayıtların kısa bir özeti veya statüsü (Opsiyonel ama hoş olabilir).
- "Çıkış" (Quit) ve "Ayarlar" (Settings) butonları/ikonları.
- (Eğer o sırada işlem yapılıyorsa) İşleme yüzdesi veya yükleme animasyonu.

### 3. Ayarlar Ekranı (Settings View)
macOS standartlarına uygun, sekmeli (tab) veya tek sayfa ayarlar penceresi.
*İçerebileceği öğeler:*
- **Genel (General):** Başlangıçta çalıştır (Launch at login), sabit global klavye kısayolunu gösterme (ör: `⌘⇧Space`).
- **Dil ve Model (Language & Model):** Dikte dili seçimi (Türkçe, İngilizce vb.), AI Modeli durumu (Yüklü / İndiriliyor...).
- **Çıktı (Output):** Markdown formatı ayarları (Örn: Ekleri ¹, ², ³ şeklinde dipnot olarak ekle seçeneği).

### 4. Yüzer Bildirim Paneli (Floating HUD / Dynamic Toast)
Bu bileşen uygulamanın ana etkileşim yüzeylerinden biridir. Ekranın sağ üst köşesinde beliren, kompakt, şık ve dinamik bir pencere tasarımı gerektirir.
*İçerebileceği durumlar (States):*
- **Kayıt Halinde:** Kırmızı ses dalgası animasyonu ve iptal/kapatma (X) butonu.
- **Pano (Clipboard) Eklendiğinde:** Kopyalanan öğenin kaynağı (Uygulama ikonu ve adı, örn: 🟦 Ghostty). Her yeni kopyalamada altına yeni bir öğe eklenerek listelenen bir yığın (stack) tasarımı.
- **Süreç Durumu (Progress):** Kayıt bittiğinde işleme adımlarını (Saved -> Transcribed -> ⌘V to paste) gösteren, adım adım yeşil tik (✓) atan süreç takibi görünümü.

### 5. Geri Bildirimler ve Mikro-Animasyonlar
- HUD öğelerinin (kopyalanan metinlerin vb.) listeye eklenirken göstereceği yaylanma (spring) veya kayma animasyonları.
- Süreç tamamlandığında `⌘V to paste` metninin belirmesiyle oluşan başarılı tamamlanma hissi.

## 🛠 Teknik Çıktı Örneği (Tasarımcıya Kontekst Vermesi İçin)
Uygulamanın günün sonunda ürettiği metin yapısı şu şekildedir:

> Şu an tasarımcıya göndereceğim dökümana bakıyorum, buradaki renk paleti çok güzelmiş¹. Bir de şu web sitesindeki² fontları kullansak nasıl olur?
>
> **--- Eklentiler ---**
> [1]: `![Ekran Görüntüsü](file:///tmp/.../image.png)` *(745 KB)*
> [2]: `https://apple.com/design` *(Safari)*

Tasarımcı bu metnin uygulamanın içindeki (eğer bir geçmiş görünümü tasarlanacaksa) nasıl görüneceğini de hayal edebilir.

---
**Tasarımcıya Not:** Geliştirme süreci SwiftUI ile yapılacaktır. Bu yüzden tasarımların Apple'ın native komponentlerine (SF Symbols, standart corner radius'lar, blur/vibrancy efektleri) uyumlu olması işimizi çok kolaylaştıracaktır.
