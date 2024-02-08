#!/bin/bash
# Owner ISTC Foundation
# Created By Vardges Hovhannisyan
#Certbot Install
#/////////////////////////////////////////////////////////
#Collection All neccessary data and configruing Variables
#/////////////////////////////////////////////////////////
#Checking VTX Supoprt
if egrep "svm|vmx" /proc/cpuinfo > /dev/null; then
    echo "AMD's IOMMU / Intel's VT-D is enabled in the BIOS/UEFI."
else
    echo "AMD's IOMMU / Intel's VT-D is not enabled in the BIOS/UEFI"
    exit 0
fi

# Getting Virtualization type
PS3='Please enter your Virtualization type: '
options=("kvm" "openvz" "xen" "proxmox" "lxc" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "kvm")
            echo "you chose KVM"
            break
            ;;
        "openvz")
            echo "you chose OpenVZ"
            break
            ;;
        "xen")
            echo "you chose Xen"
            break
            ;;
        "proxmox")
            echo "you chose Proxmox"
            break
            ;;
        "lxc")
            echo "you chose LXC"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
#get User Admin Email:
read -p "Input Email for Administator user:  " -i "example@example.com" email
#Getting Domain
read -p 'Domain/Subdomain:   ' -i "sub.mydomain.com" domain

#Getting Server IP Address
ipaddress="$(dig @ns1-1.akamaitech.net ANY whoami.akamai.net +short)" 

#Getting DNS Provider
dnsserver=$(dig +short ns "$domain")

#Comparing the IP And Domian
checkip="$(dig +short $domain)"

if [[ "$ipaddress" == "$checkip" ]];
    then
        echo "////////////// S U C C E S S /////////////////" 
        echo "//////////////////////////////////////////////"
        echo "SUCCESS:: DNS Records Changed Successfully"
        echo "//////////////////////////////////////////////"
        echo "////////////// S U C C E S S /////////////////" 
    else
        echo "/////////////////////////////// E R R O R ////////////////////////////////////////"
        echo "//////////////////////////////////////////////////////////////////////////////////"
        echo "The $domain A record is not set to $ipaddress, Please Do changes And Run Again"
        echo "//////////////////////////////////////////////////////////////////////////////////"
        echo "/////////////////////////////// E R R O R ////////////////////////////////////////"
        echo ""
        echo ""
        echo "See Your DNS Provider below"
        echo "$dnsserver"
        
        #Cloudlfare DNS
        if [[ $dnsserver == *"cloudflare"* ]] && [ "$ipaddress" != "$checkip" ]; then
          echo ""
          echo ""
          printf "Please Check in Cloudlfare Documentation:\t\033[1mhttps://www.cloudflare.com/learning/dns/dns-records/dns-a-record\033[m\n"
          exit 0
        #AWS Route DNS
        elif [[ $dnsserver == *"aws"* ]] && [ "$ipaddress" != "$checkip" ]; then
          echo ""
          echo ""
          printf "Please Check in AWS Route53 Documentation:\t\033[1mhttps://aws.amazon.com/ru/premiumsupport/knowledge-center/route-53-create-alias-records/\033[m\n"
          exit 0
        #Name.com DNS
        elif [[ $dnsserver == *"akam"* ]] && [ "$ipaddress" != "$checkip" ]; then
          echo ""
          echo ""
          printf "Please Check in Name.com Documentation:\t\033[1mhttps://www.name.com/support/articles/115004893508-Adding-an-A-record\033[m\n"
          exit 0
        #NameCheap.com DNS
        elif [[ $dnsserver == *"namecheap"* ]] || [[ $dnsserver == *"registrar-servers"* ]] || [[ $dnsserver == *"ultradns"* ]]  && [ "$ipaddress" != "$checkip" ]; then
          echo ""
          echo ""
          printf "Please Check in NameCheap Documentation:\t\033[1mhttps://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/\033[m\n"
          exit 0
        #Other DNS Providers
        elif [[ $dnsserver != *"namecheap"* ]] && [[ $dnsserver != *"registrar-servers"* ]] && [[ $dnsserver != *"ultradns"* ]] && [[ $dnsserver != *"namecheap"* ]] && [[ $dnsserver != *"akam"* ]] && [[ $dnsserver != *"cloudflare"* ]] && [[ $dnsserver != *"aws"* ]]  && [ "$ipaddress" != "$checkip" ]; then
          echo ""
          echo ""
          printf "Please Check in NameCheap Documentation:\t\033[1mhttps://docs.digitalocean.com/products/networking/dns/how-to/manage-records/\033[m\n"
          exit 0
        fi
fi


if [ -d "/usr/local/virtualizor" ] 
    then 
        echo "Virtualizor has already installed"
    else
        echo "Starting Virtualizor package Installation"
          wget -N http://files.virtualizor.com/install.sh
          chmod 0755 install.sh
          ./install.sh email=$email kernel=kvm
fi

if [ -d "/usr/local/virtualizor" ] 
  then
    sudo /usr/local/emps/bin/php /usr/local/virtualizor/scripts/virt_acme.php --install -d $domain --contactemail $email
fi
