# ELK Stack Automation

This repository provides a set of automation scripts to facilitate the installation and configuration of the ELK stack (Elasticsearch, Kibana, Fleet Server) for log management and analysis. This script will download all the prerequisites, install and configure the ELK stack, start and enable the ELK stack services, and configure them.

![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

## Table of Contents

- [Introduction](#-introduction)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Usage](#-usage)
- [Limitations](#limitations)
- [Future Updates](#-future-updates)
- [Support](#coffee-support)

## 📚 Introduction

ELK stack is a popular solution for centralized logging and log analysis. It consists of three main components:

- **Elasticsearch**: A distributed, RESTful search and analytics engine that stores and indexes the logs.
- **Kibana**: A web interface that allows users to visualize and explore the logs stored in Elasticsearch.
- **Fleet Server**: A centralized management interface for Elastic agents that collect and forward logs to Elasticsearch.

Setting up and configuring these components can be time-consuming and error-prone. This repository provides automation scripts to streamline the installation and configuration process, reducing manual effort and ensuring consistency.

## 🚀 Features

- Automated installation of Elasticsearch, Kibana, and Fleet Server.
- Configuration of Elasticsearch.
- Configuration of Kibana.
- Configuration of Fleet Server for centralized agent management.

## 📋 Prerequisites

Before proceeding with the installation, make sure you have the following prerequisites:

- Operating System: Linux (Ubuntu, CentOS, etc.).
- Internet Connectivity: The installation process requires internet access to download necessary dependencies.

## 🛠️ Functionality

The automation scripts provided in this repository will perform the following tasks:

- Install prerequisites required for the automation script.
- Install Elasticsearch.
- Configure Elasticsearch with the given IP Address.
- Install Kibana.
- Configure Kibana with the given IP Address and generate a self-signed CA certificate for Kibana to run on HTTPS.
- Configure and Install Fleet Server using Python Selenium.
- Remove all the cluttering done during the execution of the script.

For detailed instructions and tutorials on ELK stack Installation, refer to the [official Elastic Stack Installation documentation](https://www.elastic.co/guide/en/elastic-stack/current/installing-elastic-stack.html).

## 💻 Usage

To install and configure the ELK stack, follow these steps:
1. Switch to Root:
   
   ```shell
   sudo -s
   ```
2. Download the scripts from the repository to your desired machine (Where you want to install the ELK stack):
   
   ```shell
   wget https://raw.githubusercontent.com/SanketBaraiya/elk-stack-automation/main/elk_stack.sh
   wget https://raw.githubusercontent.com/SanketBaraiya/elk-stack-automation/main/configure-fleet.py
   ```
3. Navigate to the cloned repository:

   ```shell
   cd elk-stack-automation
   ```
4. Give the required permissions to the script:

   ```shell
   chmod 744 elk_stack.sh
   ```
5. Run the script:

   ```shell
   bash elk_stack.sh [IP-ADDR]
   ```

Wait for the installation to complete. Once finished, you can access Kibana at `https://[IP-ADDR]:5601` in your web browser. Now you can enroll agents by creating policies for the same.

## ❗Limitations

Please be aware of the following limitations:

- The automation scripts provided in this repository are tested on specific versions (8.x) of the ELK stack and may not be compatible with future versions. Ensure that you verify the compatibility and make necessary adjustments (APT Repository, etc.) before using them in production.
- This automation repository focuses on the installation and basic configuration of the ELK stack. Customizations beyond the provided configurations may require additional manual intervention.
- The scripts provided here currently install everything on the same system where the script is being executed.
- The scripts provided here are currently compatible with Linux only.

## 🔮 Future Updates

I plan to add the following features and enhancements in future updates:

- Support for additional platforms and operating systems.
- Advanced configuration options and templates.
- Improved error handling and logging.

## :coffee: Support
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.me/sanketbaraiya16)
[![Google Pay](https://img.shields.io/badge/GooglePay-%233780F1.svg?style=for-the-badge&logo=Google-Pay&logoColor=white)](https://mega.nz/file/5AgGWYJY#OS2bS3sbPkUai0lE9wW6ymq_Ub1gLHn2XCZVanMWYts)
[![Paytm](https://img.shields.io/badge/Paytm-1C2C94?style=for-the-badge&logo=paytm&logoColor=05BAF3)](https://mega.nz/file/kBwSxKpL#BMColiA74JWw1cXx7Z0LdpEjBRmkc6rp5oWmq23pXNY)
