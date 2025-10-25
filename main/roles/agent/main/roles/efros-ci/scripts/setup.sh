#!/bin/bash
VARS_FILE="$(dirname "$0")/../vars/main.yml"

# Проверяем наличие пароля
EXISTING_PASS=$(grep "user_password:" "$VARS_FILE" | awk '{print $2}')

if [[ -n "$EXISTING_PASS" ]]; then
    whiptail --yesno "Пароль для efrosci уже задан. Перезаписать?" 10 60
    if [[ $? -ne 0 ]]; then
        echo "Пароль оставлен без изменений."
        exit 0
    fi
fi

NEW_PASS=$(whiptail --passwordbox "Введите пароль для пользователя efrosci:" 10 60 3>&1 1>&2 2>&3)
if [[ -z "$NEW_PASS" ]]; then
    whiptail --msgbox "Пароль не введён. Настройка прервана." 10 60
    exit 1
fi

HASH=$(python3 -c "import crypt; print(crypt.crypt('$NEW_PASS', crypt.mksalt(crypt.METHOD_SHA512)))")

# Обновляем или создаём vars/main.yml
sed -i "/user_password:/d" "$VARS_FILE"
echo "user_password: \"$HASH\"" >> "$VARS_FILE"

whiptail --msgbox "Пароль успешно обновлён и сохранён." 10 60