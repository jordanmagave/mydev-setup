# mydev-setup

Guia rápido para configurar o ambiente de desenvolvimento deste repositório.

## Visão geral

Este repositório contém scripts e configurações para preparar um ambiente de desenvolvimento pessoal. Os arquivos principais são:

- `setup.sh` — script de configuração automatizada (para sistemas Unix-like / WSL / Git Bash).
- `config.lua` — arquivo de configuração (usado por ferramentas que suportam Lua, por exemplo Neovim).

> Observação: o repositório foi pensado para ser usado tanto em ambientes Linux/Mac quanto através do WSL no Windows. No Windows nativo, prefira executar os scripts em um terminal compatível (WSL, Git Bash, Cygwin) ou adaptar os passos manualmente.

## Pré-requisitos

- Git
- Um terminal compatível com shell POSIX para rodar `setup.sh` (WSL, Git Bash, Cygwin). No Windows com PowerShell nativo, parte do script pode não funcionar sem adaptação.
- (Opcional) Neovim ou outra ferramenta que consome `config.lua`.

Instale ferramentas recomendadas antes de prosseguir.

## Como usar

1. Clone o repositório:

   git clone `URL_DO_REPOSITORIO`
   cd mydevsetup

2. Revise o conteúdo dos scripts antes de executá-los.

3. Executando em sistemas Unix / WSL / Git Bash:

   chmod +x setup.sh
   ./setup.sh

4. Executando no Windows (PowerShell):

   - Se você usa WSL, abra o WSL e siga os passos Unix acima.
   - Se preferir PowerShell diretamente, abra `setup.sh` e adapte os comandos para PowerShell ou execute comandos manualmente.

5. `config.lua` — uso comum:

   - Copie `config.lua` para o local esperado pela ferramenta (ex.: configuração do Neovim em `~/.config/nvim/lua/`), ou importe o arquivo conforme a documentação da ferramenta.

## Estrutura do repositório

- `setup.sh` — script principal de setup.
- `config.lua` — configurações em Lua.

## Segurança e boas práticas

- Sempre leia scripts antes de executá-los. Verifique se não há comandos que apaguem dados ou modifiquem configurações críticas.
- Execute primeiro em um ambiente isolado (máquina virtual ou WSL) se não tiver certeza.

## Troubleshooting (problemas comuns)

- Permissão negada ao executar `setup.sh`: rode `chmod +x setup.sh` ou execute com `bash setup.sh`.
- Erros no Windows PowerShell: o script foi escrito para shells POSIX; use WSL ou adapte os comandos para PowerShell.
- Dependências faltando: instale Git, curl, wget ou outras ferramentas mencionadas no script.

## Contribuições

Sinta-se à vontade para abrir issues ou PRs com melhorias no script, documentação ou suporte explícito para PowerShell/Windows.

## Contato

Para dúvidas, abra uma issue no repositório.
