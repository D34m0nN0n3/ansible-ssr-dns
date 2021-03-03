# Установка и настройка сервера разрешения имен ISC BIND 9 с помощью Ansible

??? abstract
    1. [Общее описание](#общее-описание)
    2. [Параметры](#параметры)
    3. [Теги](#теги)
    4. [Примеры](#примеры)
    5. [Дополнительные материалы](#дополнительные-материалы)

## Общее описание
Domain name server — приложение, предназначенное для ответов на DNS-запросы. По выполняемым функциям DNS-серверы делятся на несколько групп; сервер определённой конфигурации может относиться сразу к нескольким типам:

* *Авторитативный DNS-сервер* — сервер, отвечающий за какую-либо зону.
    * *Мастер* — имеет право на внесение изменений в данные зоны. Обычно зоне соответствует только один мастер-сервер. В случае Microsoft DNS-сервера и его интеграции с Active Directory мастер-серверов может быть несколько (так как репликация изменений осуществляется не средствами DNS-сервера, а средствами Active Directory, за счёт чего обеспечивается равноправность серверов и актуальность данных).
    * *Слейв* - не имеющий права на внесение изменений в данные зоны и получающий сообщения об изменениях от мастер-сервера. В отличие от мастер-сервера, их может быть (практически) неограниченное количество. Слейв также является авторитативным сервером (и пользователь не может различить мастер и слейв, разница появляется только на этапе конфигурирования/внесения изменений в настройки зоны).
* *Кэширующий DNS-сервер* — обслуживает запросы клиентов (получает рекурсивный запрос, выполняет его с помощью нерекурсивных запросов к авторитативным серверам или передаёт рекурсивный запрос вышестоящему DNS-серверу).
* *Перенаправляющий DNS-сервер* — перенаправляет полученные рекурсивные запросы вышестоящему кэширующему серверу в виде рекурсивных запросов. Используется преимущественно для снижения нагрузки на кэширующий DNS-сервер.
* *Корневой DNS-сервер* — сервер, являющийся авторитативным за корневую зону. Общеупотребительных корневых серверов в мире всего 13, их доменные имена находятся в зоне `root-servers.net` и называются `a.root-servers.net, b.root-servers.net, …, m.root-servers.net`. В определённых конфигурациях локальной сети возможна ситуация настройки локальных корневых серверов.
* *Регистрирующий DNS-сервер* - cервер, принимающий динамические обновления от пользователей. Часто совмещается с DHCP-сервером. В Microsoft DNS-сервере при работе на контроллере домена сервер работает в режиме регистрирующего DNS-сервера, принимая от компьютеров домена информацию о соответствии имени и IP-адреса компьютера и обновляя в соответствии с ней данные зоны домена.

При выполнение роли устанавливается и настраивается [ISC BIND 9](https://www.isc.org/bind/). BIND (Berkeley Internet Name Domain, до этого: Berkeley Internet Name Daemon) — открытая и наиболее распространённая реализация DNS-сервера, обеспечивающая выполнение преобразования DNS-имени в IP-адрес и наоборот. Исполняемый файл-демон сервера BIND называется named. BIND поддерживается организацией Internet Systems Consortium. 10 из 13 корневых серверов DNS работают на BIND, оставшиеся 3 работают на NSD.

!!! note
    Роль настраивает два типа конфигураций: авторитативный DNS-сервер и кэширующий DNS-сервер, а так же их комбинацию.

!!! info RPZ
    Так же включена поддержка raesponse policy zone (зона политики ответа) - это механизм для введения настраиваемой политики на серверах системы доменных имен, чтобы рекурсивные распознаватели возвращали возможно измененные результаты. Зоны и их политика: "rpz.passeddomain.hosts" policy passthru; "rpz.changeddomain.hosts" policy given; "rpz.blockeddomain.hosts" policy nxdomain;

!!! attention
    Вместе с DNS сервером устанавливаются `node_exporter` и `bind_exporter`. Необходимо не забыть открыть в брандмауэр порты: `9100`, `9153`.

!!! tip
    Поддерживается загрузка предыдущей конфигурации из `git` репозитория.

## Параметры
|Название переменной               | Тип переменной | Значения по умолчанию                | Описание                                                    |
|:---------------------------------|:--------------:|:------------------------------------:|:------------------------------------------------------------|
|prometheus_user                   | string         | def in var (prometheus)              | |
|node_exporter_url                 | string         | undef                                | |
|bind_exporter_url                 | string         | undef                                | |
|bind_forwarders                   | array          | undef                                | |
|bind_acl_int                      | array          | undef                                | |
|bind_acl_int_exclude              | array          | undef                                | |
|bind_acl_ext                      | array          | def in var (any)                     | |
|bind_acl_ext_exclude              | array          | undef                                | |
|bind_acl_change                   | boolean        | undef (false)                        | |
|bind_cont_ph_num                  | string         | undef                                | |
|bind_cont_mail                    | string         | undef                                | |
|bind_srv_role                     | string         | undef                                | |
|bind_srv_type                     | string         | def in var (resolver)                | |
|bind_ip_v6_on                     | boolean        | undef (false  )                      | |
|bind_max_cache                    | string         | 256M                                 | |
|bind_max_journal                  | string         | 500M                                 | |
|bind_cleanig_interval             | string         | 60                                   | |
|alt_tranfer_src                   | boolean        | undef (false)                        | |
|mf_format                         | string         | undef                                | |
|zero_ttl                          | boolean        | undef                                | |
|trust_clients                     | array          | localhost                            | |
|trust_servers                     | array          | {{ ansible_all_ipv4_addresses }}     | |
|empty_zone_name                   | string         | def in var (example.com)             | |
|bind_restore_last_conf            | boolean        | def in var (false)                   | |
|remote_git_repo                   | string         | undef                                | |
|local_git_repo                    | string         | def in var (/var/tmp/isc-bind-files) | |

## Теги
|Тег                       | Описание                            |
|:-------------------------|:------------------------------------|
| bind_setupe              | Установка `BIND`                    |
| bind_exporter_prometheus | Установка `exporter`                |
| bind_configure           | Создание конфигурационных файлов    |
| bind_copy_configs        | Копирование конфигурационных файлов |
| bind_ip_v6_enable        | Настройка IPv6                      |
| bind_create_zone         | Создание первой зоны                |
| bind_restore_from_git    | Копирование предыдущей конфигурации |

## Примеры

!!! example "inventory/hosts"
    ``` ini
    # Переменные которые необходимо заменить на свои значения указаны в '< >', значения указываются без них.
    # Все узлы объединяются в группы ИС/АСУ.
    # Данный фаил формируется в формате INI.
    [all:vars]
    bind_cont_ph_num='+7(000)111-22-33'
    bind_cont_mail='mail@example.com'
    bind_forwarders=['192.168.2.1','192.168.2.2']
    alt_tranfer_src=True
    bind_acl_int=['192.168.1.0/24','192.168.2.0/24']
    bind_srv_type='mixed'
    remote_git_repo='git@github.com:D34m0nN0n3/backup-isc-bind.git'
    node_exporter_url='https://github.com/prometheus/node_exporter/releases/download/v1.1.1/node_exporter-1.1.1.linux-amd64.tar.gz'
    bind_exporter_url='https://github.com/prometheus-community/bind_exporter/releases/download/v0.4.0/bind_exporter-0.4.0.linux-amd64.tar.gz'
    ansible_connection=ssh
    
    [master]
    bootstrap.lab ansible_connection=local
    
    [slaves]
    rhel7.lab ansible_ssh_host=192.168.1.101
    rhel8.lab ansible_ssh_host=192.168.1.102
    ```

## Дополнительные материалы

