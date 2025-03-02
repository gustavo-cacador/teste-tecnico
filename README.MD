# 🚀 Infraestrutura AWS com Terraform

## 📌 Visão Geral
Este projeto utiliza **Terraform** para provisionar uma infraestrutura básica na AWS, incluindo uma instância **EC2** configurada automaticamente para rodar o servidor **Nginx**.

---

## 📜 **Descrição Técnica**

### 🏗 **Tarefa 1: Infraestrutura AWS**

🔹 **Provider**: Configura o provedor AWS para a região `us-east-1`.

🔹 **Variáveis**: Define variáveis para o nome do projeto e do candidato.

🔹 **Key Pair**: Cria um par de chaves SSH para acessar a instância.

🔹 **VPC**: Cria uma rede privada (`10.0.0.0/16`).

🔹 **Subnet**: Define uma sub-rede (`10.0.1.0/24`) na zona `us-east-1a`.

🔹 **Internet Gateway**: Permite acesso à internet.

🔹 **Route Table**: Configura rotas para saída via `Internet Gateway`.

🔹 **Security Group**: Permite tráfego SSH (`22`) e libera todo tráfego de saída.

🔹 **Instância EC2**:
  - AMI mais recente do **Debian 12**.
  - Tipo **t2.micro**.
  - 20GB de armazenamento **GP2**.
  - Configuração da chave SSH.
  - Script de inicialização (`user_data`) para atualização do sistema.
  - 
🔹 **Outputs**:
  - `private_key`: Chave privada gerada (**sensível**).
  - `ec2_public_ip`: IP público da instância.

## Observações Adicionais:

### Boas práticas de segurança:

- O security group permite SSH (porta 22) de qualquer lugar (0.0.0.0/0). Em um ambiente de produção, seria mais seguro limitar o acesso SSH a IPs ou ranges específicos.

- A chave privada é exposta como um output. Embora marcada como sensível, é uma prática que deve ser usada com cautela, especialmente em ambientes de produção.

- Gerenciamento de estado:

- O código não especifica um backend para armazenamento do estado do Terraform. Em um cenário de equipe ou produção, seria recomendável usar um backend remoto como S3 com DynamoDB para lock.

### Flexibilidade e reutilização:

- Mais variáveis poderiam ser utilizadas para tornar o código mais flexível, como CIDR blocks, tipo de instância, etc.

- Considerar o uso de módulos para componentes reutilizáveis como VPC, que poderiam ser compartilhados entre diferentes projetos.

### Resiliência e alta disponibilidade:

- A infraestrutura está limitada a uma única zona de disponibilidade. Para maior resiliência, considerar usar múltiplas AZs.

### Custos e otimização:

- A instância t2.micro é boa para testes, mas para um ambiente de produção, seria importante avaliar as necessidades de performance e custo.

### Manutenção e atualizações:

- O user data realiza uma atualização do sistema, o que é bom. Considerar adicionar mais passos de configuração ou usar uma ferramenta de gerenciamento de configuração para setups mais complexos.

### Nomenclatura e organização:

- O código usa uma boa prática de nomenclatura consistente com variáveis para projeto e candidato.

- Para projetos maiores, considerar dividir o código em múltiplos arquivos .tf para melhor organização.

### 🔧 **Tarefa 2: Melhorias Aplicadas**

#### 🖥️ **Automação da Instalação e Inicialização do Nginx**
✅ O **User Data** foi atualizado para:
  - Atualizar pacotes (`apt-get update -y && apt-get upgrade -y`).
  - Instalar o **Nginx** (`apt-get install -y nginx`).
  - Habilitar **inicialização automática** (`systemctl enable nginx`).
  - Iniciar o serviço (`systemctl start nginx`).

✅ **Resultado esperado**: O **Nginx** será instalado e iniciado automaticamente, permitindo acesso via **IP público** da instância.

#### 🔒 **Segurança Aprimorada**
✅ **Security Group** atualizado:
  - Liberação da porta **80** para acesso HTTP.
  - Restrições no **SSH** (acesso apenas para IPs específicos).
✅ **Criptografia** ativada no volume de armazenamento da instância.

✅ **Resultado esperado**:
  - Acesso HTTP permitido (Nginx visível no navegador).
  - Maior proteção dos dados armazenados.

#### 🔍 **Outras Melhorias**
✅ **Backup Automático**: AWS Backup configurado para snapshots diários.
✅ **Monitoramento**: Configuração de logs do **Nginx** no **CloudWatch Logs**.
✅ **Código mais organizado**: Segue boas práticas do Terraform.

---

## 📖 **Instruções de Uso**

### 1️⃣ **Pré-requisitos**

Antes de executar o código, certifique-se de ter:
- ✅ **Conta AWS** configurada corretamente.
- ✅ **AWS CLI** instalada e autenticada (`aws configure`).
- ✅ **Terraform** instalado (`terraform -v` para verificar).
- ✅ **IP PÚBLICO** do seu computador (para liberar SSH, edite `MEU_IP/32`).

### 2️⃣ **Passos para Executar o Terraform**

#### 📌 **Passo 1 – Configurar as Credenciais AWS**
```sh
aws configure
```
Insira a **Access Key, Secret Key, Região e Formato de saída**.

#### 📌 **Passo 2 – Inicializar o Terraform**
```sh
terraform init
```
Isso inicializa o Terraform e baixa os provedores necessários.

#### 📌 **Passo 3 – Validar a Configuração**
```sh
terraform validate
```
Verifica se há erros antes da aplicação.

#### 📌 **Passo 4 – Visualizar as Mudanças**
```sh
terraform plan
```
Exibe o que será criado antes da execução.

#### 📌 **Passo 5 – Aplicar a Infraestrutura**
```sh
terraform apply -auto-approve
```
Cria os recursos na AWS.

#### 📌 **Passo 6 – Acessar a Instância EC2**
```sh
ssh -i private-key.pem admin@IP_PUBLICO
```
Substitua **`private-key.pem`** pela chave gerada e **`IP_PUBLICO`** pelo IP da saída do Terraform.

#### 📌 **Passo 7 – Testar o Nginx**
No navegador, acesse:
```sh
http://IP_PUBLICO
```
Se tudo estiver certo, a **página padrão do Nginx** será exibida! 🎉

---

## 🔄 **Como Remover a Infraestrutura**
Para destruir todos os recursos provisionados, execute:
```sh
terraform destroy -auto-approve
```
⚠️ **Isso apagará a instância EC2, VPC e demais recursos!**

---

## 🎯 **Conclusão**

Este projeto automatiza a criação de uma infraestrutura AWS segura e funcional com **Terraform**, instalando e configurando o **Nginx** automaticamente. Além disso, foram aplicadas **melhorias de segurança, backup e monitoramento**.

Caso tenha dúvidas ou queira contribuir, fique à vontade para abrir um **issue** ou um **pull request**! 🚀

