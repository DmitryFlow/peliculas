import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../helpers/debouncer.dart';
import '../models/models.dart';

class MoviesProvider extends ChangeNotifier{

  final String _apiKey = '4a189be2464d2a8e7b5e49ddd5fe0c97';
  final String _baseURL = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  // * Para controlar el stream de búsqueda.
  // ? 500 milisegundos espera tras dejar de escribir para buscar.
  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500)
  );

  final StreamController<List<Movie>> _suggestionsStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionsStreamController.stream;
  // *\

  MoviesProvider() {
    // ignore: avoid_print
    print('Movies Provider inicializado');
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final Uri url = Uri.https(_baseURL, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page'
    });

    // Await the http get response, then decode the json-formatted response.
    final http.Response response = await http.get(url);
    
    return response.body;
  }

  getOnDisplayMovies() async {
    // var url = Uri.https(_baseURL, '3/movie/now_playing', {
    //   'api_key': _apiKey,
    //   'language': _language,
    //   'page': '1'
    // });

    // // Await the http get response, then decode the json-formatted response.
    // final http.Response response = await http.get(url);

    final jsonData = await _getJsonData('3/movie/now_playing');

    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    // final dynamic decodedData = json.decode(response.body) as Map<String, dynamic>;
    // print(decodedData['results']);

    //print(nowPlayingResponse.results[1].title);

    onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }

  getPopularMovies() async {
    // var url = Uri.https(_baseURL, '3/movie/popular', {
    //   'api_key': _apiKey,
    //   'language': _language,
    //   'page': '1'
    // });

    // // Await the http get response, then decode the json-formatted response.
    // final http.Response response = await http.get(url);

    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [...popularMovies, ...popularResponse.results];

    // ignore: avoid_print
    // print(popularMovies.length);
    // print(popularMovies[0].posterPath);

    notifyListeners();
  }

  // ignore: slash_for_doc_comments
  /**
   * ! Async porque es una petición http.
   * ! Devuelve un Future porque async lo fuerza.
   */
  Future<List<Cast>> getMovieCast(int movieId) async {

    // ! Para no volver a solicitar petición si ya esta cargada previamente.
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    // ignore: avoid_print
    print('pidiendo info al servidor - Cast');

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    // ! Esto es todo el objeto de credits.
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {

    final Uri url = Uri.https(_baseURL, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query
    });

    final http.Response response = await http.get(url);
    final searchMovieResponse = SearchMovieResponse.fromJson(response.body);

    return searchMovieResponse.results;
  }

  // * Meter valor de query al stream.
  // * Sólo buscar cuando la persona ha dejado de escribir.
  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {

      // ignore: avoid_print
      // print('Tenemos valor a buscar: $value');
      final results = await searchMovies(value);
      // ? Para que stream sepa que estamos emitiendo un valor.
      _suggestionsStreamController.add(results);
    };

    // ? Cada vez que pase esa cantidad de tiempo, voy a mandar debouncer.
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    // ? Para esperar.
    Future.delayed(const Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}