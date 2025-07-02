# Movie Favorites App

Um aplicativo Flutter para explorar filmes populares, gerenciar favoritos e descobrir novos títulos. Desenvolvido com arquitetura limpa e gerenciamento de estado eficiente.

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** – Framework principal
- **Provider** – Gerenciamento de estado
- **Hive** – Armazenamento local
- **Dio** – Cliente HTTP
- **Youtube Player** – Player de vídeos
- **Cached Network Image** – Cache de imagens
- **GoRouter** – Navegação avançada
- **Equatable** – Igualdade de objetos
- **RxDart** – Programação reativa

---

## 🚀 Recursos Principais

- 🎬 **Listagem de filmes populares** com paginação
- ⭐ **Sistema de favoritos offline**
- 🔍 **Busca avançada de filmes** em tempo real
- 📺 **Player de trailers integrado** via YouTube
- 🌗 **Suporte a tema claro/escuro**
- 💾 **Cache inteligente** de imagens e dados

---

## 🏁 Como Executar

1. **Clone o repositório**

   ```bash
   git clone https://github.com/jmfdev6/teste_appmoove.git
   cd app_movie_favorites
   ```

2. **Instale as dependências**

   ```bash
   flutter pub get
   ```

3. **Configure as variáveis de ambiente**

   Crie um arquivo `.env` na raiz do projeto com o conteúdo:

   ```env
   API_URL=https://api.themoviedb.org/3
   API_KEY=<sua_chave_tmdb_aqui>
   ```

4. **Execute o aplicativo**

   ```bash
   flutter run
   ```

---

## 📁 Estrutura do Projeto

```
lib/
├── core/
│   ├── utils/            # Utilitários e widgets
├── models/               # Modelos de dados
├── services/             # Serviços externos
├── repositories/         # Camada de acesso a dados
├── viewmodels/           # Lógica de apresentação
├── views/                # Telas do aplicativo
│   ├── favorites_screen.dart
│   ├── home_screen.dart
│   ├── movie_details_screen.dart
│   └── search_screen.dart
└── main.dart             # Ponto de entrada
```

---

## 🔌 Configuração da API

1. Crie uma conta em [The Movie Database (TMDb)](https://www.themoviedb.org)
2. Obtenha sua **API KEY** na seção de configurações
3. Adicione a chave ao arquivo `.env` conforme indicado acima

---

## 🎯 Funcionalidades Implementadas

### Tela Inicial

- Listagem de filmes populares com paginação
- Filme em destaque com visualização especial
- Carregamento progressivo ao rolar
- Indicador de filmes favoritados

### Sistema de Favoritos

- Armazenamento local com **Hive**
- Sincronização offline
- Notificações em tempo real
- Persistência entre sessões

### Tela de Detalhes

- Informações completas do filme
- Trailer integrado via **YouTube**
- Sistema de avaliação (0-10 estrelas)
- Gêneros com chips interativos

### Busca Inteligente

- Pesquisa em tempo real
- Sugestões durante a digitação
- Resultados paginados
- Feedback visual durante o carregamento

---

## 📸 Screenshots

&#x20;&#x20;

---

## ⚙️ Otimizações

- **Cache de Requisições:** Redução de chamadas à API
- **Compressão de Imagens:** Carregamento otimizado de posters
- **Estado Imutável:** Atualizações eficientes da UI
- **Paginação Inteligente:** Carregamento sob demanda
- **Gerenciamento de Memória:** Dispose adequado de recursos

---

## 📝 Licença

Este projeto está licenciado sob a **Licença MIT**. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---


