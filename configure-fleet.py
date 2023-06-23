import os
import sys
import time
import subprocess
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

IP_ADDR = str(sys.argv[1])
PASS = str(sys.argv[2])

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('ignore-certificate-errors')
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
driver.get(f"https://{IP_ADDR}:5601/")

userNameField = WebDriverWait(driver, 15).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="loginUsername"]'))
userNameField.send_keys("elastic")
driver.find_element("xpath", '//*[@data-test-subj="loginPassword"]').send_keys(PASS)
driver.find_element("xpath", '//*[@data-test-subj="loginSubmit"]').click()

skipWelcomeScreenElement = WebDriverWait(driver, 50).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="skipWelcomeScreen"]'))
skipWelcomeScreenElement.click() #Explore own

toggleNavButtonElement = WebDriverWait(driver, 10).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="toggleNavButton"]'))
toggleNavButtonElement.click() #Navbar

fleetElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//span[@title="Fleet"]'))
fleetElement.click() 	#Fleet

fleetSettingsTabElement = WebDriverWait(driver, 2).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="fleet-settings-tab"]'))
fleetSettingsTabElement.click() 	#Settings

editOutputBtnElement = WebDriverWait(driver, 10).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="editOutputBtn"]'))
editOutputBtnElement.click() #edit icon

specifyHostURLElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//input[@placeholder="Specify host URL"]'))
specifyHostURLElement.clear() #Hosts
time.sleep(1)
specifyHostURLElement.send_keys(f"https://{IP_ADDR}:9200") #Hosts
SSL_FINGERPRINT = subprocess.getoutput('cat SSL_FINGERPRINT')
SSL_KEY= f"""ssl:
  certificate authorities:
  - |
  {SSL_FINGERPRINT}
"""
time.sleep(5)

yamlElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//*[@aria-label="YAML Code Editor"]'))
yamlElement.send_keys(SSL_KEY) #YAML

saveApplySettingsElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="saveApplySettingsBtn"]'))
saveApplySettingsElement.click() #save

confirmModalElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="confirmModalConfirmButton"]'))
confirmModalElement.click() #confirm

addFleetServerHostBtn = WebDriverWait(driver, 15).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="settings.fleetServerHosts.addFleetServerHostBtn"]'))
addFleetServerHostBtn.click() #Fleet

fleetServerSetupElement = WebDriverWait(driver, 10).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="fleetServerSetup.nameInput"]'))
fleetServerSetupElement.send_keys("Fleet Server") #fleet name

specifyHostURLElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//input[@placeholder="Specify host URL"]'))
specifyHostURLElement.clear() #Hosts
time.sleep(1)
specifyHostURLElement.send_keys(f"https://{IP_ADDR}:8220") #fleet ip

generateFleetServerPolicyElement = WebDriverWait(driver, 10).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="generateFleetServerPolicyButton"]'))
generateFleetServerPolicyElement.click()
time.sleep(60)

euiFlyoutCloseElement = WebDriverWait(driver, 60).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="euiFlyoutCloseButton"]'))
euiFlyoutCloseElement.click()

fleetAgentsTabElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="fleet-agents-tab"]'))
fleetAgentsTabElement.click()

fleetServerLandingElement = WebDriverWait(driver, 5).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="fleetServerLanding.addFleetServerButton"]'))
fleetServerLandingElement.click()

generateFleetServerPolicyElement = WebDriverWait(driver, 10).until(EC.element_to_be_clickable(By.XPATH, '//*[@data-test-subj="generateFleetServerPolicyButton"]'))
generateFleetServerPolicyElement.click()

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