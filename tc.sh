

case "$1" in
start)

ips='10.0.101.0/24 10.0.2.0/24 10.0.3.0/24 10.0.4.0/24 10.0.5.0/24 10.0.6.0/24 10.0.7.0/24 10.0.8.0/24 10.0.9.0/24 10.0.10.0/23 10.0.154.0/23 10.0.164.0/23 10.0.174.0/23 10.0.184.0/23 10.0.194.0/23 10.0.204.0/23 10.0.214.0/23 10.0.224.0/23 10.0.234.0/23 10.0.238.0/23 10.0.242.0/23 10.0.180.0/23 10.0.190.0/23 10.0.210.0/23 10.0.140.0/23 10.0.232.0/23 10.0.248.0/23 10.0.240.0/23'
#ips='10.0.0.0/16'
#  A placa de rede que tera o controle de banda
p_rede="eth5"

# Velocidade para os clientes
velocidade=77000kbit

# LIMPANDO TUDO
tc qdisc del dev $p_rede root

tc qdisc add dev $p_rede root handle 1:0 htb default 1000

count=1

tc class add dev eth5 parent 1: classid 1:3 htb rate 1000000kbit                #SQUID
tc class add dev eth5 parent 1:3 classid 1:90 htb rate 1000000kbit prio 0       #ZPH



for IPS in $ips
   do
        tc class add dev $p_rede parent 1:0 classid 1:$count htb rate $velocidade
        echo "OK"
        tc filter add dev $p_rede protocol ip parent 1:0 prio 1 u32 match ip dst $IPS flowid 1:$count
        tc filter add dev $p_rede protocol ip parent 1:0 prio 1 u32 match ip src $IPS flowid 1:$count
        echo "OK"
        count=`expr $count + 1`
   done


# Regra para ZPH = 16 no Squid - Cache full
tc filter add dev eth5 protocol ip parent 1:0 prio 1 u32 match ip protocol 0x6 0xff match ip tos 0x10 0xff flowid 1:90
tc filter add dev eth5 protocol ip parent 1:0 prio 1 u32 match ip protocol 1 0xFF flowid 1:90

tc qdisc add dev eth5 parent 1:1 handle 10: sfq perturb 10

;;

stop)
tc qdisc del dev eth5 root

;;

restart)
$PROGRAMA stop
sleep 1
$PROGRAMA start
;;

*)
echo "Use: {start|stop|restart}"
exit 1
esac
exit 0
