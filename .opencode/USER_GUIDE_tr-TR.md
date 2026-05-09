# MYB Software Studio Kullanıcı Rehberi

Bu rehber, yeni veya mevcut bir projede agent sistemini nasıl hazırlayacağını, context’i nasıl yöneteceğini ve yeni agent/command/skill ihtiyaçlarını nasıl değerlendireceğini açıklar.

## 1. Yeni Projede İlk Adım

> **Kısa karar:** Önce projeyi öğret, sonra iş yaptır.

Yeni projeye başlarken ilk komut:

```text
/init-project --dry-run
```

Bu komut önce projeyi okur, hiçbir dosya değiştirmez ve sana şunları raporlar:

- proje existing mi fresh mi?
- `SYSTEM_ROOT` neresi?
- mevcut `AGENTS.md` var mı?
- proje ne yapıyor?
- hangi komutlar var?
- hangi kurallar ve privacy/safety beklentileri var?
- hangi bilgiler eksik?

## 2. Context’i Ben mi Hazırlamalıyım, Agent mı?

En iyi model:

> **Kullanıcı yön verir, agent çıkarır, kullanıcı onaylar.**

Sen projenin önemli gerçeklerini söylersin:

```text
Bu proje local-first çalışmalı. Network transcription ve telemetry istemiyorum.
```

Agent bunu context önerisine çevirir:

- project overview
- privacy rules
- build/test commands
- architecture notes
- safety constraints

Sonra preview gösterir. Sen onaylamadan kalıcı dosya yazmamalı.

## 3. Ne Zaman Kalıcı Context Gerekir?

Bir bilgi context’e yazılmadan önce şu sorulara bak:

| Soru | Evet ise |
|---|---|
| Tekrar kullanılacak mı? | Context olabilir |
| Agent davranışını değiştirecek mi? | Agent/command prompt’una da işlenmeli |
| Proje standardı mı? | Context + AGENTS.md gerekebilir |
| Unutulursa hata çıkar mı? | Kalıcı hale getirilmeli |
| Sadece bu görev için mi? | Context’e yazma |

## 4. Kalıcı Kural mı, Geçici Talimat mı?

| Tür | Örnek | Nereye gitmeli? |
|---|---|---|
| Geçici talimat | “Bu sefer kısa cevap ver.” | Sadece mevcut görev |
| Kalıcı davranış kuralı | “Bundan sonra yazmadan önce preview göster.” | İlgili agent/command prompt’u |
| Proje kararı | “project.yml source of truth.” | AGENTS.md veya project context |
| Tercih | “Türkçe kullanıcı çıktısı ver.” | Agent/command style kuralı |

> **Dikkat:** Kritik davranış kuralları sadece context’e gömülmemeli; ilgili agent veya command yapısına da işlenmeli.

## 5. Context Güncelliğinden Nasıl Emin Olurum?

Context dosyalarında kaynak ve tarih net olmalı.

Özellikle external docs için:

```md
Source: https://opencode.ai/docs/skills/
Updated: 2026-05-09
Applies to: OpenCode Agent Skills
```

Güncellik için pratik kurallar:

- Dış kütüphane/framework/API için canlı dokümantasyon kontrol et.
- Tam dokümanı kopyalama; MVI özet çıkar.
- Kaynak linkini ve tarihini yaz.
- API/framework değiştiyse context’i güncelle.
- Emin değilsen agent “bunu güncel dokümandan doğrulayalım mı?” diye sormalı.

## 6. External Documentation Agent’a Nasıl Öğretilir?

> **Kısa karar:** External docs tam kopyalanmaz; kısa, kaynaklı ve güncel context’e dönüştürülür.

Doğru akış:

1. Official dokümanı oku.
2. MVI formatında özetle.
3. Önemli kuralları çıkar.
4. Kaynak ve tarih ekle.
5. Agent/command/workflow’a bağla.

Örnek hedef yapı:

```text
context/agent-system/
├── concepts/
│   └── skills.md
├── guides/
│   └── create-skill.md
└── lookup/
    └── skill-structure.md
```

