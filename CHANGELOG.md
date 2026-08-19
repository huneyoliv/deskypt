# Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado no [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.1] - 2026-08-18

### ✨ Adicionado
- **Ícones Oficiais Multiplataforma**: Ícone autêntico do YPT configurado para executáveis e janelas no Windows (`.ico`), macOS (`.png` / `AppIcon.appiconset`) e Linux.
- **Exploração e Pesquisa de Grupos**: Suporte completo a listagem por categorias oficiais (Vestibular, Concursos, Graduação, Idiomas, etc.), ordenação, busca reativa por nome e ingresso em grupos privados com senha.
- **Notificações em Lote**: Suporte à notificação de cutucada em grupo (`shakeAllMembers`).
- **Changelog Integrado**: Exibição direta das notas de versão a partir do `CHANGELOG.md` na janela de atualização do aplicativo.

### 🐛 Corrigido
- **API de Grupos**: Mapeamento e parsing seguro de membros ativos, tempo estudado (`sm`), disciplina atual e identificadores Studicon (`sd`, `gd`, `st`).
- **Testes Multiplataforma**: Padronização do `splashFactory` para `InkRipple` nos testes de widget para evitar falhas com shaders ausentes no Flutter Desktop.
- **Sincronização de Versão**: Resolução da flag de atualização que exibia download indevido quando o app já estava na última versão.

---

## [1.0.0] - 2026-08-17

### ✨ Adicionado
- **Versão Inicial do DeskYPT**: Cliente desktop nativo para Yeolpumta (YPT) com suporte para Windows, macOS e Linux.
- **Timer de Estudos**: Cronômetro de estudos em tempo real com rastreamento de disciplinas, metas diárias e descanso.
- **Gerenciamento de Matérias**: Criação, edição, exclusão, reordenação e cores customizadas para disciplinas.
- **Planner & Horários**: Tabela de horários e planejamento diário de estudos.
- **Cam Study & Grupos**: Visualização de participantes estudando em tempo real com fotos e status.
- **Flashcards & SmartBook**: Leitor de PDF integrado e criação/revisão de cartões de estudo.
- **Rankings**: Visualização de classificações individuais e por grupo.
- **Modo Foco Estrito**: Bloqueio de distrações e monitoramento de processos desktop.
- **Suporte Multilíngue**: Suporte completo para Português (pt-BR), Inglês (en-US), Espanhol (es-ES) e Coreano (ko-KR).
- **Auto-Update**: Verificação de novas versões com download direto de instaladores oficiais.
