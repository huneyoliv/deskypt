<div align="center">

# ⏱️ DeskYPT — Yeolpumta Desktop Client

**Um cliente desktop moderno, poderoso e elegante para a plataforma de estudos Yeolpumta (YPT).**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/huneyoliv/deskypt/releases)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![CI/CD](https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/huneyoliv/deskypt/actions)
[![Tests](https://img.shields.io/badge/Tests-245%2B%20Passing-success?style=for-the-badge&logo=dart)](https://github.com/huneyoliv/deskypt)

[Recursos](#-recursos-principais) •
[Instalação](#-instalação-e-download) •
[Arquitetura](#-arquitetura-e-tecnologias) •
[Desenvolvimento](#-desenvolvimento-local) •
[CI/CD e Releases](#-cicd-e-releases) •
[Licença](#-licença)

</div>

---

## 📖 Sobre o Projeto

O **DeskYPT** foi desenvolvido para oferecer a melhor experiência de produtividade e foco para estudantes que utilizam computadores desktop (Windows, macOS e Linux). Com uma interface dark moderna inspirada no design nativo do Yeolpumta e aprimorada para monitores de alta resolução, o aplicativo traz todas as funcionalidades essenciais da plataforma diretamente para o seu computador.

---

## ✨ Recursos Principais

### ⏱️ Cronômetro de Estudo & Pomodoro
- **Modo Padrão & Pomodoro**: Ciclos configuráveis de foco, pausa curta e pausa longa.
- **Gestão de Matérias**: Criação, edição, arquivamento e paleta de cores personalizada.
- **Registro Manual**: Inserção de sessões de estudo passadas com cálculo instantâneo.
- **Sincronização Offline**: Fila de requisições persistente em caso de instabilidade na conexão.

### 🛡️ Modo Foco & Bloqueador de Distrações
- **Monitoramento de Processos**: Detecção automática e alertas para aplicativos não permitidos abertos durante o estudo.
- **Modo Estrito**: Bloqueio de navegação lateral para foco ininterrupto.
- **Mini Player Flutuante**: Janela compacta do cronômetro para acompanhar o tempo enquanto consulta materiais.

### 👥 Grupos de Estudo & Cam Study
- **Feed e Presença em Tempo Real**: Visualize membros estudando ao vivo com status detalhado.
- **Cam Study**: Captura periódica e upload seguro de fotos de webcam para comprovação de presença.
- **Chat do Grupo**: Envio de mensagens, reações com emojis, anexos de mídia e stickers oficiais do YPT.
- **Interações Sociais**: Envio de "Toques" (Shake) para incentivar colegas de grupo.

### 📅 Planner, Timetable & D-Days
- **D-Day Countdown**: Contagem regressiva visual para provas, exames e metas importantes.
- **To-Do List Inteligente**: Tarefas com prazos, prioridades e suporte a regras de recorrência.
- **Grade Semanal (Timetable)**: Planejador semanal interativo com blocos de horários por disciplina.

### 📊 Rankings Globais & Heatmap de Atividade
- **Classificação Multicategoria**: Rankings em tempo real globais, nacionais e por categoria de estudo.
- **Matriz de Heatmap**: Gráfico de intensidade anual estilo GitHub para visualização da constância de estudo.
- **Calendário Mensal**: Histórico dia a dia com metas diárias e streaks.

### 🃏 Flashcards com Repetição Espaçada (SM-2)
- **Baralhos Personalizados**: Organização de cartas por matérias e tópicos.
- **Algoritmo SM-2**: Agendamento inteligente de revisões baseado na facilidade de retenção (Novamente, Difícil, Bom, Fácil).

### 📹 Gravador de Timelapse
- Captura contínua de tela em intervalos configuráveis com galeria e reprodutor interno.

### 🎨 Studicons & Loja
- Personalização de avatar com roupas, acessórios e poses dinâmicas sincronizadas com o estado de estudo.
- Visualização e histórico do saldo de Chamas (Flames).

### 🌐 Internacionalização Completa (i18n)
- Suporte a 28 idiomas (incluindo Português, Inglês, Espanhol, Coreano, Japonês, Chinês e Francês) com troca instantânea.

### 🔄 Notificação de Atualizações In-App
- Verificação automática de novas versões com badge pulsante ao lado do sino de notificações.
- Modal interno com visualização do changelog oficial e botão de download direto do instalador da plataforma do usuário.

---

## 💻 Instalação e Download

Baixe a versão mais recente diretamente na página de [**Releases Oficiais**](https://github.com/huneyoliv/deskypt/releases/latest).

| Plataforma | Pacote / Instalador | Formato | Como Instalar |
| :--- | :--- | :--- | :--- |
| **Windows** | `DeskYPT-Windows-Installer-x64.exe` | Instalador Executável | Execute o instalador `.exe` e siga as instruções do assistente. |
| **macOS** | `DeskYPT-macOS-Installer.dmg` | Imagem de Disco | Abra o arquivo `.dmg` e arraste o `DeskYPT.app` para `Applications`. |
| **Linux (Debian/Ubuntu)** | `DeskYPT-Linux-x64.deb` | Pacote Debian | `sudo apt install ./DeskYPT-Linux-x64.deb` ou `sudo dpkg -i DeskYPT-Linux-x64.deb` |
| **Linux (Outras Distros)** | `DeskYPT-Linux-x64.tar.gz` | Arquivo Portável | Extraia o `.tar.gz` e execute o binário `./deskypt`. |

---

## 🏗️ Arquitetura e Tecnologias

O projeto segue as diretrizes da **Clean Architecture**, com separação clara de responsabilidades:

```
lib/
├── core/                  # Serviços globais, rede, temas, constantes e i18n
│   ├── api/               # Cliente HTTP (Dio) e interceptors de autenticação
│   ├── cdn/               # Resolução dinâmica de URLs de avatares e mídias
│   ├── constants/         # Endpoints e constantes da aplicação
│   ├── localization/      # Sistema de tradução e fallbacks
│   ├── services/          # Serviços do sistema (Foco, Webcam, Atualizações, Janelas)
│   └── theme/             # Paleta de cores escura, tipografia e estilos
├── data/                  # Modelos de dados e repositórios
│   ├── models/            # DTOs com serialização JSON e Freezed
│   └── repositories/      # Camada de abstração de dados e chamadas de API
├── features/              # Módulos verticais de funcionalidades
│   ├── auth/              # Login com e-mail e social (Google / Apple)
│   ├── challenges/        # Desafios de estudo e apostas em Chamas
│   ├── flashcards/        # Baralhos e algoritmo SM-2
│   ├── focus/             # Bloqueio de processos e Mini Player
│   ├── groups/            # Grupos, presenças ao vivo, chat e Cam Study
│   ├── notifications/     # Central de notificações e avisos
│   ├── planner/           # Planner, To-Do list e grade horária
│   ├── profile/           # Perfil do estudante e configurações de conta
│   ├── ranks/             # Tabelas de classificação, Heatmap e Calendário
│   ├── settings/          # Preferências de estudo, idioma e legal
│   ├── smartbook/         # Visualizador integrado de PDFs e materiais
│   ├── store/             # Loja de Studicons e inventário
│   ├── timelapse/         # Gravação e galeria de timelapses
│   ├── timer/             # Cronômetro principal, Pomodoro e matérias
│   └── updates/           # Verificador de releases, changelog e instaladores
└── shared/                # Widgets compartilhados (Shell, Sidebar, Título, Avatares)
```

### Principais Bibliotecas:
- **Framework**: [Flutter Desktop](https://flutter.dev) (Dart 3.x)
- **Gerenciamento de Estado**: [Flutter Riverpod](https://riverpod.dev)
- **Roteamento**: [GoRouter](https://pub.dev/packages/go_router)
- **Comunicação HTTP**: [Dio](https://pub.dev/packages/dio)
- **Armazenamento Seguro**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) & [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Gráficos & Animações**: [FL Chart](https://pub.dev/packages/fl_chart) & [Lottie](https://pub.dev/packages/lottie)
- **Manipulação de Janelas**: [window_manager](https://pub.dev/packages/window_manager)

---

## 🛠️ Desenvolvimento Local

### Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.0.0`)
- **Windows**: Visual Studio 2022 com a carga de trabalho "Desenvolvimento para Desktop com C++".
- **macOS**: Xcode 15+ com ferramentas de linha de comando.
- **Linux**: Dependências de compilação:
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsecret-1-dev libjsoncpp-dev
  ```

### Clonando o Repositório
```bash
git clone git@github.com:huneyoliv/deskypt.git
cd deskypt
```

### Instalando Dependências
```bash
flutter pub get
```

### Executando a Aplicação
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Executando a Suíte de Testes
```bash
# Executa todos os 245+ testes automatizados
flutter test

# Análise estática do código
flutter analyze
```

---

## 🚀 CI/CD e Releases

O projeto utiliza o **GitHub Actions** para automação de ponta a ponta:

1. **Validação Contínua (`ci.yml`)**: Disparado a cada Push e Pull Request para executar análise de lint (`flutter analyze`) e a suíte completa de testes (`flutter test`).
2. **Compilação de Releases Multiplataforma (`release.yml`)**: Disparado automaticamente ao criar uma tag de versão semântica (ex: `v1.0.0`):
   - **Windows**: Compila o app e gera o instalador oficial `DeskYPT-Windows-Installer-x64.exe` via Inno Setup.
   - **macOS**: Compila o bundle `.app` e cria a imagem de disco montável `DeskYPT-macOS-Installer.dmg`.
   - **Linux**: Compila o executável e empacota o instalador nativo Debian `DeskYPT-Linux-x64.deb` para `apt`, além do pacote portável `DeskYPT-Linux-x64.tar.gz`.
   - **Publicação Automática**: Anexa todos os instaladores diretamente na Release oficial do repositório com o changelog gerado.

### Como Publicar uma Nova Versão
```bash
# 1. Atualize a versão no pubspec.yaml (ex: 1.0.1)
# 2. Crie e envie a tag semântica correspondente:
git tag v1.0.1
git push origin v1.0.1
```

---

## 📄 Licença

Este projeto está sob a licença [MIT](LICENSE).
