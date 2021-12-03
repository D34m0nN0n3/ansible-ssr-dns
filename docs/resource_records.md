# Записи о соответствии имени и служебной информации в системе доменных имен

# Доменные имена и IP адреса

* Доменное имя — символьное имя, служащее для идентификации областей, которые являются единицами административной автономии в сети.
* Доменная зона — совокупность доменных имён определённого уровня, входящих в конкретный домен.
* FQDN («полностью определённое имя домена») — имя домена, не имеющее неоднозначностей в определении. Включает в себя имена всех родительских доменов иерархии DNS.

!!! example "Пример FQDN доменного имени пятого уровня — `sample.gtw-02.office4.example.com.`"
    * sample — пятый уровень;  
    * gtw-02 — четвертый уровень;  
    * office4 — третий уровень;  
    * example — второй уровень;  
    * com — первый (верхний) уровень;  
    * .(точка) — нулевой (корневой) уровень.  

* IP адрес — уникальный числовой идентификатор устройства в компьютерной сети, работающий по протоколу TCP/IP.

!!! example "IP адреса используемые в локальных сетях"
    * 10.0.0.0/8  
    * 172.16.0.0/12  
    * 192.168.0.0/16  

* NAT (Network Address Translation) — это механизм в сетях TCP/IP, позволяющий преобразовывать IP-адреса транзитных пакетов.

!!! attention "Обратите внимание"
    Для доступа из Интернета на сервер в локальной сети необходимо указать преобразованный NAT адрес.

## Типы записей

|  Тип  | Описание                                                                                                                    |                 RFC                 |
| :---: | :-------------------------------------------------------------------------------------------------------------------------- | :---------------------------------: |
|   A   | Адресная запись, соответствие между именем и IP-адресом                                                                     | [1035](https://tools.ietf.org/html/rfc1035) |
| CNAME | Каноническое имя для псевдонима (одноуровневая переадресация)                                                               | [1035](https://tools.ietf.org/html/rfc1035) |
|  MX   | Адрес почтового шлюза для домена. Состоит из двух частей — приоритета (чем число больше, тем ниже приоритет), и адреса узла | [1035](https://tools.ietf.org/html/rfc1035) |
|  PTR  | Соответствие адреса имени — обратное соответствие для A                                                                     | [1035](https://tools.ietf.org/html/rfc1035) |
|  RP   | Ответственный                                                                                                               | [1183](https://tools.ietf.org/html/rfc1183) |
|  SRV  | Указание на местоположение серверов для сервисов                                                                            | [2782](https://tools.ietf.org/html/rfc2782) |
| SSHFP | Отпечаток ключа SSH                                                                                                         | [4255](https://tools.ietf.org/html/rfc4255) |
|  TXT  | Запись произвольных двоичных данных, до 255 байт в размере                                                                  | [1035](https://tools.ietf.org/html/rfc1035) |


## Форма для генерации записей

!!! attention "Обратите внимание"
    Столбцы помеченные `*` обязательны к заполнению.

<div id="myform">
<b>Ведите данные...</b>
<table>
    <tr>
        <th>Имя *</th>
        <th>Домен *</th>
        <th>Тип</th>
        <th>Значение *</th>
    </tr>
    <tr>
        <td style="min-width:150px"><input type="text" maxlength="32" placeholder="Имя" id="name"></td>
        <td style="min-width:150px"><input type="text" minlength="3" maxlength="16" placeholder="Домен" id="domain"></td>
        <td style="min-width:250px"><select name="RR type" id="type" tabindex="0"><option value="">Выберите из списка</option><option value="A">A</option><option value="CNAME">CNAME</option><option value="MX">MX</option><option value="RP">RP</option><option value="SRV">SRV</option><option value="SSHFP">SSHFP</option><option value="TXT">TXT</option></select></td>
        <td style="min-width:350px"><input type="text" minlength="2" maxlength="255" size="15" id="rr"></td>
    </tr>
</table>
<input type="button" id="add" value="Добавить веденные данные в таблицу" onclick="Javascript:addRow()">
&nbsp;

</div>
<br>
<div id="mydata">
<b>Данные для добавления в DNS...</b>
<table id="myTableData" cellpadding="2">
    <tr>
        <th style="min-width:300px"><b>Forward records</b></th>
        <th style="min-width:300px"><b>Reverse records</b></th>
        <th>&nbsp;</th>
    </tr>
</table>
&nbsp;

</div>

<input type="button" id="add" value="Сохранить таблицу в CSV" onclick="Javascript:exportTableToCSV('dns_rr.csv')">
