#!/data/data/com.termux/files/usr/bin/bash

TARGET="$1"

# Проверяем, что IP указан
if [ -z "$TARGET" ]; then
    echo "❌ Ошибка: не указан IP сервера"
    exit 1
fi

START=1500
END=1200
STEP=10

echo "🔍 Ищем оптимальный MTU (цель: $TARGET)"
echo ""

current=$START
last_success=$END

while [ $current -ge $END ]; do
    if ping -c 2 -M do -s $current $TARGET 2>/dev/null | grep -q "bytes from"; then
        echo "✅ Проходит: $current"
        last_success=$current
        if [ $STEP -eq 10 ]; then
            current=$((last_success + 5))
            STEP=1
        elif [ $STEP -eq 1 ]; then
            break
        fi
    else
        echo "❌ Не проходит: $current"
        current=$((current - STEP))
    fi
done

mtu_net=$((last_success + 28))
mtu_xray=$((last_success - 16))

echo ""
echo "🎯 Результат:"
echo "   MTU сети: $mtu_net"
echo "   Рекомендуемый MTU для Karing: $mtu_xray"
