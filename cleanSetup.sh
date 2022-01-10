#!/bin/bash
cp Dockerfile Dockerfile.ori
cp Dockerfile.migrator Dockerfile.migrator.ori
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/getEnvVault_Source.sh > getEnvVault_Source.sh
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/addJsonFile.sh > addJsonFile.sh
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/generaDockerfile.sh > generaDockerfile.sh
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/getEnvVault.sh > getEnvVault.sh
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/buildContainerBack.sh > buildContainer.sh
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/createEnvFileBack.sh > createEnvFile.sh
curl -L -u $PASSWORD:x-oauth-basic https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/deployContainerBack.sh > deployContainer.sh
chmod +x buildContainer.sh
chmod +x createEnvFile.sh
chmod +x deployContainer.sh
chmod +x getEnvVault.sh
chmod +x getEnvVault_Source.sh
chmod +x addJsonFile.sh
chmod +x buildContainer.sh
chmod +x deployContainer.sh
