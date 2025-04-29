# Spider Solitaire Oyunu

Klasik Spider Solitaire kart oyununun iOS platformu için Swift ile geliştirilmiş bir versiyonu.

## Oyun Açıklaması

Spider Solitaire, tek oyunculu bir iskambil kart oyunudur. Temel amacı, kartları sıralı bir şekilde düzenleyerek tam setler oluşturmak ve bu setleri oyun alanından kaldırmaktır. Oyun 104 kart (2 deste) ile oynanır ve zorluk seviyesine göre 1, 2 veya 4 takım kart kullanılabilir.

## Özellikler

- Üç farklı zorluk seviyesi:
  - Kolay (1 Takım): Sadece sinek sembolleri
  - Orta (2 Takım): Sinek ve kupa sembolleri
  - Zor (4 Takım): Tüm semboller (sinek, kupa, karo, maça)
- Sürükle bırak kart hareketi
- Otomatik tamamlanan setlerin tespiti
- Zaman sayacı ve puan sistemi
- Hamle sayacı
- Güzel yeşil oyun masası tasarımı

## Nasıl Oynanır

1. Kartlar ön yüzü kapalı şekilde 10 sütuna dağıtılır, her sütunun en üstündeki kart açılır
2. Amacınız kartları K'dan A'ya doğru azalan sırayla ve aynı sembolle düzenlemektir
3. Kartları sadece bir küçük değerdeki kartın üzerine koyabilirsiniz
4. Birden fazla kartı, düzenli bir sıra oluşturuyorlarsa, grup olarak taşıyabilirsiniz
5. Boş bir sütuna herhangi bir kart koyabilirsiniz
6. Tüm sütunlarda en az bir kart olduğunda, stok yığınına tıklayarak her sütuna yeni kartlar dağıtabilirsiniz
7. K'dan A'ya kadar aynı sembollü bir seri oluşturduğunuzda, bu set otomatik olarak oyun alanından kaldırılır
8. Oyunu kazanmak için tüm kartları uygun setler halinde düzenlemeniz gerekir

## Teknik Detaylar

Oyun şu teknolojileri kullanmaktadır:
- Swift programlama dili
- UIKit framework
- Özel kart ve kart istifi sınıfları
- Sürükle bırak özelliği için dokunmatik ekran yönetimi
- Zamanlayıcı ve animasyon özellikleri

## Gereksinimler

- iOS 14.0 veya daha yüksek
- iPhone veya iPad
- Yatay ekran desteği

## App Store Hazırlığı

App Store'a yüklemeden önce düşünülmesi gerekenler:
1. App Store için güzel simgeler ve ekran görüntüleri eklenmesi
2. Game Center entegrasyonu ile yüksek puan tablosu eklenmesi
3. Ses efektleri ve müzik eklenmesi
4. İleri düzey ipucu ve geri alma özellikleri
5. Gelişmiş istatistik takibi 
