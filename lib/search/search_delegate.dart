//

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/movies_provider.dart';

//

class MovieSearchDelegate extends SearchDelegate {

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = ''
      )
    ];
  }

  // ? Regresar a la pantalla anterior.
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  Widget _emptyContainer() {
    return const Center(
      child: Icon(
        Icons.movie_creation_outlined,
        color: Colors.black38,
        size: 130
      )
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return _emptyContainer();

    // Hace peticiones HTTP por cada caracter.
    // print('Peticion HTTP Request');

    // ? <MoviesProvider>: necesito que lo busque.
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    // * Se va mandar a llamar cada vez que el usuario toque cualquier tecla.
    moviesProvider.getSuggestionsByQuery(query);

    /* return FutureBuilder(
      future: moviesProvider.searchMovies(query), */
    return StreamBuilder(
      // * Se va a disparar unicamente cuando suggestionStream emita un valor.
      stream: moviesProvider.suggestionStream,
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {

        if (!snapshot.hasData) return _emptyContainer();

        final movies = snapshot.data;

        return ListView.builder(
          itemCount: movies?.length,
          itemBuilder: (_, int index) => _MovieItem(movie: movies![index])
        );
      }
    );
  }
}

class _MovieItem extends StatelessWidget {

  final Movie movie;

  const _MovieItem({
    Key? key,
    required this.movie
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    movie.heroId = 'search-${movie.id}';

    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
          placeholder: const AssetImage('assets/no-image.jpg'),
          image: NetworkImage(movie.fullPosterImg),
          width: 50,
          fit: BoxFit.contain
        ),
      ),
      title: Text(movie.title),
      subtitle: Text(movie.originalTitle),
      // ignore: avoid_print
      onTap: () => Navigator.pushNamed(context, 'details', arguments: movie)
    );
  }
}