## 7. OpenCode Skills Örneği

OpenCode Skills dokümantasyonu: `https://opencode.ai/docs/skills/`

Bu dokümana göre kısa bilgi:

- Skill klasörü içinde `SKILL.md` bulunur.
- OpenCode proje ve global skill path’lerini arar.
- `SKILL.md` YAML frontmatter ile başlamalıdır.
- Zorunlu alanlar: `name`, `description`.
- Skill adı lowercase alphanumeric ve hyphen formatında olmalı.
- Agent skill’i ihtiyaç olduğunda native `skill` tool ile yükler.
- Skill izinleri `opencode.json` içinde kontrol edilebilir.

Örnek:

```text
.opencode/skills/git-release/SKILL.md
```

Bu sistemde OpenCode Skills için temel context dosyaları şurada tutulur:

```text
context/agent-system/concepts/skills.md
context/agent-system/guides/use-skill.md
context/agent-system/guides/create-skill.md
context/agent-system/lookup/skill-structure.md
```

> **Öneri:** Skill ihtiyacı sadece oluşturma değil, kullanım için de doğabilir. Bu yüzden önce `use-skill.md` ve `skill-structure.md` context’ini kullan; skill oluşturma sıklaşırsa sonra `/create-skill` command ekle.

## 8. Yeni Agent Ne Zaman Oluşturulur?

Yeni agent sadece şu şartlardan en az birkaçını karşılıyorsa mantıklı:

- Tekrarlanan uzmanlık ihtiyacı var.
- Kendi kalıcı context’ine ihtiyaç duyuyor.
- Kalite kriterleri domain-specific.
- İş birden fazla workflow’u etkiliyor.
- Mevcut orchestrator fazla genel kalıyor.

> **Kısa karar:** Tek seferlik işler için agent oluşturma; önce context veya workflow yeterli mi bak.

## 9. Yeni Command, Workflow veya Skill Ne Zaman Gerekir?

| İhtiyaç | Daha uygun yapı |
|---|---|
| Tekrar eden kullanıcı operasyonu | Command |
| Adım adım süreç | Workflow |
| Agent’a gerektiğinde yüklenecek özel bilgi/davranış | Skill |
| Kalıcı proje bilgisi | Context |
| Uzman karar/uygulama alanı | Agent |

Örnekler:

- “Yeni agent oluşturma süreci” → `/create-agent`
- “Projeyi ilk kez tanıma” → `/init-project`
- “OpenCode skill oluşturmayı öğren” → skills context + gerekirse `/create-skill`

## 10. Context Şişmesini Nasıl Önlerim?

- Her bilgiyi context’e yazma.
- Context dosyalarını kısa tut.
- Navigation-first ilerle.
- Her task’te sadece ilgili context’i oku.
- Büyük karar kayıtlarını her seferinde yükleme.
- Kritik davranış kurallarını agent/command prompt’una işle.

## 11. Pratik Başlangıç Akışı

Yeni veya eski projede önerilen sıra:

```text
1. /init-project --dry-run
2. Eksik bilgileri cevapla
3. AGENTS integration block gerekiyorsa onayla
4. Project context gerekiyorsa preview al
5. /check-context-deps çalıştır
6. İlk gerçek görevi ver
7. Gerekirse agent/command/skill önerilerini değerlendir
```

## 12. Kendi Kendine Kontrol Soruları

Yeni bir bilgi veya yapı eklemeden önce sor:

- Bu bilgi tekrar kullanılacak mı?
- Bu agent davranışını değiştiriyor mu?
- Bunu context mi, command mı, workflow mu, skill mi çözmeli?
- Official doküman güncel mi?
- Kullanıcı onayı gerekiyor mu?
- Bu yapı sistemi sade mi tutuyor, yoksa gereksiz büyütüyor mu?

> **Sonuç:** Agent sistemi en iyi, kullanıcı stratejik bilgiyi verdiğinde; agent bunu yapılandırıp preview sunduğunda; kullanıcı da kalıcı hale getirmeden önce onayladığında çalışır.
