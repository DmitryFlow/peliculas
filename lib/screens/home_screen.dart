//

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/movies_provider.dart';
import '../search/search_delegate.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // ! Lo que hace es ir al arbol de las instancias y traer a la primera que
    // ! encuentre, si no encuentra, crea una nueva siempre y cuando en main()
    // ! en Multiproviders en providers este definido.
    // * listen: redibuja cuando hay alguna modificación.
    final moviesProvider = Provider.of<MoviesProvider>(context/*, listen: false*/);

    // print(moviesProvider.onDisplayMovies);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas en cines'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: MovieSearchDelegate())
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardSwiper(movies: moviesProvider.onDisplayMovies),
            MovieSlider(
              movies: moviesProvider.popularMovies,
              title: 'Populares',
              onNextPage: () {
                // print('Mostrar siguientes peliculas.');
                moviesProvider.getPopularMovies();
              }
            )
          ]
        )
      )
    );
  }
}