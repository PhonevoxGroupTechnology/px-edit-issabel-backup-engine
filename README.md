# Phonevox EDIT: Custom backup-engine (px-edit-backup-engine)

**pt-BR**: Script visando a instalação de uma backup-engine customizada, para o Issabel4.<br>
**en-US**: Script for installing a custom backup-engine, meant for Issabel4.

# Descrição

Este instalador é utilizado para substituir a "backup-engine" padrão do Issabel4, para utilizar uma backup-engine customizada pela Phonevox.

A backup-engine da Phonevox implementa uma classe, utilizada para controlar o "$BACKUP_PLAN" da engine. Ela implementa novos campos na página de backup do Issabel4 (feitos específicamente para o backup do Issabel manter nossas customizações).<br>
A backup-engine customizada está escrita de uma forma a ser facilmente utilizada para criar novos campos pro "$BACKUP_PLAN".

**NOTA**: *Perceba que as alterações no "$BACKUP_PLAN" da backup-engine __NÃO SÃO__ refletidas automaticamente para botões na página de backup do Issabel4! É necessário realizar a "adição" dos botões manualmente, editando os arquivos de ".html" e ".tpl" do Issabel.*

# Instalação

```sh
git clone https://github.com/PhonevoxGroupTechnology/px-edit-issabel-backup-engine.git
cd px-edit-issabel-backup-engine
chmod +x install.sh
./install.sh
```
**NOTA**: *O instalador precisa ser executado como root.*<br>
**NOTA**: *Pretendo simplificar o método de instalação.*

# Uso

Rode o instalador e, caso necessário, interaja com o terminal.

O instalador gera uma cópia da backup-engine atual, e sobe a backup-engine editada em seu lugar. Caso precise alterar para o antigo após a instalação, é só substituir o arquivo atual (engine editada) pela versão de backup (sua engine antiga).
