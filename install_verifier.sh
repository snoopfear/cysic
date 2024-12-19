#!/bin/bash

# Обновление системы
echo "Обновляем систему..."
sudo apt update && sudo apt upgrade -y

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
