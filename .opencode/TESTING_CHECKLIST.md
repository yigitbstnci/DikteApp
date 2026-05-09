# MYB Software Studio System Test Checklist

Bu checklist’i `newsystem/` yapısını eski veya mevcut bir projede test ederken kullan.

## 1. Kurulum Öncesi

- [ ] Hedef projede mevcut `AGENTS.md` var mı kontrol et.
- [ ] Projede README/docs, package/config dosyaları ve test/build dosyaları var mı not al.
- [ ] `newsystem/` klasörünü hedef projeye kopyala.
- [ ] `SYSTEM_ROOT` değerini belirle:

```text
SYSTEM_ROOT = ./newsystem
```

Eğer `system-manifest.json` proje root’una yerleştirildiyse:

```text
SYSTEM_ROOT = .
```

## 2. Init Project Dry Run

- [ ] `/init-project --dry-run` çalıştır.
- [ ] Existing/fresh project mode’unu doğru tespit ediyor mu kontrol et.
- [ ] Framework/tech stack sinyallerini doğru yakalıyor mu kontrol et.
- [ ] Varsa package manager, test/build/lint komutlarını tespit ediyor mu kontrol et.
- [ ] `AGENTS.md` var/yok bilgisini raporluyor mu kontrol et.
- [ ] Confidence score ve missing information alanlarını incele.

## 3. AGENTS Merge Davranışı

- [ ] Mevcut `AGENTS.md` üzerine yazılmıyor.
- [ ] `AGENTS_TEMPLATE.md` merge rehberi olarak kullanılıyor.
- [ ] Hedef proje talimatları daha yüksek öncelikli kabul ediliyor.
- [ ] Preview ve approval olmadan yazma işlemi yapılmıyor.

## 4. Context Oluşturma

- [ ] `/init-project --existing` sadece faydalı olduğunda proje context’i öneriyor.
- [ ] Önerilen context yapısı gereksiz derecede büyük değil.
- [ ] Navigation dosyaları şu formatı takip ediyor:

```text
Purpose → Structure → Quick Routes → By Concern/Type → Related Context
```

- [ ] Proje context’i tech stack, komutlar, mimari, kısıtlar ve workflow boşluklarını yakalıyor.

## 5. Path Resolution

- [ ] Agent navigation dosyasını `{SYSTEM_ROOT}/context/navigation.md` üzerinden çözüyor.
- [ ] `navigation.md` bulunamazsa önce `SYSTEM_ROOT` değerini kontrol ediyor.
- [ ] Runtime working directory’yi sistem root’u varsaymıyor.

## 6. Agent Recommendation

Test prompt:

```text
Bu projeye dashboard ve component-based frontend development eklemek istiyorum.
```

- [ ] Olası frontend capability gap’i tespit ediyor.
- [ ] Frontend Agent’ın neden faydalı olabileceğini açıklıyor.
- [ ] Otomatik agent oluşturmuyor.
- [ ] Context gereksinimlerini soruyor.
- [ ] Seçenek sunuyor: plan oluştur, orchestrator ile devam et, sadece context oluştur veya iptal.

## 7. Create Agent Flow

Test command:

```text
/create-agent frontend-agent
```

- [ ] Yeni agent gerçekten gerekli mi kontrol ediyor.
- [ ] Frontend context sorularını soruyor: framework, UI library, styling, component pattern, accessibility.
- [ ] Yazmadan önce agent/context/workflow/manifest etkisini preview ediyor.
- [ ] Onaylı değişikliklerden sonra `/check-context-deps` öneriyor.

## 8. Update Agent Flow

Test command:

```text
/update-agent myb-orchestrator "Bu projede test komutlarını çalıştırmadan önce onay istesin"
```

- [ ] Kullanıcı talebini anlıyor.
- [ ] Kuralın kalıcı olup olmadığını tespit ediyor.
- [ ] Davranış değiştiren kuralları ilgili agent/command prompt’una işlemeyi öneriyor.
- [ ] Kritik davranış kurallarını sadece context’e kaydetmeyi önermiyor.
- [ ] Düzenleme yapmadan önce approval istiyor.

## 9. Persistent Rule Handling

Test prompt:

```text
Bundan sonra bu projede navigation dosyaları Structure → Quick Routes → By Concern → Related Context formatını kullansın.
```

- [ ] Kalıcı kural olduğunu tespit ediyor.
- [ ] Kalıcı hale getirmek isteyip istemediğini soruyor.
- [ ] Doğru hedef dosyayı öneriyor: AGENTS.md, orchestrator, command, workflow veya context guide.
- [ ] Yazmadan önce approval istiyor.

## 10. Dependency Check

Test command:

```text
/check-context-deps
```

- [ ] `system-manifest.json` içinde listelenen dosyaları doğruluyor.
- [ ] Agent/command context dependency’lerini kontrol ediyor.
- [ ] Bozuk veya eksik dependency’leri raporluyor.
- [ ] Approval olmadan auto-fix yapmıyor.

## 11. Genel Kalite

- [ ] Varsayılan olarak çok fazla dosya okumaktan kaçınıyor.
- [ ] Eksik bilgiyi tahmin etmek yerine soruyor.
- [ ] Hedef proje kurallarını MYB template kurallarından üstün tutuyor.
- [ ] `SYSTEM_ROOT` değerini tutarlı şekilde kullanıyor.
- [ ] Ürettiği planları küçük ve uygulanabilir tutuyor.
- [ ] Gereksiz agent önermiyor.
- [ ] Yazma işlemlerinden önce preview ve approval kullanıyor.

## Başarı Kriterleri

Sistem başarılı kabul edilir eğer:

- eski projeyi doğru analiz ediyorsa,
- mevcut proje kurallarını koruyorsa,
- path’leri `SYSTEM_ROOT` üzerinden çözüyorsa,
- specialist agentları otomatik oluşturmadan öneriyorsa,
- agent oluşturmadan önce context istiyorsa,
- kalıcı kurallar için doğru hedef dosyaları öneriyorsa,
- create/update işlemlerinden sonra dependency doğrulaması yapıyorsa.
