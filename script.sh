#!/bin/sh
# First run script

hostname=$(date +"%m-%d-%y-%N" | md5sum | sed 's/[^0-9]//g')
echo $hostname > /etc/hostname
hostname --file /etc/hostname

apt-get install puppet -y
echo "10.0.0.254 newman.localdomain newman" >> /etc/hosts
sed -i '2iserver=newman.localdomain' /etc/puppet/puppet.conf
service puppet restart
puppet agent --enable
puppet agent -t

#delete me
rm -f /etc/init.d/script.sh

#Ideer til OpenStack-node konfig
#Jeg ville tro at Nova og Neutron er ikke OpenStack-noder
#	somkrever veldig mye lagringsplass, men mere RAM og CPU
#Derfor vil man på forhånd kunne avtale med kunde hvilke servere
#	som best egner seg til de aktuelle rollene og få tilsendt
#	mac-adresser på disse. Her kan det også være aktuelt
#	at det er mac-adressen på det første netverkskortet på
#	maskinen (eth0, em1, pp1, etc). Evt. at vi bare får vite
#	at de har et nettverkskort som heter f.eks "LOL" og at 
#	den har tilhørende mac-adresse "wh:at:ev:er"
#Eksempel;
#	Vi får mac-adressen på to maskiner fra kunde.
#	aa-aa-aa-aa
#	bb-bb-bb-bb
#Pseudokode
#
#	if (ifconfig %netverkskort% | grep ipv4: == 10.0.0.X) {
#		if (cat /sys/class/net/%nettverkskort%/address = aa-aa-aa-aa) {
#			echo nova > /etc/hostname
#		}
#		elseif (cat /sys/class/net/%nettverkskort%/address = bb-bb-bb-bb) {
#			echo neutron > /etc/hostname
#		}
#		elseif %for resten av aktuelle OpenStack-noder {
#		}11
#		else {
#			echo compute + %randnumber% > /etc/hostname
#		}
#		hostname -F /etc/hostname
#	}
#	else {
#		echo "I can't find Newman :("
#		echo "her kan det være aktuelt med en løkke som sjekker
#			alle netverkskortene for å se om det er noen av dem
#			som har kontakt med newman"
#	}
#
#Hvis alt ovenfor går bra, kontaktes PuppetMaster med hostname = den aktuelle noden
#Fra dette tidspunktet kan Puppet-manifestene ta over og kan se ut ca slik;
#node /nova/
#	ensure => openstack_nova
#node /neutron/
#	ensure => openstack_neutron
#node /compute%%%/
#	ensure => openstack_compute
#node /etc/
#	ensure => etc...
