#!/bin/bash

# Yardım mesajı
display_help() {
  echo "Kullanım: ./liman.sh <kur, kaldır, administrator, reset<mail>, help>"
  echo " Kurulum için: ./liman.sh kur"
  echo " Kur komutu ile birlikte Node.js, PHP ve PostgreSQL kurulur. Ardından Liman MYS 2.0 kurulur."
  echo " Kaldırma için: ./liman.sh kaldır"
  echo " Kaldır komutu ile birlikte Liman MYS 2.0 kaldırılır. Ardından kalıntılar temizlenir."
  echo " Administrator hesabı için: ./liman.sh administrator"
  echo " Administrator komutu ile birlikte Liman MYS 2.0 için admin hesabı yaratılır."
  echo " Reset işlemi için: ./liman.sh reset <mail>"
  echo " Reset komutu ile birlikte Liman MYS 2.0 için verilen hesap resetlenir."
}

# Argüman sayısını kontrol et
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Hatalı argüman sayısı!"
  display_help
  exit 1
fi

# Argüman biçimini kontrol et
case "$1" in
  "kur"|"kaldır"|"administrator"|"help")
    # İstenilen argümanlardan biri, devam et
    ;;
  "reset")
    # reset için ek kontrol (mail parametresi var mı?)
    if [ "$#" -ne 2 ]; then
      echo "Hatalı argüman sayısı reset komutu için!"
      display_help
      exit 1
    fi
    ;;
  *)
    # Geçersiz argüman, hata mesajını göster ve yardımı görüntüle
    echo "Geçersiz argüman: $1"
    display_help
    exit 1
    ;;
esac
echo "Kurulum için sudo yetkileri alınıyor..."
sudo -v || { echo "Sudo yetkileri alınamadı! Çıkılıyor..."; exit 1; }

# Geri kalan script işlemleri buraya eklenir
# ...

# Örnek: Argümanlara göre farklı işlemler yapabilirsiniz
case "$1" in
  "kur")
echo "Kurulum işlemleri yapılıyor..."
echo "Güncel Node.js sürümü kuruluyor..."
NODE_MAJOR=18
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
echo "Güncel Node.js sürümü kuruldu..."
echo " "
echo "Güncel PHP 8.1 sürümü kuruluyor..."
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
echo "Güncel PHP 8.1 sürümü kuruldu..."
echo " "
echo "Güncel PostgreSQL 14 sürümü kuruluyor..."
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > pgsql.gpg
sudo mv pgsql.gpg /etc/apt/trusted.gpg.d/pgsql.gpg
echo "Güncel PostgreSQL 14 sürümü kuruldu..."
echo " "
echo " Liman MYS 2.0 kuruluyor..."
sudo apt update
wget https://github.com/limanmys/core/releases/download/release.feature-new-ui.863/liman-2.0-RC2-863.deb
apt install ./liman-2.0-RC2-863.deb
echo " Liman MYS 2.0 kuruldu..."
echo " "
echo " Liman MYS 2.0 kurulumu tamamlandı..."
echo "Admin hesabınız için ./liman.sh administrator komutunu kullanabilirsiniz."
echo " Hoşçakalın..."
    ;;
  "kaldır")
    echo "Kaldırma işlemleri yapılıyor..."
    apt remove liman
    echo "Kaldırma işlemleri tamamlandı..."
    echo  "Kalıntılar temizleniyor..."
    apt purge liman
    echo "Kalıntılar temizlendi..."
    ;;
  "administrator")
    echo "Administrator hesabı yaratılıyor..."
    limanctl administrator
    ;;
  "reset")
    echo "Reset işlemi için mail: $2"
    limanctl reset administrator@liman.dev
    ;;
  "help")
    display_help
    ;;
esac

# Script başarıyla tamamlandı
exit 0