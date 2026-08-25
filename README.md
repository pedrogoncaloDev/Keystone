# Keystone

Sistema de autenticação full-stack: cadastro, login, edição de perfil e exclusão de conta, com front-end em Vue 3 e back-end em Delphi (REST API sobre o framework Horse) persistindo em SQL Server.

## Funcionalidades

- Cadastro de usuário (nome, sobrenome, e-mail, senha)
- Login
- Edição de perfil (nome, sobrenome, e-mail, senha) com confirmação da senha atual
- Exclusão de conta com confirmação de senha
- Senhas armazenadas com hash **PBKDF2-HMAC-SHA256** (salt aleatório por usuário, 100.000 iterações) — nunca em texto puro
- Validação de campos obrigatórios (não deixa cadastrar/atualizar com campos em branco ou só espaços) tanto no front-end quanto no back-end
- Nome, sobrenome e e-mail são normalizados (`trim`) antes de gravar
- Toasts de sucesso/erro para toda requisição feita ao back-end
- Log de exceções do back-end em arquivo diário (`logs/AAAA-MM-DD.log`), com horário, rota e mensagem do erro
- Datas de criação (`creation_date`) e última atualização (`updation_date`) por usuário — `updation_date` é mantida por uma trigger no SQL Server, então reflete qualquer alteração na linha, não só as feitas pela API
- Criação automática do banco, da tabela `users` e da trigger na primeira execução do back-end (com migração para bancos já existentes)

## Stack

**Front-end** (`front_end/`)
- Vue 3 (Composition API) + Vite
- Vue Router
- Sem UI framework — design system próprio ("Nocturne") em CSS puro (`src/assets/styles.css`)
- Estado global simples via `reactive` (sem Pinia/Vuex): `stores/auth.js`, `stores/toast.js`

**Back-end** (`back_end/`)
- Delphi (VCL) — a aplicação em si é uma tela de configuração/start-stop; a API roda embarcada no processo
- [Horse](https://github.com/hashload/horse) — framework REST sobre Indy/WebBroker (vendorizado em `modules/horse`)
- [Horse CORS](https://github.com/hashload/horse-cors) (vendorizado em `modules/horse-cors`)
- FireDAC — acesso a dados
- SQL Server (testado com 2019/2022) como banco de dados

## Estrutura

```
back_end/
  API.dpr / API.dproj      # projeto Delphi
  uAPI.pas                 # tela de configuração (host/porta/banco/usuário) e start/stop da API
  uApp.pas                 # bootstrap: provisiona o banco e registra as rotas do Horse
  uUserController.pas      # rotas HTTP (/users/login, /cadastro, /atualizar, /deletar)
  uUserService.pas         # regras de negócio e validação
  uUserRepository.pas      # queries FireDAC contra a tabela users
  uMssqlDriver.pas         # criação/migração do banco, tabela e trigger
  uPasswordHasher.pas      # hash e verificação de senha (PBKDF2-HMAC-SHA256)
  uErrorLogger.pas         # log de exceções em arquivo
  uConnectionFactory.pas   # conexão FireDAC usada em tempo de requisição
  uConfigProvider.pas / uIniConfigStore.pas / uCreateDatabase.pas
  modules/                 # dependências vendorizadas (horse, horse-cors)

front_end/
  src/views/               # LoginView, SignupView, HomeView, ProfileView
  src/components/          # AuthLayout, FormField, AppButton, ToastContainer
  src/stores/               # auth.js (usuário logado), toast.js (notificações)
  src/services/api.js      # client HTTP para o back-end
  src/assets/styles.css    # design system (tokens, componentes)
```

## API

Base URL padrão: `http://localhost:9000`

| Método | Rota              | Descrição                                   |
| ------ | ------------------ | -------------------------------------------- |
| POST   | `/users/login`      | Autentica com e-mail e senha                  |
| POST   | `/users/cadastro`   | Cria um novo usuário                          |
| PUT    | `/users/atualizar`  | Atualiza dados do usuário (exige senha atual) |
| DELETE | `/users/deletar`    | Exclui a conta (exige senha atual)            |

Todas as rotas recebem e devolvem JSON em UTF-8.

## Como rodar

### Back-end

Pré-requisitos: Delphi/RAD Studio com FireDAC, e uma instância do SQL Server acessível.

1. Abra `back_end/API.dproj` no RAD Studio e compile (ou rode `msbuild API.dproj` com o `rsvars.bat` carregado).
2. Execute `API.exe`. Na tela que abrir, preencha host, porta, nome do banco, usuário e senha do SQL Server e clique em **Iniciar**.
   - Esses dados ficam salvos em `config_database.ini`, ao lado do executável.
   - Na primeira execução, o banco, a tabela `users` e a trigger de `updation_date` são criados automaticamente.
3. A API sobe em `http://localhost:9000` (porta configurável em `uAPI.pas`/tela de start).

### Front-end

Pré-requisitos: Node.js.

```bash
cd front_end
npm install
cp .env.example .env   # ajuste VITE_API_BASE_URL se o back-end não estiver em localhost:9000
npm run dev
```

Build de produção: `npm run build` (gera `front_end/dist`).

## Segurança

- Senhas nunca são armazenadas nem trafegam de volta em texto puro; o hash usa salt aleatório por usuário, então a mesma senha nunca gera o mesmo valor duas vezes.
- Atualização e exclusão de conta verificam a senha atual comparando o hash em código (Delphi), não via `WHERE password = ...` no SQL — necessário porque o salt torna essa comparação direta inviável.
- Contas antigas eventualmente cadastradas com senha em texto puro (antes do hash existir) continuam autenticando normalmente por compatibilidade retroativa.
