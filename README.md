# Домашнее задание к занятию "10.3 - Pacemaker" - Копылов Филипп

## Задание 1

Опишите основные функции и назначение Pacemaker.

**Pacemaker** - это наиболее широко используемый диспетчер ресурсов кластера с открытым исходным кодом в среде Linux. Pacemaker использует функции управления сообщениями и элементами кластера, предоставляемые инфраструктурой кластера (Corosync или Heartbeat), для обнаружения сбоев на уровне узлов и ресурсов и восстановления ресурсов, тем самым обеспечивая максимальную надежность Высокая доступность кластерных сервисов.
Основные функции:

* позволяет находить и устранять сбои на уровне нод и служб;
* не зависит от подсистемы хранения: можем забыть общий накопитель, как страшный сон;
* не зависит от типов ресурсов: все, что можно прописать в скрипты, можно кластеризовать;
* поддерживает STONITH (Shoot-The-Other-Node-In-The-Head), то есть умершая нода изолируется и запросы к ней не поступают, пока нода не отправит сообщение о том, что она снова в рабочем состоянии;
* поддерживает кворумные и ресурсозависимые кластеры любого размера;
* поддерживает практически любую избыточную конфигурацию;
* может автоматически реплицировать конфиг на все узлы кластера — не придется править все вручную;
* можно задать порядок запуска ресурсов, а также их совместимость на одном узле;
* поддерживает расширенные типы ресурсов: клоны (когда ресурс запущен на множестве узлов) и дополнительные состояния (master/slave и подобное) — актуально для СУБД (MySQL, MariaDB, PostgreSQL, Oracle);
* имеет единую кластерную оболочку CRM с поддержкой скриптов.

## Задание 2

Опишите основные функции и назначение Corosync.

**Corosync** — программный продукт, который позволяет создавать единый кластер из нескольких аппаратных или виртуальных серверов. Corosync отслеживает и передает состояние всех участников (нод) в кластере.
Этот продукт позволяет:

* мониторить статус приложений;
* оповещать приложения о смене активной ноды в кластере;
* отправлять идентичные сообщения процессам на всех нодах;
* предоставлять доступ к общей базе данных с конфигурацией и статистикой;
* отправлять уведомления об изменениях, произведенных в базе.

## Задание 3

Соберите модель, состоящую из двух виртуальных машин. Установите pacemaker, corosync, pcs.  Настройте HA кластер.

### Развертка кластера

Установка pacemaker:

`sudo apt install pacemaker corosync pcs`

На обоих серверах ставим:

`systemctl enable pcsd`

Обязательно прописать в файле **/etc/hosts** dns суффиксы нодов:

```
127.0.0.1 localhost
192.168.0.1 nodeone
192.168.0.2 nodetwo
192.168.1.1 nodeone
192.168.1.2 nodetwo
# The following lines are desirable for IPv6 capable hosts
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Для управления кластером рекомендуется пользоваться утилитой
pcs. При установке pacemaker автоматически будет создан
пользователь hacluster. Для использования pcs, а также для
доступа в веб-интерфейс, нужно задать пароль пользователю
hacluster:

`passwd hacluster`

Запуск сервиса:

`service pcsd start`

Настраиваем аутентификацию (на одном узле):

```
pcs host auth <Сервер_1> <Сервер_2>
Username: hacluster
Password:
<Сервер_1>: Authorized
<Сервер_2>: Authorized
```
![alt text](https://github.com/filipp761/10.3-Pacemaker/blob/main/img/auth.jpg)

*Пришлите конфигурации сервисов для каждой ноды, конфигурационный файл corosync и бэкап конфигурации pacemaker при помощи команды pcs config backup filename.*

---

## Дополнительные задания (со звездочкой*)

Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

### Задание 4

Установите и настройте DRBD сервис для настроенного кластера.

Установка DRBD

`sudo apt install drbd-utils`

Подключаем DRBD к модулям ядра:

`sudo modprobe drbd`

Добавляем в загрузки системы:

`echo “drbd” >> /etc/modules`

Установка должна быть на двух машинах

Следующим шагом требуется проверить созданные накопители:

`ls /dev |grep sd`

Выполнить: 

`fdisk /dev/sdb`

Команды пошагово:
n — создание диска — либо primary, либо extension.
Создаем primary — ключ p.
Остальное по вашему усмотрению — по умолчанию.
Enter — Enter готово

Создаем логические разделы:

`pvcreate /dev/sdb1`

`vgcreate vg0 /dev/sdb1`

`lvcreate -L3G -n www vg0`

`lvcreate -L3G -n mysql vg0`

Создаем конфигурационные файлы

`/etc/drbd.d/www.res`

`/etc/drbd.d/mysql.res`

После чего на обоих серверах выполняем:

`drbdadm create-md www`

`drbdadm create-md mysql`

`drbdadm up all`

Выполнить на первой ноде:

`drbdadm primary --force www`

`drbdadm primary --force mysql`

На второй ноде:

`drbdadm secondary www`

Теперь требуется подключить разделы и проверить репликацию:

`mkdir /mnt/www`

`mkdir /mnt/mysql`

`mount /dev/drbd0 /mnt/www`

`mount /dev/drbd2 /mnt/mysql`
