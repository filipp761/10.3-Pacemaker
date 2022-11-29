resource www {
protocol C;
disk {
fencing resource-only;
}
handlers {
fence-peer
"/usr/lib/drbd/crm-fence-peer.sh";
after-resync-target
"/usr/lib/drbd/crm-unfence-peer.sh";
}
syncer {
rate 110M;
}
on node2
{
device /dev/drbd1;
disk /dev/vg0/www;
address 192.168.2.2:7794;
meta-disk internal;
}
on node1
{
device /dev/drbd1;
disk /dev/vg0/www;
address 192.168.2.1:7794;
meta-disk internal;
}
}
