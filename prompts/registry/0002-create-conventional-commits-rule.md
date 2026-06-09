# 0002 - Create Conventional Commits Rule

This file preserves the prompt used to create the shared Conventional Commits rule.

````text
# Create Conventional Commits Rule

Crie uma regra permanente de padronizacao de commits para este projeto, baseada na especificacao Conventional Commits 1.0.0.

A regra deve ser aplicada sempre que qualquer agente criar commits em qualquer repositorio deste projeto.

Referencia oficial:
https://www.conventionalcommits.org/en/v1.0.0/

Regras obrigatorias:

1. Todo commit DEVE seguir o formato:

<type>[optional scope]: <description>

[optional body]

[optional footer(s)]

2. O commit DEVE iniciar com um type valido.

Types permitidos:
- feat: nova funcionalidade
- fix: correcao de bug
- docs: documentacao
- style: formatacao, espacos, lint, sem alteracao de logica
- refactor: refatoracao sem mudar comportamento
- perf: melhoria de performance
- test: testes
- build: build, dependencias, pacotes, SDKs
- ci: pipelines, GitHub Actions, Azure DevOps, automacoes
- chore: tarefas auxiliares sem impacto direto no codigo de producao
- revert: reversao de commit anterior

3. O type DEVE ser escrito em minusculo.

4. O escopo e opcional, mas recomendado quando ajudar a identificar a area alterada.

Exemplos de escopo:
- api
- auth
- tenant
- database
- docs
- ci
- tests
- migration
- packages

Exemplo:
feat(tenant): add activation workflow

5. A descricao DEVE:
- ser curta, clara e objetiva
- estar em ingles
- usar verbo no imperativo quando possivel
- nao terminar com ponto final
- explicar o que foi alterado, nao como foi alterado

Exemplos validos:
fix(auth): validate expired refresh tokens
docs(readme): update setup instructions
build(dotnet): upgrade project to .NET 10
ci(github): add backend validation workflow

6. Commits com breaking changes DEVEM usar uma das formas abaixo:

Forma curta:
feat(api)!: change tenant activation contract

Forma com footer:
feat(api): change tenant activation contract

BREAKING CHANGE: tenant activation now requires an explicit activation token.

7. O marcador BREAKING CHANGE DEVE estar em letras maiusculas quando usado no footer.

8. Quando houver referencia a issue, task ou ticket, usar footer:

Refs: #123
Closes: #456

9. Nao criar commits genericos como:
- update
- changes
- fix
- ajustes
- wip
- melhorias
- commit final

10. Se as alteracoes misturarem assuntos diferentes, o agente DEVE preferir commits separados.

Exemplo:
- Um commit para atualizacao de pacotes
- Um commit para ajuste de breaking changes
- Um commit para atualizacao de documentacao
- Um commit para correcao de testes

11. Antes de criar qualquer commit, o agente DEVE:
- executar git status
- revisar os arquivos alterados
- agrupar alteracoes semanticamente
- escolher o type correto
- escolher scope quando aplicavel
- garantir que a mensagem esteja aderente ao padrao

12. Sempre que possivel, o agente DEVE criar commits pequenos, coesos e rastreaveis.

13. O agente NAO DEVE criar commit se:
- houver arquivos alterados fora do escopo da tarefa
- houver segredos, tokens, senhas ou arquivos sensiveis
- o build/testes exigidos pela tarefa estiverem falhando sem explicacao
- a mensagem de commit nao seguir Conventional Commits

14. Exemplos esperados para este projeto:

build(dotnet): upgrade backend projects to .NET 10

fix(tenant): adjust activation workflow validation

docs(migration): update .NET version references

ci(backend): validate build and tests on pull requests

refactor(api): simplify tenant activation handlers

test(tenant): add coverage for activation failure scenarios

feat(tenant): add tenant activation workflow

feat(api)!: change tenant activation endpoint contract

BREAKING CHANGE: tenant activation endpoint now requires activationToken in the request body.

Resultado esperado:
Criar uma regra clara e reutilizavel no projeto para que todo agente siga Conventional Commits ao gerar commits, mantendo historico consistente, legivel e compativel com automacoes de changelog, versionamento semantico e pipelines.
````
