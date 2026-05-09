# MYB Software Studio Agent System

Fikir aşamasından teslimata kadar yazılım ürünlerini yönetmek için tasarlanmış bağımsız, context-aware agent sistemi.

## Amaç

Bu sistem, küçük ama genişleyebilir bir software studio işletim sistemi olarak tasarlandı. Güvenli şekilde büyüyebilmesi için bir universal orchestrator ve bir uzman agent ile başlar.

## Ana Bileşenler

- `agent/myb-Orchestrator.md` — OpenAgent pattern’lerinden esinlenen ana universal orchestrator.
- `agent/subagents/agent-system-designer.md` — agent, context, command ve dependency tasarımı için uzman agent.
- `command/create-agent.md` — interview, context intake, preview ve approval akışıyla yeni agent oluşturur.
- `command/init-project.md` — sistemi mevcut veya sıfırdan projelere güvenli şekilde onboard eder.
- `command/update-agent.md` — kullanıcı talepleri ve yapısal analiz ile mevcut agentları günceller.
- `command/manage-context.md` — context dosyalarını oluşturur, günceller, haritalar ve organize eder.
- `command/check-context-deps.md` — agent/command/context/workflow dependency sağlığını doğrular.

## Çalışma Prensipleri

1. Çekirdeği basit tut.
2. Sadece gerçek bir capability gap varsa agent ekle.
3. Uzman davranış beklemeden önce context oluştur.
4. Dosya yazmadan önce değişiklikleri preview et.
5. Create/update işlemlerinden sonra dependency doğrulaması yap.

## Önerilen İlk Akış

```text
MYB Orchestrator’dan bir ürün görevi iste
→ İsteği sınıflandırır
→ İlgili context’i yükler
→ Kendisi uygular veya uzman önerir
→ Yeni agent gerekiyorsa /create-agent kullanılır
→ Değişikliklerden sonra /check-context-deps çalıştırılır
```

## Başka Bir Runtime Kullanımı

Bu klasörü taşınabilir bir sistem paketi gibi kullan:

1. `agent/`, `command/`, `context/`, `workflows/` ve `system-manifest.json` dosyasını hedef runtime’a kopyala.
2. `SYSTEM_ROOT` değerini `system-manifest.json` dosyasını içeren klasör olarak tanımla.
3. Hedef runtime’ın agent/command discovery path’lerini bu klasörlere eşle.
4. Hedef projede zaten `AGENTS.md` varsa üzerine yazma; `AGENTS_TEMPLATE.md` içindeki MYB integration block’u mevcut dosyaya ekle.
5. Dependency kontrolleri için `system-manifest.json` dosyasını sistem index’i olarak tut.
6. Hedef projeyi analiz etmek veya başlatmak için `/init-project` çalıştır.
7. Taşıma sonrası `/check-context-deps` çalıştır veya manuel olarak uygula.
8. Runtime daha sıkı frontmatter kurallarına sahipse desteklenmeyen metadata’yı `system-manifest.json` içine taşı.

## Proje Başlatma

Sistemi bir projeye taşıdıktan sonra `/init-project` kullan:

- Mevcut proje: dosyaları, dokümanları, configleri, commandları ve mevcut `AGENTS.md` dosyasını analiz eder; sonra güvenli merge önerir.
- Sıfırdan proje: başlangıç sorularını sorar ve onaydan sonra temel proje `AGENTS.md` dosyasını oluşturur.
- Dry run: yazmadan sadece bulguları ve önerilen kurulumu raporlar.

## Path Resolution

`SYSTEM_ROOT`, `system-manifest.json` dosyasını içeren klasördür.

Sistemi başka bir runtime’a uyarlarken şu path pattern’ini kullan:

```text
{SYSTEM_ROOT}/context/navigation.md
{SYSTEM_ROOT}/agent/myb-Orchestrator.md
{SYSTEM_ROOT}/command/create-agent.md
{SYSTEM_ROOT}/workflows/create-agent.md
```

Bir agent `navigation.md` dosyasını bulamıyorsa önce `SYSTEM_ROOT` doğru mu kontrol et.

## System Manifest

`system-manifest.json` bir OpenCode runtime config dosyası değildir. Bu taşınabilir sistemin envanteri ve dependency haritasıdır.

Şunları listeler:

- agentlar
- commandlar
- context dosyaları
- workflowlar
- dependency ilişkileri

Bu dosyayı sistemi doğrulamak, başka bir runtime’a taşımak veya hedef runtime’ın native config formatına uyarlamak için kullan.

## V1.1 Notları

- `/create-agent`, kullanıcı interview ve context intake akışından sorumludur.
- `agent-system-designer`, mimari kalite ve dependency hygiene’dan sorumludur.
- MYB Orchestrator, routing, safety gate’ler ve capability-gap detection’dan sorumludur.
- Dependency referansları `type:path` formatını kullanır. Örnek: `context:root/navigation`.
