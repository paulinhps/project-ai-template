# 0003 - Create Configurar Ambiente AI Skill

This file preserves the prompt that requested the shared setup skill for this repository.

```text
Nome da Habilidade: Configurar Ambiente AI

Crie uma skill para que configure o projeto com as regras estabelecidas até agora.

- Gerar os diretórios simbólicos (links)
    - .claude
    - .codex
    - . agents

- Gerar a estrutura de diretórios.

├───docs
│   ├───adr
│   ├───architecture
│   ├───business
│   ├───decisions
│   ├───engineering
│   ├───product
│   ├───references
│   ├───requirements
│   └───specs
├───sources

Asserts da habilidade.
AGENTS.md: Especifica a inicialização do projeto
.gitignore: Especifica os diretórios simbólicos que devem ser adicionados no ignore do git.

- Verificar as configurações do OpenSpec. Caso elas não existam inicializar a estrutura do OpenSpec
- Caso não exista um repositório git inicializar um repositório.
- Ao existir um repositório git gerar um submodulo para o repositório que está em `.ai`
- Criar o commit inicial do projeto no repositório raiz.

Essa habilidade provavelmente será chamada referenciando o arquivo principal da skill.

Resultado esperado.

- Arquivos e diretórios da raiz configurado
- Links para os principais diretórios mapeados por agentes de ia
- .ai como submodulo do repositório raiz
- commit inicial com as configurações do projeto de IA
```
