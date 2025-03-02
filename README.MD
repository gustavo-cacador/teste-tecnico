Descrição Técnica: 

Provider - Configura o provedor AWS para a região us-east-1

Variáveis - Define duas variáveis "projeto" (define o nome do projeto) e "candidato" (representa o nome do candidato)

Key Pair - Cria uma chave RSA e um par de chaves EC2 associado

VPC - cria uma VPC com rede privada com CIDR 10.0.0.0/16

Subnet - Sub-rede dentro da VPC com CIDR 10.0.1.0/24 na zona us-east-1a.

Internet Gateway - Cria e associa um Internet Gateway à VPC

Route Table - Direciona tráfego externo para o Internet Gateway, configura uma tabela de rotas para permitir tráfego de internet

Route Table Association - Liga a tabela de rotas à subnet

Security Group - Permite SSH (porta 22) de qualquer IP e libera todo o tráfego de saída

Instância EC2 - AMI mais recente do Debian 12, Tipo t2.micro, 20GB de armazenamento GP2, Associada à subnet criada, Configurada com a chave SSH, Script de inicialização (user_data) para atualizar o sistema.
Além disso, há outputs: 
private_key: Chave privada gerada (sensível), ec2_public_ip: Endereço IP público da instância

Observações Adicionais:

Boas práticas de segurança:

O security group permite SSH (porta 22) de qualquer lugar (0.0.0.0/0). Em um ambiente de produção, seria mais seguro limitar o acesso SSH a IPs ou ranges específicos.

A chave privada é exposta como um output. Embora marcada como sensível, é uma prática que deve ser usada com cautela, especialmente em ambientes de produção.

Gerenciamento de estado:

O código não especifica um backend para armazenamento do estado do Terraform. Em um cenário de equipe ou produção, seria recomendável usar um backend remoto como S3 com DynamoDB para lock.

Flexibilidade e reutilização:

Mais variáveis poderiam ser utilizadas para tornar o código mais flexível, como CIDR blocks, tipo de instância, etc.

Considerar o uso de módulos para componentes reutilizáveis como VPC, que poderiam ser compartilhados entre diferentes projetos.

Resiliência e alta disponibilidade:

A infraestrutura está limitada a uma única zona de disponibilidade. Para maior resiliência, considerar usar múltiplas AZs.

Custos e otimização:

A instância t2.micro é boa para testes, mas para um ambiente de produção, seria importante avaliar as necessidades de performance e custo.

Manutenção e atualizações:

O user data realiza uma atualização do sistema, o que é bom. Considerar adicionar mais passos de configuração ou usar uma ferramenta de gerenciamento de configuração para setups mais complexos.

Nomenclatura e organização:

O código usa uma boa prática de nomenclatura consistente com variáveis para projeto e candidato.

Para projetos maiores, considerar dividir o código em múltiplos arquivos .tf para melhor organização.

Descrição Técnica de alteração: 

A alteração no código Terraform foi realizada para automatizar a instalação e execução do servidor web Nginx na instância EC2 logo após sua criação. Além disso, foram aplicadas melhorias de segurança, incluindo a liberação da porta 80 para tráfego HTTP e a criptografia do volume de armazenamento da instância.


Automação da Instalação e Inicialização do Nginx

O script User Data foi modificado para incluir comandos que:
Atualizam e atualizam os pacotes do sistema (apt-get update -y e apt-get upgrade -y).
Instalam o servidor Nginx (apt-get install -y nginx).
Habilitam o serviço para iniciar automaticamente em reinicializações (systemctl enable nginx).
Iniciam o serviço imediatamente (systemctl start nginx).
Resultado esperado: Assim que a instância for criada, o Nginx será instalado e iniciado automaticamente, permitindo o acesso à sua página padrão através do IP público da instância.

Configuração de Segurança Aprimorada

O Security Group foi modificado para permitir conexões na porta 80 (HTTP), garantindo que a instância possa servir páginas web acessíveis publicamente.
O volume raiz da instância (root_block_device) foi atualizado para ter criptografia ativada (encrypted = true), garantindo a segurança dos dados armazenados.
Resultado esperado:

A instância estará mais segura, permitindo apenas o tráfego essencial e protegendo os dados armazenados.
Qualquer tentativa de acesso ao servidor via HTTP será permitida, possibilitando a visualização do Nginx no navegador.

Testes e Validação

Após a criação da infraestrutura, a funcionalidade pode ser validada seguindo os passos abaixo:

Verificar se o Nginx está rodando:

Acessar http://<IP_PUBLICO> no navegador e confirmar se a página padrão do Nginx é exibida.

Testar conectividade SSH:

Conectar via SSH na instância (ssh -i minha_chave.pem usuario@<IP_PUBLICO>) e executar systemctl status nginx para confirmar que o serviço está ativo.

Verificar regras de segurança:

Validar as regras do Security Group para garantir que apenas as portas necessárias estão abertas.

Conferir criptografia do volume:

No console da AWS, acessar EC2 → Volumes e verificar que o volume de armazenamento está criptografado.

Conclusão:

Com essa modificação, a infraestrutura provisionada com Terraform cria automaticamente um servidor web seguro e funcional na AWS. O uso do User Data simplifica o processo de configuração da instância EC2, garantindo que ela esteja pronta para uso assim que for iniciada.









