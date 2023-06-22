from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import subprocess
import time
import os
import sys

IP_ADDR = str(sys.argv[1])
PASS = str(sys.argv[2])
options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('ignore-certificate-errors')
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
driver.get(f"https://{IP_ADDR}:5601/")
time.sleep(15)
driver.find_element("xpath", '//*[@data-test-subj="loginUsername"]').send_keys("elastic")
driver.find_element("xpath", '//*[@data-test-subj="loginPassword"]').send_keys(PASS)
driver.find_element("xpath", '//*[@data-test-subj="loginSubmit"]').click()
time.sleep(50)
driver.find_element("xpath", '//*[@data-test-subj="skipWelcomeScreen"]').click() #Explore own
time.sleep(10)
driver.find_element("xpath", '//*[@data-test-subj="toggleNavButton"]').click() #Navbar
time.sleep(5)
driver.find_element("xpath", '//span[@title="Fleet"]').click() 	#Fleet
time.sleep(2)
driver.find_element("xpath", '//*[@data-test-subj="fleet-settings-tab"]').click() 	#Settings
time.sleep(10)
driver.find_element("xpath", '//*[@data-test-subj="editOutputBtn"]').click() #edit icon
time.sleep(5)
driver.find_element("xpath", '//input[@placeholder="Specify host URL"]').clear() #Hosts
time.sleep(1)
driver.find_element("xpath", '//input[@placeholder="Specify host URL"]').send_keys(f"https://{IP_ADDR}:9200") #Hosts
SSL_FINGERPRINT = subprocess.getoutput('cat SSL_FINGERPRINT')
SSL_KEY= f"""ssl:
  certificate authorities:
  - |
  {SSL_FINGERPRINT}
"""
time.sleep(5)
driver.find_element("xpath", '//*[@aria-label="YAML Code Editor"]').send_keys(SSL_KEY) #YAML
time.sleep(5)
driver.find_element("xpath", '//*[@data-test-subj="saveApplySettingsBtn"]').click() #save
time.sleep(5)
driver.find_element("xpath", '//*[@data-test-subj="confirmModalConfirmButton"]').click() #confirm
time.sleep(15)
driver.find_element("xpath", '//*[@data-test-subj="settings.fleetServerHosts.addFleetServerHostBtn"]').click() #Fleet
time.sleep(10)
driver.find_element("xpath", '//*[@data-test-subj="fleetServerSetup.nameInput"]').send_keys("Fleet Server") #fleet name
driver.find_element("xpath", '//input[@placeholder="Specify host URL"]').clear()
time.sleep(1)
driver.find_element("xpath", '//input[@placeholder="Specify host URL"]').send_keys(f"https://{IP_ADDR}:8220") #fleet ip
driver.find_element("xpath", '//*[@data-test-subj="generateFleetServerPolicyButton"]').click()
time.sleep(60)
driver.find_element("xpath", '//*[@data-test-subj="euiFlyoutCloseButton"]').click()
time.sleep(5)
driver.find_element("xpath", '//*[@data-test-subj="fleet-agents-tab"]').click()
time.sleep(5)
driver.find_element("xpath", '//*[@data-test-subj="fleetServerLanding.addFleetServerButton"]').click()
time.sleep(5)
driver.find_element("xpath", '//*[@data-test-subj="generateFleetServerPolicyButton"]').click()
time.sleep(30)
FLEET = driver.find_element("css selector", "pre[class^='CommandCode']").text
time.sleep(5)
cmd = f'echo -n "{FLEET}" > fleet-install.sh'
os.system(cmd)
IP = os.environ["IP_ADDR"]
CD = os.environ["CURR_PATH"]
cmd = f'echo " --url=https://{IP}:8220 --fleet-server-es-ca=/usr/local/share/ca-certificates/http_ca.crt --certificate-authorities={CD}/ca/ca.crt --fleet-server-cert={CD}/fleet-server/fleet-server.crt --fleet-server-cert-key={CD}/fleet-server/fleet-server.key --force" >> fleet-install.sh'
os.system(cmd)
time.sleep(10)
driver.find_element("xpath", '//*[@data-test-subj="euiFlyoutCloseButton"]').click()
driver.close()