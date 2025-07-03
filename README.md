Movie Favorites App
Um aplicativo Flutter para explorar filmes populares, gerenciar favoritos e descobrir novos títulos. Desenvolvido com arquitetura limpa e gerenciamento de estado eficiente.

Recursos Principais
🎬 Listagem de filmes populares

⭐ Sistema de favoritos offline

🔍 Busca avançada de filmes

📺 Player de trailers integrado

🌗 Suporte a tema claro/escuro

💾 Cache inteligente de imagens e dados

Tecnologias Utilizadas
Flutter - Framework principal

Provider - Gerenciamento de estado

Hive - Armazenamento local

Dio - Cliente HTTP

Youtube Player - Player de vídeos

Cached Network Image - Cache de imagens

GoRouter - Navegação avançada

Equatable - Igualdade de objetos

RxDart - Programação reativa

Como Executar

Clone o repositório

bash
git clone https://github.com/jmfdev6/teste_appmoove.git
cd app_movie_favorites
Instale as dependências

bash
flutter pub get
Configure as variáveis de ambiente
Crie um arquivo .env na raiz do projeto:

env
API_URL=https://api.themoviedb.org/3
API_KEY=sua_chave_tmdb_aqui
Execute o aplicativo

bash
flutter run
Estrutura do Projeto
text
lib/
├── core/
│   ├── models/           # Modelos de dados
│   ├── repositories/     # Camada de acesso a dados
│   ├── services/         # Serviços externos
│   ├── utils/            # Utilitários e widgets
│   └── viewmodels/       # Lógica de apresentação
├── views/                # Telas do aplicativo
│   ├── favorites_screen.dart
│   ├── home_screen.dart
│   ├── movie_details_screen.dart
│   └── search_screen.dart
└── main.dart             # Ponto de entrada
Configuração da API
Crie uma conta em The Movie Database

Obtenha sua API KEY na seção de configurações

Adicione a chave ao arquivo .env

Funcionalidades Implementadas
Tela Inicial
Listagem de filmes populares com paginação

Filme em destaque com visualização especial

Carregamento progressivo ao rolar

Indicador de filmes favoritados

Sistema de Favoritos
Armazenamento local com Hive

Sincronização offline

Notificações em tempo real

Persistência entre sessões

Tela de Detalhes
Informações completas do filme

Trailer integrado via YouTube

Sistema de avaliação (0-10 estrelas)

Gêneros com chips interativos

Busca Inteligente
Pesquisa em tempo real

Sugestões durante a digitação

Resultados paginados

Feedback visual durante o carregamento

Screenshots
Tela Inicial	Detalhes do Filme	Favoritos
<img src="screenshots/home.png" width="300">	<img src="screenshots/details.png" width="300">	<img src="screenshots/favorites.png" width="300">
Otimizações
Cache de Requisições: Redução de chamadas à API

Compressão de Imagens: Carregamento otimizado de posters

Estado Imutável: Atualizações eficientes da UI

Paginação Inteligente: Carregamento sob demanda

Gerenciamento de Memória: Dispose adequado de recursos

Licença
Este projeto está licenciado sob a Licença MIT - veja o arquivo LICENSE para detalhes.

Contribuição
Contribuições são bem-vindas! Siga os passos:

Faça um fork do projeto

Crie sua branch (git checkout -b feature/nova-feature)

Faça commit das suas alterações (git commit -m 'Adiciona nova feature')

Faça push para a branch (git push origin feature/nova-feature)

Abra um Pull Request

Contato
José Mário - @jmfdev6 - josefigueiredoroot62@gmail.com

Projeto Link: https://github.com/jmfdev6/teste_appmoove.git


