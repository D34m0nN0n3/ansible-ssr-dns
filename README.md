[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# Install and configuration BIND 9
Copyright (C) 2020 Dmitriy Prigoda deamon.none@gmail.com This script is free software: Everyone is permitted to copy and distribute verbatim copies of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License.

Протестировано на:
- CentOS 7 & 8
- Ansible = 2.9.5
- foreman-1.22.0.36

## Общее описание
Ansible Roles для установки и настройки сервера разрешения имен ISC BIND 9, а так же настройки DNS клиента в CentOS/RHEL 7 & 8.

Чтобы скачать последнюю версию необходимо выполнить команду на клиенте с которого будет запущен данный playbook:

```
> cd ~
> git clone https://github.com/D34m0nN0n3/ansible-ssr-dns.git
```
### Запуск Playbook'а
Для запуска данного сценария необходимо:
1. Убедится что есть сетевой доступ с управляющего сервера до управляемых узлов по 22 порту (ssh). Подробно описано в документации: `Connection methods` и `Ansible passing sudo`. 
2. В наличии учетной записи с правами администратора из под которой будет производится подключение.
3. Заполненный файл `inventory` с перечисленными управляемыми узлами и переменными. *Пример файла: [inventory/hosts.example](inventory/hosts.example)*

Пример запуска с указанием пароля пользователя под которым подключаемся к управляемым хостам:
```
bash
# Go to the project folder:
> cd ~/ansible-update-os
# Run playbook:
> ansible-playbook -i inventory/hosts pre-config-ssh.yml --user=<local_user_name> --ask-pass --become
> ansible-playbook -i inventory/hosts playbook.yml
```
### Ключи
Key                 |INFO
--------------------|------------------------------------------------------------------
-i                  |Необходимо указать путь к файлу `inventory`
-v or -vv           |Повышает информативность вывода, нужен для анализа ошибок
--become            |Предоставляет повышение полномочий через `sudo` УЗ при подключение
--ask-pass          |Запрашивает пароль УЗ под которой будет выполнен сценарий
--ask-become-pass   |Запрашивает пароль УЗ при запуске `sudo`

*При запуске и в момент исполнения формируется файл с логами для анализа ошибок `logs/ansible-log.log`. Размер файла зависит от уровня подробного вызова и количества запусков сценария.*

## Параметры и теги
Все параметры и теги приведены в отдельных разделах документации по ролям:

1.  [infra-system.linux.isc-bind-setup](docs/roles/dns_server.md)
2.  [infra-system.linux.os.resolv](docs/roles/dns_client.md)