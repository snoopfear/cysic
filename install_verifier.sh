#!/bin/bash

# Обновление системы
echo "Обновляем систему..."
sudo apt update && sudo apt upgrade -y

# Создание файла подкачки
echo "Создаём файл подкачки..."
sudo fallocate -l 5G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Проверка, что файл подкачки добавлен
if sudo swapon --show | grep -q "/swapfile"; then
    echo "Файл подкачки успешно создан и активирован."
else
    echo "Ошибка при создании файла подкачки."
    exit 1
fi

# Добавление в /etc/fstab для сохранения после перезагрузки
echo "Добавляем файл подкачки в /etc/fstab..."
if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Файл подкачки добавлен в /etc/fstab."
else
    echo "Файл подкачки уже добавлен в /etc/fstab."
fi

# Запрос переменной (reward wallet)
read -p "Введите адрес вашего reward wallet (например, 0x123...): " REWARD_WALLET

# Проверка, что переменная введена
if [[ -z "$REWARD_WALLET" ]]; then
    echo "Ошибка: вы не ввели reward wallet. Скрипт завершён."
    exit 1
fi

# Скачивание и установка setup_linux.sh
echo "Скачиваем и запускаем setup_linux.sh..."
curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
bash ~/setup_linux.sh "$REWARD_WALLET"

# Создание systemd службы
echo "Создаём systemd службу для cysic..."

sudo bash -c "cat <<EOF > /etc/systemd/system/cysic.service
[Unit]
Description=cysic
After=network.target

[Service]
ExecStart=/bin/bash /$USER/cysic-verifier/start.sh
WorkingDirectory=/$USER/cysic-verifier/
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF"

# Активируем и запускаем службу
echo "Активируем и запускаем службу cysic..."
sudo systemctl daemon-reload
sudo systemctl enable cysic.service
sudo systemctl start cysic.service

# Показываем логи службы
echo "Запуск логов службы cysic..."
sudo journalctl -u cysic.service -f -n 100
