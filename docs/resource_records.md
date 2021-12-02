# Записи о соответствии имени и служебной информации в системе доменных имен

## Типы записей

| Тип | Описание | RFC |
|:---:|:---------|:---:|
| A   | Адресная запись, соответствие между именем и IP-адресом | https://tools.ietf.org/html/rfc1035 |
| CNAME | Каноническое имя для псевдонима (одноуровневая переадресация) | https://tools.ietf.org/html/rfc1035 |
| TXT | Запись произвольных двоичных данных, до 255 байт в размере | https://tools.ietf.org/html/rfc1035 |
| MX | Адрес почтового шлюза для домена. Состоит из двух частей — приоритета (чем число больше, тем ниже приоритет), и адреса узла | https://tools.ietf.org/html/rfc1035 |
| RP | Ответственный | https://tools.ietf.org/html/rfc1183 |
| SRV | Указание на местоположение серверов для сервисов | https://tools.ietf.org/html/rfc2782 |


<div id="myform">
<b>Ведите данные...</b>
<table>
    <tr>
        <th>Имя *</th>
        <th>Домен *</th>
        <th>IP address *</th>
    </tr>
    <tr>
        <td style="min-width:300px"><input type="text" maxlength="32" placeholder="Имя" id="name"></td>
        <td style="min-width:150px"><input type="text" minlength="3" maxlength="16" placeholder="Домен" id="domain"></td>
        <td style="min-width:180px"><input type="text" minlength="7" maxlength="15" size="15" required pattern="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" placeholder="IP address" id="ip"><span class="validity"></span></td>
    </tr>
</table>
<input type="button" id="add" value="Добавить веденные данные в таблицу" onclick="Javascript:addRow()">
&nbsp;
 
</div>
<div id="mydata">
<b>Данные для добавления в DNS...</b>
<table id="myTableData" cellpadding="2">
    <tr>
        <th style="min-width:300px"><b>Forward records</b></th>
        <th style="min-width:180px"><b>Reverse records</b></th>
        <th>&nbsp;</th>
    </tr>
</table>
&nbsp;
 
</div>
