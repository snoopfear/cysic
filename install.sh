#!/bin/bash

# Обновление системы
echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

# Установка screen и nano
echo "Установка screen и nano..."
sudo apt install -y screen nano

# Путь к entrypoint.sh
ENTRYPOINT_FILE="/app/entrypoint.sh"

# Замена содержимого entrypoint.sh
echo "Обновление содержимого entrypoint.sh..."
sudo bash -c "cat > $ENTRYPOINT_FILE" <<'EOF'
#!/bin/sh

# Проверка наличия EVM_ADDR
if [ ! -z "$1" ]; then
    EVM_ADDR="$1"
fi

if [ -z "${EVM_ADDR}" ]; then
    echo "Error: EVM_ADDR environment variable is not set or is empty"
    exit 1
fi

# Настройка config.yaml
rm -f /app/config.yaml
cp /app/.template.yaml /app/config.yaml 

sed -i "s|__EVM_ADDRESS__|$EVM_ADDR|g" /app/config.yaml
if [ $? -ne 0 ]; then
    echo "Error: Failed to replace __EVM_ADDRESS__ in config.yaml"
    exit 1
fi

echo
echo
echo "[Testnet Phase 2] EVM_ADDR: \`$EVM_ADDR\`, CHAIN_ID: $CHAIN_ID"
echo
echo "- Telegram: https://t.me/blockchain_minter"
echo "- Github: https://github.com/whoami39/blockchain-tools/tree/main/cysic/prover"
echo
echo

# Цикл для автоматического перезапуска приложения
while true; do
    /app/prover
    exit_code=$?

    # Если приложение завершилось с ошибкой
    if [ $exit_code -ne 0 ]; then
        echo "Error: /app/prover exited with code $exit_code. Restarting..."
    else
        echo "Info: /app/prover exited gracefully. Exiting loop."
        break
    fi

    # Задержка перед повторным запуском
    sleep 5
done
EOF

# Сделать entrypoint.sh исполняемым
echo "Делаем файл entrypoint.sh исполняемым..."
sudo chmod +x $ENTRYPOINT_FILE

# Вывод инструкций на экран
echo
echo "Все готово! Для запуска выполните следующие команды:"
echo "1. screen -S prover"
echo "2. $ENTRYPOINT_FILE 0x1145699b4e433530Ca39DFf9536ba544fd82a0b4"
