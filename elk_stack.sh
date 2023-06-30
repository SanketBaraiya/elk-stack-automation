#!/bin/sh
if [[ $# -eq 0 || $# -gt 1 ]] ; 
then
   echo -e "\e[1;31m[!] Required 1 positional argument. Given $#\e[0m\n"
   echo -e "\e[1;36m[?] Usage: bash elk_stack.sh [IP_ADDR]\e[0m\n"
   exit 0
fi

clear

#Handling Ctrl+C & Ctrl+Z
trap ctrl_c INT  
trap ctrl_z TSTP

ctrl_c() {
  { printf "\e[1;31m\r[!] Script Stopped By User.\e[0m"; kill $! && wait $!; } 2>/dev/null
  tput cnorm
  exit 1
}

ctrl_z() {
  { printf "\e[1;31m\r[!] Script Suspended By User.\e[0m"; kill $! && wait $!; } 2>/dev/null
  tput cnorm
  kill -SIGSTOP $$
  exit 1
}

IP_ADDR=$1
CURR_PATH=$(pwd)

tput civis

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Installing Elasticsearch Dependencies...\e[0m"; sleep .1; done; done) &

#Disabling Linux Auto Update so that it doesn't interrupt the script   
systemctl stop unattended-upgrades
sleep 2

#Import the Elasticsearch PGP Key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sleep 2

#APT Repository
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list
sleep 5

wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &> /dev/null
sleep 5
apt-get update &> /dev/null
sleep 5
apt install -f ./google-chrome-stable_current_amd64.deb -y &> /dev/null
sleep 10
apt install python3-pip -y &> /dev/null
sleep 5
apt install apt-transport-https -y &> /dev/null
sleep 5
pip3 install selenium webdriver-manager &> /dev/null
sleep 5

{ printf "\e[1;32m\r[+] Successfully Installed Elasticsearch Dependencies.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Installing Elasticsearch...\e[0m"; sleep .1; done; done) &

apt-get update &> /dev/null && apt-get install elasticsearch -y > elasticsearch.conf.details

{ printf "\e[1;32m\r[+] Successfully Installed Elasticsearch.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Configuring Elasticsearch...\e[0m"; sleep .1; done; done) &

sed -i "/^#network.host/ c\network.host: ${IP_ADDR}" /etc/elasticsearch/elasticsearch.yml   #Setting Elasticsearch Host to Given IP
sed -i "/^#http.port/ c\http.port: 9200" /etc/elasticsearch/elasticsearch.yml               #Setting Elasticsearch Port to 9200
sleep 2

{ printf "\e[1;32m\r[+] Successfully Configured Elasticsearch.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Starting and Enabling Elasticsearch Service...\e[0m"; sleep .1; done; done) &

systemctl start elasticsearch.service
systemctl enable elasticsearch.service &> /dev/null
sleep 2

{ printf "\e[1;36m\r[?] Elasticsearch Service Status: $(systemctl is-active elasticsearch.service)\e[0m          "; kill $! && wait $!; } 2>/dev/null
printf "\n"
printf "\e[1;32m[+] Elasticsearch Service Up & Running.\e[0m"
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Checking Elasticsearch...\e[0m"; sleep .1; done; done) &

#Extracting Elasticsearch Auto-genrated password
TEMP=$(grep "The generated password for the elastic built-in superuser is :" elasticsearch.conf.details)
ELASTIC_PASS=${TEMP#*:}
ELASTIC_PASS=${ELASTIC_PASS#"${ELASTIC_PASS%%[![:space:]]*}"}
echo "$ELASTIC_PASS" > pass.txt
ELASTIC_AUTH=$(tr -d $'\r' < pass.txt)
rm pass.txt
sleep 2

{ printf "\e[1;32m\r[+] Elasticsearch Check Complete.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"
curl --cacert /etc/elasticsearch/certs/http_ca.crt --user elastic:${ELASTIC_AUTH} "https://${IP_ADDR}:9200"
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Installing Kibana...\e[0m"; sleep .1; done; done) &

apt-get install kibana -y &> /dev/null
sleep 2

{ printf "\e[1;32m\r[+] Successfully Installed Kibana.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Configuring Kibana...\e[0m"; sleep .1; done; done) &

apt-get install unzip -y &> /dev/null

#Generating Self-Signed CA for Kibana HTTPS
mkdir /etc/kibana/certs
/usr/share/elasticsearch/bin/elasticsearch-certutil ca --pem --out ca.zip &> /dev/null
mv /usr/share/elasticsearch/ca.zip $CURR_PATH
unzip ca.zip &> /dev/null
cp ca/ca.* /etc/kibana/certs
cp /etc/elasticsearch/certs/http_ca.crt /etc/kibana/certs/

#Extracting Kibana Password
/usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system -b > kibana.conf.details
TEMP=$(grep "New value:" kibana.conf.details)
KIBANA_PASS=${TEMP#*:}
KIBANA_PASS=${KIBANA_PASS#"${KIBANA_PASS%%[![:space:]]*}"}
echo "$KIBANA_PASS" > pass.txt
KIBANA_AUTH=$(tr -d $'\r' < pass.txt)
rm pass.txt

sed -i "/^#server.port/ c\server.port: 5601" /etc/kibana/kibana.yml                                             #Setting Kibana Server Port to 5601
sed -i "/^#server.host/ c\server.host: \"${IP_ADDR}\"" /etc/kibana/kibana.yml                                   #Setting Kibana Server Host to given IP address
sed -i "/^#elasticsearch.hosts/ c\elasticsearch.hosts: [\"https://${IP_ADDR}:9200\"]" /etc/kibana/kibana.yml    #Setting Elasticsearch Hosts
sed -i "/^#elasticsearch.username/ c\elasticsearch.username: \"kibana_system\"" /etc/kibana/kibana.yml          #Setting Kibana Elasticsearch User
sed -i "/^#elasticsearch.password/ c\elasticsearch.password: \"${KIBANA_AUTH}\"" /etc/kibana/kibana.yml         #Setting Kibana Elasticsearch Password
sed -i "/^#elasticsearch.ssl.certificateAuthorities/ c\elasticsearch.ssl.certificateAuthorities: [\"/etc/kibana/certs/http_ca.crt\"]" /etc/kibana/kibana.yml    #Setting the path of Elasticsearch CA
sed -i "/^#server.ssl.enabled/ c\server.ssl.enabled: true" /etc/kibana/kibana.yml                               #Setting SSL to True
sed -i "/^#server.ssl.certificate/ c\server.ssl.certificate: /etc/kibana/certs/ca.crt" /etc/kibana/kibana.yml   #Setting the path of Kibana CA certificate
sed -i "/^#server.ssl.key/ c\server.ssl.key: /etc/kibana/certs/ca.key" /etc/kibana/kibana.yml                   #Setting the path of Kiabana CA key

{ printf "\e[1;32m\r[+] Successfully Configured Kibana.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Starting & Enabling Kibana...\e[0m"; sleep .1; done; done) &

systemctl start kibana.service
systemctl enable kibana.service &> /dev/null
sleep 30

{ printf "\e[1;36m\r[?] Kibana Service Status: $(systemctl is-active kibana.service)\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n"
printf "\e[1;32m[+] Kibana Service Up & Running.\e[0m"
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Preparing Fleet Server Prerequisites...\e[0m"; sleep .1; done; done) &

#Preparing SSL Fingerprint for Outputs
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --name fleet-server --ca-cert $CURR_PATH/ca/ca.crt --ca-key $CURR_PATH/ca/ca.key --dns elk --ip $IP_ADDR --pem --out fleet-server.zip &> /dev/null
mv /usr/share/elasticsearch/fleet-server.zip $CURR_PATH
unzip fleet-server.zip &> /dev/null
openssl x509 -fingerprint -sha256 -in /etc/elasticsearch/certs/http_ca.crt | tail -n +2 > SSL_FINGERPRINT
cat <<EOF > ssl_key.txt
ssl:
  certificate_authorities:
  - |
EOF
while IFS= read -r line
do
  echo -e "    $line" >> ssl_key.txt
done <<< $(cat SSL_FINGERPRINT)

{ printf "\e[1;32m\r[+] Successfully Prepared Fleet Server Prerequisites.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Configuring Fleet Server...\e[0m"; sleep .1; done; done) &

#Generating Self-Signed CA for Fleet Server HTTPS
cp /etc/elasticsearch/certs/http_ca.crt /usr/local/share/ca-certificates
update-ca-certificates &> /dev/null
export IP_ADDR
export CURR_PATH
chmod 744 configure-fleet.py
python3 -W ignore configure-fleet.py ${IP_ADDR} ${ELASTIC_AUTH} &> /dev/null

{ printf "\e[1;32m\r[+] Successfully Configured Fleet Server.\n\n\e[0m"; kill $! && wait $!; } 2>/dev/null

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Installing Fleet Server...\e[0m"; sleep .1; done; done) &

chmod 744 fleet-install.sh
bash fleet-install.sh &> /dev/null

{ printf "\e[1;32m\r[+] Successfully Fleet Server.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

(while :; do for c in / - \\ \|; do printf "\e[1;33m\r[$c] Removing Clutter...\e[0m"; sleep .1; done; done) &

rm ca.zip fleet-server.zip google-chrome-stable_current_amd64.deb elastic-agent-*.tar.gz fleet-install.sh SSL_FINGERPRINT ssl_key.txt configure-fleet.py
rm elasticsearch.conf.details kibana.conf.details
rm -R elastic-agent-*
apt --purge remove google-chrome-stable -y &> /dev/null
systemctl start unattended-upgrades
sleep 2

{ printf "\e[1;32m\r[+] Successfully Removed Clutter.\e[0m"; kill $! && wait $!; } 2>/dev/null
printf "\n\n"

echo -e "\e[1;32m[+] Successfully Installed ELK Stack (Elasticsearch & Kibana) With Fleet Server.\e[0m"
printf "\n"

cat <<EOF > elk.conf.details
===================================
Elasticsearch Details & Credentials
===================================
Username: elastic
Password: ${ELASTIC_AUTH}
IP: ${IP_ADDR}
Port: 9200

============================
Kibana Details & Credentials
============================
Username: kibana_system
Password: ${KIBANA_AUTH}
IP: ${IP_ADDR}
Port: 5601

EOF

tput cnorm

while true; do
    read -p "Do You Want To Display Login Credentials On Terminal [Y\n]: " cred_choice
    case $cred_choice in
        [Yy]*)
        echo -e "\n\e[1;36m[?] Please Login To https://${IP_ADDR}:5601/ Using Below Credentials:\e[0m"
        echo -e "\e[1;36m\t|-Username: elastic\e[0m"
        echo -e "\e[1;36m\t|-Password: ${ELASTIC_AUTH}\e[0m"
        exit;;
        [Nn]*)
        printf "\n\e[1;36m[?] The Configuration Details of Elasticsearch & Kibana Are Stored In \033[1melk.conf.details\033[0m Situated In Same Directory.\e[0m"
        exit;;
        *) printf "\e[1;31m[!] Please Answer Y Or N.\e[0m";;
    esac
done
printf "\n"